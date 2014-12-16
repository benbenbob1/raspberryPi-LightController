//
//  rpiSecondViewController.m
//  Raspberry Pi Controller
//
//  Created by Ben Brown on 3/20/14.
//  Copyright (c) 2014 Ben Brown. All rights reserved.
//

#import "rpiSecondViewController.h"
#import "rpiAppDelegate.h"

@interface rpiSecondViewController ()

@end

@implementation rpiSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


    NSString *host;
    int port;

    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    if ([defs objectForKey:@"host"]) {
        host = [defs stringForKey:@"host"];
    } else {
        host = kDefaultHost;
    }
    if ([defs objectForKey:@"port"]) {
        port = (int)[defs integerForKey:@"port"];
    } else {
        port = kDefaultPort;
    }

    [hostField setText:[NSString stringWithFormat:@"%@:%i", host, port]];
    [hostField setReturnKeyType:UIReturnKeyDone];
    [messageField setReturnKeyType:UIReturnKeyDone];

    appDel = (rpiAppDelegate *)[UIApplication sharedApplication].delegate;

	[trackBeaconSwitch setOn:appDel.trackingBeacon];

    sendButton.enabled = false;
}

- (IBAction)connectButtonPushed:(id)sender {
    NSString *typed = [hostField text];
    NSArray *textArr = [typed componentsSeparatedByString:@":"];
    NSString *host = @"";
    int port;
    if (textArr.count > 2) {
        for (int i=0; i<textArr.count-1; i++) {
            host = [host stringByAppendingString:[textArr objectAtIndex:i]];
        }
    } else {
        host = [textArr firstObject];
    }
    [hostField endEditing:YES];

    port = [[textArr lastObject] intValue];
    [appDel disconnect];
    [appDel connectTo:host Port:port];
}

- (IBAction)sendMessageButtonPushed:(id)sender {
    NSString *typed = [[messageField text] stringByAppendingString:@"\0"];
    if (appDel.isConnected) {
        NSData *dataToSend = [typed dataUsingEncoding:NSASCIIStringEncoding];
        [appDel.outputStream write:[dataToSend bytes] maxLength:[dataToSend length]];
        [messageField setText:@""];
    }
}

- (IBAction)trackSwitchTouched:(id)sender {
	UISwitch *trackSwitch = (UISwitch *)sender;
	[appDel switchBeaconTracking:[trackSwitch isOn]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newStr = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:hostField]) {
        [connectButton setEnabled:(newStr.length > 1 && [(NSString *)[newStr componentsSeparatedByString:@":"].lastObject length] > 0)];
    } else if ([textField isEqual:messageField]) {
        [sendButton setEnabled:(newStr.length && appDel.isConnected)];
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}


@end
