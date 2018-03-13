//
//  UIFont+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/18.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UILabel+Extension.h"
#import "NSNotification+Extension.h"
#import "UIFont+Provider.h"

@implementation UILabel (Extension)

+ (void)changeLineSpaceForLabel:(UILabel * _Nonnull)label WithSpace:(float)space {
    
    NSString *labelText = label.text;
    if(!labelText) return;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    label.attributedText = attributedString;
    [label sizeToFit];
    
}

+ (void)changeWordSpaceForLabel:(UILabel * _Nonnull)label WithSpace:(float)space {
    
    NSString *labelText = label.text;
    if(!labelText) return;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(space)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    label.attributedText = attributedString;
    [label sizeToFit];
    
}

+ (void)changeSpaceForLabel:(UILabel * _Nonnull)label withLineSpace:(float)lineSpace WordSpace:(float)wordSpace {
    
    NSString *labelText = label.text;
    if(!labelText) return;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(wordSpace)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    label.attributedText = attributedString;
    [label sizeToFit];
}

- (instancetype) init {
    
    if(self = [super init]) {
        
        addNotificationObserver(self, @selector(didUIFontChange), didUIFontChangeNotification, nil);
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    addNotificationObserver(self, @selector(didUIFontChange), didUIFontChangeNotification, nil);
}

- (void)addDidFontChangeObserver {
    
    addNotificationObserver(self, @selector(didUIFontChange), didUIFontChangeNotification, nil);
}

- (void) didUIFontChange {
    
    [self setFont:[UIFont systemFontOfSize:self.font.pointSize] ];
}

@end

@implementation UIButton (Extension)

- (void)addDidFontChangeObserver {

    addNotificationObserver(self, @selector(didUIFontChange), didUIFontChangeNotification, nil);
}

- (void) didUIFontChange {
    
    [self.titleLabel setFont:[UIFont systemFontOfSize:self.titleLabel.font.pointSize] ];
}

@end
