//
//  UINewsGridCell.m
//  TRSMobileV2
//
//  Created by  TRS on 16/5/16.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UINewsGridCell.h"
#import "Globals.h"

@implementation UINewsGridCell

- (instancetype)initWithFrame:(CGRect)frame {

    if(self = [super initWithFrame:frame]) {
        
        //--->设置cell界面显示样式
        [self setup];
    }
    return self;
}

- (void)setup {
    
    _imagePic1 = [UIImageView new];
    _imagePic1.clipsToBounds = YES;
    _imagePic1.contentMode = UIViewContentModeScaleAspectFill;
    _imagePic1.backgroundColor = [UIColor colorWithRGB:UIColorImageBackgrond];
    [self.contentView addSubview:_imagePic1];
    
    _imagePic1.sd_layout
    .topSpaceToView(self.contentView, 0)
    .bottomSpaceToView(self.contentView, 0)
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0);
}

- (void)updateCell {
    
    //--->设置列表cell界面显示数据
    NSArray *images = self.dict[@"RelPhoto"];
    if(images.count  > 0) {
        [self.imagePic1 setUIImageWithURL:images[0][@"picurl"]
                         placeholderImage:[UIImage imageNamed:@"normal.bundle/图片_小.png"]
                                completed:nil];
    }
}

@end
