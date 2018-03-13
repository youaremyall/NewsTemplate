//
//  QRViewController+Provider.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/24.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import "QRViewController.h"
#import "UIViewController+AssociatedObject.h"
#import "UIImage+QRCode.h"
#import "UIView+Extension.h"
#import "UIColor+Extension.h"
#import "UIDevice+Extension.h"

#define kScreenSize         [UIScreen mainScreen].bounds.size
#define kAVQRInterestSize   CGSizeMake(200.0 , 200.0)

@interface QRViewController () <AVCaptureMetadataOutputObjectsDelegate,
                                UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate> {

    //上下滚动扫描线的当前Y坐标
    CGFloat     currentY;
    
    //是否打开系统相册行为
    BOOL        isPhotoAlbum;
                                    
    //判断扫描线滚动方向 (YES ： 向上，NO ： 向下)
    BOOL        isScanningUp;
    
    //上下滚动扫描定时器
    NSTimer     *scaningTimer;
    
    //扫描背景掩码图层
    UIView      *scanningRectView;
    
    //中间的(感兴趣)扫描范围区域
    UIView      *scanningInterestView;
    
    //模拟上下滚动扫描线
    UIImageView *scanningLine;
}

@property (nonatomic) AVCaptureSession  *captureSession;

@end

@implementation QRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initUIParamter];
}

- (void)viewWillAppear:(BOOL)animated {

    if(!isPhotoAlbum) {
        [self startAVQRScanning]; //开始扫描
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {

    [self stopAVQRScanning]; //停止扫描
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

/**
 * 初始化操作
 */
- (void)initUIParamter {

    [self initAVQRScanningRect];
    [self initAVQRCapture];
    [self setUINavbar];
}

/**
 * 初始化二维码扫描
 */
- (void) initAVQRCapture {

    // 错误信息
    NSError *error = nil;
    
    // 获取AVCaptureDevice实例
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 初始化输入流
    AVCaptureDeviceInput  *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if(!captureInput) {
        
        NSLog(@"设备输入出错 : %@", error.localizedDescription);
        
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"请在iPhone的“设置-隐私-相机”选项中，允许应用访问您的相机" preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:vc animated:YES completion:^{}];
        
        return;
    }

    // 初始化输出流
    AVCaptureMetadataOutput *captureOutput = [[AVCaptureMetadataOutput alloc] init];
    captureOutput.rectOfInterest = CGRectMake(scanningInterestView.frame.origin.y / kScreenSize.height,
                                              scanningInterestView.frame.origin.x / kScreenSize.width,
                                              scanningInterestView.frame.size.height / kScreenSize.height,
                                              scanningInterestView.frame.size.width / kScreenSize.width
                                              );
    [captureOutput setMetadataObjectsDelegate:self
                                        queue:dispatch_queue_create("AVQRScanCodeQueue", NULL)];
    
    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];

    // 添加输入流
    if([_captureSession canAddInput:captureInput]) {
        [_captureSession addInput:captureInput];
    }
    
    // 添加输出流
    if([_captureSession canAddOutput:captureOutput]) {
        [_captureSession addOutput:captureOutput];
    }

    //一定要先设置会话的输出为output之后，再指定输出的元数据类型
    captureOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,   //二维码
                                          AVMetadataObjectTypeUPCECode,
                                          AVMetadataObjectTypeCode39Code, //条形码 韵达和申通
                                          AVMetadataObjectTypeCode39Mod43Code,
                                          AVMetadataObjectTypeCode128Code, //CODE128条码 顺丰速递
                                          AVMetadataObjectTypeEAN13Code,
                                          AVMetadataObjectTypeEAN8Code,
                                          AVMetadataObjectTypeCode93Code, //条形码，星号用来表示起始符及终止符，如邮政EMS单上的条码
                                          AVMetadataObjectTypeCode128Code,
                                          AVMetadataObjectTypePDF417Code,
                                          AVMetadataObjectTypeAztecCode,
                                          AVMetadataObjectTypeDataMatrixCode
                                          ];

    // 创建输出对象
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    videoPreviewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:videoPreviewLayer below:scanningRectView.layer];
}


/**
 * 初始化扫描范围区域
 */
