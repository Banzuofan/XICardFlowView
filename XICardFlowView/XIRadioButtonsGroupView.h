//
//  XIRadioButtonsGroupView.h
//  XICardFlowView
//
//  Created by YXLONG on 15/11/26.
//  
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSInteger, UILayoutConstraintAxis) {
//    UILayoutConstraintAxisHorizontal = 0,
//    UILayoutConstraintAxisVertical = 1
//};

@interface XIRadioButtonsGroupView : UIView
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, assign) CGFloat itemSpace;
@property(nonatomic, copy) void(^valueChangedHandler)(NSInteger newIndex);

- (instancetype)initWithFrame:(CGRect)frame
                        items:(NSArray *)items
              layoutAlongAxis:(UILayoutConstraintAxis)axis;
@end

@class OCImageLabelView;
@interface XIRadioButtonView : UIButton
{
@protected
    OCImageLabelView *contentLabel;
}
@property(nonatomic, strong, readonly) OCImageLabelView *contentLabel;
@property(nonatomic, strong) UIImage *imageForNormalState UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIImage *imageForSelectedState UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat itemSpace;

- (void)setImage:(UIImage *)image title:(NSString *)title;
- (void)setTitle:(NSString *)title;
@end

//SAMPLE CODE:
//
//XIRadioButtonsGroupView *groupView = [[XIRadioButtonsGroupView alloc] initWithFrame:CGRectMake(0, 180, 200, 140)
//                                                                              items:@[@"全部",@"男",@"女"]
//                                                                    layoutAlongAxis:UILayoutConstraintAxisVertical];
//groupView.selectedIndex = 1;
//groupView.itemSpace = 25;
//groupView.backgroundColor = [UIColor whiteColor];
//[self.view addSubview:groupView];
//
//[groupView setValueChangedHandler:^(NSInteger newIndex) {
//    JLog(@"%@", @(newIndex));
//}];

