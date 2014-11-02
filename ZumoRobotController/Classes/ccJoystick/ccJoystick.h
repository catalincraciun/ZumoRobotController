//
//  ccJoystick.h
//  ZumoRobotController
//
//  Created by Cătălin Crăciun on 29/09/14.
//  Copyright (c) 2014 Cătălin Crăciun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ccJoystickDelegate <NSObject>
- (void)velocityDidChangeWithX:(float)velX andY:(float)velY withPriority:(BOOL)priority;
@end

@interface ccJoystick : UIView

@property (nonatomic) id<ccJoystickDelegate> delegate;

@property (nonatomic) float velocityX;
@property (nonatomic) float velocityY;

@end
