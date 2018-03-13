//
//  UINewsCell.m
//  TRSMobileV2
//
//  Created by  TRS on 16/4/27.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UINewsCell.h"
#import "Globals.h"

@interface UINewsCell () {
    
    //分割线高度
    CGFloat vLineH;
    
    //约束间距
    CGFloat margin;
    
    //默认小图片的宽度
    CGFloat widthSmallPic;
}

@end

@implementation UINewsCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        vLineH = 0.5;
        margin = 8.0;
        widthSmallPic = ([[UIScreen mainScreen] currentMode].size.width == 640.0 ? 96.0 : 120.0);
        
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setup {

    _imagePic1 = [UIImageView new];
    _imagePic1.clipsToBounds = YES;
    _imagePic1.contentMode = UIViewContentModeScaleAspectFill;
    _imagePic1.backgroundColor = [UIColor colorWithRGB:UIColorImageBackgrond];
    [self.contentView addSubview:_imagePic1];
    
    _imagePic2 = [UIImageView new];
    _imagePic2.clipsToBounds = YES;
    _imagePic2.contentMode = UIViewContentModeScaleAspectFill;
    _imagePic2.backgroundColor = [UIColor colorWithRGB:UIColorImageBackgrond];
    [self.contentView addSubview:_imagePic2];
    
    _imagePic3 = [UIImageView new];
    _imagePic3.clipsToBounds = YES;
    _imagePic3.contentMode = UIViewContentModeScaleAspectFill;
    _imagePic3.backgroundColor = [UIColor colorWithRGB:UIColorImageBackgrond];
    [self.contentView addSubview:_imagePic3];
    
    _labelTitle = [UILabel new];
    _labelTitle.numberOfLines = 2;
    _labelTitle.font = [UIFont systemFontOfSize:17.0];
    [self.contentView addSubview:_labelTitle];
    
    _labelSource = [UILabel new];
    _labelSource.font = [UIFont systemFontOfSize:15.0];
    _labelSource.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_labelSource];
    
    _labelComment = [UILabel new];
    _labelComment.font = [UIFont systemFontOfSize:15.0];
    _labelComment.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_labelComment];
    
    _labelDate = [UILabel new];
    _labelDate.font = [UIFont systemFontOfSize:15.0];
    _labelDate.textColor = [UIColor darkGrayColor];
    _labelDate.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_labelDate];
    
    _viewLine = [UIView new];
    _viewLine.backgroundColor = [UIColor colorWithRGB:0x6e6e6e alpha:0.3];
    [self.contentView addSubview:_viewLine];
}

#pragma mark -
- (void)cellMutilStyleLayout:(docType)style {
    
    switch (style) {
        case docTypeNormalPicRight:
            [self cellNormalPicRightLayout];
            break;
        case docTypeNormal:
            [self cellNormalPicNoneLayout];
            break;
        case docTypeImagesLargeFix:
            [self cellImagesLargeFixLayout];
            break;
        case docTypeImagesLargeAuto:
            [self cellImagesLargeAutoLayout];
            break;
        case docTypeImages2Equal:
            [self cellImages2EqualWidthLayout];
            break;
        case docTypeImages3Equal:
            [self cellImages3EqualWidthLayout];
            break;
        case docTypeImagesLeft2Small:
            [self cellImages3Left2SmallLayout];
            break;
        case docTypeImagesRight2Small:
            [self cellImages3Right2SmallLayout];
            break;
        default:
            [self cellNormalLayout];
            break;
    }
}

