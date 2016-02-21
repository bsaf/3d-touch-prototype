//
//  ViewController.h
//  three d touch prototype
//
//  Created by Basil Safwat on 21/02/2016.
//  Copyright © 2016 Basil Safwat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "phidget21.h"

@interface ViewController : UIViewController {
    CPhidgetBridgeHandle bridge;
}

@property (weak, nonatomic) IBOutlet UILabel *dataPoint;
@property (weak, nonatomic) IBOutlet UISlider *dataSlider;

- (void)updateDataPoint:(NSNumber *) val;


@end