- (void)initAVQRScanningRect {
    
     //整个二维码扫描界面
    scanningRectView = [[UIView alloc] initWithFrame:self.view.bounds];
    scanningRectView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scanningRectView];
    
    //扫描范围区域
    scanningInterestView = [UIView new];
    scanningInterestView.frame = CGRectMake((kScreenSize.width - kAVQRInterestSize.width)/2.0,
                                        (kScreenSize.height - kAVQRInterestSize.height)/2.0 - 80.0,
                                        kAVQRInterestSize.width,
                                        kAVQRInterestSize.height);
    scanningInterestView.backgroundColor = [UIColor clearColor];
    [scanningInterestView setBorderWithColor:[UIColor colorWithWhite:1.0 alpha:0.6] borderWidth:0.5];
    [scanningRectView addSubview:scanningInterestView];
    
    //上方阴影图层
    UIView *view1 = [UIView new];
    view1.frame = CGRectMake(0,
                            0,
                            scanningRectView.frame.size.width,
                            scanningInterestView.frame.origin.y);
    view1.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [scanningRectView addSubview:view1];
    
    //左侧阴影图层
    UIView *view2 = [UIView new];
    view2.frame = CGRectMake(0,
                             scanningInterestView.frame.origin.y,
                             scanningInterestView.frame.origin.x,
                             scanningInterestView.frame.size.height);
    view2.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [scanningRectView addSubview:view2];

    
    //右侧阴影图层
    UIView *view3 = [UIView new];
    view3.frame = CGRectMake(CGRectGetMaxX(scanningInterestView.frame),
                             scanningInterestView.frame.origin.y,
                             scanningInterestView.frame.origin.x,
                             scanningInterestView.frame.size.height);
    view3.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [scanningRectView addSubview:view3];

    
    //下方阴影图层
    UIView *view4 = [UIView new];
    view4.frame = CGRectMake(0,
                             CGRectGetMaxY(scanningInterestView.frame),
                             scanningRectView.frame.size.width,
                             scanningRectView.frame.size.height - CGRectGetMaxY(scanningInterestView.frame));
    view4.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [scanningRectView addSubview:view4];

    
    //左上角边框
    UIImageView *qr1 = [UIImageView new];
    qr1.image = [UIImage imageNamed:@"QRCode.bundle/scan_qr1.png"];
    qr1.frame = CGRectMake(0,
                           0,
                           qr1.image.size.height/qr1.image.scale,
                           qr1.image.size.width/qr1.image.scale);
    [scanningInterestView addSubview:qr1];

    //右上角边框
    UIImageView *qr2 = [UIImageView new];
    qr2.image = [UIImage imageNamed:@"QRCode.bundle/scan_qr2.png"];
    qr2.frame = CGRectMake(kAVQRInterestSize.width - qr2.image.size.height/qr2.image.scale,
                           0,
                           qr2.image.size.height/qr2.image.scale,
                           qr2.image.size.width/qr2.image.scale);
    [scanningInterestView addSubview:qr2];

    //左下角边框
    UIImageView *qr3 = [UIImageView new];
    qr3.image = [UIImage imageNamed:@"QRCode.bundle/scan_qr3.png"];
    qr3.frame = CGRectMake(0,
                           kAVQRInterestSize.height - qr3.image.size.height/qr3.image.scale,
                           qr3.image.size.height/qr3.image.scale,
                           qr3.image.size.width/qr3.image.scale);
    [scanningInterestView addSubview:qr3];

    //右下角边框
    UIImageView *qr4 = [UIImageView new];
    qr4.image = [UIImage imageNamed:@"QRCode.bundle/scan_qr4.png"];
    qr4.frame = CGRectMake(kAVQRInterestSize.width - qr4.image.size.height/qr4.image.scale,
                           kAVQRInterestSize.height - qr3.image.size.height/qr3.image.scale,
                           qr4.image.size.height/qr4.image.scale,
                           qr4.image.size.width/qr4.image.scale);
    [scanningInterestView addSubview:qr4];

    
    //扫描滚动条
    scanningLine = [UIImageView new];
    scanningLine.frame = CGRectMake(3.0,
                                    2.0,
                                    CGRectGetWidth(scanningInterestView.frame) - 6.0,
                                    0.5);
    scanningLine.backgroundColor = [UIColor colorWithRGB:0x09bb07 alpha:1.0];
    scanningLine.hidden = YES;
    [scanningInterestView addSubview:scanningLine];
    currentY = CGRectGetMinY(scanningLine.frame);
    
    
    //扫描提示文字说明
    UILabel * labelTip = [UILabel new];
    labelTip.frame = CGRectMake(0,
                                CGRectGetMaxY(scanningInterestView.frame) + 40.0,
                                self.view.frame.size.width,
                                40);
    labelTip.text = @"将二维码放入框内，即可自动扫描";
    labelTip.textColor = [UIColor whiteColor];
    labelTip.textAlignment = NSTextAlignmentCenter;
    labelTip.lineBreakMode = NSLineBreakByCharWrapping;
    labelTip.backgroundColor = [UIColor clearColor];
    [scanningRectView addSubview:labelTip];
    
    
    //我的二维码
    UIButton  *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.view.center.x - 60.0,
                              CGRectGetMaxY(labelTip.frame) + 20.0,
                              120.0, 44.0);
    [button setTitleColor:[UIColor colorWithRGB:0x09bb07 alpha:1.0] forState:UIControlStateNormal];
    [button setTitle:@"我的二维码" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.0] ];
    [button addTarget:self action:@selector(selfQRCode:) forControlEvents:UIControlEventTouchUpInside];
    [scanningRectView addSubview:button];
    
    
    //闪光灯图标
    AVCaptureFlashMode mode = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo].flashMode;
    UIButton *flash = [UIButton buttonWithType:UIButtonTypeCustom];
    flash.frame = CGRectMake(CGRectGetWidth(scanningRectView.frame) - 60.0, CGRectGetHeight(scanningRectView.frame) - 60.0, 60.0, 60.0);
    [flash setImage:[UIImage imageNamed:[self imageForTorchMode:mode] ] forState:UIControlStateNormal];
    [flash addTarget:self action:@selector(didTorchSelect:) forControlEvents:UIControlEventTouchUpInside];
    [scanningRectView addSubview:flash];
}

