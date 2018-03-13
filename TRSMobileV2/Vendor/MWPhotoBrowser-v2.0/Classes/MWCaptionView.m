//
//  MWCaptionView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MWCommon.h"
#import "MWCaptionView.h"
#import "MWPhoto.h"
#import "SDAutoLayout.h"

static const CGFloat labelPadding = 10;

// Private
@interface MWCaptionView () {
    UILabel *_label;
    UITextView *_label2;
}
@end

@implementation MWCaptionView

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 160.0)]; // Random initial frame
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupCaption];
    }
    return self;
}

- (void)setupCaption {
    _label = [UILabel new];
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentLeft;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:15];
    [self addSubview:_label];
    
    _label2 = [UITextView new];
    _label2.opaque = NO;
    _label2.editable = NO;
    _label2.backgroundColor = [UIColor clearColor];
    _label2.textAlignment = NSTextAlignmentLeft;
    _label2.textColor = [UIColor whiteColor];
    _label2.font = [UIFont systemFontOfSize:13];
    [self addSubview:_label2];
    
    _label.sd_layout.xIs(labelPadding).yIs(labelPadding).widthIs(self.bounds.size.width - 2 *labelPadding).heightIs(21);
    _label2.sd_layout.leftSpaceToView(self, labelPadding).topSpaceToView(_label, 0).rightSpaceToView(self, labelPadding).bottomSpaceToView(self, labelPadding);
}

- (void)setDict:(NSDictionary *)dict {

    _label.text = dict[@"title"];
    _label2.text = dict[@"caption"];
}


@end
