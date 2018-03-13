//
//  UISplashViewController.m
//  TRSMobileV2
//
//  Created by 廖靖宇 on 2016/3/31.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "UILaunchViewController.h"
#import "UIViewController+AssociatedObject.h"
#import "AFHTTP+Provider.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "DACircularProgressView.h"
#import "NSString+Extension.h"
#import "NSUserDefaults+Extension.h"
#import "UIDevice+Extension.h"
#import "UIView+Extension.h"
#import "SDWebImage+Extension.h"

bool isFirstLaunch () {
    
    return ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLaunch"] == NO
            || ([[[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"] floatValue] > [[NSUserDefaults standardUserDefaults] floatForKey:@"version"]));
}

void setFirstLaunchCompeletion () {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLaunch"];
    [[NSUserDefaults standardUserDefaults] setObject:[[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"version"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSString *const kUILaunchMediaKey = @"launchMedia";

@interface UILaunchViewController () <UIScrollViewDelegate> {

    //加载图片的滚动视图
    UIScrollView            *pageScrollView;
    
    //播放进度
    DACircularProgressView  *progressView;
    
    //播放计时
    NSTimer                 *timer;

    //页面指示器
    UIPageControl           *pageControl;
}

/**
 * 视频播放器
 */
@property (strong, nonatomic) AVPlayer  *player;

/**
 * 是否跳转标识在顶部
 */
@property (nonatomic, assign) BOOL isTop;

/**
 * 底部的应用Logo位大小
 */
@property (assign, nonatomic) CGSize sizeLogo;

/**
 * 右上角的跳过按钮大小
 */
@property (assign, nonatomic) CGSize sizeSkip;

/**
 * 图片或视频的播放时长
 */
@property (assign, nonatomic) NSTimeInterval duration;

@end

@implementation UILaunchViewController

+ (void)load {

    [self performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:YES];
}

- (id)init {

    if(self = [super init]) {
        
        _isTop = NO;
        _sizeLogo = CGSizeMake([UIScreen mainScreen].bounds.size.width, 120.0);
        _sizeSkip = CGSizeMake(48.0, 48.0);

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadCover)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUIControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

+ (instancetype)sharedInstance {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)appear {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *view = [UILaunchViewController sharedInstance].view;
    [window addSubview:view];
    
    [UIView animateWithDuration:0.0
                     animations:^{
                         view.x = 0.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)dismiss {
    
    [timer invalidate]; //销毁计时器

    if(_willEnterAppBlock) {_willEnterAppBlock();}
    UIView *view = [UILaunchViewController sharedInstance].view;
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         view.x = - [UIScreen mainScreen].bounds.size.width;
                     }
                     completion:^(BOOL finished) {
                         if(self.player) {[self.player pause]; self.player = nil;} //若是视频广告，则停止播放并销毁.
                         [view removeFromSuperview];
                     }];
}

#pragma mark -

- (void)initUIControls {

    pageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    pageScrollView.pagingEnabled = YES;
    pageScrollView.delegate = self;
    pageScrollView.bounces = NO;
    pageScrollView.showsVerticalScrollIndicator = NO;
    pageScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:pageScrollView];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 60, self.view.bounds.size.width, 60)];
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    pageControl.hidesForSinglePage = YES;
    [self.view addSubview:pageControl];
}

- (void)loadCover {

    [self loadAppCover:^(){[self appear];}];
    [self performSelectorInBackground:@selector(fetchAppCover:) withObject:kLaunchAPIUrl];
}

- (void)loadAppCover:(void (^)(void))completion{

    //清除以前添加的子视图
    for(id view in pageScrollView.subviews) {[view performSelector:@selector(removeFromSuperview)];}
    
    //用户第一次安装后加载，需要显示用户引导指南?
    if(isFirstLaunch()) {
        
        [self loadAppGuide];
    }
    else {
        
        //打开应用后的正常显示--？先判断是否有广告数据，同时广告文件未过期且文件在目录下存在.
        BOOL hasCoverAD = NO; NSString *__path = nil;
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kUILaunchMediaKey];
        if(dict) {
            
            id expiredDate = dict[kLaunchExpireDate];
            //有expiredDate失效时间字段且时间戳为有效，则加载广告，反之则加载默认的启动图；若无，则默认是一直有效，加载广告
            if(!expiredDate
               || ([expiredDate doubleValue] > [NSDate date].timeIntervalSince1970) ) {
                
                __path = [[self getCachingPath] stringByAppendingFormat:@"/%@.%@", [NSString md5:[dict[kLaunchMedia] stringByDeletingPathExtension] ], [dict[kLaunchMedia] pathExtension] ];
                hasCoverAD = [[NSFileManager defaultManager] fileExistsAtPath:__path];
            }
        }
        
        if(hasCoverAD) {
            BOOL isVideo = [[dict[kLaunchMedia] pathExtension].lowercaseString isEqual:@"mp4"];
            if(isVideo) {
                [self loadAppAdVideo:[NSURL fileURLWithPath:__path] ];
            }
            else {
                [self loadAppAdImage:YES path:__path];
            }
        }
        else {
               [self loadAppAdImage:YES path:@"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=697563148,4247827459&fm=27&gp=0.jpg"];
//            [self loadAppAdImage:NO path:nil];
        }
    }
    
    if(completion) {completion();}
}

- (void)loadAppGuide {

    //先搜索导入的用户指南图片，并返回是否为文件路径标识
    BOOL isFilePath = [self loadAppGuideImages];
    
    //
    NSInteger total = _coverImages.count;
    if(total == 0) { //增加对于不引入用户指南，也首次默认加载Brand Asset.
        [self loadAppAdImage:NO path:nil];
        setFirstLaunchCompeletion();
        return;
    }
    
    //用户指南显示
    for(NSInteger i = 0 ; i < total; i++) {
        
        UIImageView *imageview = [[UIImageView alloc] init];
        imageview.frame = CGRectMake(i * self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        imageview.backgroundColor = [UIColor whiteColor];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.image = (isFilePath ? [UIImage imageWithContentsOfFile:_coverImages[i] ] : [UIImage imageNamed:_coverImages[i]]);
        [pageScrollView addSubview:imageview];
        
        //增加"用户进入"Button
        if(i == total - 1) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, 120, 44);
            button.center = CGPointMake(imageview.center.x, self.view.bounds.size.height - (60.0 + button.frame.size.height));
            button.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
            [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
            [button setTitle:@"开始使用" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(didEnterClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setCornerWithRadius:CGRectGetHeight(button.bounds)/2.0];
            [pageScrollView addSubview:button];
        }
    }
    pageControl.numberOfPages = total;
    pageScrollView.contentSize = CGSizeMake(total * pageScrollView.bounds.size.width, pageScrollView.bounds.size.height);
}

- (BOOL)loadAppGuideImages {

    if(_coverImages == nil) {
        
        //搜索导入的用户指南图片
        BOOL isIPad = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
        BOOL is35Screen = ([UIScreen instancesRespondToSelector:@selector(currentMode)]
                           && CGSizeEqualToSize(CGSizeMake(640,960), [[UIScreen mainScreen] currentMode].size) );
        NSString *dir = (isIPad ? @"iPad" : (is35Screen ? @"2x" : @"3x"));
        NSString *dicretory = [NSString stringWithFormat:@"splash.bundle/%@", dir];
        _coverImages = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:dicretory];
        
        return YES;
    }
    
    return NO;
}

- (void)loadAppAdVideo:(NSURL *)url {

    //底部应用标识
//    UIImageView *splash = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    splash.backgroundColor = [UIColor whiteColor];
//    splash.image = [UIImage imageNamed:launchImage()];
//    [pageScrollView addSubview:splash];

    //视频广告
    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"keep" ofType:@"mp4"];
//    self.moviePlayerController.contentURL = [[NSURL alloc] initFileURLWithPath:moviePath];
    self.player = [AVPlayer playerWithURL:[[NSURL alloc] initFileURLWithPath:moviePath]];
    self.duration = CMTimeGetSeconds(self.player.currentItem.asset.duration); //视频广告的播放时长
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - _sizeLogo.height);
    [self.player play];
    [pageControl setNumberOfPages:1];
    [pageScrollView.layer addSublayer:playerLayer];
    [pageScrollView setContentOffset:CGPointZero animated:NO];
    
    [self addAVPlayerItemObserver];
    [self loadSkipView]; //加载跳过
}

- (void)loadAppAdImage:(BOOL)isAd path:(NSString *)path {
    
    //底部应用标识
    UIImageView *splash = [[UIImageView alloc] initWithFrame:self.view.bounds];
    splash.backgroundColor = [UIColor whiteColor];
    splash.image = [UIImage imageNamed:launchImage()];
    [pageScrollView addSubview:splash];

    if(isAd) {
        
        //图片广告
        UIImageView *imageView = nil;
        BOOL isGIF = [path.pathExtension.lowercaseString isEqualToString:@"gif"];
        if(isGIF) {
            
            FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:path]];
            self.duration = animatedImage.frameCount; //GIF动画的播放时长
            
            imageView = [[FLAnimatedImageView alloc] init];
            [(FLAnimatedImageView *)imageView setAnimatedImage:animatedImage];
        }
        else {
            self.duration = 5.0; //图片广告的播放时长
            
            imageView = [[UIImageView alloc] init];
//            [imageView sd_setImageWithURL:[NSURL fileURLWithPath:path] ];
             [imageView sd_setImageWithURL:[NSURL fileURLWithPath:@"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=697563148,4247827459&fm=27&gp=0.jpg"]];
        }
        
        imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - _sizeLogo.height);
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        [imageView addTapGesture:self selector:@selector(didCoverClick:)];
        [pageScrollView addSubview:imageView];
        [pageControl setNumberOfPages:1];
        [pageScrollView setContentOffset:CGPointZero animated:NO];
    }
    
    [self loadSkipView]; //加载跳过
}

