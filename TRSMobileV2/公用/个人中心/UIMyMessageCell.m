//
//  UIMyMessageCell.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/30.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIMyMessageCell.h"
#import "Globals.h"

@implementation UIMyMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
        [self setCellLayout];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setup {
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _imagePic1 = [[UIImageView alloc] init];
    _imagePic1.clipsToBounds = YES;
    _imagePic1.contentMode = UIViewContentModeScaleAspectFit;
    _imagePic1.backgroundColor = [UIColor colorWithRGB:UIColorImageBackgrond];
    [self.contentView addSubview:_imagePic1];
    
    _labelType = [[UILabel alloc] init];
    _labelType.backgroundColor = [UIColor clearColor];
    _labelType.textColor = [UIColor lightGrayColor];
    _labelType.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:_labelType];
    
    _labelContent = [[UILabel alloc] init];
    _labelContent.backgroundColor = [UIColor clearColor];
    _labelContent.textColor = [UIColor blackColor];
    _labelContent.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_labelContent];
    
    _labelDate = [[UILabel alloc] init];
    _labelDate.backgroundColor = [UIColor clearColor];
    _labelDate.textAlignment = NSTextAlignmentRight;
    _labelDate.textColor = [UIColor lightGrayColor];
    _labelDate.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:_labelDate];
    
    _viewLine = [[UIView alloc] init];
    _viewLine.backgroundColor = [UIColor colorWithRGB:0x6e6e6e alpha:0.3];
    [self.contentView addSubview:_viewLine];
}

- (void)setCellLayout
{
    //设置约束
    CGFloat margin = 8.0;
    
    _imagePic1.sd_layout
    .centerYEqualToView(self.contentView)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(4.0)
    .heightIs(4.0);
    
    _labelType.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(_imagePic1, margin)
    .widthIs(200.0)
    .heightIs(21.0);
    
    _labelDate.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(_imagePic1, margin)
    .rightSpaceToView(self.contentView, margin)
    .heightIs(21.0);
    
    _labelContent.sd_layout
    .topSpaceToView(_labelType, margin)
    .leftSpaceToView(_imagePic1, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0);
    
    _viewLine.sd_layout
    .topSpaceToView(_labelContent, 8.0)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .heightIs(0.5);
    
    [_imagePic1 setCornerWithRadius:CGRectGetHeight(_imagePic1.frame)/2.0];
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)updateCell {
    
    //--->设置列表cell界面显示数据
    _labelType.text = self.dict[@"type"];
    _labelContent.text = self.dict[@"content"];
    _labelDate.text = [NSString timeValue:self.dict[@"date"] ];
    _imagePic1.image = [UIImage imageWithColor:([self.dict[@"unRead"] boolValue] ? [UIColor redColor] : [UIColor lightGrayColor]) cornerRadius:0];
}

@end
