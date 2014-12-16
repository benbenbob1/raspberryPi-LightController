//
//  rpiAppDelegate.m
//  Raspberry Pi Controller
//
//  Created by Ben Brown on 3/20/14.
//  Copyright (c) 2014 Ben Brown. All rights reserved.
//

#import "rpiAppDelegate.h"
#import "UIColor-HSVAdditions.h"

@implementation rpiAppDelegate

- (void)connect {
    [self connectTo:nil Port:0];
}

- (void)connectTo:(NSString *)host Port:(int)port {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudTapped:) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
    
    //NSInputStream *inputStream;

    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    if (!host || host.length == 0) {
        if ([defs objectForKey:@"host"]) {
            host = [defs stringForKey:@"host"];
        } else {
            host = kDefaultHost;
        }
    } else {
        [defs setObject:host forKey:@"host"];
    }

    if (!port || port <= 0) {
        if ([defs objectForKey:@"port"]) {
            port = (int)[defs integerForKey:@"port"];
        } else {
            port = kDefaultPort;
        }
    } else {
        [defs setInteger:port forKey:@"port"];
    }

    NSString *connStr = [NSString stringWithFormat:@"Connecting to %@:%i...", host, port];
    NSLog(@"%@", connStr);
    //[self displayError:connStr];

    [defs synchronize];

    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)host, port, NULL, &writeStream);
    //inputStream = (__bridge_transfer NSInputStream *)readStream;
    _outputStream = (__bridge_transfer NSOutputStream *)writeStream;

    //[inputStream setDelegate:self];
    [_outputStream setDelegate:self];

    //[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    //[inputStream open];
    [_outputStream open];

    [SVProgressHUD showWithStatus:@"Connecting...\nTap to cancel" maskType:SVProgressHUDMaskTypeBlack];
}

- (void)disconnect {
    if (_isConnected) {
        [SVProgressHUD showWithStatus:@"Disconnecting..."];
        NSLog(@"Attempting to disconnect");
        [_outputStream close];
        [_outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        _outputStream = nil;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _isConnected = NO;
	self.piID = @"F0A6E130-690C-11E4-9803-0800200C9A66";

	self.beaconManager = [[KCSBeaconManager alloc] init];
	self.beaconManager.delegate = self;

	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	if ([defs boolForKey:@"trackBeacon"]) {
		[self startTrackingBeacon];
	}

    return YES;
}

- (void)switchBeaconTracking:(BOOL)shouldTrack {
	if (!shouldTrack && self.trackingBeacon) {
		[self.beaconManager stopMonitoringForRegion:@"Pi.Zone.1"];
		self.trackingBeacon = NO;
	} else if (shouldTrack && !self.trackingBeacon) {
		[self startTrackingBeacon];
	}
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setBool:shouldTrack forKey:@"trackBeacon"];
	[defs synchronize];
}

- (void)startTrackingBeacon {
	NSError *err;
	[self.beaconManager startMonitoringForRegion:self.piID identifier:@"Pi.Zone.1" error:&err];
	self.trackingBeacon = YES;
}

- (void)rangedBeacon:(CLBeacon *)beacon {
	UIColor *color = [UIColor whiteColor];
	BOOL conn = NO;
	if ([beacon.proximityUUID.UUIDString isEqual:self.piID]) {
		NSLog(@"Ranging");
		conn = YES;
		switch (beacon.proximity) {
			case CLProximityImmediate:
				color = [UIColor redColor];
				break;
			case CLProximityFar:
				color = [UIColor blueColor];
				break;
			case CLProximityNear:
				color = [UIColor yellowColor];
				break;
			case CLProximityUnknown:
				conn = NO;
				break;
		}
	}
	CGFloat brightness = conn?1.0:0.0;
	NSString *msg = [NSString stringWithFormat:@"c %i %i %i\0", (int)((color.red*100.0)*brightness), (int)((color.green*100.0)*brightness), (int)((color.blue*100.0)*brightness)];
	rpiAppDelegate *appDel = (rpiAppDelegate *)[UIApplication sharedApplication].delegate;
	NSData *dataToSend = [msg dataUsingEncoding:NSASCIIStringEncoding];
	[appDel.outputStream write:[dataToSend bytes] maxLength:[dataToSend length]];
	
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self disconnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    /*if (!errorLabel) {
        errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 21)];
        [errorLabel setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
        [errorLabel setOpaque:NO];
        [errorLabel setTextAlignment:NSTextAlignmentCenter];
        [errorLabel setTextColor:[UIColor whiteColor]];
        [errorLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [errorLabel setHidden:NO];
        [self.window addSubview:errorLabel];
    }*/
    if (!connectedCircle) {
        CGSize circleSize = CGSizeMake(50, 50);
        connectedCircle = [[rpiConnectedView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.window.frame)-circleSize.width/2, 450, circleSize.width, circleSize.height)];
        [connectedCircle setBackgroundColor:[UIColor clearColor]];
        [self.window addSubview:connectedCircle];
    }
    [self connect];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self disconnect];
}

- (void)hudTapped:(NSNotification *)notif {
    NSLog(@"Hud tapped");
    [SVProgressHUD dismiss];
    [self disconnect];
}

- (void)setIsConnected:(BOOL)isConnected {
    _isConnected = isConnected;
    connectedCircle.isConnected = _isConnected;
    [connectedCircle setNeedsDisplay];
}

#pragma mark - Stream Handling

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (eventCode == NSStreamEventErrorOccurred) {
        //[self displayError:@"Stream error"];
        NSLog(@"Stream error!");
        self.isConnected = NO;
        [SVProgressHUD showErrorWithStatus:@"Stream error!\nDisconnected"];
    } else if (eventCode == NSStreamEventHasSpaceAvailable) {
        //NSLog(@"Has space available!");
        self.isConnected = YES;
    } else if (eventCode == NSStreamEventOpenCompleted) {
        self.isConnected = YES;
        //[self hideError];
        //NSLog(@"Stream opened successfully!. Is connected: %i", _isConnected);
        [SVProgressHUD showSuccessWithStatus:@"Connected!"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
    } else if (eventCode == NSStreamEventEndEncountered ) {
        NSLog(@"Stream ended. Disconnecting");
        self.isConnected = NO;
    }
}

- (void)displayError:(NSString *)errorString {
    /*[errorLabel setHidden:NO];
    [errorLabel setText:errorString];
    CGFloat labelHeight = errorLabel.frame.size.height;
    CGFloat maxY = CGRectGetMaxY(self.window.frame)-100;
    CGRect finalRect = CGRectMake(0, maxY-labelHeight, self.window.frame.size.width, labelHeight);
    if (!CGRectEqualToRect(errorLabel.frame, finalRect)) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [errorLabel setFrame:finalRect];
        [UIView commitAnimations];
    }
    if (errorTimer) {
        [errorTimer invalidate];
        errorTimer = nil;
    }
    errorTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(hideError) userInfo:nil repeats:NO];*/

}

- (void)hideError {
    CGRect finalRect = CGRectMake(0, CGRectGetMaxY(self.window.bounds), self.window.frame.size.width, errorLabel.frame.size.height);
    if (!CGRectEqualToRect(errorLabel.frame, finalRect)) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [errorLabel setFrame:finalRect];
        [UIView commitAnimations];
    }
}

@end
