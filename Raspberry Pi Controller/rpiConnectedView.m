//
//  rpiConnectedView.m
//  Raspberry Pi Controller
//
//  Created by Ben Brown on 10/16/14.
//  Copyright (c) 2014 Ben Brown. All rights reserved.
//

#import "rpiConnectedView.h"

@implementation rpiConnectedView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:rect];
    if (_isConnected) {
        [[UIColor greenColor] setFill];
    } else {
        [[UIColor redColor] setFill];
    }

    [circle fill];
}


@end
