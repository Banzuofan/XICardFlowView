//
//  SegmentedControlViewController.m
//  XICardFlowView
//
//  Created by YXLONG on 2016/12/5.
//  Copyright © 2016年 yxlong. All rights reserved.
//

#import "SegmentedControlViewController.h"

@interface SegmentedControlViewController ()
{
    NSArray *arr;
    UISegmentedControl *segControl;
}
@end

@implementation SegmentedControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arr = @[@"One",@"Two",@"Three",@"Four",@"Five"];
    
    segControl = [[UISegmentedControl alloc] initWithItems:arr];
    segControl.frame = CGRectMake(0, 0, 20, 44);
    [segControl addTarget:self action:@selector(valueDidChange) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segControl];
}

- (void)valueDidChange
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
