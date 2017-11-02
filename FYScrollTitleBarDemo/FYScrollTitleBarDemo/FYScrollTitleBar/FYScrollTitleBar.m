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
    if ([_delegate respondsToSelector:@selector(titleBar:didSelectedIndex:)] && _delegate) {
        ///通知代理
        [_delegate titleBar:self didSelectedIndex:button.tag-kTitleBarTagStartValue];
    }
    
}

/// 滚动进度
- (void)updatePercentX:(CGFloat)precentX
{
    // 根据 precentX 计算需要到达的 button
    NSInteger targetIndex = ceilf(precentX);
    UIButton *targetButton = [self viewWithTag:(targetIndex+kTitleBarTagStartValue)];
    
    // 初始 button, 默认第一个
    UIButton *startButton = [self viewWithTag:kTitleBarTagStartValue];
    
    // indicator widht 变化
    CGFloat indicatorPercentWidth = (targetButton.titleLabel.width - startButton.titleLabel.width) * precentX;
    self.indicator.width = startButton.titleLabel.width + indicatorPercentWidth;
    
    // 计算 indicator centerX 百分比变化量
    CGFloat indicatorPercentX = (targetButton.centerX - startButton.centerX) * precentX;
    CGFloat startIndicatorCenterX = startButton.centerX;
    self.indicator.centerX = startIndicatorCenterX + indicatorPercentX;
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
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.indicator];
        [self addSubview:self.topLine];
        [self addSubview:self.bottomLine];
        
        // 添加 button
        UIButton *lastButton;
        for (int i=0; i<titles.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:titles[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button setTitleColor:[UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:1] forState:UIControlStateSelected];
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
    if (_selectedButton == selectedButton) {
        return;
    }
    
    _selectedButton.selected = NO;
    _selectedButton = selectedButton;
    _selectedButton.selected = YES;
    
    // 没有实现 updatePercentX: 方法,自己更新滚动条位置
    if (![_delegate respondsToSelector:@selector(updatePercentX:)]) {
        [UIView animateWithDuration:0.3 animations:^{
            _indicator.width = selectedButton.titleLabel.width;
            _indicator.centerX = selectedButton.centerX;
        }];
    }
    
    
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
        _indicator.backgroundColor = [UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:1/1.0];
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
    
    _topLine.y = 0;
    _topLine.width = self.width;
    _topLine.height = 0.3;
    _topLine.x = 0;
    
    _bottomLine.height = 0.3;
    _bottomLine.width = self.width;
    _bottomLine.x = 0;
    _bottomLine.y = self.height - _bottomLine.height;
    
    _indicator.height = 2;
    _indicator.width = 30;
    _indicator.y = self.height - _indicator.height;
    _indicator.centerX = _selectedButton.centerX;
    
    _contentView.frame = self.bounds;
    UIButton *lastButton  = [self.contentView viewWithTag:kTitleBarTagStartValue+self.titles.count-1];
    
    if (CGRectGetMaxX(lastButton.frame) <= _contentView.width) {
        
        CGFloat width = self.contentView.width / self.titles.count;
        UIButton *lastButton;
        for (int i=0; i<self.titles.count; i++) {
            UIButton *btn = [self.contentView viewWithTag:kTitleBarTagStartValue+i];
            btn.width = width;
            btn.height = self.contentView.height;
            btn.y = 0;
            btn.x = lastButton ? CGRectGetMaxX(lastButton.frame) : 0;
            
            lastButton = btn;
        }
        
        _indicator.height = 2;
        _indicator.width = 30;
        _indicator.y = self.height - _indicator.height;
        _indicator.centerX = _selectedButton.centerX;
        
    } else {
        _contentView.contentSize = CGSizeMake(CGRectGetMaxX(lastButton.frame), self.height);
    }
    
    NSLog(@"%@",_contentView);
}

@end
