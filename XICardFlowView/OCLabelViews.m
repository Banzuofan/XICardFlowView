//
//  OCLabelViews.m
//  XICardFlowView
//
//  Created by YXLONG on 16/7/15.
//  
//

#import "OCLabelViews.h"

static inline CGSize SizeOfLabel(NSString *text, UIFont *font, CGSize constraintSize){
    NSDictionary *attrs = @{NSFontAttributeName:font};
    CGSize aSize = [text boundingRectWithSize:constraintSize
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:attrs
                                      context:nil].size;
    return CGSizeMake(aSize.width+2, aSize.height);
}

@interface OCLabelView()
- (BOOL)isFixedImage;
@end

@implementation OCLabelView
@synthesize imageView;
@synthesize titleLabel;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self prepareViews];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self commonInit];
    [self prepareViews];
}

- (void)commonInit
{
    self.userInteractionEnabled = NO;
    _font = [UIFont systemFontOfSize:15.0f];
    _textColor = [UIColor blackColor];
    _showMark = NO;
    
    _itemSpace = 4;
    _contentInsets = UIEdgeInsetsZero;
    appliedConstraints = @[].mutableCopy;
}

- (void)prepareViews
{
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = self.mark;
    [self addSubview:imageView];
    imageView.hidden = !self.showMark;
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.numberOfLines = 1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (BOOL)isFixedImage
{
    return !CGSizeEqualToSize(self.fixedImageSize, CGSizeZero);
}

- (CGSize)getFitSize
{
    CGFloat _maxWidth = 0.0;
    CGFloat _maxHeight = 0.0;
    if (self.showMark) {
        if (titleLabel.text != nil) {
            CGSize size = SizeOfLabel(titleLabel.text, titleLabel.font, CGSizeMake(MAXFLOAT, MAXFLOAT));
            _maxWidth = size.width;
            _maxHeight = size.height;
            if (CGSizeEqualToSize(_fixedImageSize, CGSizeZero)==NO) {
                _maxWidth = _maxWidth+_fixedImageSize.width+self.itemSpace;
                if (_maxHeight < _fixedImageSize.height){
                    _maxHeight = _fixedImageSize.height;
                }
            }
            else{
                if (imageView.image) {
                    CGSize aSize = imageView.image.size;
                    _maxWidth = _maxWidth+aSize.width+self.itemSpace;
                    
                    if (_maxHeight < aSize.height){
                        _maxHeight = aSize.height;
                    }
                }
            }
        }
        else{
            if (CGSizeEqualToSize(_fixedImageSize, CGSizeZero)==NO) {
                _maxWidth = _fixedImageSize.width;
                if (_maxHeight < _fixedImageSize.height){
                    _maxHeight = _fixedImageSize.height;
                }
            }
            else{
                if (imageView.image) {
                    CGSize aSize = imageView.image.size;
                    _maxWidth = aSize.width;
                    
                    if (_maxHeight < aSize.height){
                        _maxHeight = aSize.height;
                    }
                }
            }
        }
    }
    else{
        if (titleLabel.text) {
            CGSize size = SizeOfLabel(titleLabel.text, titleLabel.font, CGSizeMake(MAXFLOAT, MAXFLOAT));
            _maxWidth = size.width;
            _maxHeight = size.height;
        }
    }
    _maxWidth += _contentInsets.left+_contentInsets.right;
    _maxHeight += _contentInsets.top+_contentInsets.bottom;
    return CGSizeMake(_maxWidth, _maxHeight);
}

- (CGSize)intrinsicContentSize
{
    return [self getFitSize];
}

- (void)setNeedsUpdateConstraints
{
    if(appliedConstraints.count>0){
        [self removeConstraints:appliedConstraints];
    }
    [appliedConstraints removeAllObjects];
    [super setNeedsUpdateConstraints];
}

#pragma Mark-- Setters

- (void)setText:(NSString *)text
{
    _text = text;
    titleLabel.text = text;
    [self invalidateIntrinsicContentSize];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    titleLabel.textColor = textColor;
}

- (void)setShowMark:(BOOL)showMark
{
    _showMark = showMark;
    imageView.hidden = !_showMark;
    if(self.mark){
        [self invalidateIntrinsicContentSize];
        [self setNeedsUpdateConstraints];
    }
}

- (void)setMark:(UIImage *)mark
{
    _mark = mark;
    imageView.image = mark;
    if(self.showMark){
        [self invalidateIntrinsicContentSize];
        [self setNeedsUpdateConstraints];
    }
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    titleLabel.font = font;
    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
}

- (void)setItemSpace:(CGFloat)itemSpace
{
    _itemSpace = itemSpace;
    if(self.showMark&&self.mark){
        [self invalidateIntrinsicContentSize];
        [self setNeedsUpdateConstraints];
    }
}

- (void)setFixedImageSize:(CGSize)fixedImageSize
{
    _fixedImageSize = fixedImageSize;
    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
}


@end


@implementation OCImageLabelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [imageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [imageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        
        [titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    }
    return self;
}

- (void)updateConstraints
{
    if (appliedConstraints.count>0) {
        [super updateConstraints];
        return;
    }
    
    if(self.showMark){
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:self.contentInsets.left]];
        
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:titleLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:-self.itemSpace]];
        
        
        if([self isFixedImage]){
            [imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.fixedImageSize.width]];
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.fixedImageSize.height]];
        }
        else{
            [imageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [imageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        }
        
        
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:imageView
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1
                                                                    constant:self.itemSpace]];
        
        CGFloat yOffset = 0.0;
        if(self.contentInsets.top>self.contentInsets.bottom){
            yOffset = (self.contentInsets.top-self.contentInsets.bottom)/2;
        }
        else if (self.contentInsets.bottom>self.contentInsets.top){
            yOffset = -1*(self.contentInsets.bottom-self.contentInsets.top)/2;
        }
        
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:imageView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:yOffset];
        centerY.priority = 1000;
        [appliedConstraints addObject:centerY];
        centerY = [NSLayoutConstraint constraintWithItem:titleLabel
                                               attribute:NSLayoutAttributeCenterY
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self
                                               attribute:NSLayoutAttributeCenterY
                                              multiplier:1
                                                constant:yOffset];
        centerY.priority = 1000;
        [appliedConstraints addObject:centerY];
    }
    else{
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:self.contentInsets.left]];
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationLessThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1
                                                                    constant:-self.contentInsets.right]];
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:self.contentInsets.top]];
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationLessThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:-self.contentInsets.bottom]];
    }
    [self addConstraints:appliedConstraints];
    [super updateConstraints];
}

