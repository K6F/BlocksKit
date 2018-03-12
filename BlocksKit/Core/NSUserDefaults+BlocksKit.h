//
//  NSUserDefaults+BlocksKit.h
//  BlocksKit
//
//  Created by Andrew Romanov on 05/03/2018.
//  
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSUserDefaults (BlocksKit)

/*
 * If object for a key exists, call default implementation other call getter block
*/
- (nullable id)bk_objectForKey:(NSString *)defaultName withDefaultGetter:(id(^)(void))getter;
- (nullable NSString *)bk_stringForKey:(NSString *)defaultName withDefaultGetter:(NSString*(^)(void))getter;
- (nullable NSArray *)bk_arrayForKey:(NSString *)defaultName withDefaultGetter:(NSArray*(^)(void))getter;
- (nullable NSDictionary<NSString *, id> *)bk_dictionaryForKey:(NSString *)defaultName withDefaultGetter:(NSDictionary<NSString *, id>*(^)(void))getter;
- (nullable NSData *)bk_dataForKey:(NSString *)defaultName withDefaultGetter:(NSData*(^)(void))getter;
- (nullable NSArray<NSString *> *)bk_stringArrayForKey:(NSString *)defaultName withDefaultGetter:(NSArray<NSString *> *(^)(void))getter;
- (NSInteger)bk_integerForKey:(NSString *)defaultName withDefaultGetter:(NSInteger(^)(void))getter;
- (float)bk_floatForKey:(NSString *)defaultName withDefaultGetter:(float(^)(void))getter;
- (double)bk_doubleForKey:(NSString *)defaultName withDefaultGetter:(double(^)(void))getter;
- (BOOL)bk_boolForKey:(NSString *)defaultName withDefaultGetter:(BOOL(^)(void))getter;
- (nullable NSURL *)bk_URLForKey:(NSString *)defaultName withDefaultGetter:(NSURL*(^)(void))getter;

@end

NS_ASSUME_NONNULL_END
