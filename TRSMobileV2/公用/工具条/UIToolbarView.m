//
//  UIToolBar.m
//  TRSMobileV2
//
//  Created by  TRS on 16/5/10.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIToolbarView.h"
#import "UICommentViewController.h"
#import "Globals.h"

CGFloat kHeightUIToolbar = 60.0;
NSString *const didFavoriteChangeNotification = @"favoriteDidChange";

@interface UIToolbarView  ()

/*发布评论背景*/
@property (strong, nonatomic) UIImageView *viewBG;

/*发布评论组件*/
@property (strong, nonatomic) UIControl *buttonPost;

/*评论数文本*/
@property (strong, nonatomic) UILabel   *labelComment;

/*评论列表按钮*/
@property (strong, nonatomic) UIButton  *buttonComment;

/*收藏按钮*/
@property (strong, nonatomic) UIButton  *buttonFavorite;

/*分享按钮*/
@property (strong, nonatomic) UIButton  *buttonShare;

/*评论输入组件*/
@property (strong, nonatomic) UICommentPostView *commentPost;

/*第一次加载不需要动画*/
@property (assign, nonatomic) BOOL      isFirstLoad;

@end


@implementation UIToolbarView

- (instancetype) initWithFrame:(CGRect)frame {

    if(self = [super initWithFrame:frame]) {
        
        [self setup];
        addNotificationObserver(self, @selector(commentDidPost:), didCommentPostNotification, nil);
    }
    return self;
}

- (void)dealloc {
    
    removeNotifcationObserverAll(self);
}

- (void)setup {
    
    self.isFirstLoad = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    _viewBG = [[UIImageView alloc] initWithFrame:self.bounds];
    _viewBG.backgroundColor = [UIColor colorWithRGB:0xeeeeee alpha:0.6];
    [self addSubview:_viewBG];
    
    _buttonPost = [[UIControl alloc] init];
    _buttonPost.tag = actionTypeComment;
    _buttonPost.backgroundColor = [UIColor whiteColor];
    [_buttonPost addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_buttonPost];
    
    UIImageView *_iconPost = [[UIImageView alloc] init];
    _iconPost.backgroundColor = [UIColor clearColor];
    _iconPost.contentMode = UIViewContentModeScaleAspectFit;
    _iconPost.image = [UIImage imageNamed:@"normal.bundle/写评论.png"];
    [_buttonPost addSubview:_iconPost];
    
    UILabel *_labelPost = [[UILabel alloc] init];
    _labelPost.backgroundColor = [UIColor clearColor];
    _labelPost.font = [UIFont systemFontOfSize:13.0];
    _labelPost.textColor = [UIColor lightGrayColor];
    _labelPost.text =  @"写评论...";
    [_buttonPost addSubview:_labelPost];
    
    _buttonComment = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonComment.tag = (actionTypeComment + 0x100);
    _buttonComment.backgroundColor = [UIColor clearColor];
    [_buttonComment setImage:[UIImage imageNamed:@"normal.bundle/评论.png"] forState:UIControlStateNormal];
    [_buttonComment addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_buttonComment];

    UIImage *imgFavorite = [UIImage imageNamed:@"normal.bundle/收藏.png"];
    _buttonFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonFavorite.tag = actionTypeFavorite;
    _buttonFavorite.backgroundColor = [UIColor clearColor];
    [_buttonFavorite setImage:imgFavorite forState:UIControlStateNormal];
    [_buttonFavorite setImage:[imgFavorite colorImage:[UIColor colorWithRGB:UIColorThemeDefault] ] forState:UIControlStateSelected];
    [_buttonFavorite addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_buttonFavorite];

    _buttonShare = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonShare.tag = actionTypeShare;
    _buttonShare.backgroundColor = [UIColor clearColor];
    [_buttonShare setImage:[UIImage imageNamed:@"normal.bundle/分享.png"] forState:UIControlStateNormal];
    [_buttonShare addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_buttonShare];
    
    CGFloat x = CGRectGetWidth(self.frame) - 2*44.0 - 44.0/2.0;
    _labelComment = [[UILabel alloc] init];
    _labelComment.frame = CGRectMake(x, 6.0, 24.0, 14.0);
    _labelComment.backgroundColor = [UIColor colorWithRGB:0xff0000 alpha:0.8];
    _labelComment.textAlignment = NSTextAlignmentCenter;
    _labelComment.textColor = [UIColor whiteColor];
    _labelComment.font = [UIFont systemFontOfSize:10.0];
    _labelComment.hidden = YES;
    [self addSubview:_labelComment];

    _buttonShare.sd_layout
    .topSpaceToView(self, 0)
    .bottomSpaceToView(self, 0)
    .rightSpaceToView(self, 0)
    .widthIs(44.0);

    _buttonFavorite.sd_layout
    .topSpaceToView(self, 0)
    .bottomSpaceToView(self, 0)
    .rightSpaceToView(_buttonShare, 0)
    .widthIs(44.0);

    _buttonComment.sd_layout
    .topSpaceToView(self, 0)
    .bottomSpaceToView(self, 0)
    .rightSpaceToView(_buttonFavorite, 0)
    .widthIs(44.0);
    
    _buttonPost.sd_layout
    .centerYEqualToView(self)
    .leftSpaceToView(self, 8.0)
    .rightSpaceToView(_buttonComment, 8.0)
    .heightIs(36.0);
    
    _iconPost.sd_layout
    .leftSpaceToView(_buttonPost, 10.0)
    .centerYEqualToView(_buttonPost)
    .widthIs(16.0)
    .heightIs(16.0);
    
    _labelPost.sd_layout
    .topSpaceToView(_buttonPost, 0)
    .bottomSpaceToView(_buttonPost, 0)
    .leftSpaceToView(_iconPost, 4.0)
    .rightSpaceToView(_buttonPost, 0);
    
    [_buttonPost setCornerWithRadius:CGRectGetHeight(_buttonPost.frame)/2.0];
    [_labelComment setCornerWithRadius:CGRectGetHeight(_labelComment.frame)/2.0];
}