@end

@implementation OCLabelImageView

- (void)updateConstraints
{
    if (appliedConstraints.count>0) {
        [super updateConstraints];
        return;
    }
    
    if(self.showMark){
        
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:self.contentInsets.left]];
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:imageView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:-self.itemSpace]];
        
        
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:titleLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1
                                                                    constant:self.itemSpace]];
        if([self isFixedImage]){
            [imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.fixedImageSize.width]];
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.fixedImageSize.height]];
        }
        else{
            [imageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [imageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        }
        
        
        CGFloat yOffset = 0.0;
        if(self.contentInsets.top>self.contentInsets.bottom){
            yOffset = (self.contentInsets.top-self.contentInsets.bottom)/2;
        }
        else if (self.contentInsets.bottom>self.contentInsets.top){
            yOffset = -1*(self.contentInsets.bottom-self.contentInsets.top)/2;
        }
        
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:imageView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:yOffset];
        centerY.priority = 1000;
        [appliedConstraints addObject:centerY];
        centerY = [NSLayoutConstraint constraintWithItem:titleLabel
                                               attribute:NSLayoutAttributeCenterY
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self
                                               attribute:NSLayoutAttributeCenterY
                                              multiplier:1
                                                constant:yOffset];
        centerY.priority = 1000;
        [appliedConstraints addObject:centerY];
    }
    else{
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:self.contentInsets.left]];
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationLessThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1
                                                                    constant:-self.contentInsets.right]];
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:self.contentInsets.top]];
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationLessThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:-self.contentInsets.bottom]];
    }
    
    [self addConstraints:appliedConstraints];
    [super updateConstraints];
}

