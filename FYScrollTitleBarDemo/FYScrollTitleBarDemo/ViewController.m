//
//  ViewController.m
//  FYScrollTitleBarDemo
//
//  Created by tongfy on 2017/11/2.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "ViewController.h"
#import "FYScrollTitleBar.h"

@interface ViewController ()

@property (nonatomic, strong) FYScrollTitleBar *titleBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _titleBar = [FYScrollTitleBar titleBarWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 40) titles:@[@"我的",@"你得你你你",@"2321",@"322",@"你wew",@"你得你",@"剑影你",@"你得"]];
    _titleBar = [FYScrollTitleBar titleBarWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 40) titles:@[@"我的",@"你得你你你",@"2321"]];
    [self.view addSubview:_titleBar];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
