//
//  NSUserDefaults+BlocksKit.m
//  BlocksKit
//
//  Created by Andrew Romanov on 05/03/2018.
//  2018 Zachary Waldowski and Pandamonia LLC
//

#import "NSUserDefaults+BlocksKit.h"


#define CODE(defaultSelector) do{if([self objectForKey:defaultName])\
{\
	return [self defaultSelector defaultName];\
}\
else\
{\
	return getter();\
}} while(false)


@implementation NSUserDefaults (BlocksKit)

- (nullable id)bk_objectForKey:(NSString *)defaultName withDefaultGetter:(id(^)(void))getter
{
	CODE(objectForKey:);
}


- (nullable NSString *)bk_stringForKey:(NSString *)defaultName withDefaultGetter:(NSString*(^)(void))getter
{
	CODE(stringForKey:);
}


- (nullable NSArray *)bk_arrayForKey:(NSString *)defaultName withDefaultGetter:(NSArray*(^)(void))getter
{
	CODE(arrayForKey:);
}


- (nullable NSDictionary<NSString *, id> *)bk_dictionaryForKey:(NSString *)defaultName withDefaultGetter:(NSDictionary<NSString *, id>*(^)(void))getter
{
	CODE(dictionaryForKey:);
}


- (nullable NSData *)bk_dataForKey:(NSString *)defaultName withDefaultGetter:(NSData*(^)(void))getter
{
	CODE(dataForKey:);
}


- (nullable NSArray<NSString *> *)bk_stringArrayForKey:(NSString *)defaultName withDefaultGetter:(NSArray<NSString *> *(^)(void))getter
{
	CODE(stringArrayForKey:);
}


- (NSInteger)bk_integerForKey:(NSString *)defaultName withDefaultGetter:(NSInteger(^)(void))getter
{
	CODE(integerForKey:);
}


- (float)bk_floatForKey:(NSString *)defaultName withDefaultGetter:(float(^)(void))getter
{
	CODE(floatForKey:);
}


- (double)bk_doubleForKey:(NSString *)defaultName withDefaultGetter:(double(^)(void))getter
{
	CODE(doubleForKey:);
}


- (BOOL)bk_boolForKey:(NSString *)defaultName withDefaultGetter:(BOOL(^)(void))getter
{
	CODE(boolForKey:);
}


- (nullable NSURL *)bk_URLForKey:(NSString *)defaultName withDefaultGetter:(NSURL*(^)(void))getter
{
	CODE(URLForKey:);
}

@end
