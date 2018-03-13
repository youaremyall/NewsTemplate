//
//  UICommentCell.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/5/26.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UICommentCell.h"
#import "Globals.h"

@implementation UICommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup {

    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _imagePic1 = [[UIImageView alloc] init];
    _imagePic1.clipsToBounds = YES;
    _imagePic1.contentMode = UIViewContentModeScaleAspectFit;
    _imagePic1.backgroundColor = [UIColor colorWithRGB:UIColorImageBackgrond];
    [self.contentView addSubview:_imagePic1];
    
    _labelNick = [[UILabel alloc] init];
    _labelNick.backgroundColor = [UIColor clearColor];
    _labelNick.textColor = [UIColor lightGrayColor];
    _labelNick.font = [UIFont systemFontOfSize:17.0];
    [self.contentView addSubview:_labelNick];
    
    _labelDate = [[UILabel alloc] init];
    _labelDate.backgroundColor = [UIColor clearColor];
    _labelDate.textColor = [UIColor lightGrayColor];
    _labelDate.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_labelDate];

    _labelContent = [[UILabel alloc] init];
    _labelContent.backgroundColor = [UIColor clearColor];
    _labelContent.textColor = [UIColor blackColor];
    _labelContent.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:_labelContent];

    UIImage *imgLike = [UIImage imageNamed:@"normal.bundle/点赞.png"];
    _buttonLike = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonLike.hidden = YES;
    _buttonLike.backgroundColor = [UIColor clearColor];
    _buttonLike.contentMode = UIViewContentModeRight;
    [_buttonLike.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [_buttonLike setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_buttonLike setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [_buttonLike setImage:imgLike forState:UIControlStateNormal];
    [_buttonLike setImage:[imgLike colorImage:[UIColor colorWithRGB:UIColorThemeDefault]] forState:UIControlStateSelected];
    [self.contentView addSubview:_buttonLike];
    
    _viewExtension = [UIView new];
    _viewExtension.backgroundColor = [UIColor colorWithRGB:0xeeeeee alpha:1.0];
    [self.contentView addSubview:_viewExtension];
    
    _imagePic2 = [[UIImageView alloc] init];
    _imagePic2.clipsToBounds = YES;
    _imagePic2.contentMode = UIViewContentModeScaleAspectFit;
    _imagePic2.backgroundColor = [UIColor colorWithRGB:UIColorImageBackgrond];
    [_viewExtension addSubview:_imagePic2];
    
    _labelTitle = [[UILabel alloc] init];
    _labelTitle.backgroundColor = [UIColor clearColor];
    _labelTitle.textColor = [UIColor blackColor];
    _labelTitle.font = [UIFont systemFontOfSize:15.0];
    _labelTitle.numberOfLines = 0;
    [_viewExtension addSubview:_labelTitle];
    
    _viewLine = [[UIView alloc] init];
    _viewLine.backgroundColor = [UIColor colorWithRGB:0x6e6e6e alpha:0.3];
    [self.contentView addSubview:_viewLine];
}

- (void)setCellLayout
{
    //设置约束
    CGFloat margin = 20.0;
    
    _imagePic1.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(36.0)
    .heightIs(36.0);

    _buttonLike.sd_layout
    .topSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .widthIs(60)
    .heightIs(30);

    _labelNick.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(_imagePic1, margin)
    .rightSpaceToView(self.contentView, margin)
    .heightIs(21.0);
    
    _labelDate.sd_layout
    .topSpaceToView(_labelNick, 0)
    .leftSpaceToView(_imagePic1, margin)
    .rightSpaceToView(_buttonLike, margin)
    .heightIs(21.0);
    
    _labelContent.sd_layout
    .topSpaceToView(_labelDate, 0)
    .leftSpaceToView(_imagePic1, margin)
    .rightSpaceToView(self.contentView, margin)
    .minHeightIs(30)
    .autoHeightRatio(0);
    
    if(_isMyComment) {
    
        _viewExtension.sd_layout
        .topSpaceToView(_labelContent, 8.0)
        .leftSpaceToView(_imagePic1, margin)
        .rightSpaceToView(self.contentView, margin)
        .heightIs(60.0);
        
        _imagePic2.sd_layout
        .topSpaceToView(_viewExtension, 0)
        .bottomSpaceToView(_viewExtension, 0)
        .leftSpaceToView(_viewExtension, 0)
        .widthIs(60.0);
        
        _labelTitle.sd_layout
        .topSpaceToView(_viewExtension, 0)
        .bottomSpaceToView(_viewExtension, 0)
        .leftSpaceToView(_imagePic2, 8.0)
        .rightSpaceToView(_viewExtension, 8.0);

        _viewLine.sd_layout
        .topSpaceToView(_viewExtension, margin)
        .leftSpaceToView(self.contentView, margin)
        .rightSpaceToView(self.contentView, margin)
        .heightIs(0.5);
    }
    else {
        _viewLine.sd_layout
        .topSpaceToView(_labelContent, 8.0)
        .leftSpaceToView(self.contentView, margin)
        .rightSpaceToView(self.contentView, margin)
        .heightIs(0.5);
    }
    
    [_imagePic1 setCornerWithRadius:CGRectGetHeight(_imagePic1.frame)/2.0];
    [_buttonLike setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)updateCell {

    //--->设置列表cell界面布局
    [self setCellLayout];

    //--->设置列表cell界面显示数据
    _labelContent.text = self.avObject[@"content"];
    _labelDate.text = [NSString timeValue:[NSDate dateStringByDate:self.avObject[@"createdAt" ] format:@"YYYY-MM-dd HH:mm:ss"] ];

    //是否匿名评论
    BOOL isUserHide = [self.avObject[@"isUserHide"] boolValue];
    if(!isUserHide) {
        _labelNick.text = [self.avObject[@"user"] objectForKey:@"nickname"];
        
        NSString *avatar = [self.avObject[@"user"] objectForKey:@"avatar"];
        [self.imagePic1 setUIImageWithURL:avatar
                         placeholderImage:[UIImage imageNamed:@"normal.bundle/图片_小.png"]
                                completed:nil];
    }
    else {
        _labelNick.text = @"匿名用户";
        [self.imagePic1 setImage:[UIImage imageNamed:@"normal.bundle/评论头像.png"] ];
    }
    
    //我的评论(原文相关信息)
    if(_isMyComment) {
        NSDictionary *docValue = self.avObject[@"docValue"];
        _labelTitle.text = [docValue objectForVitualKey:@"title"];
        NSArray *images = docValue[@"RelPhoto"];
        if(images.count  > 0) {
            [self.imagePic2 setUIImageWithURL:images[0][@"picurl"]
                             placeholderImage:[UIImage imageNamed:@"normal.bundle/图片_小.png"]
                                    completed:nil];
        }
    }
}

@end
