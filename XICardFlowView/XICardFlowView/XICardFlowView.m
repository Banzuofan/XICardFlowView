//
//  XICardFlowView.m
//  XICardFlowView
//
//  Created by YXLONG on 15/11/26.
//
//

#import "XICardFlowView.h"
#import <objc/runtime.h>

#define kDefaultItemSpacing 20
#define kDefaultInvisibleViewMinScaleValue 0.95
#define kDefaultInvisibleViewMinAlphaValue 0.8

@interface XICardFlowLayout ()

@property(nonatomic, assign) CGFloat scaleFactor;
@property(nonatomic, assign) CGFloat activeDistance;
@property(nonatomic, assign) CGFloat alphaFactor;
@end

@implementation XICardFlowCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0
                                               green:arc4random_uniform(255)/255.0
                                                blue:arc4random_uniform(255)/255.0
                                               alpha:1];
    }
    return self;
}
@end

@interface XICardFlowView ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSInteger lastPageIndex;
    BOOL scrollingByDragging;
}
@end

@implementation XICardFlowView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if(self=[super initWithFrame:frame collectionViewLayout:layout]){
        self.backgroundColor = [UIColor clearColor];
        self.scrollsToTop = NO;
        lastPageIndex = 0;
        scrollingByDragging = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    XICardFlowLayout* lineLayout = [[XICardFlowLayout alloc] initWithItemSize:CGSizeMake(5, 5)
                                                                  itemSpacing:kDefaultItemSpacing
                                                                  scaleFactor:kDefaultInvisibleViewMinScaleValue
                                                                  alphaFactor:kDefaultInvisibleViewMinAlphaValue];
    if(self=[self initWithFrame:frame collectionViewLayout:lineLayout]){
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.dataSource = self;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return self;
}

- (XICardFlowLayout *)_flowLayout
{
    return (XICardFlowLayout *)self.collectionViewLayout;
}

- (void)centerCardIfNeeded
{
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    NSIndexPath *centeredIndexPath = [self indexPathForItemAtPoint:point];
    [self scrollToItemAtIndexPath:centeredIndexPath
                 atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                         animated:NO];
}

- (void)setItemSpace:(NSInteger)itemSpace
{
    _itemSpace = itemSpace;
    
    [self _flowLayout].minimumLineSpacing = _itemSpace;
    
    if(self.superview){
        [[self _flowLayout] invalidateLayout];
        [self centerCardIfNeeded];
    }
}

- (void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize;
    [self _flowLayout].itemSize = itemSize;
    [self _flowLayout].activeDistance = itemSize.width;
    
    if(self.superview){
        [[self _flowLayout] invalidateLayout];
        [self centerCardIfNeeded];
    }
}

- (void)setInvisibleViewMinAlphaValue:(CGFloat)invisibleViewMinAlphaValue
{
    _invisibleViewMinAlphaValue = invisibleViewMinAlphaValue;
    [self _flowLayout].alphaFactor = 1.0-invisibleViewMinAlphaValue;
    
    if(self.superview){
        [[self _flowLayout] invalidateLayout];
    }
}

- (void)setInvisibleViewMinScaleValue:(CGFloat)invisibleViewMinScaleValue
{
    _invisibleViewMinScaleValue = invisibleViewMinScaleValue;
    [self _flowLayout].scaleFactor = 1-invisibleViewMinScaleValue;
    
    if(self.superview){
        [[self _flowLayout] invalidateLayout];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    lastPageIndex = [self currentPageIndex];
    [super setContentOffset:contentOffset animated:animated];
    
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    lastPageIndex = [self currentPageIndex];
    [super scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (CGRect)visibleRect
{
    CGRect _visibleRect;
    _visibleRect.origin = self.contentOffset;
    _visibleRect.size = self.bounds.size;
    return _visibleRect;
}

- (NSInteger)currentPageIndex
{
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    NSIndexPath *centeredIndexPath = [self indexPathForItemAtPoint:point];
    
    return centeredIndexPath.row;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSInteger numberOfItems = 0;
    if([self.wrappedDelegate respondsToSelector:@selector(numberOfCardsForCardFlowView:)]){
        
        numberOfItems = [self.wrappedDelegate numberOfCardsForCardFlowView:self];
        if([self.pageControl respondsToSelector:@selector(setNumberOfPages:)]){
            [self.pageControl setNumberOfPages:numberOfItems];
        }
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowView:cardViewAtIndexPath:)]){
        cell = [self.wrappedDelegate cardFlowView:self cardViewAtIndexPath:indexPath];
        return cell;
    }
    return cell;
}

#pragma mark-- UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollingByDragging = YES;
    if (_pageControl && [_pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        
        lastPageIndex = [_pageControl currentPage];
    }
    else{
        CGPoint point = [self.superview convertPoint:self.center toView:self];
        NSIndexPath *centeredIndexPath = [self indexPathForItemAtPoint:point];
        
        lastPageIndex = centeredIndexPath.row;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    
    NSIndexPath *centeredIndexPath = [self indexPathForItemAtPoint:point];
    
    UICollectionViewFlowLayout *flowlayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGPoint paddingPoint = CGPointMake(self.center.x + flowlayout.itemSize.width+flowlayout.minimumLineSpacing, self.center.y);
    
    CGPoint nextPoint = [self.superview convertPoint:paddingPoint toView:self];
    NSIndexPath *nextIndexPath = [self indexPathForItemAtPoint:nextPoint];
    
    if (scrollingByDragging && centeredIndexPath.row != nextIndexPath.row) {
        if([self.wrappedDelegate respondsToSelector:@selector(cardFlowView:centeredIndexWillChange:)]){
            [self.wrappedDelegate cardFlowView:self centeredIndexWillChange:centeredIndexPath.row];
        }
    }
    
    if (scrollingByDragging && _pageControl && [_pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        
        if (centeredIndexPath.row != nextIndexPath.row) {
            [_pageControl setCurrentPage:centeredIndexPath.row];
        }
    }
    
    //---
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowViewDidScroll:)]){
        [self.wrappedDelegate cardFlowViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //---
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowViewDidEndDragging:willDecelerate:)]){
        [self.wrappedDelegate cardFlowViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowView:didSelectFromIndex:to:)]){
        [self.wrappedDelegate cardFlowView:self didSelectFromIndex:lastPageIndex to:indexPath.row];
    }
    
    scrollingByDragging = NO;
    
    //---
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowViewDidEndDecelerating:)]){
        [self.wrappedDelegate cardFlowViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowView:didSelectFromIndex:to:)]){
        [self.wrappedDelegate cardFlowView:self didSelectFromIndex:lastPageIndex to:indexPath.row];
    }
    
    //---
    if([self.wrappedDelegate respondsToSelector:@selector(cardFlowViewDidEndScrollingAnimation:)]){
        [self.wrappedDelegate cardFlowViewDidEndScrollingAnimation:scrollView];
    }
}