- (void)cellNormalLayout {

    //设置约束
    self.imagePic1.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(widthSmallPic)
    .autoHeightRatio(0.75);
    
    self.labelTitle.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.imagePic1 , margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0)
    .maxHeightIs(48.0);
    
    self.labelSource.sd_layout
    .leftSpaceToView(self.imagePic1, margin)
    .bottomSpaceToView(self.contentView, margin)
    .heightIs(21.0)
    .maxWidthIs(120.0);
    
    self.labelDate.sd_layout
    .bottomSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .heightIs(21.0)
    .widthIs(120.0);
    
    self.viewLine.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .heightIs(vLineH);

    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)cellNormalPicNoneLayout {
    
    //设置约束
    self.imagePic1.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(0)
    .heightIs(widthSmallPic * 0.75);
    
    self.labelTitle.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0)
    .maxHeightIs(60);
    
    self.labelSource.sd_layout
    .bottomSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .heightIs(21.0)
    .widthIs(120.0);
    
    self.labelDate.sd_layout
    .bottomSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .heightIs(21.0)
    .widthIs(160.0);
    
    self.viewLine.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .leftSpaceToView(self.contentView,0)
    .rightSpaceToView(self.contentView,0)
    .heightIs(vLineH);
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)cellNormalPicRightLayout {

    //设置约束
    self.imagePic1.sd_layout
    .topSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .widthIs(widthSmallPic)
    .autoHeightRatio(0.75);
    
    self.labelTitle.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.imagePic1, margin)
    .autoHeightRatio(0)
    .maxHeightIs(60);
    
    self.labelSource.sd_layout
    .bottomSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .heightIs(21.0)
    .widthIs(120.0);
    
    self.labelDate.sd_layout
    .bottomSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.imagePic1, margin)
    .heightIs(21.0)
    .widthIs(120.0);

    self.viewLine.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .leftSpaceToView(self.contentView,0)
    .rightSpaceToView(self.contentView,0)
    .heightIs(vLineH);
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)cellImagesLargeFixLayout {
    
    //设置约束
    self.labelTitle.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0);
    
    self.imagePic1.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .heightIs(widthSmallPic  * 0.75);
    
    self.labelSource.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.labelDate.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .rightSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.viewLine.sd_layout
    .topSpaceToView(self.labelSource, margin)
    .leftSpaceToView(self.contentView,0)
    .rightSpaceToView(self.contentView,0)
    .heightIs(vLineH);
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)cellImagesLargeAutoLayout {
    
    //设置约束
    self.labelTitle.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0);
    
    self.imagePic1.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .heightIs(widthSmallPic * 0.75 * 2 + margin/4);
    
    self.labelSource.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.labelDate.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .rightSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.viewLine.sd_layout
    .topSpaceToView(self.labelSource, margin)
    .leftSpaceToView(self.contentView,0)
    .rightSpaceToView(self.contentView,0)
    .heightIs(vLineH);
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)cellImages2EqualWidthLayout {

    //设置约束
    self.contentView.sd_equalWidthSubviews = @[self.imagePic1, self.imagePic2];
    
    self.labelTitle.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0);
    
    self.imagePic1.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.contentView, margin)
    .autoHeightRatio(0.75);
    
    self.imagePic2.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.imagePic1, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0.75);
    
    self.labelSource.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.labelDate.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .rightSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.viewLine.sd_layout
    .topSpaceToView(self.labelSource, margin)
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .heightIs(vLineH);
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)cellImages3EqualWidthLayout {

    //设置约束
    self.contentView.sd_equalWidthSubviews = @[self.imagePic1, self.imagePic2, self.imagePic3];
    
    self.labelTitle.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0);
    
    self.imagePic1.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.contentView, margin)
    .autoHeightRatio(0.75);
    
    self.imagePic2.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.imagePic1, margin)
    .autoHeightRatio(0.75);
    
    self.imagePic3.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.imagePic2, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0.75);
    
    self.labelSource.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.labelDate.sd_layout
    .topSpaceToView(self.imagePic1, margin)
    .rightSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.viewLine.sd_layout
    .topSpaceToView(self.labelSource, margin)
    .rightSpaceToView(self.contentView,0)
    .leftSpaceToView(self.contentView,0)
    .heightIs(vLineH);
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)cellImages3Left2SmallLayout {

    //设置约束
    self.labelTitle.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0);
    
    self.imagePic1.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(widthSmallPic)
    .autoHeightRatio(0.75);
    
    self.imagePic2.sd_layout
    .topSpaceToView(self.imagePic1, margin/4)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(widthSmallPic)
    .autoHeightRatio(0.75);
    
    self.imagePic3.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.imagePic1, margin/4)
    .rightSpaceToView(self.contentView, margin)
    .heightIs(widthSmallPic * 0.75 * 2 + margin/4);
    
    self.labelSource.sd_layout
    .topSpaceToView(self.imagePic3, margin)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.labelDate.sd_layout
    .topSpaceToView(self.imagePic3, margin)
    .rightSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.viewLine.sd_layout
    .topSpaceToView(self.labelSource, margin)
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .heightIs(vLineH);
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)cellImages3Right2SmallLayout {

    //设置约束
    self.labelTitle.sd_layout
    .topSpaceToView(self.contentView, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0);
    
    self.imagePic1.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.contentView, margin)
    .rightSpaceToView(self.contentView, margin + widthSmallPic + margin/4)
    .heightIs(widthSmallPic * 0.75 * 2 + margin/4);
    
    self.imagePic2.sd_layout
    .topSpaceToView(self.labelTitle, margin)
    .leftSpaceToView(self.imagePic1, margin/4)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0.75);
    
    self.imagePic3.sd_layout
    .topSpaceToView(self.imagePic2, margin/4)
    .leftSpaceToView(self.imagePic1, margin/4)
    .rightSpaceToView(self.contentView, margin)
    .autoHeightRatio(0.75);
    
    self.labelSource.sd_layout
    .topSpaceToView(self.imagePic3, margin)
    .leftSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.labelDate.sd_layout
    .topSpaceToView(self.imagePic3, margin)
    .rightSpaceToView(self.contentView, margin)
    .widthIs(160.0)
    .heightIs(21.0);
    
    self.viewLine.sd_layout
    .topSpaceToView(self.labelSource, margin)
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .heightIs(vLineH);
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

