//
//  ZRJoystick.h
//  ZumoRobotController
//
//  Created by Cătălin Crăciun on 29/09/14.
//  Copyright (c) 2014 Cătălin Crăciun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZRJoystickDelegate <NSObject>
- (void)velocityDidChangeWithX:(float)velX andY:(float)velY withPriority:(BOOL)priority;
@end

IB_DESIGNABLE @interface ZRJoystick : UIView

@property (nonatomic) id<ZRJoystickDelegate> delegate;

@property (nonatomic) float velocityX;
@property (nonatomic) float velocityY;

@end
