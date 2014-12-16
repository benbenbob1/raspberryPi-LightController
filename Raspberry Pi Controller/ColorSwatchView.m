//
//  ColorSwatchView.m
//  ColorPicker
//
//  Created by Fabián Cañas on 9/9/10.
//  Copyright 2010 Fabián Cañas. All rights reserved.
//

#import "ColorSwatchView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ColorSwatchView
@synthesize swatchColor;

- (void)didMoveToSuperview {
	self.layer.cornerRadius = 7.0f;
	self.layer.masksToBounds = YES;
}

- (void)setSwatchColor:(UIColor *)aColor {
	swatchColor = aColor;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	/*[[UIColor whiteColor] setFill];
	UIRectFill(rect);
	
	UIBezierPath *blackCorner = [UIBezierPath bezierPath];
	[blackCorner moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
	[blackCorner addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
	[blackCorner addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
	[blackCorner addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
	[[UIColor blackColor] setFill];
	[blackCorner fill];*/
	
	[swatchColor setFill];
	CGFloat cornerRadius = 7.0f;
	//UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
	//UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
	//[roundedRect fill];
	UIRectFill(rect);
}


@end
