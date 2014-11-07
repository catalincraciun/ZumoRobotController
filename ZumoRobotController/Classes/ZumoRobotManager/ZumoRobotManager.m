//
//  ZumoRobotManager.m
//  ZumoRobotController
//
//  Created by Cătălin Crăciun on 30/09/14.
//  Copyright (c) 2014 Cătălin Crăciun. All rights reserved.
//

#import "ZumoRobotManager.h"

@interface ZumoRobotManager () {
    
    int transmissionIntervalRestriction;
}

@end

@implementation ZumoRobotManager

#pragma mark - Bluetooth part
/**
 *
 * Sends a string to the ZumoRobot
 *
 * @param avoid It forces to string to be sent the moment it has been received
 *
 */
- (void)sendString:(NSString *)str avoidingRestriction:(BOOL)avoid {
    if (transmissionIntervalRestriction >= 5 || avoid) {
        transmissionIntervalRestriction = 0;
        str = [str stringByAppendingString:@"\n"];
        for (CBService * service in [_selectedPeripheral services]) {
            for (CBCharacteristic * characteristic in [service characteristics]) {
                [_selectedPeripheral writeValue:[str dataUsingEncoding:NSUTF8StringEncoding]
                              forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            }
        }
    }
}

/**
 *
 * String to be sent pattern
 *
 * l1l2s1s2a1..al1b1..bl2
 *
 * l1, l2 = the length of the floats
 * s1, s2 = the sign of the floats
 * a1..al1 = the digits after .
 * b1..bl2 = the digits after .
 *
 * Numbers sent should be <= 1
 *
 */
- (NSString *)stringForVelocityX:(float)velX andY:(float)velY {
    
    // For sending a float which is less than 1
    NSString *stringToSend = @"";

    NSString *s1, *s2;
    if (velX > 0)
        s1 = @"+";
    else {
        s1 = @"-";
        velX = -velX;
    }
    if (velY > 0)
        s2 = @"+";
    else {
        s2 = @"-";
        velY = -velY;
    }
    
    stringToSend = [stringToSend stringByAppendingString:s1];
    stringToSend = [stringToSend stringByAppendingString:s2];
    
    int decsVelXInt = (velX - (int)velX) * 100;
    int decsVelYInt = (velY - (int)velY) * 100;
    
    int p = 10;
    while (p >= 1) {
        stringToSend = [stringToSend stringByAppendingFormat:@"%d", decsVelXInt / p];
        decsVelXInt = decsVelXInt % p;
        p /= 10;
    }
    
    p = 10;
    while (p >= 1) {
        stringToSend = [stringToSend stringByAppendingFormat:@"%d", decsVelYInt / p];
        decsVelYInt = decsVelYInt % p;
        p /= 10;
    }

    return stringToSend;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    [self.delegate log:@"Discovered descriptor"];
    //Store data from the UUID in byte format, save in the bytes variable.
    const char * bytes =[(NSData*)[[characteristic UUID] data] bytes];
    //Check to see if it is two bytes long, and they are both FF and E1.
    if (bytes && strlen(bytes) == 2 && bytes[0] == (char)255 && bytes[1] == (char)225) {
        // We set the connected peripheral data to the instance peripheral data.
        self.selectedPeripheral = peripheral;
        for (CBService * service in [self.selectedPeripheral services])
        {
            for (CBCharacteristic * characteristic in [service characteristics])
            {
                // For every characteristic on every service, on the connected peripheral
                // set the setNotifyValue to true.
                [self.selectedPeripheral setNotifyValue:true forCharacteristic:characteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    [self.delegate log:@"Discovered characterisic"];
    for (CBCharacteristic *charact in service.characteristics) {
        [peripheral discoverDescriptorsForCharacteristic:charact];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    [self.delegate log:@"Discovered service in peripheral"];
    for (CBService *service in [peripheral services]) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [self.delegate log:@"Succeded to connect to peripheral!"];
    
    // Setting up the peripheral
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *uuidOfDevice = [[peripheral identifier] UUIDString];
    
    if (uuidOfDevice) {
        [self.delegate log:[NSString stringWithFormat:@"Discovered peripherial with UUID: %@", uuidOfDevice]];
        self.selectedPeripheral = peripheral;
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if (central.state != CBCentralManagerStatePoweredOn) {
        [self.delegate log:@"Bluetooth should be turned on!"];
        return;
    } else {
        [self.delegate log:@"Scanning for bluetooth devices..."];
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}

#pragma mark - Talking with the device
- (void)connectToDevice {
    // Connecting to the bluetooth
    if (!self.connectedToDevice) {
        self.connectedToDevice = YES;
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    } else {
        [self.delegate log:@"Already connected to device"];
    }
}

- (void)disconnectFromDevice {
    // Disconnecting from the bluetooth
    if (self.connectedToDevice) {
        [self.delegate log:@"Disconnecting"];
        self.connectedToDevice = NO;
        self.centralManager = nil;
    } else {
        [self.delegate log:@"Not connected to any device!"];
    }
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

- (void)updateCounter {
 
    // Increasing the number of 0.05 units since last transmission
    transmissionIntervalRestriction++;
}

- (instancetype)init {
    
    if (self = [super init]) {
        NSLog(@"*** ZumoRobotManager - Shared instance initialised");
        self.connectedToDevice = NO;
        NSTimer *timer = [NSTimer timerWithTimeInterval:(NSTimeInterval)0.05f target:self selector:@selector(updateCounter) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [timer fire];
    }
    
    return self;
}

@end
