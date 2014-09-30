//
//  ViewController.m
//  ZumoRobotController
//
//  Created by Cătălin Crăciun on 29/09/14.
//  Copyright (c) 2014 Cătălin Crăciun. All rights reserved.
//

#import "ViewController.h"
#import "ZumoRobotManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)disconnectButtonPressed:(UIButton *)sender {
    NSLog(@"Disconnecting...");
    [[ZumoRobotManager sharedZumoRobotManager] disconnectFromDevice];
}


- (IBAction)connectButtonPressed:(UIButton *)sender {
    NSLog(@"Connecting to your bluetooth device...");
    [[ZumoRobotManager sharedZumoRobotManager] connectToDevice];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
