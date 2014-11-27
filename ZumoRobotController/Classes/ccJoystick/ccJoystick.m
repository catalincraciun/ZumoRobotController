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

float thumbJoystickScale(int width) { return width / 175.0f; };
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
            self.velocityY = locationInViewConv.y/(self.bounds.size.height/2);
            
            [self.delegate velocityDidChangeWithX:self.velocityX andY:self.velocityY withPriority:NO];
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
            self.velocityY = locationInViewConv.y/(self.bounds.size.height/2);
            
            [self.delegate velocityDidChangeWithX:self.velocityX andY:self.velocityY withPriority:NO];
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
            self.velocityY = onCirclePointConv.y/(self.bounds.size.height/2);
            
            [self.delegate velocityDidChangeWithX:self.velocityX andY:self.velocityY withPriority:NO];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Getting the thumbJoystick back to center
    [thumbJoystick setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
    self.velocityX = 0.0f;
    self.velocityY = 0.0f;
    
    [self.delegate velocityDidChangeWithX:0.0f andY:0.0f withPriority:YES];
}

#pragma mark - Draw Rect
- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    UIBezierPath *bigCircle = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [bigCircle addClip];
    [[UIColor whiteColor] setFill];
    [bigCircle fill];

    UIBezierPath *smallCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 12 * thumbJoystickScale(self.bounds.size.width), 12 * thumbJoystickScale(self.bounds.size.width))];
    [[UIColor colorWithRed:0.65f green:0.65f blue:0.65f alpha:1.0f] setFill];
    [smallCircle fill];
    
    thumbJoystick = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[[UIImage imageNamed:@"thumbJoystick"] CGImage] scale:1/thumbJoystickScale(self.bounds.size.width) orientation:UIImageOrientationLeft]];
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
    
    // Awaking from the nib
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