@end


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation XICardFlowLayout
{
    CGFloat _insetsValue;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (instancetype)initWithItemSize:(CGSize)itemSize itemSpacing:(CGFloat)space scaleFactor:(CGFloat)factor alphaFactor:(CGFloat)factor1
{
    if(self = [self init]){
        self.itemSize = itemSize;
        self.minimumLineSpacing = space;
        self.activeDistance = self.itemSize.width;
        self.scaleFactor = factor;
        self.alphaFactor = factor1;
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    _insetsValue = (CGRectGetWidth(self.collectionView.frame) - self.itemSize.width)/2;
    self.sectionInset = UIEdgeInsetsMake(0, _insetsValue, 0, _insetsValue);
    
    self.collectionView.contentSize = [self collectionViewContentSize];
}

- (CGSize)collectionViewContentSize
{
    NSInteger rowCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat _contentSizeWidth = _insetsValue*2+self.itemSize.width*rowCount+self.minimumLineSpacing*(rowCount-1);
    return CGSizeMake(_contentSizeWidth, CGRectGetHeight(self.collectionView.frame));
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    NSArray* originalArray = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes* elem in originalArray) {
        
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:elem.indexPath];
        [array addObject:attributes];
    }
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = self.itemSize;
    
    CGFloat itemCenterX = _insetsValue + self.pageWidth * indexPath.row + self.itemSize.width / 2;
    attributes.center = CGPointMake(itemCenterX, CGRectGetHeight(self.collectionView.frame)/2);
    
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
    CGFloat changeRatio = distance / self.activeDistance;
    CGFloat scale;
    
    if (fabs(distance) < self.activeDistance) {
        scale = 1-self.scaleFactor*ABS(changeRatio);
        attributes.transform3D = CATransform3DMakeScale(scale, scale, 1.0);
        
        attributes.alpha = 1-self.alphaFactor*ABS(changeRatio);
        attributes.zIndex = 1;
    }
    else{
        scale = 1 - self.scaleFactor;
        attributes.zIndex = 0;
        attributes.transform3D = CATransform3DMakeScale(scale, scale, 1.0);
        attributes.alpha = 1-self.alphaFactor;
    }
    
    return attributes;
}

- (CGFloat)pageWidth {
    return self.itemSize.width + self.minimumLineSpacing;
}

- (CGFloat)flickVelocity {
    return 0.3;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat rawPageValue = self.collectionView.contentOffset.x / self.pageWidth;
    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.x) > [self flickVelocity];
    if (pannedLessThanAPage && flicked) {
        proposedContentOffset.x = nextPage * self.pageWidth;
    } else {
        proposedContentOffset.x = round(rawPageValue) * self.pageWidth;
    }
    
    if(fabs(proposedContentOffset.x)<1){
        proposedContentOffset.x = 0;
    }
    
    proposedContentOffset.y = 0;
    return proposedContentOffset;
}

@end
