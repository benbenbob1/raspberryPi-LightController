//
//  rpiButton.m
//  Raspberry Pi Controller
//
//  Created by Ben Brown on 3/20/14.
//  Copyright (c) 2014 Ben Brown. All rights reserved.
//

#import "rpiButton.h"

@implementation rpiButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	[self setNeedsDisplay]; 
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	if (!lightBlueColor) {
		lightBlueColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
	}
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 2, 2) cornerRadius:7.0f];
	if (self.isTouchInside) {
		[[lightBlueColor colorWithAlphaComponent:0.5] setStroke];
	} else {
		[lightBlueColor setStroke];
	}

    if (!self.isEnabled) {
        [[UIColor lightGrayColor] setFill];
        [path fill];
    }

	[path setLineWidth:0.5f];
	[path stroke];
}

@end
