//
//  ZumoRobotManager.h
//  ZumoRobotController
//
//  Created by Cătălin Crăciun on 30/09/14.
//  Copyright (c) 2014 Cătălin Crăciun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol ZumoRobotManagerDelegate <NSObject>
- (void)log:(NSString *)string;
@end

@interface ZumoRobotManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, retain) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *selectedPeripheral;

@property (strong, nonatomic) CBCharacteristic *characteristics;

@property (nonatomic) BOOL connectedToDevice;

@property (nonatomic) id<ZumoRobotManagerDelegate> delegate;

- (void)connectToDevice;
- (void)disconnectFromDevice;

- (void)sendString:(NSString *)str avoidingRestriction:(BOOL)avoid;
- (NSString *)stringForVelocityX:(float)velX andY:(float)velY;

+ (ZumoRobotManager *)sharedZumoRobotManager;

@end
