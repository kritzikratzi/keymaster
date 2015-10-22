//
//  AppDelegate.m
//  
//
//  Created by Hansi on 29.06.15.
//  Copyright (c) 2015 superduper. All rights reserved.
//

#import "AppDelegate.h"
#include "Editor.h"
#import <Carbon/Carbon.h>

@interface AppDelegate (){
	Editor * editor;
}

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet SearchView *searchView;
@property (strong, nonatomic) NSStatusItem *statusItem;
- (IBAction)showPasswordEditor:(id)sender;
- (IBAction)reloadPasswords:(id)sender;

@end

@implementation AppDelegate

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData){
	NSNotification * notification = [NSNotification notificationWithName:@"appear" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	
	AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
	[appDelegate appear]; 
	return 0;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// create editor
	editor = [[Editor alloc] initWithWindowNibName:@"Editor"];
	
	// Create status bar icon
	// partially following the guide from
	// https://nsrover.wordpress.com/2014/10/10/creating-a-os-x-menubar-only-app/
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	self.statusItem.image = [NSImage imageNamed:@"StatusIcon"];
	self.statusItem.menu = self.statusMenu;
	self.statusItem.highlightMode = YES;
	self.statusItem.toolTip = @"With Keymaster mastering your keys becomes a breeze";
	
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

- (IBAction)showPasswords:(id)sender {
	NSNotification * notification = [NSNotification notificationWithName:@"appear" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)quit:(id)sender {
	[[NSRunningApplication currentApplication] terminate];
}

- (IBAction)showPasswordEditor:(id)sender {
	[editor reset];
	[editor.window makeKeyAndOrderFront: nil];
}

- (IBAction)reloadPasswords:(id)sender {
	NSNotification * notification = [NSNotification notificationWithName:@"appear" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void) appear{
	[self.searchView appear];
}

-(void) reloadPasswords{
	[self.searchView reloadPasswords];
}
@end
