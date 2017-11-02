//
//  UIView+FrameChange.h
//  PapaQuanLife
//
//  Created by 晖哥 on 17/2/23.
//  Copyright © 2017年 PPQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameChange)

@property (nonatomic, assign)CGFloat x;
@property (nonatomic, assign)CGFloat y;
@property (nonatomic, assign)CGFloat width;
@property (nonatomic, assign)CGFloat height;
@property (nonatomic, assign)CGSize size;
@property (nonatomic, assign)CGFloat centerX;
@property (nonatomic, assign)CGFloat centerY;

@property (nonatomic, assign)CGFloat right;  // maxX  only getter
@property (nonatomic, assign)CGFloat bottom; // maxY  only getter

@end
