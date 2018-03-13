//
//  UIImagesDetailViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/5/3.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIImagesDetailViewController.h"
#import "MWPhotoBrowser.h"
#import "Globals.h"

@interface UIImagesDetailViewController () <MWPhotoBrowserDelegate>

/*图片查看器*/
@property (strong, nonatomic) MWPhotoBrowser    *browser;

@end

@implementation UIImagesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initImagesBrowser];

#if isMyReadingEnable
    /*添加到我的阅读记录*/
    [StroageService setValue:@{@"type" : @(clickTypeGallery), @"content" : self.dict}
                      forKey:[self.dict objectForVitualKey:@"url"] serviceType:serviceTypeHistory];
#endif

    //上传文章属性统计数据
    [self syncDocAnalytics:[self.dict objectForVitualKey:@"docId"] action:actionTypeRead completion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initImagesBrowser {

    _browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [_browser setCurrentPhotoIndex:0];
    [self addChildViewController:_browser];
    [self.view addSubview:_browser.view];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    
    return [self.dict[@"RelPhoto"] count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    NSDictionary *dict = self.dict[@"RelPhoto"][index];
    return [MWPhoto photoWithURL:[NSURL URLWithString:dict[@"picurl"] ] ];
}

- (NSDictionary *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionForPhotoAtIndex:(NSUInteger)index {
    
    NSDictionary *_dict = self.dict[@"RelPhoto"][index];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    if(self.dict[@"MetaDataTitle"]) {[dict setObject:self.dict[@"MetaDataTitle"] forKey:@"title"];}
    if(_dict[@"pictitle"]) {[dict setObject:_dict[@"pictitle"] forKey:@"caption"];}
    
    return dict;
}

- (UIView *)toolBarViewOfPhotoBrowser:(MWPhotoBrowser *)photoBrowser {

    CGRect frame = CGRectMake(0, 0, self.view.width, kHeightUIToolbar);
    UIToolbarView *_toolbar = [[UIToolbarView alloc] initWithFrame:frame];
    _toolbar.type = clickTypeGallery;
    _toolbar.vc = self;
    [_toolbar loadProperty];
    return _toolbar;
}

@end
