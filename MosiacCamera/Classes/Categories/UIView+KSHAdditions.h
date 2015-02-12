//
//  UIView+KSHAdditions.h
//  MosiacCamera
//
//  Created by 金聖輝 on 14/11/30.
//  Copyright (c) 2014年 kimsungwhee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KSHAdditions)

@property (nonatomic, assign) CGFloat frameX;
@property (nonatomic, assign) CGFloat frameY;
@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, assign) CGFloat frameHeight;
@property (nonatomic, assign) CGPoint frameOrigin;
@property (nonatomic, assign) CGSize frameSize;
@property (nonatomic, assign) CGFloat boundsX;
@property (nonatomic, assign) CGFloat boundsY;
@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGFloat boundsHeight;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@end
