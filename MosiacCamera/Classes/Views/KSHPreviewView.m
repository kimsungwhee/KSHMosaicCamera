//
//  KSHPreviewView.m
//  MosiacCamera
//
//  Created by 金聖輝 on 14/11/30.
//  Copyright (c) 2014年 kimsungwhee.com. All rights reserved.
//

#import "KSHPreviewView.h"



@interface KSHPreviewView()
@property (nonatomic) CGRect drawableBounds;
@end

@implementation KSHPreviewView

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context
{
    if (self = [super initWithFrame:frame context:context]) {
        self.enableSetNeedsDisplay = NO;
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;
        
        // because the native video image from the back camera is in
        // UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right),
        // we need to apply a clockwise 90 degree transform so that we can draw
        // the video preview as if we were in a landscape-oriented view;
        // if you're using the front camera and you want to have a mirrored
        // preview (so that the user is seeing themselves in the mirror), you
        // need to apply an additional horizontal flip (by concatenating
        // CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.frame = frame;
        
        [self bindDrawable];
        _drawableBounds = self.bounds;
        _drawableBounds.size.width = self.drawableWidth;
        _drawableBounds.size.height = self.drawableHeight;
    }
    return self;
}



- (void)updateContentImage:(CIImage*)image
{
    [self bindDrawable];
    
    [self.coreImageContext drawImage:image
                              inRect:self.drawableBounds
                            fromRect:image.extent];
    [self display];
}
@end
