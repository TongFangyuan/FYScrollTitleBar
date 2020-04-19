//
//  FYScrollTitleBar.m
//  FYScrollTitleBarDemo
//
//  Created by tongfy on 2017/11/2.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "FYScrollTitleBar.h"
#import "UIView+FrameChange.h"

@interface FYScrollTitleBar()

@property (nonatomic, assign) NSInteger selectedIndex;

@end;


@implementation FYScrollTitleBar

#pragma mark - public

- (void)buttonAction:(UIButton *)button
{
    if (_selectedButton == button) {
        return;
    }
    
    [self setSelectedButton:button];
    
    // 事件传递
    if ([_delegate respondsToSelector:@selector(titleBar:didSelectedIndex:)] && _delegate)
    {
        ///通知代理
        [_delegate titleBar:self didSelectedIndex:button.tag-kTitleBarTagStartValue];
    }
    
}

/// 滚动进度
- (void)updatePercentX:(CGFloat)precentX
{
    // 根据 precentX 计算需要到达的 button
    NSInteger targetIndex = precentX>self.selectedIndex ? ceilf(precentX) : floor(precentX);
    UIButton *targetButton = [self viewWithTag:(targetIndex+kTitleBarTagStartValue)];
    
    BOOL increase = precentX > self.selectedIndex;
    CGFloat percent = fabs(precentX - self.selectedIndex);
    
    UIButton *startButton = self.selectedButton;

    // indicator width 变化
    if (self.autoResizeIndicator) {
    BOOL widthIncrease = targetButton.titleLabel.width > startButton.titleLabel.width;
    CGFloat indicatorPercentWidth = fabs(targetButton.titleLabel.width - startButton.titleLabel.width) * percent;
    self.indicator.width = widthIncrease ?startButton.titleLabel.width + indicatorPercentWidth : startButton.titleLabel.width - indicatorPercentWidth;
    }
    
    // 计算 indicator centerX 百分比变化量
    CGFloat indicatorPercentX = fabs(targetButton.centerX - startButton.centerX) * percent;
    CGFloat startIndicatorCenterX = startButton.centerX;
    self.indicator.centerX = increase ?startIndicatorCenterX + indicatorPercentX : startIndicatorCenterX - indicatorPercentX;
    
}

/// 更新选中按钮
- (void)setSelectedButtonAtIndex:(NSInteger)index
{
    UIButton *button = [self.contentView viewWithTag:(index+kTitleBarTagStartValue)];
    self.selectedButton = button;
}



+ (instancetype)titleBarWithFrame:(CGRect)frame
                           titles:(NSArray<NSString *> *)titles
{
    return [self titleBarWithFrame:frame
                            titles:titles delegate:nil];
}

+ (instancetype)titleBarWithFrame:(CGRect)frame
                           titles:(NSArray<NSString *> *)titles
                         delegate:(id<FYScrollTitleBarDelegate>)delegate
{
    return [[self alloc] initWithFrame:frame titles:titles delegate:delegate];
}

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray<NSString *> *)titles
                     delegate:(id<FYScrollTitleBarDelegate>)delegate
{
    if (self = [super initWithFrame:frame]) {
        _titles = [NSArray arrayWithArray:titles];
        _delegate = delegate;
        _automicAdjustIndicator = NO;
        _autoResizeIndicator = NO;
        _indicatorSize = CGSizeMake(18.f, 1.f);
        _indicatorColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1.00];
        _normalStateColor = [UIColor colorWithRed:0.57 green:0.57 blue:0.57 alpha:1.00];
        _normalStateFont = [UIFont systemFontOfSize:15.f];
        _selectStateColor = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.00];
        _selectStateFont = [UIFont systemFontOfSize:16.f];
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.indicator];
        [self addSubview:self.topLine];
        [self addSubview:self.bottomLine];
        
        self.indicator.size = _indicatorSize;
        
        // 添加 button
        UIButton *lastButton;
        for (int i=0; i<titles.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:titles[i] forState:UIControlStateNormal];
            [button setTitleColor:_normalStateColor forState:UIControlStateNormal];
            button.titleLabel.font = _normalStateFont;
            [button setTitleColor:_selectStateColor forState:UIControlStateSelected];
            button.tag = kTitleBarTagStartValue + i;
            [button sizeToFit];
            
            button.width = button.width+30;
            button.height = frame.size.height;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.x = lastButton ? CGRectGetMaxX(lastButton.frame) : 0;
            lastButton = button;
            
            [self.contentView addSubview:button];
            
            if (i==0) {
                self.selectedButton = button;
            }
        }
        
    }
    return self;
}

