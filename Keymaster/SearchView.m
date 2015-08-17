//
//  SearchViewController.m
//  
//
//  Created by Hansi on 29.06.15.
//  Copyright (c) 2015 superduper. All rights reserved.
//

#import "SearchView.h"
#import "cfmadness.h"

@implementation KeystoreEntry
- (id) initWithDictionary: (CFDictionaryRef)dict{
	self = [super init];
	if( self ){
		self.dict = dict;
		self.label = cf_dictString(dict, kSecAttrLabel);
		self.username = cf_dictString(dict, kSecAttrAccount);
	}

	return self;
}

- (NSString*) getPassword{
	return cf_getPassword(self.dict);
}
@end

@interface SearchView (){
}
@end

@implementation SearchView

- (id)initWithCoder:(NSCoder *)coder
{
	NSString* nibName = NSStringFromClass([self class]);
	self = [super initWithCoder:coder];
	// this is stupid. is there no better way?
	if (self) {
		if ([[NSBundle mainBundle] loadNibNamed:nibName
										  owner:self
								topLevelObjects:nil]) {
			[self.view setFrame:[self bounds]];
			[self addSubview:self.view];
		}
		
		[self iterateKeychainWithType:kSecClassInternetPassword];
		[self iterateKeychainWithType:kSecClassGenericPassword];
		
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
		[self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appear) name:@"appear" object:nil];
	}
	
	return self;
}

- (void) appear{
	[NSApp activateIgnoringOtherApps:YES];
	[self.view.window setIsVisible:YES]; 
	[self.view.window makeFirstResponder:self.searchField];
	[self.searchField selectText:self.searchField];
}

- (void) iterateKeychainWithType: (CFTypeRef)type{
	// based on some example in the apple docs, can't remember.
	// or was it on stackoverflow? who knows, long live copy&paste!!!
	CFMutableDictionaryRef query = CFDictionaryCreateMutable(kCFAllocatorDefault, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionaryAddValue(query, kSecReturnAttributes, kCFBooleanTrue);
	CFDictionaryAddValue(query, kSecMatchLimit, kSecMatchLimitAll);
	CFDictionaryAddValue(query, kSecClass, type );
	
	// get search results
	CFArrayRef result = nil;
	OSStatus status = SecItemCopyMatching(query, (CFTypeRef*)&result);
	assert(status == 0);
	
	// do something with the result
	for( CFIndex i = 0; i < CFArrayGetCount(result); i++){
		CFDictionaryRef dict = CFArrayGetValueAtIndex(result, i);
		KeystoreEntry * entry = [[KeystoreEntry alloc] initWithDictionary:dict];
		[self.entries addObject:entry];
	}
}

- (IBAction)showMenu:(id)sender
{
	CGPoint p = [NSEvent mouseLocation];
	p = [self.window convertRectFromScreen:CGRectMake(p.x, p.y, 1, 1)].origin;
	NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseUp location:CGPointMake(p.x, p.y) modifierFlags:0 timestamp:NSTimeIntervalSince1970 windowNumber:[_window windowNumber]  context:nil eventNumber:0 clickCount:0 pressure:0.1];
	[NSMenu popUpContextMenu:self.popupMenu withEvent:event forView:nil];
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
	// this gets called multiple times when pressing enter
	// (it seems that it iterates until it finds (or doesn't find) an editable column.
	static CFAbsoluteTime lastPressed = 0;
	CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
	if( now - lastPressed > 0.05 ){
		lastPressed = now;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self showMenu:self];
			
		});
	}
	lastPressed = now;
	return NO;
}

- (IBAction)copyPassword:(id)sender {
	KeystoreEntry * entry = self.entries.selectedObjects.firstObject;
	NSString * password = entry.password;
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard clearContents];
	[pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
	[pasteBoard setString: password forType:NSStringPboardType];
}

- (IBAction)typePassword:(id)sender {
	KeystoreEntry * entry = self.entries.selectedObjects.firstObject;
	NSString * password = entry.password;
	[NSApp hide:sender];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		unichar * ptr = malloc(2*password.length+2);
		for( int i = 0; i < password.length; i++ ){
			ptr[i] = [password characterAtIndex:i];
		}
		ptr[password.length] = 0;
		CGEventRef e = CGEventCreateKeyboardEvent(NULL, 0, true);
		CGEventKeyboardSetUnicodeString(e, password.length, ptr);
		CGEventPost(kCGHIDEventTap, e);
		free(ptr);
	});
}

// select first row when down is pressed
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command{
	if( command == @selector(cancelOperation:)){
		if( [self.searchField.stringValue isEqualTo:@""] ){
			[NSApp hide:self];
		}
	}
	else if( command == @selector(moveDown:)){
		[self.tableView.window makeFirstResponder:self.tableView];
		[self.tableView scrollRowToVisible:self.tableView.selectedRow];
		return YES;
	}
	else if( command == @selector(moveUp:)){
		[self.tableView.window makeFirstResponder:self.tableView];
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:self.tableView.numberOfRows-1];
		[self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
		[self.tableView scrollRowToVisible:self.tableView.selectedRow];
		return YES;
	}
	
	
	return NO;
}

- (BOOL)tableView:(NSTableView *)tableView
shouldTypeSelectForEvent:(NSEvent *)event
withCurrentSearchString:(NSString *)searchString{
	if( [@"c" isEqualToString:event.characters] ){
		[self copyPassword:tableView];
	}
	else if( [@"t" isEqualToString:event.characters]){
		[self typePassword:tableView];
	}
	return NO;
}


@end
