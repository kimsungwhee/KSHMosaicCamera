//
//  KSHCameraController.h
//  MosiacCamera
//
//  Created by 金聖輝 on 14/11/30.
//  Copyright (c) 2014年 kimsungwhee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KSHImageTarget.h"


#define KSHThumbnailCreatedNotification @"KSHThumbnailCreated"

@protocol KSHCameraControllerDelegate <NSObject>
- (void)deviceConfigurationFailedWithError:(NSError*)error;
- (void)mediaCaptureFailedWithError:(NSError*)error;
- (void)assetLibraryWriteFailedWithError:(NSError*)error;
@end

@interface KSHCameraController : NSObject
@property (nonatomic, weak) id <KSHCameraControllerDelegate> delegate;
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
@property (nonatomic, assign, readonly) NSUInteger cameraCount;
@property (nonatomic, assign, readonly) BOOL cameraHasTorch;
@property (nonatomic, assign, readonly) BOOL cameraHasFlash;
@property (nonatomic, assign, readonly) BOOL cameraSupportsTapToFocus;
@property (nonatomic, assign, readonly) BOOL cameraSupportsTapToExpose;
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign, readonly) NSTimeInterval recordedDuration;
@property (nonatomic, copy) NSString *sessionPreset;
@property (nonatomic, weak) id<KSHImageTarget> imageTarget;
@property (nonatomic, assign) BOOL filterEnable;

- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;

- (BOOL)switchCameras;
- (BOOL)canSwitchCameras;

- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;

- (void)captureStillImage;

- (void)startRecording;
- (void)stopRecording;
- (BOOL)isRecording;
@end
