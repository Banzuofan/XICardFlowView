//
//  XICardFlowView.h
//  XICardFlowView
//
//  Created by YXLONG on 15/11/26.
//
//

#import <UIKit/UIKit.h>

@interface XICardFlowCell : UICollectionViewCell

@end

@protocol XICardFlowViewDelegate;
@interface XICardFlowView : UICollectionView

@property(nonatomic, weak) id<XICardFlowViewDelegate> cf_delegate;
@property(nonatomic, weak) UIPageControl *pageControl;

@property(nonatomic, assign) NSInteger itemSpace;
@property(nonatomic, assign) CGSize itemSize;
@property(nonatomic, assign) CGFloat invisibleViewMinScaleValue;
@property(nonatomic, assign) CGFloat invisibleViewMinAlphaValue;

- (NSInteger)currentPageIndex;
@end

@protocol XICardFlowViewDelegate <NSObject>

- (NSInteger)numberOfCardsForCardFlowView:(XICardFlowView *)flowView;
- (UICollectionViewCell *)cardFlowView:(XICardFlowView *)flowView cardViewAtIndexPath:(NSIndexPath *)indexPath;
@optional
/**
 * 居中显示的子视图索引将改变。此方法会跟随scroll动作进行而不断被调用
 * 方法setContentOffset/scrollRectVisible:animated:的调用不会触发此方法
 *
 * @Param newCenteredIndex 新的居中显示的子视图索引
 */
- (void)cardFlowView:(XICardFlowView *)flowView centeredIndexWillChange:(NSInteger)newCenteredIndex;
/**
 * 居中显示的子视图索引已经发生改变。此方法会在scrollViewDidEndDecelerating中被调用
 * 方法setContentOffset/scrollRectVisible:animated:的调用结束后会触发此方法
 *
 * @Param from 新的居中显示的子视图索引
 * @Param to   上一个居中显示的子视图索引
 */
- (void)cardFlowView:(XICardFlowView *)flowView didSelectFromIndex:(NSInteger)from to:(NSInteger)to;

- (void)cardFlowViewDidScroll:(UIScrollView *)scrollView;
- (void)cardFlowViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)cardFlowViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (void)cardFlowViewDidEndDecelerating:(UIScrollView *)scrollView;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface XICardFlowLayout : UICollectionViewFlowLayout

- (instancetype)initWithItemSize:(CGSize)itemSize
                     itemSpacing:(CGFloat)space
                     scaleFactor:(CGFloat)factor
                     alphaFactor:(CGFloat)factor1;
@end
