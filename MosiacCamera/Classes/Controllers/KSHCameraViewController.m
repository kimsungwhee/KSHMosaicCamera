//
//  KSHCameraViewController.m
//  MosiacCamera
//
//  Created by 金聖輝 on 14/12/12.
//  Copyright (c) 2014年 kimsungwhee.com. All rights reserved.
//

#import "KSHCameraViewController.h"
#import "KSHCameraController.h"
#import "KSHPreviewView.h"
#import "KSHCaptureButton.h"
#import "KSHContextManager.h"
#import "KSHOverlayView.h"

static void *CameraTorchModeObservationContext     = &CameraTorchModeObservationContext;

@interface KSHCameraViewController () <KSHPreviewViewDelegate>
@property (nonatomic, strong) KSHCameraController *cameraController;
@property (strong, nonatomic) KSHPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *cameraFlashButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *cameraSwitchButton;
@property (weak, nonatomic) IBOutlet KSHOverlayView *overlayView;
@end

@implementation KSHCameraViewController

- (void)dealloc {
	[self.cameraController removeObserver:self forKeyPath:@"torchMode"];
}

- (KSHCameraController *)cameraController {
	if (!_cameraController) {
		_cameraController = [[KSHCameraController alloc] init];
	}
	return _cameraController;
}

-(KSHPreviewView *)previewView
{
    if (!_previewView) {
        _previewView = [[KSHPreviewView alloc] initWithFrame:self.view.bounds context:[KSHContextManager sharedInstance].eaglContext];
    }
    return _previewView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.overlayView.tapToFocusEnabled = self.cameraController.cameraSupportsTapToFocus;
    self.overlayView.tapToExposeEnabled = self.cameraController.cameraSupportsTapToExpose;
    self.overlayView.tapedHandelDelegate = self;
    
    self.previewView.coreImageContext = [KSHContextManager sharedInstance].ciContext;
    
    self.cameraController.imageTarget = self.previewView;
    [self.view insertSubview:self.previewView atIndex:0];
    
    
    self.cameraController.sessionPreset = AVCaptureSessionPreset1280x720;
    
    self.overlayView.session = self.cameraController.captureSession;
    
    NSError *error;
	if ([self.cameraController setupSession:&error]) {
		[self.cameraController startSession];
	}
	else {
		NSLog(@"%@", error.localizedDescription);
	}
    
    
	if ([self.cameraController cameraHasTorch]) {
		[self.cameraController addObserver:self forKeyPath:@"torchMode" options:NSKeyValueObservingOptionNew context:CameraTorchModeObservationContext];
	}
	else {
		self.cameraFlashButton.hidden = YES;
	}
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (IBAction)switchFlashButtonPressed:(UIButton *)sender {
	switch (self.cameraController.torchMode) {
		case AVCaptureTorchModeOff:
			self.cameraController.torchMode = AVCaptureTorchModeOn;
			break;

		case AVCaptureTorchModeOn:
			self.cameraController.torchMode = AVCaptureTorchModeAuto;
			break;

		case AVCaptureTorchModeAuto:
			self.cameraController.torchMode = AVCaptureTorchModeOff;
			break;

		default:
			break;
	}
}

- (IBAction)switchCameraButtonPressed:(UIButton *)sender {
	if ([self.cameraController canSwitchCameras]) {
		[self.cameraController switchCameras];
	}
}

- (IBAction)recordButtonPressed:(KSHCaptureButton *)sender {
    if (!self.cameraController.isRecording) {
        sender.selected = YES;
        [self.cameraController startRecording];
        [self updateOverLayer];
        [self startTimer];
    }else{
        sender.selected = NO;
        [self.cameraController stopRecording];
        [self updateOverLayer];
        [self stopTimer];
    }
}
- (IBAction)filterEnableButtonPressed:(UIButton *)sender {
    if (self.cameraController.filterEnable) {
        self.cameraController.filterEnable = NO;
        [sender setImage:[UIImage imageNamed:@"OnOffButton_off"] forState:UIControlStateNormal];
    }else{
        self.cameraController.filterEnable = YES;
        
        [sender setImage:[UIImage imageNamed:@"OnOffButton_on"] forState:UIControlStateNormal];
    }
        
}

- (void)updateOverLayer
{
    if (!self.cameraController.isRecording) {
        [UIView animateWithDuration:0.2 animations:^{
            self.cameraFlashButton.transform = CGAffineTransformMakeTranslation(0, -60);
            self.cameraFlashButton.alpha = 0;
            self.cameraSwitchButton.transform = CGAffineTransformMakeTranslation(0,-60);
            self.cameraSwitchButton.alpha = 0;
        } completion:^(BOOL finished) {
            
            self.timerViewTopConstraint.constant = 0;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
            } completion:nil];
        }];
    }else{
        self.timerViewTopConstraint.constant = -25;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:.5 options:0 animations:^{
                self.cameraFlashButton.transform = CGAffineTransformIdentity;
                self.cameraFlashButton.alpha = 1;
                self.cameraSwitchButton.transform = CGAffineTransformIdentity;
                self.cameraSwitchButton.alpha = 1;
            } completion:nil];
        }];
    }
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(updateTimeDisplay)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)updateTimeDisplay {
    NSUInteger time = self.cameraController.recordedDuration;
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i:%02i";
    NSString *timeString = [NSString stringWithFormat:format, hours, minutes, seconds];
    self.timerLabel.text = timeString;
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    self.timerLabel.text  = @"00:00:00";
}

#pragma mark- update View Status

- (void)updateFlashButtonByTochMode:(AVCaptureTorchMode)touchMode {
	switch (touchMode) {
		case AVCaptureTorchModeOff:
			[self.cameraFlashButton setImage:[UIImage imageNamed:@"SwitchFlash_off"] forState:UIControlStateNormal];
			break;

		case AVCaptureTorchModeOn:
			[self.cameraFlashButton setImage:[UIImage imageNamed:@"SwitchFlash_on"] forState:UIControlStateNormal];
			break;

		case AVCaptureTorchModeAuto:
			[self.cameraFlashButton setImage:[UIImage imageNamed:@"SwitchFlash_auto"] forState:UIControlStateNormal];
			break;

		default:
			break;
	}
}

#pragma mark- KSHPreviewViewDelegate
- (void)tappedToFocusAtPoint:(CGPoint)point {
    [self.cameraController focusAtPoint:point];
}

- (void)tappedToExposeAtPoint:(CGPoint)point {
    [self.cameraController exposeAtPoint:point];
}

- (void)tappedToResetFocusAndExposure {
    [self.cameraController resetFocusAndExposureModes];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == CameraTorchModeObservationContext) {
		[self updateFlashButtonByTochMode:(AVCaptureTorchMode)[change[@"new"] intValue]];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
