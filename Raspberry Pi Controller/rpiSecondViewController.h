//
//  rpiSecondViewController.h
//  Raspberry Pi Controller
//
//  Created by Ben Brown on 3/20/14.
//  Copyright (c) 2014 Ben Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@class rpiAppDelegate;

@protocol SettingsScreenDelegate <NSObject>

- (void)serverChanged:(NSString *)hostStr;
- (void)trackingChanged:(BOOL)shouldTrack;

@end

@interface rpiSecondViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField *hostField, *messageField;
    IBOutlet UIButton *connectButton, *sendButton;
	IBOutlet UISwitch *trackBeaconSwitch;
    rpiAppDelegate *appDel;
}

- (IBAction)connectButtonPushed:(id)sender;
- (IBAction)sendMessageButtonPushed:(id)sender;
- (IBAction)trackSwitchTouched:(id)sender;

@property (nonatomic, assign) id<SettingsScreenDelegate> delegate;

@end