/**
 * 初始化顶部导航条
 */
- (void)setUINavbar {
    
    __weak __typeof(self) wself = self;
    self.navbar.backgroundColor = [UIColor clearColor];
    self.navbar.clickEvent = ^(NSDictionary *dict , NSInteger index) {
        switch (index) {
            case 0:
            {
                id vc = [wself.navigationController popViewControllerAnimated:YES];
                if(!vc) [wself dismissViewControllerAnimated:YES completion:^(){}];
                break;
            }
            case 1:
                [wself takePhotoFromPhotoLibrary];
                break;
                
            default:
                break;
        }
    };
    [self.navbar.barRight setTitle:@"相册" forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.navbar];
}

/**
 * 扫描滚动动画效果
 */
- (void)scaningAnimation
{
    if (!isScanningUp) { //向下滚动
        
        currentY += 4.0;
        if(currentY > scanningInterestView.frame.size.height - 2.0) { //避免和边框重合
            currentY = scanningInterestView.frame.size.height - 2.0;
            isScanningUp = YES;
        }
        [scanningLine setY:currentY];
        
    }
    else { //向上滚动
        
        currentY -= 4.0;
        if(currentY < 0.0 + 2.0) { //避免和边框重合
            currentY = 0.0 + 2.0;
            isScanningUp = NO;
        }
        [scanningLine setY:currentY];
    }
}

#pragma mark -

/**
 * 切换闪光灯
 */
- (void)didTorchSelect:(UIButton *)button {

    AVCaptureFlashMode mode = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo].flashMode;
    ++mode;
    if(mode > AVCaptureTorchModeAuto) {mode = AVCaptureFlashModeOff;}
    [self setDeviceTorchEnable:mode];
    [button setImage:[UIImage imageNamed:[self imageForTorchMode:mode] ] forState:UIControlStateNormal];
}

/**
 * 设置设备的闪光灯照明
 */
- (void)setDeviceTorchEnable:(AVCaptureFlashMode)mode {

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device hasTorch]) {
        
        NSError *error = nil;
        [device lockForConfiguration:&error];
        if(error) {NSLog(@"锁定设备配置出错 : %@", error.localizedDescription);}
        [device setTorchMode:(AVCaptureTorchModeOff + mode)];
        [device setFlashMode:mode ];
        [device unlockForConfiguration];
    }
}

/**
 * 获取闪光灯模式对应的图标
 */
