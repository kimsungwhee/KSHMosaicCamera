//
//  KSHOverlayView.m
//  MosiacCamera
//
//  Created by 金聖輝 on 14/12/13.
//  Copyright (c) 2014年 kimsungwhee.com. All rights reserved.
//

#import "KSHOverlayView.h"

#define BOX_BOUNDS CGRectMake(0.0f, 0.0f, 150, 150.0f)

@interface KSHOverlayView()
@property (nonatomic, strong) UIView *focusBox;
@property (nonatomic, strong) UIView *exposureBox;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleDoubleTapRecognizer;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation KSHOverlayView

//-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    id hitView = [super hitTest:point withEvent:event];
//    if (hitView == self) return nil;
//    else return hitView;
//}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupView];
    }
    return self;
}

-(void)setupView
{
    _singleTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    _doubleTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    _doubleTapRecognizer.numberOfTapsRequired = 2;
    
    _doubleDoubleTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleDoubleTap:)];
    _doubleDoubleTapRecognizer.numberOfTapsRequired = 2;
    _doubleDoubleTapRecognizer.numberOfTouchesRequired = 2;
    
    [self addGestureRecognizer:_singleTapRecognizer];
    [self addGestureRecognizer:_doubleTapRecognizer];
    [self addGestureRecognizer:_doubleDoubleTapRecognizer];
    [_singleTapRecognizer requireGestureRecognizerToFail:_doubleTapRecognizer];
    
    _focusBox = [self viewWithColor:[UIColor colorWithRed:0.102 green:0.636 blue:1.000 alpha:1.000]];
    _exposureBox = [self viewWithColor:[UIColor colorWithRed:1.000 green:0.421 blue:0.054 alpha:1.000]];
    [self addSubview:_focusBox];
    [self addSubview:_exposureBox];
}

- (void)setSession:(AVCaptureSession *)session
{
    [self.previewLayer setSession:session];
}

- (UIView *)viewWithColor:(UIColor *)color {
    UIView *view = [[UIView alloc] initWithFrame:BOX_BOUNDS];
    view.backgroundColor = [UIColor clearColor];
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = 5.0f;
    view.hidden = YES;
    return view;
}

/**
 *  @author Kim SungWhee, 14-11-30 19:11:09
 *
 *  @brief  对角Gesture
 *
 *  @param recognizer
 */
- (void)handleSingleTap:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    [self runBoxAnimationOnView:self.focusBox point:point];
    if (self.tapedHandelDelegate) {
        [self.tapedHandelDelegate tappedToFocusAtPoint:[self captureDevicePointForPoint:point]];
    }
}

/**
 *  @author Kim SungWhee, 14-11-30 19:11:33
 *
 *  @brief  转换坐标
 *
 *  @param point UIViewPoint
 *
 *  @return 相机坐标系
 */
- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer =self.previewLayer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

/**
 *  @author Kim SungWhee, 14-11-30 19:11:05
 *
 *  @brief  曝光Gesture
 *
 *  @param recognizer
 */
- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    [self runBoxAnimationOnView:self.exposureBox point:point];
    if (self.tapedHandelDelegate) {
        [self.tapedHandelDelegate tappedToExposeAtPoint:[self captureDevicePointForPoint:point]];
    }
}

/**
 *  @author Kim SungWhee, 14-11-30 19:11:32
 *
 *  @brief  重置曝光以及对角
 *
 *  @param recognizer
 */
- (void)handleDoubleDoubleTap:(UIGestureRecognizer *)recognizer {
    [self runResetAnimation];
    if (self.tapedHandelDelegate) {
        [self.tapedHandelDelegate tappedToResetFocusAndExposure];
    }
}

/**
 *  @author Kim SungWhee, 14-11-30 19:11:59
 *
 *  @brief  曝光，对象动画
 *
 *  @param view
 *  @param point
 */
- (void)runBoxAnimationOnView:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
                     }
                     completion:^(BOOL complete) {
                         double delayInSeconds = 0.5f;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             view.hidden = YES;
                             view.transform = CGAffineTransformIdentity;
                         });
                     }];
}

/**
 *  @author Kim SungWhee, 14-11-30 19:11:25
 *
 *  @brief  重置动画
 */
- (void)runResetAnimation {
    if (!self.tapToFocusEnabled && !self.tapToExposeEnabled) {
        return;
    }
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    CGPoint centerPoint = [previewLayer pointForCaptureDevicePointOfInterest:CGPointMake(0.5f, 0.5f)];
    self.focusBox.center = centerPoint;
    self.exposureBox.center = centerPoint;
    self.exposureBox.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.focusBox.hidden = NO;
    self.exposureBox.hidden = NO;
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.focusBox.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
                         self.exposureBox.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0);
                     }
                     completion:^(BOOL complete) {
                         double delayInSeconds = 0.5f;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             self.focusBox.hidden = YES;
                             self.exposureBox.hidden = YES;
                             self.focusBox.transform = CGAffineTransformIdentity;
                             self.exposureBox.transform = CGAffineTransformIdentity;
                         });
                     }];
}

/**
 *  @author Kim SungWhee, 14-11-30 19:11:40
 *
 *  @brief  设置对角时候可用
 *
 *  @param enabled
 */
- (void)setTapToFocusEnabled:(BOOL)enabled {
    _tapToFocusEnabled = enabled;
    self.singleTapRecognizer.enabled = enabled;
}

/**
 *  @author Kim SungWhee, 14-11-30 19:11:08
 *
 *  @brief  设置曝光是否可用
 *
 *  @param enabled <#enabled description#>
 */
- (void)setTapToExposeEnabled:(BOOL)enabled {
    _tapToExposeEnabled = enabled;
    self.doubleTapRecognizer.enabled = enabled;
}

@end
