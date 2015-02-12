//
//  KSHOverlayView.h
//  MosiacCamera
//
//  Created by 金聖輝 on 14/12/13.
//  Copyright (c) 2014年 kimsungwhee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol KSHPreviewViewDelegate<NSObject>
- (void)tappedToFocusAtPoint:(CGPoint)point;
- (void)tappedToExposeAtPoint:(CGPoint)point;
- (void)tappedToResetFocusAndExposure;
@end

@interface KSHOverlayView : UIView
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak) id <KSHPreviewViewDelegate> tapedHandelDelegate;

@property (nonatomic, assign) BOOL tapToFocusEnabled;
@property (nonatomic, assign) BOOL tapToExposeEnabled;
@end
