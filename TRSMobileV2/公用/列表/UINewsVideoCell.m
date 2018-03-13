//
//  UINewsAudioCell.m
//  TRSMobileV2
//
//  Created by  TRS on 16/5/24.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UINewsVideoCell.h"
#import "Globals.h"

@implementation UINewsVideoCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self setup];
}

- (void) setup {

    self.contentView.backgroundColor = [UIColor colorWithRGB:0xeeeeee alpha:0.6];
    self.imagePic1.clipsToBounds = YES;
    self.imagePic1.contentMode = UIViewContentModeScaleAspectFill;
    self.labelTitle.font = [UIFont systemFontOfSize:17.0];
    self.labelSource1.font = [UIFont systemFontOfSize:13.0];
    self.labelSource1.backgroundColor = [UIColor colorRandomWithAlpha:1.0];
    self.labelDuration.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    [self.buttonPlay setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0.0 alpha:0.6] cornerRadius:0] forState:UIControlStateNormal];
    [self.buttonPlay addTarget:self action:@selector(didPlaySelect) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonPlay setCornerWithRadius:CGRectGetHeight(self.buttonPlay.frame)/2.0];
    [self.labelDuration setCornerWithRadius:CGRectGetHeight(self.labelDuration.frame)/2.0];
    [self.imageSource setCornerWithRadius:CGRectGetHeight(self.imageSource.frame)/2.0];
    [self.labelSource1 setCornerWithRadius:CGRectGetHeight(self.imageSource.frame)/2.0];
    [self.buttonComment setImage:[UIImage imageNamed:@"normal.bundle/评论.png"] forState:UIControlStateNormal];
    [self.buttonShare setImage:[UIImage imageNamed:@"normal.bundle/更多_灰.png"] forState:UIControlStateNormal];
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.contentView bottomMargin:0];
}

- (void)didPlaySelect {

    if(self.clickEvent){self.clickEvent(self.dict, 0);}
}

- (void)updateCell {

    //--->设置列表cell界面显示数据
    BOOL isVideo = ([self.dict[@"channelType"] integerValue] == 4);
    
    self.labelTitle.text = [self.dict objectForVitualKey:@"title"];
    self.labelSource1.text = (self.labelTitle.text.length > 1) ? [self.labelTitle.text substringToIndex:1] : @"";
    self.labelSource.text = @"中国西藏新闻网";
    [_buttonComment setTitle:@"1289" forState:UIControlStateNormal];
    if(isVideo) {
        [self.buttonPlay setImage:[UIImage imageNamed:@"normal.bundle/视频_图标.png"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonPlay setImage:[UIImage imageNamed:@"normal.bundle/音乐_图标.png"] forState:UIControlStateNormal];
    }
    
    if(self.dict[@"RelVideo"]
       && [self.dict[@"RelVideo"] isKindOfClass:[NSArray class] ]
       && [self.dict[@"RelVideo"] count]) {
        NSDictionary *relvideo = [self.dict[@"RelVideo"] firstObject];
        self.labelDuration.text = [NSString videoPlayTimeValue:[relvideo[@"duration"] doubleValue] ];
    }
    
    NSArray *images = self.dict[@"RelPhoto"];
    if(images.count  > 0) {
        [self.imagePic1 setUIImageWithURL:images[0][@"picurl"]
                         placeholderImage:[UIImage imageNamed:@"normal.bundle/图片_大.png"]
                                completed:nil];
    }
}

@end