- (void)setSelectedButton:(UIButton *)selectedButton
{
    if (_selectedButton == selectedButton)
    {
        return;
    }
    
    _selectedButton.titleLabel.font = _normalStateFont;
    selectedButton.titleLabel.font = _selectStateFont;
    
    _selectedButton.selected = NO;
    _selectedButton = selectedButton;
    _selectedButton.selected = YES;
    
    // 是否自己更新滚动条位置
    if (_automicAdjustIndicator) {
        [UIView animateWithDuration:0.2 animations:^{
            if (_autoResizeIndicator)
            {
                _indicatorSize.width = selectedButton.titleLabel.width;
                _indicator.width = _indicatorSize.width;
            }
            _indicator.centerX = selectedButton.centerX;
        }];
    }
    
    
    // button 显示在中间
    CGPoint targetPoint = CGPointZero;
    targetPoint.x = _selectedButton.center.x - self.contentView.width*0.5;
    
    if (targetPoint.x > self.contentView.contentSize.width-self.contentView.width) {
        targetPoint.x = self.contentView.contentSize.width-self.contentView.width;
    }
    
    if (targetPoint.x < 0) {
        targetPoint.x = 0;
    }
    
    [self.contentView setContentOffset:targetPoint animated:YES];
}

- (UIScrollView *)contentView
{
    if (!_contentView) {
        _contentView = [UIScrollView new];
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.bounces = YES;
    }
    return _contentView;
}

- (UIImageView *)topLine
{
    if (!_topLine) {
        _topLine = [UIImageView new];
        _topLine.backgroundColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1/1.0];
    }
    return _topLine;
}

- (UIImageView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [UIImageView new];
        _bottomLine.backgroundColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1/1.0];
    }
    return _bottomLine;
}

- (UIImageView *)indicator
{
    if (!_indicator) {
        _indicator = [UIImageView new];
        _indicator.tag = 9472;
    }
    return _indicator;
}

- (NSInteger)selectedIndex
{
    return self.selectedButton.tag - kTitleBarTagStartValue;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resetTitleBar];
}


- (void)resetTitleBar
{
    ///
    _contentView.frame = self.bounds;
    
    /// btn
    CGFloat width = self.contentView.width / self.titles.count;
    UIButton *lastButton = nil;
    for (int i=0; i<self.titles.count; i++) {
        UIButton *btn = [self.contentView viewWithTag:kTitleBarTagStartValue+i];
        [btn setTitleColor:_normalStateColor forState:UIControlStateNormal];
        [btn setTitleColor:_selectStateColor forState:UIControlStateSelected];
        btn.titleLabel.font = _normalStateFont;
        btn.width = width;
        btn.height = self.contentView.height;
        btn.y = 0;
        btn.x = lastButton ? CGRectGetMaxX(lastButton.frame) : 0;
        lastButton = btn;
    }
    _selectedButton.titleLabel.font = _selectStateFont;
    
    /// 顶部线条
    _topLine.y = 0;
    _topLine.width = self.width;
    _topLine.height = 0.3;
    _topLine.x = 0;
    
    /// 底部线条
    _bottomLine.height = 0.3;
    _bottomLine.width = self.width;
    _bottomLine.x = 0;
    _bottomLine.y = self.height - _bottomLine.height;
    
    /// indicator
    _indicator.height = _indicatorSize.height;
    _indicator.width = _indicatorSize.width;
    _indicator.y = self.height - _indicator.height;
    _indicator.centerX = _selectedButton.centerX;
    _indicator.backgroundColor = _indicatorColor;
        _indicator.centerX = _selectedButton.centerX;
        
    ///
    if (CGRectGetMaxX(lastButton.frame) > _contentView.width)
    {
        _contentView.contentSize = CGSizeMake(CGRectGetMaxX(lastButton.frame), self.height);
    }
    
}

@end
