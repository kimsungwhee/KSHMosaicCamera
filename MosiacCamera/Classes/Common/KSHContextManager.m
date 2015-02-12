//
//  KSHContextManager.m
//  MosiacCamera
//
//  Created by 金聖輝 on 14/12/14.
//  Copyright (c) 2014年 kimsungwhee.com. All rights reserved.
//

#import "KSHContextManager.h"

@implementation KSHContextManager

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    static KSHContextManager *instance = nil;
    dispatch_once(&predicate, ^{instance = [[self alloc] init];});
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSDictionary *options = @{kCIContextWorkingColorSpace : [NSNull null]};
        _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:options];
    }
    return self;
}

@end
