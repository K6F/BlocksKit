//
//  BKConcurrentSet.m
//  BlocksKit
//
//  Created by Andrew Romanov on 11/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import "BKConcurrentSet.h"
#import "BKLock.h"


@interface BKConcurrentSet ()

@property (nonatomic, strong) NSSet* set;

@end



@implementation BKConcurrentSet


- (instancetype)initWithSet:(NSSet*)set
{
	if (self = [super init])
	{
		_set = set;
	}
	
	return self;
}


- (NSUInteger)count
{
	return self.set.count;
}


/** Loops through a set and executes the given block with each object.
 
 @param block A single-argument, void-returning code block.
 */
- (void)bk_each:(void (^)(id obj))block
{
	[self.set enumerateObjectsWithOptions:NSEnumerationConcurrent
														 usingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
															 block(obj);
														 }];
}


/** Enumerates through a set concurrently and executes
 the given block once for each object.
 
 Enumeration will occur on appropriate background queues. This
 will have a noticeable speed increase, especially on dual-core
 devices, but you *must* be aware of the thread safety of the
 objects you message from within the block.
 
 @param block A single-argument, void-returning code block.
 */
- (void)bk_apply:(void (^)(id obj))block
{
	[self bk_each:block];
}

/** Loops through a set to find the object matching the block.
 
 bk_match: is functionally identical to bk_select:, but will stop and return
 on the match.
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns the object if found, `nil` otherwise.
 @see bk_select:
 */
- (nullable id)bk_match:(BOOL (^)(id obj))block
{
	__block id passedObject = nil;
	[self.set enumerateObjectsWithOptions:NSEnumerationConcurrent
														 usingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
															 BOOL passed = block(obj);
															 if (passed)
															 {
																 passedObject = obj;
																 *stop = YES;
															 }
														 }];
	return passedObject;
}


/** Loops through a set to find the objects matching the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns a set of the objects found.
 @see bk_match:
 */
- (NSSet *)bk_select:(BOOL (^)(id obj))block
{
	NSSet* resultSet = [self.set objectsWithOptions:NSEnumerationConcurrent
																			passingTest:^BOOL(id  _Nonnull obj, BOOL * _Nonnull stop) {
																				BOOL passed = block(obj);
																				return passed;
																			}];
	return resultSet;
}


/** Loops through a set to find the objects not matching the block.
 
 This selector performs *literally* the exact same function as select, but in reverse.
 
 This is useful, as one may expect, for removing objects from a set:
 NSSet *new = [reusableWebViews bk_reject:^BOOL(id obj) {
 return ([obj isLoading]);
 }];
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of all objects not found.
 */
- (NSSet *)bk_reject:(BOOL (^)(id obj))block
{
	NSSet* result = [self.set objectsWithOptions:NSEnumerationConcurrent
																	 passingTest:^BOOL(id  _Nonnull obj, BOOL * _Nonnull stop) {
																		 BOOL passed = block(obj);
																		 return !passed;
																	 }];
	return result;
}


/** Call the block once for each object and create a set of the return values.
 
 This is sometimes referred to as a transform, mutating one of each object:
 NSSet *new = [mimeTypes bk_map:^id(id obj) {
 return [@"x-company-" stringByAppendingString:obj]);
 }];
 
 @param block A single-argument, object-returning code block.
 @return Returns a set of the objects returned by the block.
 */
- (NSSet *)bk_map:(id (^)(id obj))block
{
	NSMutableSet* result = [NSMutableSet setWithCapacity:self.count];
	BKLock* sync = [[BKLock alloc] init];
	[self.set enumerateObjectsWithOptions:NSEnumerationConcurrent
														 usingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
															 id createdObj = block(obj);
															 [sync exec:^{
																 [result addObject:createdObj];
															 }];
														 }];
	return result;
}


/** Loops through a set to find whether any object matches the block.
 
 This method is similar to the Scala list `exists`. It is functionally
 identical to bk_match: but returns a `BOOL` instead. It is not recommended
 to use bk_any: as a check condition before executing bk_match:, since it would
 require two loops through the array.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES for the first time the block returns YES for an object, NO otherwise.
 */
- (BOOL)bk_any:(BOOL (^)(id obj))block
{
	BOOL exist = ([self bk_match:block] != nil);
	return exist;
}


/** Loops through a set to find whether no objects match the block.
 
 This selector performs *literally* the exact same function as bk_all: but in reverse.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns NO for all objects in the set, NO otherwise.
 */
- (BOOL)bk_none:(BOOL (^)(id obj))block
{
	BOOL none = ([self bk_match:block] == nil);
	return none;
}


/** Loops through a set to find whether all objects match the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all objects in the set, NO otherwise.
 */
- (BOOL)bk_all:(BOOL (^)(id obj))block
{
	BOOL all = ([self bk_match:^BOOL(id  _Nonnull obj) {
		return !block(obj);
	}] == nil);
	return all;
}


/*
 Findes max element with criteriy
 */
- (nullable id)bk_max:(CGFloat(^)(id obj))block
{
	__block id maxObj = self.set.anyObject;
	if (maxObj)
	{
		__block CGFloat maxValue = block(maxObj);
		BKLock* sync = [[BKLock alloc] init];
		[self bk_each:^(id  _Nonnull obj) {
			CGFloat value = block(obj);
			[sync exec:^{
				if (value > maxValue)
				{
					maxValue = value;
					maxObj = obj;
				}
			}];
		}];
	}
	
	return maxObj;
}


/*
 Findes min element with criteriy
 */
- (nullable id)bk_min:(CGFloat(^)(id obj))block
{
	__block id minObj = self.set.anyObject;
	if (minObj)
	{
		__block CGFloat minVal = block(minObj);
		BKLock* sync = [[BKLock alloc] init];
		[self bk_each:^(id  _Nonnull obj) {
			CGFloat value = block(obj);
			[sync exec:^{
				if (value < minVal)
				{
					minVal = value;
					minObj = obj;
				}
			}];
		}];
	}
	
	return minObj;
}

@end


#pragma mark -
@implementation NSSet (BlocksKit_Concurrent)

- (BKConcurrentSet*)bk_concurrent
{
	BKConcurrentSet* result = [[BKConcurrentSet alloc] initWithSet:[self copy]];
	return result;
}

@end
