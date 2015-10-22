//
//  NSObject+KeychainTools.h
//  Keymaster
//
//  Created by Hansi on 22.10.15.
//  Copyright (c) 2015 superduper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainTools : NSObject 

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
