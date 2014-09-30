//
//  ZumoRobotManager.h
//  ZumoRobotController
//
//  Created by Cătălin Crăciun on 30/09/14.
//  Copyright (c) 2014 Cătălin Crăciun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZumoRobotManager : NSObject

@property (nonatomic) BOOL connectedToDevice;

- (void)connectToDevice;
- (void)disconnectFromDevice;

+ (ZumoRobotManager *)sharedZumoRobotManager;

@end