#pragma mark -
- (void)updateCell {

    //--->设置列表cell界面显示数据
    self.labelTitle.text = [self.dict objectForVitualKey:@"title"];
    self.labelSource.text = [self.dict objectForKey:@"source"];
    self.labelDate.text = [NSString timeValue:self.dict[@"PubDate"] ];
    
    NSArray *images = self.dict[@"RelPhoto"];
    if(images.count  > 2) {
        [self.imagePic3 setUIImageWithURL:images[2][@"picurl"]
                         placeholderImage:[UIImage imageNamed:@"normal.bundle/图片_小.png"]
                                completed:nil];
    }
    else {
        [self.imagePic3 setImage:nil];
    }

    if(images.count  > 1) {
        [self.imagePic2 setUIImageWithURL:images[1][@"picurl"]
                         placeholderImage:[UIImage imageNamed:@"normal.bundle/图片_小.png"]
                                completed:nil];
    }
    else {
        [self.imagePic2 setImage:nil];
    }

    if(images.count  > 0) {
        [self.imagePic1 setUIImageWithURL:images[0][@"picurl"]
                         placeholderImage:[UIImage imageNamed:@"normal.bundle/图片_小.png"]
                                completed:nil];
    }
    else {
        [self.imagePic1 setImage:nil];
    }
}

@end

@implementation UINewsNormalCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //--->获取列表cell所需要的样式
        [self cellMutilStyleLayout:docTypeNormalPicLeft];
    }
    return self;
}

- (void)updateCell {
    
    //--->设置列表cell界面显示数据
    [super updateCell];
}

@end


@implementation UINewsImagesCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //--->获取列表cell所需要的样式
        [self cellMutilStyleLayout:docTypeImages3Equal];
    }
    return self;
}

- (void)updateCell {
    
    //--->设置列表cell界面显示数据
    [super updateCell];
}

@end


@implementation UINewsLargeImageCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //--->获取列表cell所需要的样式
        self.imagePic1.contentMode = UIViewContentModeScaleAspectFill;
        [self cellMutilStyleLayout:docTypeImagesLargeAuto];
    }
    return self;
}

- (void)updateCell {
    
    //--->设置列表cell界面显示数据
    [super updateCell];
}

@end


@implementation UINewsPhotoCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //--->获取列表cell所需要的样式
        docType cellType = arc4random() % 3 + docTypeImagesLargeAuto;
        [self cellMutilStyleLayout:cellType];
    }
    return self;
}

- (void)updateCell {
    
    //--->设置列表cell界面显示数据
    [super updateCell];
}

@end


