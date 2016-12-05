//
//  XICardFlowView.m
//  XICardFlowView
//
//  Created by YXLONG on 15/11/26.
//
//

#import "XICardFlowView.h"
#import <objc/runtime.h>

#define screenSize [UIScreen mainScreen].bounds.size
#define kDefaultItemSpacing 20
#define kDefaultInvisibleViewMinScaleValue 0.95
#define kDefaultInvisibleViewMinAlphaValue 0.8

@interface XICardFlowLayout ()
{
    NSInteger centerPageIndex;
}
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
    BOOL hasReloaded;
}
- (void)_reloaddata;
@end

@implementation XICardFlowView

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(reloadData);
        SEL swizzledSelector = @selector(_reloaddata);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

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

// exchanges IMP of '_reloaddata' with the 'reloadData'.
- (void)_reloaddata
{
    NSLog(@"%s, findVisibleCells :%@", __FUNCTION__, @([self numberOfVisibleCells]));
    NSInteger _visiblecells = [self numberOfVisibleCells];
    BOOL _reachTheEnding = !(self.contentOffset.x+CGRectGetWidth([UIScreen mainScreen].bounds)<self.contentSize.width);
    if(hasReloaded && _visiblecells>1 && _reachTheEnding){
        [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
    else{
        if(!hasReloaded){
            hasReloaded = YES;
        }
        [self _reloaddata];
    }
}

// '[self visibleCells]' would call [self reloadData] implicitly, so don't call '[self visibleCells]' directly in '_reloaddata'.
- (NSInteger)numberOfVisibleCells
{
    NSInteger totalCount = 0;
    [self findCellOnView:self result:&totalCount];
    return totalCount;
}

- (void)findCellOnView:(UIView *)view result:(NSInteger *)result
{
    NSArray *_subviews=[view subviews];
    if(_subviews&&_subviews.count>0) {
        for(UIView *v in _subviews){
            if([v isKindOfClass:[UICollectionViewCell class]] && !v.hidden){
                (*result)++;
            }
            else{
                [self findCellOnView:v result:result];
            }
        }
    }
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
    [self _flowLayout].sectionInset = UIEdgeInsetsMake(0, (screenSize.width-self.itemSize.width)/2, 0, (screenSize.width-self.itemSize.width)/2);
    
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
    NSInteger numberOfItems;
    if([self.cf_delegate respondsToSelector:@selector(numberOfCardsForCardFlowView:)]){
        
        numberOfItems = [self.cf_delegate numberOfCardsForCardFlowView:self];
        if([self.pageControl respondsToSelector:@selector(setNumberOfPages:)]){
            [self.pageControl setNumberOfPages:numberOfItems];
        }
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    if([self.cf_delegate respondsToSelector:@selector(cardFlowView:cardViewAtIndexPath:)]){
        cell = [self.cf_delegate cardFlowView:self cardViewAtIndexPath:indexPath];
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
        if([self.cf_delegate respondsToSelector:@selector(cardFlowView:centeredIndexWillChange:)]){
            [self.cf_delegate cardFlowView:self centeredIndexWillChange:centeredIndexPath.row];
        }
    }
    
    if (scrollingByDragging && _pageControl && [_pageControl respondsToSelector:@selector(setCurrentPage:)]) {
                
        if (centeredIndexPath.row != nextIndexPath.row) {
            [_pageControl setCurrentPage:centeredIndexPath.row];
        }
    }
    
    //---
    if([self.cf_delegate respondsToSelector:@selector(cardFlowViewDidScroll:)]){
        [self.cf_delegate cardFlowViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //---
    if([self.cf_delegate respondsToSelector:@selector(cardFlowViewDidEndDragging:willDecelerate:)]){
        [self.cf_delegate cardFlowViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    
    if([self.cf_delegate respondsToSelector:@selector(cardFlowView:didSelectFromIndex:to:)]){
        [self.cf_delegate cardFlowView:self didSelectFromIndex:lastPageIndex to:indexPath.row];
    }
    
    scrollingByDragging = NO;
    
    //---
    if([self.cf_delegate respondsToSelector:@selector(cardFlowViewDidEndDecelerating:)]){
        [self.cf_delegate cardFlowViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    CGPoint point = [self.superview convertPoint:self.center toView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    
    if([self.cf_delegate respondsToSelector:@selector(cardFlowView:didSelectFromIndex:to:)]){
        [self.cf_delegate cardFlowView:self didSelectFromIndex:lastPageIndex to:indexPath.row];
    }
    
    //---
    if([self.cf_delegate respondsToSelector:@selector(cardFlowViewDidEndScrollingAnimation:)]){
        [self.cf_delegate cardFlowViewDidEndScrollingAnimation:scrollView];
    }
}

@end


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation XICardFlowLayout

-(id)init
{
    self = [super init];
    if (self) {
        centerPageIndex = 0;
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
        self.sectionInset = UIEdgeInsetsMake(0, (screenSize.width-self.itemSize.width)/2, 0, (screenSize.width-self.itemSize.width)/2);
        self.scaleFactor = factor;
        self.alphaFactor = factor1;
    }
    return self;
}

- (CGSize)collectionViewContentSize
{
    return [super collectionViewContentSize];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    BOOL res = [super shouldInvalidateLayoutForBoundsChange:newBounds];
    res = YES;
    return res;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    NSArray* originalArray = [super layoutAttributesForElementsInRect:rect];
    for(UICollectionViewLayoutAttributes *attributes in originalArray){
        [array addObject:[attributes copy]];
    }
    
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes* attributes in array) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
            CGFloat normalizedDistance = distance / self.activeDistance;
            CGFloat scale;
            attributes.transform3D = CATransform3DIdentity;
            attributes.alpha = 1;
            
            if (ABS(distance) < self.activeDistance) {
                scale = 1- self.scaleFactor*ABS(normalizedDistance);
                attributes.transform3D = CATransform3DMakeScale(scale, scale, 1.0);
                attributes.alpha = 1-self.alphaFactor*ABS(normalizedDistance);
                attributes.zIndex = 1;
            }
            else{
                scale = 1-self.scaleFactor;
                attributes.transform3D = CATransform3DMakeScale(scale, scale, 1.0);
                attributes.alpha = 1-self.alphaFactor;
                attributes.zIndex = 0;
            }
        }
    }
    return array;
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
