//
//  ViewController.m
//  XICardFlowView
//
//  Created by YXLONG on 2016/11/30.
//  Copyright © 2016年 yxlong. All rights reserved.
//

#import "ViewController.h"
#import "XICardFlowView.h"
#import "Masonry.h"
#import "XIRadioButtonsGroupView.h"

#define kScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kCellMaxNum 7

#define  kRandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 \
                                      green:arc4random_uniform(255)/255.0 \
                                       blue:arc4random_uniform(255)/255.0 \
                                      alpha:1]

@interface ViewController ()<XICardFlowViewDelegate>
{
    XICardFlowView *_cardFlowView;
    NSInteger cellNum;
    XIRadioButtonsGroupView *radioButtonsGroupView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    cellNum = kCellMaxNum;
    
    // change the number of card views
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = 88;
    button.backgroundColor = kRandomColor;
    button.frame = CGRectMake(10, 40, 120, 30);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"Change" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:[NSString stringWithFormat:@"%@-%@", @"Change", @(cellNum)] forState:UIControlStateNormal];
    
    radioButtonsGroupView = [[XIRadioButtonsGroupView alloc] initWithFrame:CGRectMake(10, 80, self.view.frame.size.width-10, 40)
                                                                     items:@[@"Alpha", @"itemSpace", @"Scale", @"itemSize"]
                                                           layoutAlongAxis:UILayoutConstraintAxisHorizontal];
    radioButtonsGroupView.backgroundColor = kRandomColor;
    [radioButtonsGroupView setValueChangedHandler:^(NSInteger index) {
        
    }];
    [self.view addSubview:radioButtonsGroupView];

    
    // change pageMargin
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = 101;
    [button setTitle:@"+" forState:UIControlStateNormal];
    button.backgroundColor = kRandomColor;
    button.frame = CGRectMake(10, 130, 40, 30);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(changePageMarginValue:) forControlEvents:UIControlEventTouchUpInside];
    
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = 102;
    [button setTitle:@"-" forState:UIControlStateNormal];
    button.backgroundColor = kRandomColor;
    button.frame = CGRectMake(60, 130, 40, 30);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(changePageMarginValue:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    _cardFlowView = [[XICardFlowView alloc] initWithFrame:CGRectMake(0, 170, kScreenWidth, 320)];
    _cardFlowView.itemSize = CGSizeMake(kScreenWidth-50, 320);
    _cardFlowView.invisibleViewMinScaleValue = 0.9;
    _cardFlowView.invisibleViewMinAlphaValue = 0.6;
    _cardFlowView.itemSpace = -5;
    _cardFlowView.wrappedDelegate = self;
    [self.view addSubview:_cardFlowView];
    
    [_cardFlowView registerClass:[XICardFlowCell class] forCellWithReuseIdentifier:@"ReusedCell"];
}

- (void)changeValue:(UIButton *)btn
{
    if(btn.tag==88){
        if(cellNum>1){
            cellNum--;
        }
        else{
            cellNum = kCellMaxNum;
        }
        [_cardFlowView reloadData];
        
        [btn setTitle:[NSString stringWithFormat:@"%@-%@", @"Change", @(cellNum)] forState:UIControlStateNormal];
    }
}

- (void)changePageMarginValue:(UIButton *)btn
{
    CGSize _size = _cardFlowView.itemSize;
    if(btn.tag==101){
        
        if(radioButtonsGroupView.selectedIndex==0)
        {
            _cardFlowView.invisibleViewMinAlphaValue += 0.1;
        }
        else if(radioButtonsGroupView.selectedIndex==1)
        {
            _cardFlowView.itemSpace += 1;
        }
        else if(radioButtonsGroupView.selectedIndex==2)
        {
            if(_cardFlowView.invisibleViewMinScaleValue>=1.0){
                return;
            }
            _cardFlowView.invisibleViewMinScaleValue += 0.01;
        }
        else if(radioButtonsGroupView.selectedIndex==3){
            if(_size.width<CGRectGetWidth(_cardFlowView.frame)){
                _size.width +=5;
            }
            
            if(_size.height<CGRectGetHeight(_cardFlowView.frame)){
                _size.height +=10;
            }
            _cardFlowView.itemSize = _size;
        }
    }
    else{
        
        if(radioButtonsGroupView.selectedIndex==0)
        {
            if(_cardFlowView.invisibleViewMinAlphaValue>0.4){
                _cardFlowView.invisibleViewMinAlphaValue -= 0.1;
            }
        }
        else if(radioButtonsGroupView.selectedIndex==1)
        {
            _cardFlowView.itemSpace -= 1;
        }
        else if(radioButtonsGroupView.selectedIndex==2)
        {
            _cardFlowView.invisibleViewMinScaleValue -= 0.01;
        }
        else if(radioButtonsGroupView.selectedIndex==3){
            if(_size.width>CGRectGetWidth(_cardFlowView.frame)/2){
                _size.width -=5;
            }
            
            if(_size.height>CGRectGetHeight(_cardFlowView.frame)/2){
                _size.height -=10;
            }
            
            _cardFlowView.itemSize = _size;
        }
    }
}

- (NSInteger)numberOfCardsForCardFlowView:(XICardFlowView *)flowView
{
    return cellNum;
}

- (XICardFlowCell *)cardFlowView:(XICardFlowView *)flowView cardViewAtIndexPath:(NSIndexPath *)indexPath
{
    XICardFlowCell *cell = [flowView dequeueReusableCellWithReuseIdentifier:@"ReusedCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