@end

@implementation OCVImageLabelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxFixedWidth = MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
        
        titleLabel.numberOfLines = 0;
        [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return self;
}

- (void)setMaxFixedWidth:(CGFloat)maxFixedWidth
{
    _maxFixedWidth = maxFixedWidth;
    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
}

- (void)prepareViews
{
    [super prepareViews];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (CGSize)titleSize
{
    if (titleLabel.text&&titleLabel.text.length>0){
        CGSize size = SizeOfLabel(titleLabel.text, titleLabel.font, CGSizeMake(self.maxFixedWidth - self.contentInsets.left - self.contentInsets.right, MAXFLOAT));
        size.height += 1;
        return size;
    }
    return CGSizeZero;
}

- (CGSize)intrinsicContentSize
{
    return [self getFitSize];
}

- (CGSize)getFitSize
{
    CGFloat _maxWidth = 0.0;
    CGFloat _maxHeight = self.contentInsets.top + self.contentInsets.bottom;
    if (self.showMark) {
        
        if ([self isFixedImage]) {
            _maxWidth = self.fixedImageSize.width;
            _maxHeight += self.fixedImageSize.height;
        }
        else{
            CGSize imgSize = self.mark.size;
            _maxWidth = imgSize.width;
            _maxHeight += imgSize.height;
        }
        
        if (titleLabel.text) {
            CGSize size = [self titleSize];
            if (_maxWidth < size.width) {
                _maxWidth = size.width;
            }
            _maxHeight += size.height;
            
            _maxHeight += self.itemSpace;
        }
    }
    else{
        if (titleLabel.text) {
            CGSize size = [self titleSize];
            if (_maxWidth < size.width) {
                _maxWidth = size.width;
            }
            _maxHeight += size.height;
        }
    }
    _maxWidth += self.contentInsets.left + self.contentInsets.right;
    return CGSizeMake(_maxWidth, _maxHeight);
}

- (void)updateConstraints
{
    if (appliedConstraints.count>0) {
        [super updateConstraints];
        return;
    }
    
    if(self.showMark){
        //
        // 添加imageView的约束
        // 居中显示
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0]];
        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:self.contentInsets.top]];
        // 固定尺寸
        if ([self isFixedImage]) {
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.fixedImageSize.width]];
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.fixedImageSize.height]];
            
            [imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        }
        // 大小自适应
        else{
            [imageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [imageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        }
        
        
//        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
//                                                                   attribute:NSLayoutAttributeLeft
//                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
//                                                                      toItem:self
//                                                                   attribute:NSLayoutAttributeLeft
//                                                                  multiplier:1
//                                                                    constant:self.contentInsets.left]];
//        [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
//                                                                   attribute:NSLayoutAttributeRight
//                                                                   relatedBy:NSLayoutRelationLessThanOrEqual
//                                                                      toItem:self
//                                                                   attribute:NSLayoutAttributeRight
//                                                                  multiplier:1
//                                                                    constant:-self.contentInsets.right]];
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // titleLabel
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        if (self.text&&self.text.length>0) {
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1
                                                                        constant:0]];
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:imageView
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1
                                                                        constant:self.itemSpace]];
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.titleSize.width]];
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.titleSize.height]];
        }
    }
    else{
        if (self.text&&self.text.length>0) {
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1
                                                                        constant:0]];
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1
                                                                        constant:self.contentInsets.top]];
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.titleSize.width]];
            
            [appliedConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.titleSize.height]];
        }
    }
    
    [self addConstraints:appliedConstraints];
    [super updateConstraints];
}

@end

