//
//  OCLabelViews.h
//  XICardFlowView
//
//  Created by YXLONG on 16/7/15.
//  
//
// Style 1
// Class: OCImageLabelView
// Style: |----image-[space]-title---|
//
// Style 2
// Class: OCLabelImageView
// Style: |----title-[space]-image---|
//
// Style 3
// Class: OCVImageLabelView
// Style:
//---------------
//      |
//    image
//      |
//    label
//      |
//---------------

#import <UIKit/UIKit.h>

@interface OCLabelView : UIView
{
@protected
    UIImageView *imageView;
    UILabel *titleLabel;
    NSMutableArray *appliedConstraints;
}
@property(nonatomic, strong, readonly) UIImageView *imageView;
@property(nonatomic, strong, readonly) UILabel *titleLabel;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, assign) BOOL showMark;
@property(nonatomic, strong) UIImage *mark;
@property(nonatomic, assign) CGFloat itemSpace;
@property(nonatomic, assign) CGSize fixedImageSize;
@property(nonatomic, assign) UIEdgeInsets contentInsets;
- (void)prepareViews;
- (CGSize)getFitSize;
@end

@interface OCImageLabelView : OCLabelView
@end

@interface OCLabelImageView : OCLabelView
@end

@interface OCVImageLabelView : OCLabelView
@property(nonatomic, assign) CGFloat maxFixedWidth;// 横向显示文本的最大尺寸，默认是竖屏屏幕宽度
@end


//##OCVImageLabelView:
//
//OCVImageLabelView *vlabelView = [[OCVImageLabelView alloc] initWithFrame:CGRectZero];
//vlabelView.backgroundColor = [UIColor cyanColor];
//vlabelView.showMark = YES;
//vlabelView.mark = [UIImage imageNamed:@"no-wifi"];
//vlabelView.text = @"Do any additional setup after loading the view.";
//vlabelView.maxFixedWidth = kSCREEN_WIDTH-80;
//vlabelView.contentInsets = UIEdgeInsetsMake(20, 60, 20, 0);
//vlabelView.itemSpace = 15;
//vlabelView.fixedImageSize = CGSizeMake(125, 125);
//[self.view addSubview:vlabelView];
//[vlabelView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//[vlabelView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
//[vlabelView mas_makeConstraints:^(MASConstraintMaker *make) {
//    make.center.equalTo(self.view);
//}];
