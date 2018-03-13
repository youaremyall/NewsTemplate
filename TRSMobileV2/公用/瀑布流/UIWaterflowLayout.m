//
//  UIWaterflowLayout.m
//  TRSMobileV2
//
//  Created by  TRS on 16/4/28.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIWaterflowLayout.h"

/**默认间隔*/
static const CGFloat margin = 8.0;

@interface UIWaterflowLayout()

/**存放所有cell的布局属性*/
@property (nonatomic, strong) NSMutableArray * attrsArray;

/**存放所有列的当前高度*/
@property (nonatomic, strong) NSMutableArray * columnHeights;

/**内容的高度*/
@property (nonatomic, assign) CGFloat  contentHeight;

@end

@implementation UIWaterflowLayout

- (CGFloat)rowMargin {
    
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingInWaterflowLayout:)]) {
        return [self.delegate minimumLineSpacingInWaterflowLayout:self];
    } else {
        return margin;
    }
}

- (CGFloat)columnMargin {
    
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingInWaterflowLayout:)]) {
        return [self.delegate minimumInteritemSpacingInWaterflowLayout:self];
    } else {
        return margin;
    }
}

- (NSInteger)columnCount {
    
    if ([self.delegate respondsToSelector:@selector(columnCountInWaterflowLayout:)]) {
        return [self.delegate columnCountInWaterflowLayout:self];
    } else {
        return 3;
    }
}

- (UIEdgeInsets)edgeInsets {
    
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInWaterflowLayout:)]) {
        return [self.delegate edgeInsetsInWaterflowLayout:self];
    } else {
        return UIEdgeInsetsMake(margin, margin, margin, margin);
    }
}

- (CGSize)headerReferenceSize {
    
    if([self.delegate respondsToSelector:@selector(sizeForHeaderInWaterflowLayout:)]) {
        return [self.delegate sizeForHeaderInWaterflowLayout:self];
    }
    else {
        return CGSizeZero;
    }
}

#pragma mark -
- (NSMutableArray *)attrsArray {
    
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

- (NSMutableArray *)columnHeights {
    
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

#pragma mark -
/*
 * 初始化
 */
- (void)prepareLayout {
    
    [super prepareLayout];
    
    self.contentHeight = 0;
    
    //清除以前计算的所以高度
    [self.columnHeights removeAllObjects];
    
    //默认高度
    for (NSInteger i = 0; i < self.columnCount; i++) {
        [self.columnHeights addObject:@(/*self.edgeInsets.top +*/self.headerReferenceSize.height)];
    }
    
    //清除之前所以的布局属性
    [self.attrsArray removeAllObjects];

    //数组 (存放所以cell的布局属性)
    //开始创建每一个cell对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        
        //创建位置
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        if(indexPath.item == 0 && self.headerReferenceSize.height > 0.0) {
            
            //创建cell的头部布局属性
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
            attr.frame = CGRectMake(0, 0, self.headerReferenceSize.width, self.headerReferenceSize.height);
            [self.attrsArray addObject:attr];
        }
        
        //获取cell布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attrs];
    }
}

/**
 * 决定cell的布局
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    return self.attrsArray;
}

/**
 * 设置cell的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes * attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //设置布局属性的frame
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    CGFloat w = (collectionViewW - self.edgeInsets.left - self.edgeInsets.right - (self.columnCount - 1)*self.columnMargin) / self.columnCount;
    CGFloat h = [self.delegate waterflowLayout:self heightForItemAtIndex:indexPath.item itemWidth:w];
    
    //找出高度最短的那一列
    NSInteger destColumn = 0;
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    for (NSInteger i = 1; i < self.columnCount; i++) {
          CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            destColumn = i;
        }
    }
    
    CGFloat x = self.edgeInsets.left + destColumn * (w +self.columnMargin);
    CGFloat y = minColumnHeight;
    if (y != self.rowMargin) {
        y += self.rowMargin;
    }
    
    attrs.frame = CGRectMake(x, y, w, h);

    //更新最短那列的高度
    self.columnHeights[destColumn] = @(CGRectGetMaxY(attrs.frame));
    
    // 记录内容的高度
    CGFloat columnHeight = [self.columnHeights[destColumn] doubleValue];
    if (self.contentHeight < columnHeight) {
        self.contentHeight = columnHeight;
    }
    
    return attrs;
}

- (CGSize)collectionViewContentSize {
    
    return CGSizeMake(0, self.contentHeight + self.edgeInsets.bottom);
}

@end