- (void)setCommentPolicy:(commentPolicy)commentPolicy {

    _commentPolicy = commentPolicy;
    if(commentPolicy == commentPolicyNone) {
        self.backgroundColor = _viewBG.backgroundColor = [UIColor clearColor];
        _buttonPost.hidden = _buttonComment.hidden = _labelComment.hidden = YES;
    }
}

- (void)setOnlyHasPost:(BOOL)onlyHasPost {

    _buttonPost.sd_layout
    .centerYEqualToView(self)
    .leftSpaceToView(self, 8.0)
    .rightSpaceToView(self, 8.0)
    .heightIs(36.0);
    
    _onlyHasPost = onlyHasPost;
    _labelComment.hidden = _buttonComment.hidden = _buttonFavorite.hidden = _buttonShare.hidden = YES;
}

- (void)loadProperty {

    if(_onlyHasPost) return;
    
    [self loadFavorite];
    [self getCommentCount];
}

- (void)loadFavorite {
    
    BOOL isFav = [StroageService hasValueForKey:[_vc.dict objectForVitualKey:@"url"] serviceType:serviceTypeFavorite];
    [self setIsFavorite:isFav];
    self.isFirstLoad = NO;
}

- (void)setIsFavorite:(BOOL)isFavorite {

    NSTimeInterval duration = self.isFirstLoad ? 0.0 : 0.15;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         _buttonFavorite.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration
                                          animations:^{
                                              _buttonFavorite.imageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:duration
                                                               animations:^{
                                                                   _buttonFavorite.selected = isFavorite;
                                                                   _buttonFavorite.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                               }
                                                               completion:^(BOOL finished) {
                                                               }];
                                          }];
                     }];
}

- (void)setCommentValue:(NSInteger)value {

    //设置评论数显示
    _labelComment.hidden = (value <= 0);
    _labelComment.text = [NSString stringWithFormat:@"%ld", value];
    
    //重设评论数的宽度.
    CGFloat w = [_labelComment.text boundingRectWithSize:_labelComment.frame.size
                                                 options:NSStringDrawingTruncatesLastVisibleLine
                                              attributes:@{NSFontAttributeName : _labelComment.font}
                                                 context:NULL].size.width;
    if(w < CGRectGetHeight(_labelComment.frame)) w = CGRectGetHeight(_labelComment.frame);
    [_labelComment setWidth:(w + 6.0)];
}

- (void)getCommentCount {

    AVQuery *query = [AVQuery queryWithClassName:@"Comment"];
    [query whereKey:@"docId" equalTo:[_vc.dict objectForVitualKey:@"docId"] ];
    [query whereKey:@"status" notEqualTo:@(commentStatusReview)]; //增加对status审核状态的判断
    [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        if(!error) {
            [self setCommentValue:number];
        }
    }];
}

- (void)commentDidPost:(NSNotification *)notification {

    [self setCommentValue:(_labelComment.text.integerValue + 1)];
}

- (void)didButtonSelect:(id)sender {

    NSInteger tag = [(UIButton *)sender tag];
    switch (tag) {
        case actionTypeComment:
        {
            //禁用拖动返回和打开侧边栏
            [GDelegate.navTab setCanDargBack:NO];
            [GDelegate.vcDrawer setPaneDragRevealEnabled:NO forDirection:MSDynamicsDrawerDirectionHorizontal];
            
            _commentPost = [[UICommentPostView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _commentPost.type = _type;
            _commentPost.commentPolicy = _commentPolicy;
            _commentPost.dict = _vc.dict;
            _commentPost.dismissBlock = ^() {
                //启动拖动返回和打开侧边栏
                [GDelegate.navTab setCanDargBack:YES];
                [GDelegate.vcDrawer setPaneDragRevealEnabled:YES forDirection:MSDynamicsDrawerDirectionHorizontal];
            };
            [_vc.view addSubview:_commentPost];
            break;
        }
            
        case (actionTypeComment + 0x100):
        {
            UICommentViewController *vc = [[UICommentViewController alloc] init];
            vc.dict = _vc.dict;
            vc.total = [_labelComment.text integerValue];
            [_vc.navigationController pushViewController:vc animated:YES];
            break;
        }
            
        case actionTypeFavorite:
        {
            if(_buttonFavorite.selected) {
                [StroageService removeValueForKey:[_vc.dict objectForVitualKey:@"url"] serviceType:serviceTypeFavorite];
            }
            else {
                [StroageService setValue:@{@"type" : @(_type), @"content" : _vc.dict}
                                  forKey:[_vc.dict objectForVitualKey:@"url"] serviceType:serviceTypeFavorite];
            }
            [self setIsFavorite:!_buttonFavorite.selected];
            postNotificationName(didFavoriteChangeNotification, nil, nil);
            break;
        }
            
        case actionTypeShare:
        {
            [ShareSDK showShareActionSheet:_vc.dict inView:sender];
            break;
        }
            
        default:
            break;
    }
}

@end