- (NSString *)imageForTorchMode:(AVCaptureFlashMode)mode {

    return @[@"QRCode.bundle/flash_off.png", @"QRCode.bundle/flash_on.png", @"QRCode.bundle/flash_auto.png"][mode];
}

/**
 * 开始扫描
 */
- (void)startAVQRScanning {
    
    [_captureSession startRunning];
    [scanningLine setHidden:NO];
    
    //定时器，设定时间过1.5秒，
    scaningTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                    target:self
                                                  selector:@selector(scaningAnimation)
                                                  userInfo:nil
                                                   repeats:YES];
}

/**
 * 停止扫描
 */
- (void)stopAVQRScanning {

    [_captureSession stopRunning];
    [scanningLine setHidden:YES];
    
    if(scaningTimer && [scaningTimer isValid]) {[scaningTimer invalidate]; scaningTimer = nil;}
}


/**
 * 从相册选择图片
 */
- (void)takePhotoFromPhotoLibrary {

    isPhotoAlbum = YES;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker
                       animated:YES
                     completion:^{
                     }];
}

/**
 * 识别二维码图片
 * @param image : 图片
 */
- (void)getDecodeInfoWithImage:(UIImage *)image {

    // 初始化一个检测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    
    // 监测到的结果数组
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage] ];
    
    if(features.count > 0) {
        
        isPhotoAlbum = NO; //重置标识，便于从查询结果返回后可继续扫描。
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        [self performSelectorOnMainThread:@selector(didQRScaningSuccess:) withObject:feature.messageString waitUntilDone:NO];
    }
    else  {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"未发现二维码" preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            isPhotoAlbum = NO;
            [self startAVQRScanning]; //开始扫描
        }]];
        [self presentViewController:vc animated:YES completion:^{}];
    }
}

/**
 * 我的二维码
 */
- (void)selfQRCode:(id)sender {

    [self stopAVQRScanning]; //停止扫描
    
    //二维码数据
    NSString *content = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"],
                         [UIDevice currentDevice].identifierForVendor.UUIDString ];
    
    // 1.创建滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2.清空滤镜
    [filter setDefaults];
    
    // 3.设置数据(KVC)
    [filter setValue:[content dataUsingEncoding:NSUTF8StringEncoding]  forKey:@"inputMessage"];
    [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
    
    // 4.生成二维码,获取生成后的二维码图片
    CIImage   *outputImage = [filter outputImage];
    UIImage   *image = [UIImage resizeQRCodeImage:outputImage withSize:640.0];
    
    [self performSelectorOnMainThread:@selector(didQRImageSuccess:) withObject:image waitUntilDone:NO];
}

/**
 * 扫描结果处理
 */
- (void)didQRScaningSuccess:(NSString *)result {
    
    NSLog(@"扫描识别结果 : %@", result);
    if(_successBlock) {_successBlock(result, YES); return;}
    audioPlayWithURL([NSURL fileURLWithPath:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"QRCode.bundle/qrcode_found.wav"]]);
    
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:result] ];
    if(canOpen) {
        id vc = [self.navigationController popViewControllerAnimated:YES];
        if(!vc) [self dismissViewControllerAnimated:YES completion:^(){}];

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
    }
    else {
        UIViewController *vc = [[NSClassFromString(@"QRResultViewController") alloc] init];
        vc.dict = @{@"title" : @"扫描结果", @"barcode" : result, @"isscan" : @(YES)};
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/**
 * 生成结果处理
 */
- (void)didQRImageSuccess:(UIImage *)image {

    if(_successBlock) {_successBlock(image, NO); return;}
    
    UIViewController *vc = [[NSClassFromString(@"QRResultViewController") alloc] init];
    vc.dict = @{@"title" : @"我的二维码", @"image" : image, @"isscan" : @(NO)};
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

    [self stopAVQRScanning]; //停止扫描
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result = metadataObj.stringValue;
        [self performSelectorOnMainThread:@selector(didQRScaningSuccess:) withObject:result waitUntilDone:NO];
    }
    else {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"未发现二维码" preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            isPhotoAlbum = NO;
            [self startAVQRScanning]; //开始扫描
        }]];
        [self presentViewController:vc animated:YES completion:^{}];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    [picker dismissViewControllerAnimated:YES
                             completion:^{
                                 UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                                 [self getDecodeInfoWithImage:image]; //对图片解码
                             }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   [self startAVQRScanning]; //开始扫描
                               }];
}

@end
