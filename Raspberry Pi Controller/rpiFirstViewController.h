//
//  rpiFirstViewController.h
//  Raspberry Pi Controller
//
//  Created by Ben Brown on 3/20/14.
//  Copyright (c) 2014 Ben Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "rpiColorWheel.h"
#import "ColorSwatchView.h"
#import "GradientView.h"
#import "Constants.h"

@protocol ColorSenderDelegate <NSObject>

- (void)sendColorMsg:(NSString *)message;

@end

@interface rpiFirstViewController : UIViewController <ColorWheelDelegate, GradientViewDelegate> {
	IBOutlet rpiColorWheel *colorWheel;
	IBOutlet GradientView *gradientView;
	IBOutlet UISlider *brightnessSlider;
	IBOutlet UILabel *brightnessLabel;
	
	IBOutlet ColorSwatchView *newColorSwatch, *currentColorSwatch;
	CGFloat hue;
	UIColor *selectedColor, *startColor;
    NSOutputStream *outputStream;
}

- (void)setColor:(UIColor *)color;
- (IBAction)sliderAdjusted:(UISlider *)sender;
- (IBAction)offButtonPressed:(id)sender;
- (IBAction)onButtonPressed:(id)sender;

@property (nonatomic, assign) id<ColorSenderDelegate> delegate;

@end
