//
//  AppDelegate.m
//  three d touch prototype
//
//  Created by Basil Safwat on 21/02/2016.
//  Copyright © 2016 Basil Safwat. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // set up a bridge object called "bridge"
    CPhidgetBridge_create(&bridge);
    
    // open the first detected bridge over the IP shown
    CPhidget_openRemoteIP((CPhidgetHandle)bridge, -1, "127.0.0.1", 5001, NULL);
    
    // set up a serial number
    int serialNum = 0;
    
    // pause and wait for a bridge to be attached
    CPhidget_waitForAttachment((CPhidgetHandle)bridge, 10000);
    
    // grab the serial number from the bridge
    CPhidget_getSerialNumber((CPhidgetHandle)bridge, &serialNum);
    
    // output a success message
    NSLog(@"%d attached!", serialNum);
    
    //  Get a data point from Analog Port 0

    int i;
    
    for(i=0;i<4;i++)
    {
        double sensorValue = 0.0;
        CPhidgetBridge_Gain gain;
        CPhidgetBridge_getBridgeValue(bridge, i, &sensorValue);
        
        // output a data point
        NSLog(@"== Input %d =====================", i);
        NSLog(@"Gain: %d", CPhidgetBridge_getGain(bridge, i, &gain));
        NSLog(@"\n");
        NSLog(@"Value: %f", sensorValue);

    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"Closing connection to the bridge");
    CPhidget_close((CPhidgetHandle)bridge);
    CPhidget_delete((CPhidgetHandle)bridge);
    
}

@end
