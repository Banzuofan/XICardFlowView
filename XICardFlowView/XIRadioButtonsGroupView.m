//
//  XIRadioButtonsGroupView.m
//  XICardFlowView
//
//  Created by YXLONG on 15/11/26.
//  
//

#import "XIRadioButtonsGroupView.h"
#import "OCLabelViews.h"
#import "Masonry.h"

#define kBaseButtonTag 1000

@implementation XIRadioButtonsGroupView
{
    UILayoutConstraintAxis layoutAlongAxis;
    NSMutableArray *_items;
}

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items layoutAlongAxis:(UILayoutConstraintAxis)axis
{
    if(self=[super initWithFrame:frame]){
        _itemSpace = 10;
        layoutAlongAxis = axis;
        _selectedIndex = 0;
        _items = @[].mutableCopy;
        
        for(int i=0;i<items.count;i++){
            NSString *title = items[i];
            XIRadioButtonView *btn = [[XIRadioButtonView alloc] initWithFrame:CGRectZero];
            btn.tag = kBaseButtonTag+i;
            [btn setTitle:title];
            [self addSubview:btn];
            [btn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [btn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
            [_items addObject:btn];
            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            if(i==_selectedIndex){
                btn.selected = YES;
            }
        }
        [self updateViewConstraints];
        
    }
    return self;
}

- (void)btnAction:(id)sender
{
    XIRadioButtonView *btn = (XIRadioButtonView *)sender;
    self.selectedIndex = btn.tag-kBaseButtonTag;
    if(_valueChangedHandler){
        _valueChangedHandler(self.selectedIndex);
    }
}

- (void)updateViewConstraints
{
    UIView *lastView = nil;
    if(layoutAlongAxis==UILayoutConstraintAxisHorizontal){
        for(XIRadioButtonView *btn in _items){
            [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                if(!lastView){
                    make.left.equalTo(self);
                }
                else{
                    make.left.equalTo(lastView.mas_right).with.offset(_itemSpace);
                }
                make.centerY.equalTo(self);
            }];
            lastView = btn;
        }
    }
    else{
        for(XIRadioButtonView *btn in _items){
            [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                if(!lastView){
                    make.top.equalTo(self);
                }
                else{
                    make.top.equalTo(lastView.mas_bottom).with.offset(_itemSpace);
                }
                make.left.equalTo(self);
            }];
            lastView = btn;
        }
    }
}

- (void)setItemSpace:(CGFloat)itemSpace
{
    _itemSpace = itemSpace;
    [self updateViewConstraints];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if(_items.count>0){
        for(XIRadioButtonView *btn in _items){
            if(btn.selected){
                btn.selected = !btn.selected;
            }
        }
        NSParameterAssert(selectedIndex<_items.count);
        XIRadioButtonView *btn = (XIRadioButtonView *)_items[selectedIndex];
        btn.selected = YES;
    }
    _selectedIndex = selectedIndex;
}

@end

@implementation XIRadioButtonView
@synthesize contentLabel;

+ (void)initialize
{
    if (self == [XIRadioButtonView class]) {
        [XIRadioButtonView appearance].imageForNormalState = [UIImage imageNamed:@"unselected"];
        [XIRadioButtonView appearance].imageForSelectedState = [UIImage imageNamed:@"selected"];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        [self prepareViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self prepareViews];
}

- (void)prepareViews
{
    _itemSpace = 5;
    if(!contentLabel){
        contentLabel = [[OCImageLabelView alloc] initWithFrame:CGRectZero];
        contentLabel.itemSpace = _itemSpace;
        contentLabel.showMark = YES;
        contentLabel.mark = [XIRadioButtonView appearance].imageForNormalState;
        [self addSubview:contentLabel];
        
        [contentLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [contentLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).with.priority(900);
            make.left.equalTo(self);
            
            make.top.greaterThanOrEqualTo(self).with.offset(self.contentEdgeInsets.left);
            make.bottom.lessThanOrEqualTo(self).with.offset(-self.contentEdgeInsets.bottom);
            make.right.lessThanOrEqualTo(self).with.offset(-self.contentEdgeInsets.right);
        }];
    }
}

- (void)setItemSpace:(CGFloat)itemSpace
{
    _itemSpace = itemSpace;
    contentLabel.itemSpace = _itemSpace;
    [self invalidateIntrinsicContentSize];
}

- (void)setTitle:(NSString *)title
{
    [contentLabel setText:title];
    [self invalidateIntrinsicContentSize];
}

- (void)setImage:(UIImage *)image title:(NSString *)title
{
    self.imageForNormalState = image;
    if(image){
        contentLabel.showMark = YES;
    }
    else{
        contentLabel.showMark = NO;
    }
    [contentLabel setMark:image];
    [contentLabel setText:title];
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    return [contentLabel intrinsicContentSize];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    NSParameterAssert(image);
    if(state==UIControlStateNormal){
        self.imageForNormalState = image;
    }
    else if(state==UIControlStateSelected){
        self.imageForSelectedState = image;
    }
}

- (void)setImageForNormalState:(UIImage *)imageForNormalState
{
    _imageForNormalState = imageForNormalState;
    if(!self.selected){
        contentLabel.mark = _imageForNormalState;
    }
}

- (void)setImageForSelectedState:(UIImage *)imageForSelectedState
{
    _imageForSelectedState = imageForSelectedState;
    if(self.selected){
        contentLabel.mark = _imageForSelectedState;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if(selected){
        contentLabel.mark = _imageForSelectedState;
    }
    else{
        contentLabel.mark = _imageForNormalState;
    }
}

@end
