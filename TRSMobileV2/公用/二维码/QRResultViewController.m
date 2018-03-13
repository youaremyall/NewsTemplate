//
//  QRResultViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/20.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "QRResultViewController.h"
#import "UIViewController+AssociatedObject.h"
#import "UIColor+Extension.h"
#import "UIView+SDAutoLayout.h"
#import "SDWebImage+Extension.h"
#import "SVProgressHUD.h"
#import "LCActionSheet.h"
#import "TRSMobile.h"

@interface QRResultViewController ()

@property (nonatomic, strong) UILabel   *labelBarcode;
@property (nonatomic, strong) UIImageView   *imageBarcode;

@end

@implementation QRResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUIControls];
    ([self.dict[@"isscan"] boolValue] ? [self setQRResult] : [self setQRImage]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initUIControls {
    
    [self initUIBarcode];
    [self setUINavbar];
}

- (void)setUINavbar {
    
    __weak __typeof(self) wself = self;
    self.navbar.clickEvent = ^(NSDictionary *dict , NSInteger index) {
        switch (index) {
            case 0:
            {
                id vc = [wself.navigationController popViewControllerAnimated:YES];
                if(!vc) [wself dismissViewControllerAnimated:YES completion:^(){}];
                break;
            }
            case 1:
            {
                LCActionSheet *sheet = [LCActionSheet sheetWithTitle:@"保存图片" cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                    if(buttonIndex) {
                        [SVProgressHUD showWithStatus:@"保存中..."];
                        UIImageWriteToSavedPhotosAlbum(wself.imageBarcode.image, wself, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
                    }
                } otherButtonTitles:@"保存", nil];
                [sheet show];
                break;
            }
            default:
                break;
        }
    };
    if(![self.dict[@"isscan"] boolValue]) {
        [self.navbar.barRight  setImage:[UIImage imageNamed:@"normal.bundle/导航_更多.png"] forState:UIControlStateNormal];
    }
    [self.navbar.barTitle setText:self.dict[@"title"] ];
}

- (void)initUIBarcode {
    
    _labelBarcode = [[UILabel alloc] init];
    _labelBarcode.backgroundColor = [UIColor clearColor];
    _labelBarcode.textAlignment = NSTextAlignmentCenter;
    _labelBarcode.textColor = [UIColor blackColor];
    _labelBarcode.font = [UIFont systemFontOfSize:20.0];
    _labelBarcode.numberOfLines = 0;
    _labelBarcode.hidden = YES;
    [self.view addSubview:_labelBarcode];
    
    _imageBarcode = [[UIImageView alloc] init];
    _imageBarcode.hidden = YES;
    _imageBarcode.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageBarcode];
    
    
    _labelBarcode.sd_layout
    .topSpaceToView(self.navbar, 8.0f)
    .leftSpaceToView(self.view, 20.0f)
    .rightSpaceToView(self.view, 20.0f)
    .bottomSpaceToView(self.view, 20.0f);
    
    _imageBarcode.sd_layout
    .topSpaceToView(self.navbar, 8.0f)
    .leftSpaceToView(self.view, 20.0f)
    .rightSpaceToView(self.view, 20.0f)
    .bottomSpaceToView(self.view, 20.0f);
}

- (void)setQRResult {

    _labelBarcode.hidden = NO;
    _labelBarcode.text = self.dict[@"barcode"];

}

- (void)setQRImage {

    _imageBarcode.hidden = NO;
    _imageBarcode.image = self.dict[@"image"];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    [SVProgressHUD showSuccessWithStatus:@"保存成功"];
}

@end
