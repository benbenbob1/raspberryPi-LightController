//
//  rpiFirstViewController.m
//  Raspberry Pi Controller
//
//  Created by Ben Brown on 3/20/14.
//  Copyright (c) 2014 Ben Brown. All rights reserved.
//

#import "rpiFirstViewController.h"
#import "UIColor-HSVAdditions.h"
#import "rpiAppDelegate.h"

@interface rpiFirstViewController ()

@end

@implementation rpiFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[colorWheel setDelegate:self];
	[gradientView setDelegate:self];
	[self setColor:[UIColor colorWithHue:0.5f saturation:1.0f brightness:1.0f alpha:1.0f]];
    [self setDelegate:(rpiAppDelegate *)[UIApplication sharedApplication].delegate];
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)viewWillDisappear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setColor:(UIColor *)color {
	CGFloat saturation = color.saturation;
	
	currentColorSwatch.swatchColor = color;
	[colorWheel setSelectedColor:color];
	[gradientView setSelectedBrightness:saturation];
	
	[self colorSelected:color];
	startColor = color;
}

/*- (void)setColor:(UIColor *)color {
    currentColor = color;
    currentHue = color.hue;
    currentSaturation = color.saturation;
    currentBrightness = color.brightness;
    CGPoint hueSatPosition;
    CGPoint brightnessPosition;
    hueSatPosition.y = (currentHue*kMatrixWidth)+kXAxisOffset;
    hueSatPosition.x = (1.0-currentSaturation)*kMatrixHeight+kYAxisOffset;
    brightnessPosition.y = (1.0+kBrightnessEpsilon-currentBrightness)*gradientView.frame.size.height;
    
    // Original input brightness code (from down below)
    // currentBrightness = 1.0-(position.x/gradientView.frame.size.width) + kBrightnessEpsilon;
    
    brightnessPosition.y = kBrightBarYCenter;
    [gradientView setTheColor:color];
    //[showColor setBackgroundColor:currentColor];
    newColorSwatch.swatchColor = currentColor;
    
    //crossHairs.center = hueSatPosition;
    //brightnessBar.center = brightnessPosition;
}*/

- (void)colorSelected:(UIColor *)color { //From rpiColorWheel
	if (color) {
		hue = color.hue;
		[gradientView setTheColor:color];
	}
	CGFloat gradientBrightness = gradientView.selectedBrightness;
	selectedColor = [UIColor colorWithHue:hue saturation:gradientBrightness brightness:1.0f alpha:1.0f];
	newColorSwatch.swatchColor = selectedColor;
	//[self performSelectorInBackground:@selector(sendColor:) withObject:selectedColor];
    [self sendColor:selectedColor];
}

- (void)sendColor:(UIColor *)color {
    NSString *msg = [NSString stringWithFormat:@"c %i %i %i\0", (int)((color.red*100.0)*brightnessSlider.value), (int)((color.green*100.0)*brightnessSlider.value), (int)((color.blue*100.0)*brightnessSlider.value)];

    /*if (self.delegate && [self.delegate respondsToSelector:@selector(sendColorMsg:)]) {
        [self.delegate sendColorMsg:msg];
    }*/
    rpiAppDelegate *appDel = (rpiAppDelegate *)[UIApplication sharedApplication].delegate;
    NSData *dataToSend = [msg dataUsingEncoding:NSASCIIStringEncoding];
    [appDel.outputStream write:[dataToSend bytes] maxLength:[dataToSend length]];

    //[((rpiAppDelegate *)self.tabBarController.delegate) sendMSG:msg];
    //[outputStream write:dataToSend.bytes maxLength:dataToSend.length];
}

- (void)gradientChanged {
	[self colorSelected:nil];
}

- (IBAction)sliderAdjusted:(UISlider *)sender {
	[brightnessLabel setText:[NSString stringWithFormat:@"Brightness: %i%@", (int)(sender.value*100.0f), @"%"]];
	//[newColorSwatch setAlpha:sender.value];
    [self colorSelected:selectedColor];
}

- (IBAction)offButtonPressed:(id)sender {
	[brightnessSlider setValue:0.0];
    [self sliderAdjusted:brightnessSlider];
}

- (IBAction)onButtonPressed:(id)sender {
	[brightnessSlider setValue:1.0];
    [self sliderAdjusted:brightnessSlider];
}

@end
