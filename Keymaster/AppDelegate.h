//
//  AppDelegate.h
//  Keymaster
//
//  Created by Hansi on 29.06.15.
//  Copyright (c) 2015 superduper. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet SearchView *searchView;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) BOOL darkModeOn;

@end

