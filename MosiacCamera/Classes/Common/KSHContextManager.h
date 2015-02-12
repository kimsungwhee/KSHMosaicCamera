//
//  KSHContextManager.h
//  MosiacCamera
//
//  Created by 金聖輝 on 14/12/14.
//  Copyright (c) 2014年 kimsungwhee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface KSHContextManager : NSObject
+ (instancetype)sharedInstance;
@property (strong, nonatomic, readonly) EAGLContext *eaglContext;
@property (strong, nonatomic, readonly) CIContext *ciContext;
@end
