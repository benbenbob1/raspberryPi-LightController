//
//  ColorMatrixView.h
//  ColorPicker
//
//  Created by Gilly Dekel on 23/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"


@interface ColorMatrixView : UIView {
	CGPoint cursorLoc;
	UIImageView *colorWheel;
}

- (UIColor *)colorAtPoint:(CGPoint)point;

@property (nonatomic) CGFloat colorWheelRadius;

@end
