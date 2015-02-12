//
//  KSHImageTarget.h
//  MosiacCamera
//
//  Created by 金聖輝 on 14/12/14.
//  Copyright (c) 2014年 kimsungwhee.com. All rights reserved.
//
#import <CoreMedia/CoreMedia.h>

@protocol KSHImageTarget <NSObject>
- (void)updateContentImage:(CIImage*)image;
@end