- (void)loadSkipView {

    CGRect frame = CGRectMake(self.view.bounds.size.width - _sizeSkip.width - 20.0,
                             (_isTop ? 60.0 : self.view.bounds.size.height - _sizeLogo.height/2.0 - _sizeSkip.height/2.0),
                              _sizeSkip.width, _sizeSkip.height);
    UIView *skipView = [[UIView alloc] initWithFrame:frame];
    [pageScrollView addSubview:skipView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = skipView.bounds;
    button.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    [button setTitle:@"跳过" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:11.0] ];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [button setCornerWithRadius:CGRectGetHeight(button.bounds)/2.0];
    [skipView addSubview:button];
    
    progressView = [[DACircularProgressView alloc] initWithFrame:skipView.bounds];
    progressView.backgroundColor = [UIColor clearColor];
    progressView.trackTintColor = [UIColor redColor];
    progressView.thicknessRatio = 0.05f;
    progressView.userInteractionEnabled = NO;
    [skipView addSubview:progressView];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(setProgress) userInfo:nil repeats:YES];
}

- (void)setProgress {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        progressView.progress += 0.01/self.duration;
        if (progressView.progress >= 1.0) {
            
            [self dismiss];
        }
    });
}

- (void)didCoverClick:(id)sender {
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kUILaunchMediaKey];
    if(self.clickEvent){self.clickEvent(dict, 0);}
    [self dismiss];
}

