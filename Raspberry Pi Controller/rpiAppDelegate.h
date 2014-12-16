//
//  rpiAppDelegate.h
//  Raspberry Pi Controller
//
//  Created by Ben Brown on 3/20/14.
//  Copyright (c) 2014 Ben Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KCSIBeacon/KCSBeaconManager.h>
#import "rpiFirstViewController.h"
#import "rpiSecondViewController.h"
#import "SVProgressHUD.h"
#import "rpiConnectedView.h"
#import "Constants.h"

@interface rpiAppDelegate : UIResponder <UIApplicationDelegate, ColorSenderDelegate, SettingsScreenDelegate, UITabBarControllerDelegate, NSStreamDelegate, KCSBeaconManagerDelegate> {
    UILabel *errorLabel;
    IBOutlet UITabBarController *tabBarContr;
    rpiConnectedView *connectedCircle;
}

- (void)displayError:(NSString *)errorString;
- (void)hideError;

- (void)connect;
- (void)connectTo:(NSString *)host Port:(int)port;
- (void)disconnect;

+ (NSThread *)networkThread;
+ (void)networkThreadMain:(id)unused;
- (void)scheduleInCurrentThread;

- (void)hudTapped:(NSNotification *)notif;

- (void)startTrackingBeacon;
- (void)switchBeaconTracking:(BOOL)shouldTrack;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (strong, nonatomic) NSMutableData *dataToWrite;
@property KCSBeaconManager *beaconManager;
@property NSString *piID;
@property (nonatomic) BOOL isConnected, trackingBeacon;

@end
