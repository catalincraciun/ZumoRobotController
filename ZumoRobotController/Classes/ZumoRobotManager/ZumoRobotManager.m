//
//  ZumoRobotManager.m
//  ZumoRobotController
//
//  Created by Cătălin Crăciun on 30/09/14.
//  Copyright (c) 2014 Cătălin Crăciun. All rights reserved.
//

#import "ZumoRobotManager.h"

@implementation ZumoRobotManager

#pragma mark - Talking with the device
- (void)connectToDevice {
    // Connecting to the bluetooth
    self.connectedToDevice = YES;
}

- (void)disconnectFromDevice {
    // Disconnecting from the bluetooth
    self.connectedToDevice = YES;
}

#pragma mark - Singleton part
static ZumoRobotManager *_sharedInstance = nil;

+ (ZumoRobotManager *)sharedZumoRobotManager {
    
    @synchronized ([ZumoRobotManager class]) {
        if (!_sharedInstance) {
            _sharedInstance = [[ZumoRobotManager alloc] init];
        }
        
        return _sharedInstance;
    }
    
    return nil;
}

+ (id)alloc {
    
    @synchronized ([ZumoRobotManager class]) {
        NSAssert(self!=nil, @"*** Attempting to allocate a second instance of ZumoRobotManager");
        _sharedInstance = [super alloc];
        
        return _sharedInstance;
    }
        
    return nil;
}

- (instancetype)init {
    
    if (self = [super init]) {
        NSLog(@"*** ZumoRobotManager - Shared instance initialised");
        
    }
    
    return self;
}

@end
