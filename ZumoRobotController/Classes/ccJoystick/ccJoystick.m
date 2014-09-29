//
//  ccJoystick.m
//  ZumoRobotController
//
//  Created by Cătălin Crăciun on 29/09/14.
//  Copyright (c) 2014 Cătălin Crăciun. All rights reserved.
//

#import "ccJoystick.h"

@interface ccJoystick () {
    
    UIImageView *thumbJoystick;
}

@end

@implementation ccJoystick

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

#define imageNameForThumb @"thumbJoystick" // Change this for changing the thumb joystick

float absolute(float x) { if (x<0) return -x; return x; };
float minimum(int a, int b) { if (a<b) return a; return b; };
float maximum(int a, int b) { if (a>b) return a; return b; };

#pragma mark - Controlling touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Assuming that self.bounds.size.width/2 = self.bounds.size.height/2 (circle)
    for (UITouch *touch in touches) {
        CGPoint locationInView = [touch locationInView:self];
        CGPoint locationInViewConv = [touch locationInView:self]; // Converted
        locationInViewConv.x = locationInViewConv.x - self.bounds.size.width/2;
        locationInViewConv.y = self.bounds.size.height - locationInViewConv.y - self.bounds.size.height/2;

        if (sqrtf(locationInViewConv.x * locationInViewConv.x + locationInViewConv.y * locationInViewConv.y) <= self.bounds.size.width/2) {
            
            [thumbJoystick setCenter:locationInView];
            self.velocityX = locationInViewConv.x/(self.bounds.size.width/2);
            self.velocityY = locationInViewConv.y/(self.bounds.size.height/2); NSLog(@"%f", self.velocityY);
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Assuming that self.bounds.size.width/2 = self.bounds.size.height/2 (circle)
    for (UITouch *touch in touches) {
        CGPoint locationInView = [touch locationInView:self];
        CGPoint locationInViewConv = [touch locationInView:self]; // Converted
        locationInViewConv.x = locationInViewConv.x - self.bounds.size.width/2;
        locationInViewConv.y = self.bounds.size.height - locationInViewConv.y - self.bounds.size.height/2;

        if (sqrtf(locationInViewConv.x * locationInViewConv.x + locationInViewConv.y * locationInViewConv.y) <= self.bounds.size.width/2) {
            
            [thumbJoystick setCenter:locationInView];
            self.velocityX = locationInViewConv.x/(self.bounds.size.width/2);
            self.velocityY = locationInViewConv.y/(self.bounds.size.height/2); NSLog(@"%f", self.velocityY);
        } else {
            int signX=1, signY=1;
            if (locationInViewConv.y < 0)
                signY=-1;
            if (locationInViewConv.x < 0)
                signX=-1;
            float alpha = atanf(locationInViewConv.y/locationInViewConv.x);
            
            CGPoint onCirclePointConv = CGPointMake(absolute(cosf(alpha))*self.bounds.size.width/2*signX, absolute(sinf(alpha))*self.bounds.size.width/2*signY);
            
            CGPoint onCirclePoint;
            onCirclePoint.x = onCirclePointConv.x + self.bounds.size.width/2;
            onCirclePoint.y = self.bounds.size.height/2 - onCirclePointConv.y;
            
            [thumbJoystick setCenter:onCirclePoint];

            self.velocityX = onCirclePointConv.x/(self.bounds.size.width/2);
            self.velocityY = onCirclePointConv.y/(self.bounds.size.height/2);  NSLog(@"%f", self.velocityY);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Getting the thumbJoystick back to center
    [thumbJoystick setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
    self.velocityX = 0.0f;
    self.velocityY = 0.0f;
}

#pragma mark - Draw Rect
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [bp addClip];
    [[UIColor whiteColor] setFill];
    [bp fill];

    thumbJoystick = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNameForThumb]];
    [self addSubview:thumbJoystick];

    [thumbJoystick setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
}

- (void)setup {
    
    // Setting the view
    self.opaque = NO;
    self.backgroundColor = nil;
    
    self.velocityX = 0.0f;
    self.velocityY = 0.0f;
    
    [self setUserInteractionEnabled:YES];
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

@end
