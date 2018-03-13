//
//  UIAdsCell.m
//  TRSMobileV2
//
//  Created by  TRS on 16/4/27.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UINewsAdsCell.h"
#import "Globals.h"

@implementation UINewsAdsCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
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
    
    self.imagePic1.sd_layout
    .topSpaceToView(self.contentView, 0)
    .bottomSpaceToView(self.contentView, 0)
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0);
}

- (void)updateCell {
    
    NSArray *images = self.dict[@"RelPhoto"];
    [self.imagePic1 setUIImageWithURL:images[0][@"picurl"]
                     placeholderImage:[UIImage imageNamed:@"normal.bundle/图片_大.png"]
                            completed:nil];
}

@end
