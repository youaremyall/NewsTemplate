//
//  TodayCell.m
//  TRSMobileV2
//
//  Created by 廖靖宇 on 2017/6/17.
//  Copyright © 2017年  liaojingyu. All rights reserved.
//

#import "TodayCell.h"
#import "UIImageView+WebCache.h"
#import "SDAutoLayout.h"

@interface TodayCell  ()

@property (strong, nonatomic) UILabel   *labelTitle;
@property (strong, nonatomic) UILabel   *labelSource;
@property (strong, nonatomic) UILabel   *labelTime;
@property (strong, nonatomic) NSMutableArray *arrImages;

@end

@implementation TodayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        // 标题
        _labelTitle = [UILabel new];
        _labelTitle.font = [UIFont systemFontOfSize:15.0];
        _labelTitle.textColor = [UIColor blackColor];
        _labelTitle.numberOfLines = 2;
        [self.contentView addSubview:_labelTitle];

        // 来源
        _labelSource = [UILabel new];
        _labelSource.textAlignment = NSTextAlignmentLeft;
        _labelSource.font = [UIFont systemFontOfSize:13.0];
        _labelSource.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_labelSource];

        // 时间
        _labelTime = [UILabel new];
        _labelTime.textAlignment = NSTextAlignmentRight;
        _labelTime.font = [UIFont systemFontOfSize:13.0];
        _labelTime.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_labelTime];

        // 配图
        _arrImages = [NSMutableArray arrayWithCapacity:0];
        for(NSInteger i = 0; i < 3; i++) {
            UIImageView *imageView = [UIImageView new];
            imageView.tag = i;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.hidden = YES;
            [self.contentView addSubview:imageView];
            [_arrImages addObject:imageView];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)updateCell {

    _labelTitle.text = _dict[@"MetaDataTitle"];
    _labelSource.text = _dict[@"source"];
    _labelTime.text = _dict[@"PubDate"];
    if(_labelTime.text.length > 16) {
        _labelTime.text = [_labelTime.text substringWithRange:NSMakeRange(5, 11)]; //截取日期和分钟
    }
    
    NSArray *images = _dict[@"RelPhoto"];
    NSInteger total = images.count;
    if(total>= 1) { //左侧图片模式
        
        UIImageView *imageView = _arrImages[0];
        imageView.hidden = NO;
        [imageView sd_setImageWithURL:[NSURL URLWithString:images[0][@"picurl"] ] placeholderImage:nil completed:nil];

        imageView.sd_layout.topSpaceToView(self.contentView, 10.0).heightIs(80.0).leftSpaceToView(self.contentView, 10.0).widthIs(80.0 * 3/2.0);
        _labelTitle.sd_layout.topSpaceToView(self.contentView, 10.0).leftSpaceToView(imageView, 10.0).rightSpaceToView(self.contentView, 10.0).autoHeightRatio(0).maxHeightIs(48);
        _labelTime.sd_layout.bottomEqualToView(imageView).rightSpaceToView(self.contentView, 10.0).widthIs(100.0).heightIs(21.0);
        _labelSource.sd_layout.centerYEqualToView(_labelTime).leftSpaceToView(imageView, 10.0).rightSpaceToView(_labelTime, 8.0).heightIs(21.0);
    }
    else { //纯文字模式
        
        _labelTitle.sd_layout.topSpaceToView(self, 10.0).leftSpaceToView(self, 10.0).rightSpaceToView(self, 10.0).autoHeightRatio(0).maxHeightIs(48);
        _labelSource.sd_layout.topSpaceToView(_labelTitle, 10.0).leftEqualToView(_labelTitle).widthIs(60.0).heightIs(21.0);
        _labelTime.sd_layout.centerYEqualToView(_labelSource).leftSpaceToView(_labelSource, 8.0).rightSpaceToView(self.contentView, 10.0).heightIs(21.0);
    }
}

@end
