//
//  GWKeyChain.m
//  Categories
//
//  Created by Wess Cope on 11/19/12.
//  Copyright (c) 2012 GroundWork. All rights reserved.
//

static NSString *const kBJKeyChainService()
{
   return [NSString stringWithFormat:@"com.Keychain.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
}


NSMutableDictionary *baseDictionary(NSString *key, BOOL skipClass)
{
    return [@{
            (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
            (__bridge id)kSecAttrService : kBJKeyChainService,
            (__bridge id)kSecAttrAccount : key
            } mutableCopy];
}

@implementation GWKeyChain
+ (OSStatus)valueStatusForKey:(NSString *)key
{
	NSDictionary *searchDictionary = baseDictionary(key, NO);
	return SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, nil);
}

+ (BOOL)setString:(NSString *)string forKey:(NSString *)key
{
    if (string == nil OR key == nil) return NO;
    
	NSData *valueData   = [NSKeyedArchiver archivedDataWithRootObject:string];
	OSStatus valStatus  = [BJKeyChain valueStatusForKey:key];
    
	if (valStatus == errSecItemNotFound)
    {
		NSMutableDictionary *addQueryDict = baseDictionary(key, NO);
		[addQueryDict setObject:valueData forKey:(__bridge id)kSecValueData];
        
		valStatus = SecItemAdd ((__bridge CFDictionaryRef)addQueryDict, NULL);
		NSAssert1(valStatus == errSecSuccess, @"Value add returned status %ld", valStatus);
	}
	else if (valStatus == errSecSuccess)
    {
		NSMutableDictionary *updateQueryDict    = baseDictionary(key, NO);
		NSDictionary *valueDict                 = [NSDictionary dictionaryWithObject:valueData forKey:(__bridge id)kSecValueData];
        
		valStatus = SecItemUpdate ((__bridge CFDictionaryRef)updateQueryDict, (__bridge CFDictionaryRef)valueDict);
		NSAssert1(valStatus == errSecSuccess, @"Value update returned status %ld", valStatus);
        
	}
	else
    {
        return NO;
	}
    
	return YES;
}

+ (NSString *)stringForKey:(NSString *)key
{
    NSMutableDictionary *retrieveQueryDict = baseDictionary(key, NO);
	[retrieveQueryDict setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
	CFDataRef dataRef       = nil;
	OSStatus queryResult    = SecItemCopyMatching ((__bridge CFDictionaryRef)retrieveQueryDict, (CFTypeRef *)&dataRef);
    
	if (queryResult == errSecSuccess)
    {
		NSData *valueData   = (__bridge NSData *)dataRef;
		return [NSKeyedUnarchiver unarchiveObjectWithData:valueData];
	}
    
	return nil;
}

+ (BOOL)removeStringForKey:(NSString *)key
{
    NSDictionary *deleteQueryDict   = baseDictionary(key, NO);
    OSStatus queryResult            = SecItemDelete((__bridge CFDictionaryRef)deleteQueryDict);
    
    return (queryResult == errSecSuccess);
}

+ (BOOL)hasValueForKey:(NSString *)key
{
    return ([GWKeyChain valueStatusForKey:key] == errSecSuccess);
}
