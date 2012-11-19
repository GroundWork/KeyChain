//
//  GWKeyChain.h
//  Categories
//
//  Created by Wess Cope on 11/19/12.
//  Copyright (c) 2012 GroundWork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GWKeyChain : NSObject
+ (OSStatus)valueStatusForKey:(NSString *)key;
+ (BOOL)setString:(NSString *)string forKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key;
+ (BOOL)removeStringForKey:(NSString *)key;
+ (BOOL)hasValueForKey:(NSString *)key;
@end
