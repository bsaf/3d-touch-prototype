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

@property (weak, nonatomic)   IBOutlet UILabel     *dataPoint;
@property (weak, nonatomic)   IBOutlet UISlider    *dataSlider;
@property (weak, nonatomic)   IBOutlet UIImageView *image;
@property (weak, nonatomic)   IBOutlet UIImageView *safariIcon;

@property (strong, nonatomic) UIImageView          *overlayView;
@property (strong, nonatomic) UIVisualEffectView   *visualEffectView;

@end

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
    
    [(__bridge id)context performSelectorOnMainThread:@selector(updateDataPoint:)
                          withObject: [NSNumber numberWithDouble:val]
                          waitUntilDone:NO];
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

double clickPoint = 0.8;
double sensitivity = 1.3;
int points = 0;
bool lowValue = true;

- (void)updateDataPoint:(NSNumber *)val {
    
    double calibratedValue = (val.doubleValue - 0.4) * sensitivity;
    
    if (calibratedValue < 0) {
        calibratedValue = 0;
    }
    
    // don't log *everything*
    if (points >= 10) {
        NSLog(@"%f", val.doubleValue);
        points = 0;
    }
    else {
        points = points + 1;
    }
    
    _dataPoint.text = [NSString stringWithFormat:@"%f", val.doubleValue];
    _dataSlider.value = val.doubleValue;
    _visualEffectView.alpha = calibratedValue;
    if (calibratedValue > 0.1) {
        _safariIcon.alpha = 1;
    }
    else {
        _safariIcon.alpha = 0;
    }
    
    if (calibratedValue > clickPoint && lowValue) {
        AudioServicesPlaySystemSound (1105);
        lowValue = false;
    }
    else if (calibratedValue < clickPoint && !lowValue) {
        AudioServicesPlaySystemSound (1105);
        lowValue = true;
    }
}

@end
