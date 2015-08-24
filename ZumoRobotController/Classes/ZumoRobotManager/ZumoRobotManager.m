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
    bool silentIncorectPassword;
}

@end

@implementation ZumoRobotManager

#pragma mark - Bluetooth part

/**
 *
 * Tries to unlock the bluetooth device by sending it a password
 *
 */
- (void)sendConnectionRequestWithPassword:(NSString *)passwordToSend {
    
    passwordToSend = [passwordToSend stringByAppendingString:@"$"];
    passwordToSend = [passwordToSend stringByAppendingString:@"\n"];
    
    for (int i=0;i<5;i++)
        for (CBService *service in [_selectedPeripheral services])
            for (CBCharacteristic *characteristic in [service characteristics])
                [_selectedPeripheral writeValue:[passwordToSend dataUsingEncoding:NSUTF8StringEncoding]
                              forCharacteristic:characteristic
                                           type:CBCharacteristicWriteWithoutResponse];
}

/**
 *
 * Sends a string to the ZumoRobot
 *
 * @param avoid It forces to string to be sent the moment it has been received
 *
 */
- (void)sendString:(NSString *)str avoidingRestriction:(BOOL)avoid {
    
    if (self.connectedToDevice) {
        if (transmissionIntervalRestriction >= 5 || avoid) {
            transmissionIntervalRestriction = 0;
            str = [str stringByAppendingString:@"\n"];
            NSLog(@"%@", str);
            for (CBService *service in [_selectedPeripheral services])
                for (CBCharacteristic *characteristic in [service characteristics])
                    [_selectedPeripheral writeValue:[str dataUsingEncoding:NSUTF8StringEncoding]
                                  forCharacteristic:characteristic
                                               type:CBCharacteristicWriteWithoutResponse];
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

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [self.delegate log:[NSString stringWithFormat:@"Disconnected from peripheral with UUID: %@", [[peripheral identifier] UUIDString]] silently:YES];
    self.connectedToDevice = NO;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [self.delegate log:@"Connection to the peripheral failed! Check for errors!" silently:NO];
    self.connectedToDevice = NO;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    // Reading the informations comming from the robot
    const char *toRead = characteristic.value.bytes;
    if (toRead[0] == '$' &&
        toRead[1] == 's' &&
        toRead[2] == 'u' &&
        toRead[3] == 'c') {
        
        // Received the message that the password was correct
        self.connectedToDevice = true;
        silentIncorectPassword = YES;
        [self.delegate log:@"Password was correct! Access granted!" silently:NO];
    } else if (toRead[0] == '$' &&
               toRead[1] == 'f' &&
               toRead[2] == 'a' &&
               toRead[3] == 'i') {
        
        // Received the message that the password was wrong
        self.connectedToDevice = false;
        [self.delegate log:@"Incorrect password! Failed to connect to the bluetooth device" silently:!silentIncorectPassword];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    [self.delegate log:@"Discovered descriptor" silently:YES];
    self.selectedPeripheral = peripheral;
    for (CBService * service in [_selectedPeripheral services])
        for (CBCharacteristic * characteristic in [service characteristics])
            [_selectedPeripheral setNotifyValue:true forCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    [self.delegate log:@"Discovered characterisic" silently:YES];
    for (CBCharacteristic *charact in service.characteristics) {
        [peripheral discoverDescriptorsForCharacteristic:charact];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    [self.delegate log:@"Discovered service in peripheral" silently:YES];
    for (CBService *service in [peripheral services]) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [self.delegate log:@"Succeded to connect to peripheral!" silently:YES];
    
    // Setting up the peripheral
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *uuidOfDevice = [[peripheral identifier] UUIDString];
    
    if (uuidOfDevice) {
        [self.delegate log:[NSString stringWithFormat:@"Discovered peripherial with UUID: %@", uuidOfDevice] silently:NO];
        self.selectedPeripheral = peripheral;
        [central connectPeripheral:peripheral options:nil];
        
        // Showing an UIAlertController for getting the bluetooth's password from the user
        UIAlertController *passwordAlert = [UIAlertController alertControllerWithTitle:@"Stop! Connection needs password!"
                                                                               message:@"Enter the password in order to get access to the bluetooth device"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        
        [passwordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.secureTextEntry = true;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.keyboardAppearance = UIKeyboardAppearanceDark;
        }];
        [passwordAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
        [passwordAlert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *field = passwordAlert.textFields.firstObject;
            [[ZumoRobotManager sharedZumoRobotManager] sendConnectionRequestWithPassword:field.text];
        }]];
        
        [self.delegate presentViewController:passwordAlert animated:YES completion:nil];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if (central.state != CBCentralManagerStatePoweredOn) {
        [self.delegate log:@"Bluetooth should be turned on!" silently:NO];
        return;
    } else {
        [self.delegate log:@"Scanning for bluetooth devices..." silently:NO];
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}

#pragma mark - Talking with the device
- (void)connectToDevice {
    
    // Connecting to the bluetooth
    if (!self.connectedToDevice) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    } else {
        [self.delegate log:@"Already connected to device" silently:NO];
    }
}

- (void)disconnectFromDevice {
    
    // Disconnecting from the bluetooth
    if (self.connectedToDevice) {
        [self.delegate log:@"Disconnecting..." silently:NO];
        // Forcing the sending of "disconnect message" with a for loop
        for (int i=0;i<5;i++) {
            [[ZumoRobotManager sharedZumoRobotManager] sendString:@"$out" avoidingRestriction:YES];
            // Another way of sleeping your program than sleep or wait
            for (int j=0;j<=10000000;j++) { int x; x=0; }
        }
        
        silentIncorectPassword = NO;
        self.connectedToDevice = false;
        self.centralManager = nil;
    } else {
        [self.delegate log:@"Not connected to any device!" silently:NO];
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
        silentIncorectPassword = NO;
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:(NSTimeInterval)0.05f target:self selector:@selector(updateCounter) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [timer fire];
    }
    
    return self;
}

@end
