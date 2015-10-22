//
//  Editor.m
//  Keymaster
//
//  Created by Hansi on 22.10.15.
//  Copyright (c) 2015 superduper. All rights reserved.
//

#import "AppDelegate.h"
#import "Editor.h"
#import "KeychainTools.h"

@interface Editor ()
@property (strong) IBOutlet NSTextField *labelField;
@property (strong) IBOutlet NSTextField *accountField;
@property (strong) IBOutlet NSTextField *serverField;
@property (strong) IBOutlet NSTextField *commentField;
@property (strong) IBOutlet NSTextField *passwordField;

- (IBAction)generatePassword:(id)sender;
- (IBAction)addToKeyChain:(id)sender;


@end

@implementation Editor

- (void)windowDidLoad {
    [super windowDidLoad];
	
	NSLog(@"did load window");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) reset{
	self.labelField.stringValue = @"";
	self.accountField.stringValue = @"";
	self.serverField.stringValue = @"";
	self.commentField.stringValue = @"";
	self.passwordField.stringValue = @"";
}

- (IBAction)generatePassword:(id)sender {
	self.passwordField.stringValue = [Editor randomStringWithLength:12];
}

- (IBAction)addToKeyChain:(id)sender {
	NSData * pw = [self.passwordField.stringValue dataUsingEncoding:NSUTF8StringEncoding];
	NSURL * url = [NSURL URLWithString:self.serverField.stringValue];
	
	NSMutableDictionary * dict = [NSMutableDictionary new];
	[dict setObject:kSecClassInternetPassword forKey:kSecClass];
	[dict setObject:self.labelField.stringValue forKey:kSecAttrLabel];
	[dict setObject:self.accountField.stringValue forKey:kSecAttrAccount];
	if( url.scheme ) [dict setObject:url.scheme forKey:kSecAttrProtocol];
	if( url.host ) [dict setObject:url.host forKey:kSecAttrServer];
	if( url.port ) [dict setObject:url.port forKey:kSecAttrPort];
	if( url.path ) [dict setObject:url.path forKey:kSecAttrPath];
	[dict setObject:self.commentField.stringValue forKey:kSecAttrComment];
	[dict setObject:pw forKey:kSecValueData];

	
	OSStatus err = SecItemAdd((__bridge CFDictionaryRef)(dict), NULL);
	if (err == noErr){
		NSNotification * notification = [NSNotification notificationWithName:@"appear" object:nil];
		[[NSNotificationCenter defaultCenter] postNotification:notification];
		AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
		[appDelegate reloadPasswords];
		// [appDelegate appear];
		// TODO: a notification would be nice, no? 
		[self close];
	}
	else{
		NSLog(@"error=%d", err ); 
	}
	
}

// http://stackoverflow.com/a/2633948/347508
NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{}+~*!§$%&/()=?^°";

+(NSString *) randomStringWithLength: (int) len {
	
	NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
	
	uint32_t max = (uint32_t)letters.length;
	for (int i=0; i<len; i++) {
		[randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform(max)]];
	}
	
	return randomString;
}
@end
