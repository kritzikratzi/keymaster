//
//  SearchViewController.h
//  
//
//  Created by Hansi on 29.06.15.
//  Copyright (c) 2015 superduper. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KeystoreEntry : NSObject
@property (strong) NSString *label;
@property (strong) NSString *username;
// good god, could this cause mem leaks? who the fuck knows!!!
@property (strong) __attribute__((NSObject)) CFDictionaryRef dict;
@property (readonly,getter=getPassword) NSString * password;

- (id) initWithDictionary: (CFDictionaryRef)dict;
- (NSString*) getPassword;
@end


@interface SearchView : NSView<NSTableViewDelegate,NSTextFieldDelegate>

@property (strong) IBOutlet NSView *view;
@property (strong) IBOutlet NSArrayController *entries;
@property (strong) IBOutlet NSMenu *popupMenu;
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSSearchField *searchField;

- (IBAction)copyPassword:(id)sender;
- (IBAction)typePassword:(id)sender;


@end
