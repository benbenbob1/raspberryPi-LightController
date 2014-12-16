//
//  rpiColorWheel.m
//  Raspberry Pi Controller
//
//  Created by Ben Brown on 10/14/14.
//  Copyright (c) 2014 Ben Brown. All rights reserved.
//

#import "rpiColorWheel.h"

@implementation rpiColorWheel

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

- (void)didMoveToSuperview {
    if (!colorWheel) {
        CGRect newFrame = self.frame;
        newFrame.origin.x = 0.0;
        newFrame.origin.y = 0.0;
        /*colorWheel = [[UIImageView alloc] initWithFrame:newFrame];
        [colorWheel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [colorWheel setBackgroundColor:[UIColor clearColor]];
        [colorWheel setImage:[UIImage imageNamed:kHueSatImage]];
        [self addSubview:colorWheel];
        colorWheelRadius = colorWheel.frame.size.width/2;*/

        colorWheel = [[ColorMatrixView alloc] initWithFrame:newFrame];
        [colorWheel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self addSubview:colorWheel];
        [colorWheel setNeedsDisplay];
        colorWheelRadius = colorWheel.colorWheelRadius;

        CGFloat crosshairWidth = 30.0;
        crosshair = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, crosshairWidth, crosshairWidth)];
        [crosshair setImage:[UIImage imageNamed:kCrosshairImage]];
        [self addSubview:crosshair];
    }
}

/*- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat selectorRadius = 6.0f;
    UIBezierPath *selector = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(cursorLoc.x-selectorRadius, cursorLoc.y-selectorRadius, selectorRadius*2, selectorRadius*2)];
    [[UIColor whiteColor] setStroke];
    [selector setLineWidth:2.0f];
    [selector stroke];

    UIBezierPath *selectorOutline = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(cursorLoc.x-selectorRadius-1, cursorLoc.y-selectorRadius-1, (selectorRadius*2)+2, (selectorRadius*2)+2)];
    [[UIColor blackColor] setStroke];
    [selectorOutline setLineWidth:1.0f];
    [selectorOutline stroke];
}*/

- (void)setSelectedColor:(UIColor *)aColor {
    CGFloat hue, saturation;
    [aColor getHue:&hue saturation:&saturation brightness:NULL alpha:NULL];
    float angle = hue * M_PI * 2;

    cursorLoc.x = (self.frame.size.width/2)+(cosf(angle)*(colorWheelRadius/2.0f));
    cursorLoc.y = (self.frame.size.height/2)+(sinf(angle)*(colorWheelRadius/2.0f));
    crosshair.center = cursorLoc;
    //[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint tappedPt = [[touches anyObject] locationInView:self];
    CGPoint circleCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);

    CGFloat dx = tappedPt.x - circleCenter.x;
    CGFloat dy = tappedPt.y - circleCenter.y;
    CGFloat distFromCenter = sqrtf(dx*dx + dy*dy);

    //NSLog(@"Touches moved. Dist: %.1f, CWR: %.1f", distFromCenter, matrixView.colorWheelRadius);

    if (distFromCenter <= colorWheelRadius) {
        cursorLoc = tappedPt;
        crosshair.center = cursorLoc;
        //[self setNeedsDisplay];

        UIColor *theColor = [self colorAtPoint:cursorLoc];
        CGFloat hue, saturation;
        [theColor getHue:&hue saturation:&saturation brightness:NULL alpha:NULL];
        if (self.delegate && [self.delegate respondsToSelector:@selector(colorSelected:)]) {
            [self.delegate colorSelected:theColor];
        }
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