- (void)didEnterClick:(id)sender {

    setFirstLaunchCompeletion();
    [self dismiss];
}

#pragma mark -

- (void)addAVPlayerItemObserver {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayCompeletion:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayCompeletion:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
}

- (void)removeAVPlayerItemObserver {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
}

- (void)avPlayerItemDidPlayCompeletion:(NSNotification *)notification {
    
    [self removeAVPlayerItemObserver];
    [self dismiss];
}

#pragma mark -

- (NSString *)getCachingPath {

    /*应用的默认缓存目录*/
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    /*下载的首屏广告存放到SDWebImage的默认存储文件夹下*/
    NSString *__cachesPath = [cachesPath stringByAppendingPathComponent:@"default/com.hackemist.SDWebImageCache.default"];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:__cachesPath];
    if(!isExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:__cachesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return __cachesPath;
}

- (void)fetchAppCover:(NSString *)url {
    
    [AFHTTP request:url completion:^(BOOL success, id _Nullable responseObject, NSError * _Nullable error) {
                       
                       if(success) {

                           int code = [responseObject[@"code"] intValue];
                           if(0 == code) {
                               
                               NSDictionary *response = responseObject[kLaunchResponse];
                               NSString *url = response[kLaunchMedia];
                               
                               //判断文件是否需要下载 --？原来的广告数据存在，且广告文件的下载地址与本次不相同，或者原来广告文件不存在需重新下载.
                               BOOL isDownload = NO;
                               NSString *__path = nil;
                               NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kUILaunchMediaKey];
                               if(dict) {
                                   BOOL isSame = [url isEqualToString:dict[kLaunchMedia] ];
                                   if(!isSame) {
                                       isDownload = YES;
                                   }
                                   else {
                                       __path = [[self getCachingPath] stringByAppendingFormat:@"/%@.%@", [NSString md5:[dict[kLaunchMedia] stringByDeletingPathExtension] ], [dict[kLaunchMedia] pathExtension] ];
                                       isDownload = ([[NSFileManager defaultManager] fileExistsAtPath:__path] ? NO : YES);
                                   }
                               }
                               else {
                                   isDownload = YES;
                               }
                               
                               if(isDownload) {
                                   
                                   //先清除上次下载的内容
                                   [[NSFileManager defaultManager] removeItemAtPath:__path error:nil];
                                   
                                   //文件存储路径
                                   NSString *targetPath = [[self getCachingPath] stringByAppendingFormat:@"/%@.%@", [NSString md5:[url stringByDeletingPathExtension] ], [url pathExtension] ];
                                   
                                   //下载文件
                                   [AFHTTP downloadFile:url
                                             targetPath:targetPath
                                             parameters:nil
                                               progress:nil
                                             completion:nil];
                               }
                               
                               //序列化数据
                               [[NSUserDefaults standardUserDefaults] setObject:response forKey:kUILaunchMediaKey];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                       }
                }
        }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    NSInteger index = scrollView.contentOffset.x / self.view.bounds.size.width;
    [pageControl setCurrentPage:index];
}

@end
