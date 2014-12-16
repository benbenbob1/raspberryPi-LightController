//
//  rpiColorWheel.h
//  Raspberry Pi Controller
//
//  Created by Ben Brown on 10/14/14.
//  Copyright (c) 2014 Ben Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorMatrixView.h"
#import "Constants.h"

@protocol ColorWheelDelegate <NSObject>

- (void)colorSelected:(UIColor *)color;

@end

@interface rpiColorWheel : UIView {
    CGPoint cursorLoc;
    UIImageView /**colorWheel, */*crosshair;
    CGFloat colorWheelRadius;
    ColorMatrixView *colorWheel;
}

- (void)setSelectedColor:(UIColor *)aColor;
//- (UIColor *)colorAtPoint:(CGPoint)point;

@property (nonatomic) CGFloat selectedHue, selectedSaturation;
@property (nonatomic, assign) id<ColorWheelDelegate> delegate;

@end
