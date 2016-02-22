//
//  ViewController.m
//  three d touch prototype
//
//  Created by Basil Safwat on 21/02/2016.
//  Copyright © 2016 Basil Safwat. All rights reserved.
//

#import "ViewController.h"

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

@interface ViewController ()

@end

@implementation ViewController

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
    CPhidget_openRemoteIP((CPhidgetHandle)bridge, -1, "10.0.1.70", 5001, NULL);
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateDataPoint:(NSNumber *)val {
    _dataPoint.text = [NSString stringWithFormat:@"%f", val.doubleValue];
    _dataSlider.value = val.doubleValue;
    if (val.doubleValue > 0.5 && lowValue) {
        AudioServicesPlaySystemSound (1105);
        lowValue = false;
    }
    else if (val.doubleValue < 0.5 && !lowValue) {
        AudioServicesPlaySystemSound (1105);
        lowValue = true;
    }
}

@end
