//
//  cfmadness.h
//  Keymaster
//
//  Created by Hansi on 10.07.15.
//  Copyright (c) 2015 superduper. All rights reserved.
//

#ifndef Keymaster_cfmadness_h
#define Keymaster_cfmadness_h

#import <CoreFoundation/CoreFoundation.h>
#import <Cocoa/Cocoa.h>


NSString * cf_toString( CFStringRef str ){
	if( str == 0 ) return @"";
	
	NSString * result = (__bridge NSString *)str;
	return result;
}

NSString * cf_dictString( CFDictionaryRef dict, CFTypeRef key ){
	return cf_toString(CFDictionaryGetValue(dict,key));
}

NSNumber * cf_dictNumber( CFDictionaryRef dict, CFTypeRef key ){
	CFNumberRef num = CFDictionaryGetValue(dict, key);
	if( num == 0 ) return @0;
	else return (__bridge NSNumber *)num;
}



// if have no clue what i'm doing. but apple does!
// https://developer.apple.com/library/mac/documentation/Security/Conceptual/keychainServConcepts/03tasks/tasks.html
NSString * cf_getPassword ( CFDictionaryRef dict ){
	CFTypeRef cls = CFDictionaryGetValue(dict, kSecClass);
	
	SecKeychainItemRef itemRef = NULL;
	UInt32 passwordLength = 0;
	void *passwordData = NULL;
	OSStatus status1 ;
	
	if( CFEqual( cls, kSecClassGenericPassword ) ){
		NSString * service = cf_dictString(dict, kSecAttrService);
		NSString * account = cf_dictString(dict, kSecAttrAccount);

		status1 = SecKeychainFindGenericPassword (
												  NULL,           // default keychain
												  (int)service.length,             // length of service name
												  service.UTF8String,   // service name
												  (int)account.length,             // length of account name
												  account.UTF8String,   // account name
												  &passwordLength,  // length of password
												  &passwordData,   // pointer to password data
												  &itemRef         // the item reference
												  );
	}
	else if( CFEqual( cls, kSecClassInternetPassword ) ){
		NSString * server = cf_dictString(dict, kSecAttrServer);
		NSString * securityDomain = cf_dictString(dict, kSecAttrSecurityDomain);
		NSString * account = cf_dictString(dict, kSecAttrAccount);
		NSString * path = cf_dictString(dict, kSecAttrPath);
		
		status1 = SecKeychainFindInternetPassword(
												  NULL,
												  (int)server.length,
												  server.UTF8String,
												  (int)securityDomain.length,
												  securityDomain.UTF8String,
												  (int)account.length,
												  account.UTF8String,
												  (int)path.length,
												  path.UTF8String,
												  cf_dictNumber(dict,kSecAttrPort).intValue,
												  cf_dictNumber(dict,kSecAttrProtocol).intValue,
												  cf_dictNumber(dict,kSecAttrAuthenticationType).intValue,
												  &passwordLength,
												  &passwordData,
												  &itemRef
												);
	}
	else{
		// yea, this is YOUR fault. bad user!
		NSLog(@"unknown password type. hansi was toooo lazy to make an error pop up" );
		return @"";
	}
	
	if(status1!=0){
		NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status1 userInfo:nil];
		NSLog(@"err=%@", error);
		return @"";
	}
	
	// http://lists.apple.com/archives/cocoa-dev/2010/Jan/msg01834.html
	char * buffer = (char *) malloc((passwordLength + 1) * sizeof(char));
	strncpy(buffer, passwordData, passwordLength);
	buffer[passwordLength] = 0;
	NSString * result = [NSString stringWithUTF8String:buffer];
	free(buffer);
	
	return result;
}


#endif
