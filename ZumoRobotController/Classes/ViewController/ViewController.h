//
//  ViewController.h
//  ZumoRobotController
//
//  Created by Cătălin Crăciun on 29/09/14.
//  Copyright (c) 2014 Cătălin Crăciun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZRJoystick.h"
#import "ZumoRobotManager.h"

@interface ViewController : UIViewController <ZRJoystickDelegate, ZumoRobotManagerDelegate>

@end

