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
@property (weak, nonatomic)   IBOutlet UIImageView *settingsIcon;
@property (weak, nonatomic)   IBOutlet UIImageView *googlemapsIcon;
@property (weak, nonatomic)   IBOutlet UIImageView *photosIcon;

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
    _safariIcon.alpha = 0;
    _settingsIcon.alpha = 0;
    _googlemapsIcon.alpha = 0;
    _photosIcon.alpha = 0;
    
    // set up a bridge object called "bridge"
    CPhidgetBridge_create(&bridge);
    
    // set up the handlers
    CPhidget_set_OnAttach_Handler((CPhidgetHandle)bridge, gotAttach, NULL);
    CPhidget_set_OnDetach_Handler((CPhidgetHandle)bridge, gotDetatch, NULL);
    CPhidgetBridge_set_OnBridgeData_Handler(bridge, gotBridgeData, (__bridge void *)(self));
    
    // open the first detected bridge over the IP shown
    CPhidget_openRemoteIP((CPhidgetHandle)bridge, -1, "192.168.1.111", 5001, NULL);
    //CPhidget_openRemoteIP((CPhidgetHandle)bridge, -1, "10.0.1.72", 5001, NULL);
    
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
double offset = 0.4;
int points = 0;
bool lowValue = true;
bool logData = false;
int beingTouched = 0;

- (void)updateDataPoint:(NSNumber *)val {
    
    // obviously, never do this
    if (beingTouched == 0) {
        _safariIcon.alpha = 0;
        _settingsIcon.alpha = 0;
        _googlemapsIcon.alpha = 0;
        _photosIcon.alpha = 0;
    }
    else if (beingTouched == 1) {
        _safariIcon.alpha = 1;
    }
    else if (beingTouched == 2) {
        _settingsIcon.alpha = 1;
    }
    else if (beingTouched == 3) {
        _googlemapsIcon.alpha = 1;
    }
    else if (beingTouched == 4) {
        _photosIcon.alpha = 1;
    }
    
    double calibratedValue = (val.doubleValue - offset) * sensitivity;
    
    if (calibratedValue < 0) {
        calibratedValue = 0;
    }
    
    // don't log *everything*
    if (points >= 10 && logData) {
        NSLog(@"%f", val.doubleValue);
        points = 0;
    }
    else {
        points = points + 1;
    }
    
    _dataPoint.text = [NSString stringWithFormat:@"%f", val.doubleValue];
    _dataSlider.value = val.doubleValue;
    _visualEffectView.alpha = calibratedValue;
    
    if (calibratedValue > clickPoint && lowValue) {
        AudioServicesPlaySystemSound (1105);
        lowValue = false;
    }
    else if (calibratedValue < clickPoint && !lowValue) {
        AudioServicesPlaySystemSound (1105);
        lowValue = true;
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    CGRect fingerRect = CGRectMake(location.x-5, location.y-5, 10, 10);

    if(CGRectIntersectsRect(fingerRect, _safariIcon.frame)){
        beingTouched = 1;
    }
    else if(CGRectIntersectsRect(fingerRect, _settingsIcon.frame)){
        beingTouched = 2;
    }
    else if(CGRectIntersectsRect(fingerRect, _googlemapsIcon.frame)){
        beingTouched = 3;
    }
    else if(CGRectIntersectsRect(fingerRect, _photosIcon.frame)){
        beingTouched = 4;
    }
    
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    beingTouched = 0;
}



@end
