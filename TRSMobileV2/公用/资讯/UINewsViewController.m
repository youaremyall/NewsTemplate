//
//  UINewsViewController.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/4/11.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UINewsViewController.h"
#import "UINewsContainerViewController.h"
#import "UINewsSubscribleViewController.h"
#import "Globals.h"

@interface UINewsViewController () <RDVTabBarControlledelegate>
{
    __weak  UINavbarPicker  *_picker;
    __strong  UINewsContainerViewController   *_vcContainer;
}
@end

@implementation UINewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hasPicker = YES;
    [self initUIControls];
    [self requestNewsChannel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestNewsChannel)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)initUIControls {
    
    self.rdv_tabBarController.delegate = self;
    [self.navbar.barTitle setText:self.dict[@"title"] ];
    [self.navbar.barLeft setHidden:YES];
    
    [self initUINavbarPicker];
    [self initUIContainerView];
    [self handleEventBlocks];
}

- (void)initUINavbarPicker {

    if(!_hasPicker) return;
    
    _picker = [NSBundle instanceWithBundleNib:NSStringFromClass([UINavbarPicker class])];
    _picker.backgroundColor = [UIColor whiteColor];
    _picker.y = CGRectGetMaxY(self.navbar.bounds);
    _picker.isSubscrible = YES;
    _picker.isOnlyLoadSubscribled = YES;
    _picker.titles = [StroageService valueForKey:UserNewsChannel serviceType:serviceTypeUser];
    [self.view addSubview:_picker];
}

- (void)initUIContainerView {

    CGFloat y = CGRectGetMaxY((!_hasPicker) ? self.navbar.frame : _picker.frame);
    _vcContainer = [[UINewsContainerViewController alloc] init];
    _vcContainer.view.frame = CGRectMake(0, y, CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.frame) - y));
    _vcContainer.isFliter = _hasPicker;
    _vcContainer.channels = _picker.titles;
    [self addChildViewController:_vcContainer];
    [self.view addSubview:_vcContainer.view];
}

#pragma mark -
- (void) handleEventBlocks {

    __weak __typeof(self) wself = self;
    __weak __typeof(UINavbarPicker *) wpicker = _picker;
    __weak __typeof(UINewsContainerViewController *) wcontainer = _vcContainer;
    
    _picker.subscribleEvent = ^(){
        
        [UINewsSubscribleViewController showInVC:wself
                                        channels:_picker.titles
                                               y:self.navbar.height
                                               h:_picker.height
                                     changeBlock:^(NSArray * _Nonnull channels) {
                                         
                                         [_picker setTitles:channels];
                                         [_vcContainer setChannels:channels];
                                      }
                                      clickBlock:^(NSInteger index) {
                                         
                                          [_picker setIndex:index];
                                          [_vcContainer setIndex:index];
                                      }];
    };
    
    _picker.clickEvent = ^(NSDictionary * _Nullable dict, NSInteger index){
        
        [wcontainer setIndex:index];
    };

    _vcContainer.changeEvent = ^(NSDictionary * _Nonnull channel, NSInteger index) {
        
        [wpicker setIndex:index];
    };
}

- (void)refresh {
    
    UIViewController *vc = _vcContainer.childViewControllers[_picker.index];
    if([vc.view isKindOfClass:[UIScrollView class]]) {
        [((UIScrollView*)vc.view).mj_header beginRefreshing];
    }
}

#pragma mark -
- (BOOL)isSame2ServerChannels:(NSArray *)channels {
    
    BOOL isSame = [_picker.titles isEqualToArray:channels];
    if(isSame) return YES;
    
    NSMutableArray *serverUrls = [NSMutableArray arrayWithCapacity:0];
    for(NSDictionary *dict in channels) {
        NSMutableDictionary *dict_ = [NSMutableDictionary dictionaryWithDictionary:dict];
        [dict_ removeObjectForKey:isChannelSubscrible];
        [serverUrls addObject:dict_ ];
    }
    
    NSMutableArray *localUrls = [NSMutableArray arrayWithCapacity:0];
    for(NSDictionary *dict in _picker.titles) {
        NSMutableDictionary *dict_ = [NSMutableDictionary dictionaryWithDictionary:dict];
        [dict_ removeObjectForKey:isChannelSubscrible];
        [localUrls addObject:dict_ ];
    }
    
    isSame = (serverUrls.count == localUrls.count);
    if(isSame) {
        for(id channel in serverUrls) {
            isSame = [localUrls containsObject:channel];
            if(!isSame) break;
        }
    }
    return isSame;
}

/*
 * 遍历对比服务器数据和本地栏目定制数据，若服务器数据有更新则以服务器数据为准.
 * ps : 由于本地栏目数据经过拖动排序、添加删除订阅栏目isSubscrible字段，故本地栏目数据与服务器数据需遍历对比，不能直接仅使用数组相等来判断.
 */
- (void)requestNewsChannel {

    [AFHTTP request:self.dict[@"url"] completion:^(BOOL success, id _Nullable response, NSError * _Nullable error) {
            
         if(success) {
             
             NSArray *channels = response[@"datas"];
             if(![self isSame2ServerChannels:channels]) {
                 [_picker setTitles:channels];
                 [_vcContainer setChannels:channels];
                 [StroageService setValue:channels forKey:UserNewsChannel serviceType:serviceTypeUser];
             }
         }
     }];
}

#pragma mark - RDVTabBarControlledelegate

- (void)tabBarController:(RDVTabBarController *)tabBarController didAgainSelectViewController:(UIViewController *)viewController {
    
    [self refresh];
}

@end
