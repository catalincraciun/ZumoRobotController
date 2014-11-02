//
//  ViewController.m
//  ZumoRobotController
//
//  Created by Cătălin Crăciun on 29/09/14.
//  Copyright (c) 2014 Cătălin Crăciun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet ccJoystick *joystick;
@property (weak, nonatomic) IBOutlet UITextView *robotsConsole;

@end

@implementation ViewController

#pragma mark - ZumoRobotManager
- (void)log:(NSString *)string {
    
    NSLog(@"%@", string);
    
    NSString *finalMessage = [@"⃝  " stringByAppendingString:string];
    
    self.robotsConsole.text = [[finalMessage stringByAppendingString:@"\n"] stringByAppendingString:self.robotsConsole.text];
}

#pragma mark - ccJoystickDelegate
- (void)velocityDidChangeWithX:(float)velX andY:(float)velY withPriority:(BOOL)priority {
    
    [[ZumoRobotManager sharedZumoRobotManager] sendString:[[ZumoRobotManager sharedZumoRobotManager] stringForVelocityX:velX andY:velY] avoidingRestriction:priority];
}

#pragma mark - Buttons
- (IBAction)lightBlueLed:(id)sender {
    [self log:@"Lighting the blue led"];
    [[ZumoRobotManager sharedZumoRobotManager] sendString:@"cb" avoidingRestriction:YES];
}


- (IBAction)lightGreenLed:(id)sender {
    [self log:@"Lighting the green led"];
    [[ZumoRobotManager sharedZumoRobotManager] sendString:@"cg" avoidingRestriction:YES];
}

- (IBAction)lightRedLed:(id)sender {
    [self log:@"Lighting the red led"];
    [[ZumoRobotManager sharedZumoRobotManager] sendString:@"cr" avoidingRestriction:YES];
}

- (IBAction)disconnectButtonPressed:(UIButton *)sender {
    
    [[ZumoRobotManager sharedZumoRobotManager] disconnectFromDevice];
}


- (IBAction)connectButtonPressed:(UIButton *)sender {
 
    [[ZumoRobotManager sharedZumoRobotManager] connectToDevice];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.joystick.delegate = self;
    [ZumoRobotManager sharedZumoRobotManager].delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
