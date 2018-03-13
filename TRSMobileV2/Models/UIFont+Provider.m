//
//  UIFont+Provider.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/5/26.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <objc/runtime.h>
#import "UIFont+Provider.h"
#import "NSUserDefaults+Extension.h"

NSString *const UIFontSystemName = @"PingFangSC-Regular";
NSString *const didUIFontChangeNotification = @"didUIFontChange";

@interface UIFont (UIFont_Extension)


@end

@implementation UIFont (UIFont_Extension)

+ (void)setFontName:(NSString *)fontName {

    objc_setAssociatedObject(self, @"fontName_", fontName, OBJC_ASSOCIATION_COPY);
}

+ (NSString *)fontName {

    return objc_getAssociatedObject(self, @"fontName_");
}

+ (UIFont *) replacement_systemFontOfSize:(CGFloat)fontSize {
    
    return [UIFont fontWithName:self.fontName size:fontSize];
}

+ (UIFont *) replacement_boldSystemFontOfSize:(CGFloat)fontSize {
    
    return [UIFont fontWithName:self.fontName size:fontSize];
}

+ (UIFont *) replacement_italicSystemFontOfSize:(CGFloat)fontSize {
    
    return [UIFont fontWithName:self.fontName size:fontSize];
}

@end

#pragma mark -

@interface UIFontProvider ()

@end

@implementation UIFontProvider

+ (void) load {
    
    [self performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:YES];
}

+ (instancetype) sharedInstance {

    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype) init {

    if((self = [super init])) {
        
        //NSString *fontPath = [NSUserDefaults settingValueForType:SettingTypeFontFamily];
        NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"隶变-简" ofType:@"ttc"];
        (fontPath.pathExtension == nil) ? [self resetFont] : [self setFontPath:fontPath];
        
        [self performSelectorInBackground:@selector(replacement_systemFont) withObject:nil];
    }
    return self;
}

/**
 * 交换系统定义方法与自定义方法的实现
 */
- (void) replacement_systemFont {
    
    Method systemFontOfSize_ = class_getClassMethod([UIFont class], @selector(systemFontOfSize:));
    Method replacementSystemFontOfSize_ = class_getClassMethod([UIFont class], @selector(replacement_systemFontOfSize:));
    if (systemFontOfSize_ && replacementSystemFontOfSize_
        && strcmp(method_getTypeEncoding(systemFontOfSize_), method_getTypeEncoding(replacementSystemFontOfSize_)) == 0)
        method_exchangeImplementations(systemFontOfSize_, replacementSystemFontOfSize_);
    
    Method boldSystemFontOfSize_ = class_getClassMethod([UIFont class], @selector(boldSystemFontOfSize:));
    Method replacementBoldSystemFontOfSize_ = class_getClassMethod([UIFont class], @selector(replacement_boldSystemFontOfSize:));
    if (boldSystemFontOfSize_ && replacementBoldSystemFontOfSize_
        && strcmp(method_getTypeEncoding(boldSystemFontOfSize_), method_getTypeEncoding(replacementBoldSystemFontOfSize_)) == 0)
        method_exchangeImplementations(boldSystemFontOfSize_, replacementBoldSystemFontOfSize_);
    
    Method italicSystemFontOfSize_ = class_getClassMethod([UIFont class], @selector(italicSystemFontOfSize:));
    Method replacementItalicSystemFontOfSize_ = class_getClassMethod([UIFont class], @selector(replacement_italicSystemFontOfSize:));
    if (italicSystemFontOfSize_ && replacementItalicSystemFontOfSize_
        && strcmp(method_getTypeEncoding(italicSystemFontOfSize_), method_getTypeEncoding(replacementItalicSystemFontOfSize_)) == 0)
        method_exchangeImplementations(italicSystemFontOfSize_, replacementItalicSystemFontOfSize_);
}

/**
 * 根据字体文件路径获取字体
 * 对于TTF、OTF的字体都有效，但是对于TTC字体，只取出了一种字体。
 */
- (UIFont *)fontWithPath:(NSString*)path size:(CGFloat)size {
    
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    UIFont *font = [UIFont fontWithName:fontName size:size];
    CGFontRelease(fontRef);
    
    return font;
}

/**
 * 根据字体文件路径获取所有字体
 * 对于TTF、OTF的字体都有效，但是对于TTC字体，只取出了一种字体。
 * 因为TTC字体是一个相似字体的集合体，一般是字体的组合。所以如果对字体要求比较高，所以可以用下面的方法把所有字体取出来
 */
- (NSArray *)fontArrayWithPath:(NSString*)path size:(CGFloat)size {
    
    CFStringRef fontPath = CFStringCreateWithCString(NULL, [path UTF8String], kCFStringEncodingUTF8);
    CFURLRef fontUrl = CFURLCreateWithFileSystemPath(NULL, fontPath, kCFURLPOSIXPathStyle, 0);
    CFArrayRef fontArray = CTFontManagerCreateFontDescriptorsFromURL(fontUrl);
    CTFontManagerRegisterFontsForURL(fontUrl, kCTFontManagerScopeNone, NULL);
    NSMutableArray *customFontArray = [NSMutableArray array];
    for (CFIndex i = 0 ; i < CFArrayGetCount(fontArray); i++){
        CTFontDescriptorRef  descriptor = CFArrayGetValueAtIndex(fontArray, i);
        CTFontRef fontRef = CTFontCreateWithFontDescriptor(descriptor, size, NULL);
        NSString *fontName = CFBridgingRelease(CTFontCopyName(fontRef, kCTFontPostScriptNameKey));
        UIFont *font = [UIFont fontWithName:fontName size:size];
        [customFontArray addObject:font];
        CFRelease(fontRef);
    }
    CFRelease(fontArray);
    CFRelease(fontUrl);
    CFRelease(fontPath);
    
    return customFontArray;
}

/**
 * 设置字体库文件路径
 */
- (void) setFontPath:(NSString *)fontPath {
    
    if([[NSFileManager defaultManager] fileExistsAtPath:fontPath]) {
        NSString *fontName = [self fontWithPath:fontPath size:14.0].fontName;
        [UIFont setFontName:fontName];
        [NSUserDefaults setSettingValue:fontPath type:SettingTypeFontFamily];
    }
    else {
        [self resetFont];
    }
}

/**
 * 还原字体为默认
 */
- (void) resetFont {
    
    [UIFont setFontName:UIFontSystemName];
    [NSUserDefaults setSettingValue:@"系统字体" type:SettingTypeFontFamily];
}

@end
