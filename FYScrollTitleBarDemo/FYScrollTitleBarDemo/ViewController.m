//
//  ViewController.m
//  FYScrollTitleBarDemo
//
//  Created by tongfy on 2017/11/2.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "ViewController.h"
#import "FYScrollTitleBar.h"
#import "UIView+FrameChange.h"

@interface ViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
FYScrollTitleBarDelegate
>

@property (nonatomic, strong) FYScrollTitleBar *titleBar;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray<NSString *> *titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"FYScrollTitleBar";
    
    _titles = @[@"热门",@"推荐",@"😁🙃😆",@"今天有什么好看的",@"小视频",@"头条",@"科技",@"手机",@"财经",@"哈哈哈哈哈"];
//    _titles = @[@"热门",@"推荐",@"呵呵",@"😁🙃😆"];
    _titleBar = [FYScrollTitleBar titleBarWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 40) titles:_titles];
    _titleBar.delegate = self;
    [self.view addSubview:_titleBar];
    
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(_titleBar.frame), self.view.width, [UIScreen mainScreen].bounds.size.height-CGRectGetMaxY(_titleBar.frame));
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 255 / 255.0 blue:arc4random() % 255 / 255.0 alpha:1.0];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView==self.collectionView) {
        CGFloat percentX = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
        NSLog(@"%f",percentX);
        [self.titleBar updatePercentX:percentX];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==self.collectionView) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        NSInteger index = scrollView.contentOffset.x / screenWidth;
        [self.titleBar setSelectedButtonAtIndex:index];
    }
}

#pragma mark - FYScrollTitleBarDelegate
- (void)titleBar:(FYScrollTitleBar *)titleBar didSelectedIndex:(NSInteger)index
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat contentOffsetX = screenWidth * index;
    [self.collectionView setContentOffset:CGPointMake(contentOffsetX, 0) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-40);
        layout.minimumLineSpacing = CGFLOAT_MIN;
        layout.minimumInteritemSpacing = CGFLOAT_MIN;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    }
    return _collectionView;
}

@end
