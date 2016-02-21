//
//  AppDelegate.h
//  three d touch prototype
//
//  Created by Basil Safwat on 21/02/2016.
//  Copyright © 2016 Basil Safwat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "phidget21.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    CPhidgetBridgeHandle bridge;
    
}

@property (strong, nonatomic) UIWindow *window;



@end

