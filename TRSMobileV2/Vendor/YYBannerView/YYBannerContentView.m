//
//  YYBannerContentView.m
//  ProductSammary
//
//  Created by yuans on 16/11/15.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "YYBannerContentView.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
@interface YYBannerContentView()
@property(nonatomic,strong)UIImageView * contentIMG;
@end


@implementation YYBannerContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds= YES;
        
        self.contentIMG = [[UIImageView alloc]initWithFrame:self.bounds];
        self.contentIMG.frame = self.bounds;
        self.contentIMG.backgroundColor = [UIColor clearColor];
        self.contentIMG.contentMode = UIViewContentModeScaleAspectFill;
        self.contentIMG.clipsToBounds = YES;
        
        [self addSubview:self.contentIMG];
        
        [self.contentIMG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

-(void)setUserInteraction:(BOOL)enable{
    if (enable) {
        self.contentIMG.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnFunc:)];
        [self.contentIMG addGestureRecognizer:tap];
    }
}
-(void)btnFunc:(UIGestureRecognizer *)gesture{
    if (self.callBack) {
        self.callBack(self);
    }
}
-(void)setContentIMGWithStr:(NSString *)str palceHolder:(UIImage *)image{
    if ([str hasPrefix:@"http://"]) {
        [self.contentIMG sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:image];
    }else{
        [self.contentIMG setImage:[UIImage imageNamed:str]];
    }
}

- (void)setOffsetWithFactor:(float)value{
    CGRect  selfToWindow = [self convertRect:self.bounds toView:YYBannerContentView_getConvertView(self)]; //当前View的frame
    CGFloat selfCenterX = CGRectGetMidX(selfToWindow); //当前View的centerX
    CGPoint windowCenter = YYBannerContentView_getConvertView(self).center;
    CGFloat selfOffsetX = selfCenterX - windowCenter.x; //偏移距离
    
    CGAffineTransform transX = CGAffineTransformMakeTranslation(- selfOffsetX * value, 0);
    //    NSLog(@" 当前ContenView:%.3f windowCenter:%@ image偏移:%.3f 偏移系数(值)：%.3f  \n %@" ,selfCenterX  ,NSStringFromCGPoint( windowCenter) ,selfOffsetX , - selfOffsetX * value, NSStringFromCGRect(self.bounds));
    self.contentIMG.transform = transX;
}

static inline UIView * YYBannerContentView_getConvertView(UIView * view){
    UIView * superView = view.superview.superview;
    if(superView){
        return superView;
    }else{
        return view.window;
    }
}
@end
