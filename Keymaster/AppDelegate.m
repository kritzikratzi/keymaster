//
//  AppDelegate.m
//  
//
//  Created by Hansi on 29.06.15.
//  Copyright (c) 2015 superduper. All rights reserved.
//

#import "AppDelegate.h"
#import <Carbon/Carbon.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *statusMenu;
@end

@implementation AppDelegate

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData){
	NSNotification * notification = [NSNotification notificationWithName:@"appear" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	return 0;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Create status bar icon
	// following the guide from
	// https://nsrover.wordpress.com/2014/10/10/creating-a-os-x-menubar-only-app/
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	self.statusItem.image = [NSImage imageNamed:@"StatusIcon"];
//	[self.statusItem setAction:@selector(itemClicked:)];
	self.statusItem.menu = self.statusMenu;

	_statusItem.highlightMode = YES;
	_statusItem.toolTip = @"command-click to quit";
	
	// Register hotkey
	// following the guide from
	// http://cocoasamurai.blogspot.co.at/2009/03/global-keyboard-shortcuts-with-carbon.html
	EventHotKeyRef myHotKeyRef;
	EventHotKeyID myHotKeyID;
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	InstallApplicationEventHandler(&myHotKeyHandler,1,&eventType,NULL,NULL);
	myHotKeyID.signature='kmhk'; // " hotkey" in fourchar
	myHotKeyID.id=1;
	RegisterEventHotKey(kVK_ANSI_P, cmdKey+optionKey+controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (void) itemClicked: (id) sender{
}

- (IBAction)showPasswords:(id)sender {
	NSNotification * notification = [NSNotification notificationWithName:@"appear" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)quit:(id)sender {
	[[NSRunningApplication currentApplication] terminate];
}

@end
