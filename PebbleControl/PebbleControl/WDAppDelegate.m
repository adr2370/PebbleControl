//
//  WDAppDelegate.m
//  WeatherDemo
//
//  Created by Martijn The on 2/7/13.
//  Copyright (c) 2013 Pebble Technology Corp. All rights reserved.
//

#import "WDAppDelegate.h"
#import <PebbleKit/PebbleKit.h>
#import <Firebase/Firebase.h>

@interface WDAppDelegate () <PBPebbleCentralDelegate>
@end

@implementation WDAppDelegate {
    PBWatch *_targetWatch;
    Firebase *f;
    UILabel *text;
}

- (void)upPressed {
    [[f childByAppendingPath:[NSString stringWithFormat:@"%@/up",[_targetWatch serialNumber]]] setValue:@"1"];
}

- (void)middlePressed {
    [[f childByAppendingPath:[NSString stringWithFormat:@"%@/middle",[_targetWatch serialNumber]]] setValue:@"1"];
}

- (void)downPressed {
    [[f childByAppendingPath:[NSString stringWithFormat:@"%@/down",[_targetWatch serialNumber]]] setValue:@"1"];
}

- (void)setTargetWatch:(PBWatch*)watch {
  _targetWatch = watch;

  // NOTE:
  // For demonstration purposes, we start communicating with the watch immediately upon connection,
  // because we are calling -appMessagesGetIsSupported: here, which implicitely opens the communication session.
  // Real world apps should communicate only if the user is actively using the app, because there
  // is one communication session that is shared between all 3rd party iOS apps.

  // Test if the Pebble's firmware supports AppMessages / Weather:
  [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
    if (isAppMessagesSupported) {
      // Configure our communications channel to target the weather app:
      // See demos/feature_app_messages/weather.c in the native watch app SDK for the same definition on the watch's end:
      uint8_t bytes[] = {0x23, 0x70, 0x23, 0x70, 0x23, 0x70, 0x23, 0x70, 0x23, 0x70, 0x23, 0x70, 0x23, 0x70, 0x23, 0x70};
      NSData *uuid = [NSData dataWithBytes:bytes length:sizeof(bytes)];
      [watch appMessagesSetUUID:uuid];
        [text setText:[NSString stringWithFormat:@"%@",[_targetWatch serialNumber]]];
        
        [_targetWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *w2, NSDictionary *update) {
            NSInteger which=[[[update allValues] objectAtIndex:0] integerValue];
            switch(which) {
                case 1:
                    [self upPressed];
                    break;
                case 2:
                    [self middlePressed];
                    break;
                case 3:
                    [self downPressed];
                    break;
                    
            }
            return YES;
        }];
    } else {
      NSString *message = [NSString stringWithFormat:@"Blegh... %@ does NOT support AppMessages :'(", [watch name]];
      [[[UIAlertView alloc] initWithTitle:@"Connected..." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
  }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    text = [UILabel new];
    [text setText:@"Connecting..."];
    [text setTextAlignment:UITextAlignmentCenter];
    [text setFrame:self.window.bounds];
    [self.window addSubview:text];
    
    [self.window makeKeyAndVisible];
    
  // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
  [[PBPebbleCentral defaultCentral] setDelegate:self];

  // Initialize with the last connected watch:
  [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
      
  // Initialize firebase
  f = [[Firebase alloc] initWithUrl:@"https://pebblecontrol.firebaseio.com/"];
  return YES;
}

/*
 *  PBPebbleCentral delegate methods
 */

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    [self setTargetWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    [[[UIAlertView alloc] initWithTitle:@"Disconnected!" message:[watch name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (_targetWatch == watch || [watch isEqual:_targetWatch]) {
        [self setTargetWatch:nil];
    }
}

@end
