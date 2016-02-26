//
//  ViewController.m
//  three d touch prototype
//
//  Created by Basil Safwat on 21/02/2016.
//  Copyright © 2016 Basil Safwat. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

- (void)updateDataPoint:(NSNumber *) val;

@property (weak, nonatomic) IBOutlet UILabel *dataPoint;
@property (weak, nonatomic) IBOutlet UISlider *dataSlider;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) UIImageView *overlayView;
@property (strong, nonatomic) UIVisualEffectView *visualEffectView;
@property (weak, nonatomic) IBOutlet UIImageView *safariIcon;

@end

bool lowValue = true;

int gotAttach(CPhidgetHandle phid, void *context) {
    
    // ## TODO
    // use `dispatch_async` or `performSelectorOnMainThread` for all this stuff
    // see DeviceAttach example here: http://www.phidgets.com/docs/Language_-_iOS
    int serial;
    int enabled = -1;
    CPhidget_getSerialNumber((CPhidgetHandle)phid, &serial);
    CPhidgetBridge_setEnabled((CPhidgetBridgeHandle)phid, 0, 1);
    CPhidgetBridge_getEnabled((CPhidgetBridgeHandle)phid, 0, &enabled);
    NSLog(@"Enabled: %d", enabled);
    
    NSLog(@"Let's give a warm welcome to %d!", serial);
    
    return 0;
}

int gotDetatch(CPhidgetHandle phid, void *context) {
    
    // use dispatch async on this stuff too
    int serial;
    CPhidget_getSerialNumber((CPhidgetHandle)phid, &serial);
    
    NSLog(@"Goodbye %d!", serial);
    
    return 0;
}

int gotBridgeData(CPhidgetBridgeHandle phid, void *context, int ind, double val) {
    
    // TODO low - use dispatch async
    [(__bridge id)context performSelectorOnMainThread:@selector(updateDataPoint:)
                                  withObject: [NSNumber numberWithDouble:val]
                               waitUntilDone:NO];
    
    //    NSLog(@"%f", val);
    return 0;
    
}



@implementation ViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataPoint.text = @"HHH";
    
    
    // set up a bridge object called "bridge"
    CPhidgetBridge_create(&bridge);
    
    // set up the handlers
    CPhidget_set_OnAttach_Handler((CPhidgetHandle)bridge, gotAttach, NULL);
    CPhidget_set_OnDetach_Handler((CPhidgetHandle)bridge, gotDetatch, NULL);
    CPhidgetBridge_set_OnBridgeData_Handler(bridge, gotBridgeData, (__bridge void *)(self));
    
    // open the first detected bridge over the IP shown
    //CPhidget_openRemoteIP((CPhidgetHandle)bridge, -1, "127.0.0.1", 5001, NULL);
    CPhidget_openRemoteIP((CPhidgetHandle)bridge, -1, "10.0.1.72", 5001, NULL);
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    _visualEffectView.frame = _image.bounds;
    [_image addSubview:_visualEffectView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateDataPoint:(NSNumber *)val {
    
    double calibratedValue = val.doubleValue;// - 0.6;
    
    if (calibratedValue < 0) {
        calibratedValue = 0;
    }
    
    NSLog(@"%f", val.doubleValue);
    
    _dataPoint.text = [NSString stringWithFormat:@"%f", val.doubleValue];
    _dataSlider.value = val.doubleValue;
    _visualEffectView.alpha = calibratedValue;
    if (calibratedValue > 0.1) {
        _safariIcon.alpha = 1;
    }
    else {
        _safariIcon.alpha = 0;
    }
    
    if (calibratedValue > 0.5 && lowValue) {
        AudioServicesPlaySystemSound (1105);
        lowValue = false;
    }
    else if (calibratedValue < 0.5 && !lowValue) {
        AudioServicesPlaySystemSound (1105);
        lowValue = true;
    }
}

@end
