//
//  GradientView.m
//  ColorPicker
//
//  Created by Gilly Dekel on 23/3/09.
//  Extended by Fabián Cañas August 2010.
//  Copyright 2010 Fabián Cañas. All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//    * Neither the name of the <organization> nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//    DISCLAIMED. IN NO EVENT SHALL FABIAN CANAS BE LIABLE FOR ANY
//    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "GradientView.h"
#import "UIColor-HSVAdditions.h"

@implementation GradientView
@synthesize theColor, selectedBrightness, delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)didMoveToSuperview {
	self.layer.cornerRadius = 7.0f;
	self.layer.masksToBounds = YES;
}

- (void)setTheColor:(UIColor *)aColor {
	theColor = aColor;
	[self setupGradient];
	[self setNeedsDisplay];
}

- (void)setSelectedBrightness:(CGFloat)aBrightness {
	cursorLocY = aBrightness*self.frame.size.height;
	selectedBrightness = aBrightness;
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesMoved:touches withEvent:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint tappedPt = [[touches anyObject] locationInView:self];
	if ((tappedPt.x >= 0 && tappedPt.x <= self.frame.size.width) &&
		(tappedPt.y >= 0 && tappedPt.y <= self.frame.size.height)) {
		//cursorLocY = tappedPt.y;
		//[self setNeedsDisplay];
		self.selectedBrightness = tappedPt.y/self.frame.size.height;
		if (self.delegate && [self.delegate respondsToSelector:@selector(gradientChanged)]) {
			[self.delegate gradientChanged];
		}
	}
}

// Returns an appropriate starting point for the demonstration of a linear gradient
CGPoint demoLGStart(CGRect bounds) {
	return CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height * 0.25);
}

// Returns an appropriate ending point for the demonstration of a linear gradient
CGPoint demoLGEnd(CGRect bounds) {
	return CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height * 0.75);
}

- (void)setupGradient {
	// Create a color equivalent to the current color with brightness maximized
	const CGFloat *c = CGColorGetComponents([[UIColor colorWithHue:[theColor hue] saturation:[theColor saturation] brightness:1.0 alpha:1.0] CGColor]);
	CGFloat colors[] = {
		1.0f, 1.0f, 1.0f, 1.0f,
		c[0], c[1], c[2], 1.0f //THE COLOR with maximized brightness
	};
	
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	
    if (gradient!=nil) {
        CGGradientRelease(gradient);
    }
	gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	CGColorSpaceRelease(rgb);
	
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	// The clipping rects we plan to use, which also defines the locations of each gradient
	CGRect clips[] = {
		CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)
	};
	
	CGPoint points[] = {
		CGPointMake(0, 0),
		CGPointMake(0, self.frame.size.height),
	};
	// Linear Gradients
	CGPoint start, end;
	
	// Clip to area to draw the gradient, and draw it. Since we are clipping, we save the graphics state
	// so that we can revert to the previous larger area.
	CGContextSaveGState(context);
	CGContextClipToRect(context, clips[0]);
	
	start = points[0];
	end = points[1];
	CGContextDrawLinearGradient(context, gradient, start, end, 0);
	CGContextRestoreGState(context);
	
	CGContextSaveGState(context);
	
	UIBezierPath *insideBezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(2, cursorLocY-4, self.frame.size.width-4, 9) cornerRadius:1.0f];
	[[UIColor whiteColor] setStroke];
	[insideBezierPath stroke];
	
	UIBezierPath *outsideBezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1, cursorLocY-5, self.frame.size.width-2, 11) cornerRadius:1.0f];
	[[UIColor blackColor] setStroke];
	[outsideBezierPath stroke];
}

@end
