//
//  ColorMatrixView.m
//  ColorPicker
//
//  Created by Gilly Dekel on 23/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ColorMatrixView.h"

@implementation ColorMatrixView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGSize size = self.frame.size;
        self.colorWheelRadius = (MIN(size.width, size.height)/2)-5.0f;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
	//[[UIColor whiteColor] setFill];
	CGSize size = rect.size;
	//UIRectFill(CGRectMake(0, 0, size.width, size.height));
	CGPoint center = CGPointMake(size.width/2, size.height/2);
	
	int sectors = 180;
	float angle = 2 * M_PI/sectors;
	UIBezierPath *bezierPath;
	for ( int i = 0; i < sectors; i++)
	{
		bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:self.colorWheelRadius startAngle:i * angle endAngle:(i + 1) * angle clockwise:YES];
		[bezierPath addLineToPoint:center];
		[bezierPath closePath];
		UIColor *color = [UIColor colorWithHue:((float)i)/sectors saturation:1. brightness:1. alpha:1];
		[color setFill];
		[color setStroke];
		[bezierPath fill];
		[bezierPath stroke];
	}
}

- (UIColor *)colorAtPoint:(CGPoint)point {
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
	
    CGContextTranslateCTM(context, -point.x, -point.y);
	
    [self.layer renderInContext:context];
	
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
	
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
	
    return color;
}


@end