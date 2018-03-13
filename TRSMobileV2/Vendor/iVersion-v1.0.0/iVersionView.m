//
//  iVersionView.m
//  NXXW
//
//  Created by wangchangjun on 2017/4/12.
//  Copyright © 2017年  TRS. All rights reserved.
//

#import "iVersionView.h"
#import "UIColor+Extension.h"
#import "SDAutoLayout.h"

@interface iVersionView ()

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *releaseTime;
@property (nonatomic, strong) NSString *releaseNotes;
@property (nonatomic, strong) NSString *updateUrl;
@property (nonatomic, assign) BOOL isForceUpdate;

@end

@implementation iVersionView

+ (void)showWithVersion:(NSString *)version releaseTime:(NSString *)relseaTime releaseNotes:(NSString *)releaseNotes releaseUrl:(NSString *)releaseUrl isForceUpdate:(BOOL)isForceUpdate {

    iVersionView *view = [[iVersionView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.version = version;
    view.releaseTime = relseaTime;
    view.releaseNotes = releaseNotes;
    view.updateUrl = releaseUrl;
    view.isForceUpdate = isForceUpdate;
    [view commonInit];
    [view show];
}

- (void)commonInit{
    
    self.alpha = 0.0f;
    self.backgroundColor = [UIColor clearColor];
    
    // 渐变颜色
    NSArray *colorsHexS = @[@"#DE6262", @"#5FC3E4", @"#185a9d", @"#d53369", @"#FF6B6B", @"#49a09d", @"#FF6B6B"];
    NSArray *colorsHexE = @[@"#FFB88C", @"#E55D87", @"#43cea2", @"#e43a15", @"#D38312", @"#5f2c82", @"#D38312"];
    
    NSMutableArray *colorsS = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *colorsE = [NSMutableArray arrayWithCapacity:0];
    for(NSString *color in colorsHexS) {
        [colorsS addObject:(__bridge id)[UIColor colorWithHexString:color].CGColor];
    }
    
    for(NSString *color in colorsHexE) {
        [colorsE addObject:(__bridge id)[UIColor colorWithHexString:color].CGColor];
    }

    // 底部偏黑色背景
    UIView *blackView = [UIView new];
    blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [blackView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)] ];
    [self addSubview:blackView];
    blackView.sd_layout.topEqualToView(self).leftEqualToView(self).bottomEqualToView(self).rightEqualToView(self);
    
    // 渐变图层视图
    UIView *gradientView = [UIView new];
    gradientView.alpha = 1.0f;
    gradientView.layer.cornerRadius = 6.0f;
    [self addSubview:gradientView];
    gradientView.sd_layout.centerXEqualToView(self).centerYEqualToView(self).widthIs(240.0).heightIs(320.0);
    
    // 版本提示
    UILabel *labelTitle = [UILabel new];
    labelTitle.font = [UIFont boldSystemFontOfSize:18];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.text = @"有新版本可以升级啦！";
    [gradientView addSubview:labelTitle];
    labelTitle.sd_layout.topSpaceToView(gradientView, 20).leftSpaceToView(gradientView, 20).rightSpaceToView(gradientView, 16).heightIs(21);
    
    // 最新版本
    UILabel *labelVersion = [UILabel new];
    labelVersion.font = [UIFont systemFontOfSize:15];
    labelVersion.textAlignment = NSTextAlignmentCenter;
    labelVersion.textColor = [UIColor whiteColor];
    labelVersion.text = [NSString stringWithFormat:@"最新版本 : v%@", _version];
    [gradientView addSubview:labelVersion];
    labelVersion.sd_layout.topSpaceToView(labelTitle, 12).leftEqualToView(labelTitle).rightEqualToView(labelTitle).heightIs(18);
    
    // 发布时间
    UILabel *labelTime = [UILabel new];
    labelTime.numberOfLines = 0;
    labelTime.font = [UIFont systemFontOfSize:13];
    labelTime.textColor = [UIColor whiteColor];
    if(_releaseTime) {
        labelTime.textAlignment = NSTextAlignmentCenter;
        if(_releaseTime) {labelTime.text = [NSString stringWithFormat:@"发布日期 : %@", _releaseTime];}
    }
    else {
        labelTime.textAlignment = NSTextAlignmentLeft;
        labelTime.text = [NSString stringWithFormat:@"更新说明 :"];
    }
    [gradientView addSubview:labelTime];
    labelTime.sd_layout.topSpaceToView(labelVersion, 12).leftEqualToView(labelTitle).rightEqualToView(labelTitle).heightIs(18);
    
    // 更新内容
    UILabel *labelReleaseNote = [UILabel new];
    labelReleaseNote.font = [UIFont systemFontOfSize:13];
    labelReleaseNote.textAlignment = NSTextAlignmentLeft;
    labelReleaseNote.textColor = [UIColor whiteColor];
    labelReleaseNote.text = _releaseNotes;
    [gradientView addSubview:labelReleaseNote];
    labelReleaseNote.sd_layout.topSpaceToView(labelTime, 12).leftEqualToView(labelTitle).rightEqualToView(labelTitle).autoHeightRatio(0).maxHeightIs(140);
    
    // 更新按钮
    UIButton *buttonUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonUpdate setImage:[UIImage imageNamed:@"iVersion.png"] forState:UIControlStateNormal];
    [buttonUpdate addTarget:self action:@selector(update:) forControlEvents:UIControlEventTouchUpInside];
    [gradientView addSubview:buttonUpdate];
    buttonUpdate.sd_layout.centerXEqualToView(gradientView).bottomSpaceToView(gradientView, 8).heightIs(64).widthIs(64);
    
    // 渐变图层动画组
    CAGradientLayer *gLayer = [CAGradientLayer layer];
    gLayer.frame = gradientView.bounds;
    gLayer.cornerRadius = 6.0;
    gLayer.startPoint = CGPointMake(1, 0);
    gLayer.endPoint = CGPointMake(0, 1);
    gLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor orangeColor].CGColor];
    [gradientView.layer insertSublayer:gLayer below:labelTitle.layer];
    
    NSMutableArray *animationArr = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 0; i < colorsS.count; i++) {
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"colors"];
        anim.fromValue = @[colorsS[i], colorsE[i]];
        anim.fillMode = kCAFillModeForwards;
        anim.duration = 1;
        if (i == colorsS.count - 1) {
            anim.toValue = @[colorsS[0],colorsE[0]];
        }else{
            anim.toValue = @[colorsS[i + 1],colorsE[i + 1]];
        }
        anim.beginTime = i * 1;
        [animationArr addObject:anim];
    }
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = animationArr;
    group.removedOnCompletion = YES;
    group.beginTime = 0;
    group.duration = colorsS.count;
    group.autoreverses  = NO;
    group.repeatCount = INT_MAX;
    [gLayer addAnimation:group forKey:@"colors"];
}

- (void)update:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateUrl]];
    [self dismiss];
}

- (void)tap:(UITapGestureRecognizer *)recognizer{

    if(_isForceUpdate) return;    
    [self dismiss];
}

#pragma mark -

- (void)show {

    UIWindow *keyWindow = [UIApplication sharedApplication].windows.lastObject;
    [keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)dismiss {

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
