//
//  UINewsAudioCell.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/7.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UINewsAudioCell.h"
#import "Globals.h"

@implementation UINewsAudioCell

- (void)awakeFromNib {

    [super awakeFromNib];
    [self setup];
}

- (void) setup {
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.imagePic1.clipsToBounds = YES;
    self.labelTitle.font = [UIFont systemFontOfSize:17.0];
    self.labelSource.font = [UIFont systemFontOfSize:13.0];
    self.labelDuration.font = [UIFont systemFontOfSize:11.0];
    self.labelPlayCount.font = [UIFont systemFontOfSize:13.0];
    self.labelDuration.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    self.viewLine.backgroundColor = [UIColor colorWithRGB:0x6e6e6e alpha:0.3];
    [self.buttonPlay setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0.0 alpha:0.6] cornerRadius:0] forState:UIControlStateNormal];
    [self.buttonPlay setImage:[UIImage imageNamed:@"normal.bundle/音乐_图标.png"] forState:UIControlStateNormal];
    [self.buttonPlay addTarget:self action:@selector(didPlaySelect) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonPlay setCornerWithRadius:CGRectGetHeight(self.buttonPlay.frame)/2.0];

    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    [self setupAutoHeightWithBottomView:self.viewLine bottomMargin:0];
}

- (void)didPlaySelect {
    
    if(self.clickEvent){self.clickEvent(self.dict, 0);}
}

- (void)updateCell {
    
    //--->设置列表cell界面显示数据
    self.labelTitle.text = [self.dict objectForVitualKey:@"title"];
    
    if(self.dict[@"RelVideo"]
       && [self.dict[@"RelVideo"] isKindOfClass:[NSArray class] ]
       && [self.dict[@"RelVideo"] count]) {
        NSDictionary *relvideo = [self.dict[@"RelVideo"] firstObject];
        self.labelDuration.text = [NSString videoPlayTimeValue:[relvideo[@"duration"] doubleValue] ];
    }
    
    NSArray *images = self.dict[@"RelPhoto"];
    if(images.count  > 0) {
        [self.imagePic1 setUIImageWithURL:images[0][@"picurl"]
                         placeholderImage:[UIImage imageNamed:@"normal.bundle/图片_小.png"]
                                completed:nil];
    }
}

@end
