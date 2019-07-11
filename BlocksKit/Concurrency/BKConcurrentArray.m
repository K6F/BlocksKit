//
//  BKConcurrentArray.m
//  BlocksKit
//
//  Created by Andrew Romanov on 09/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import "BKConcurrentArray.h"
#import "BKLock.h"

@interface BKConcurrentArray ()

@property (nonatomic, strong) NSArray* objects;

@end


@implementation BKConcurrentArray

- (instancetype)initWithArray:(NSArray*)objects
{
	if (self = [super init])
	{
		_objects = objects;
	}
	
	return self;
}


- (NSUInteger)count
{
	NSUInteger count = [self.objects count];
	return count;
}


- (id)objectAtIndex:(NSInteger)index
{
	id obj = [self.objects  objectAtIndex:index];
	return obj;
}

@end


#pragma mark -
@implementation BKConcurrentArray (BlocksKit)

/** Loops through an array and executes the given block with each object.
 
 @param block A single-argument, void-returning code block.
 */
- (void)bk_each:(void (^)(id obj))block
{
	[self.objects enumerateObjectsWithOptions:NSEnumerationConcurrent
																 usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
																	 block(obj);
																 }];
}


/** Enumerates through an array concurrently and executes
 the given block once for each object.
 
 Enumeration will occur on appropriate background queues. This
 will have a noticeable speed increase, especially on dual-core
 devices, but you *must* be aware of the thread safety of the
 objects you message from within the block. Be aware that the
 order of objects is not necessarily the order each block will
 be called in.
 
 @param block A single-argument, void-returning code block.
 */
- (void)bk_apply:(void (^)(id obj))block
{
	[self bk_each:block];
}

/** Loops through an array to find the object matching the block.
 
 bk_match: is functionally identical to bk_select:, but will stop and return
 on the first match.
 
 @param block A single-argument, `BOOL`-returning code block.
 @return Returns the object, if found, or `nil`.
 @see bk_select:
 */
- (nullable id)bk_match:(BOOL (^)(id obj))block
{
	NSInteger index = [self.objects indexOfObjectWithOptions:NSEnumerationConcurrent
																							 passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
																								 BOOL passed = block(obj);
																								 return passed;
																							 }];
	id result = nil;
	if (index != NSNotFound)
	{
		result = [self.objects objectAtIndex:index];
	}
	
	return result;
}


/** Loops through an array to find the objects matching the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of the objects found.
 @see bk_match:
 */
- (NSArray *)bk_select:(BOOL (^)(id obj))block
{
	NSIndexSet* indexes = [self.objects indexesOfObjectsWithOptions:NSEnumerationConcurrent
																											passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
																												BOOL passed = block(obj);
																												return passed;
																											}];
	NSArray* result = [self.objects objectsAtIndexes:indexes];
	return result;
}


/** Loops through an array to find the objects not matching the block.
 
 This selector performs *literally* the exact same function as bk_select: but in reverse.
 
 This is useful, as one may expect, for removing objects from an array.
 NSArray *new = [computers bk_reject:^BOOL(id obj) {
 return ([obj isUgly]);
 }];
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of all objects not found.
 */
- (NSArray *)bk_reject:(BOOL (^)(id obj))block
{
	NSIndexSet* indexes = [self.objects indexesOfObjectsWithOptions:NSEnumerationConcurrent
																											passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
																												BOOL shouldReject = block(obj);
																												return !shouldReject;
																											}];
	NSArray* result = [self.objects objectsAtIndexes:indexes];
	return result;
}


/** Call the block once for each object and create an array of the return values.
 
 This is sometimes referred to as a transform, mutating one of each object:
 NSArray *new = [stringArray bk_map:^id(id obj) {
 return [obj stringByAppendingString:@".png"]);
 }];
 
 @param block A single-argument, object-returning code block.
 @return Returns an array of the objects returned by the block.
 */
- (NSArray *)bk_map:(id (^)(id obj))block
{
	NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count];
	BKLock* sync = [[BKLock alloc] init];
	[self.objects enumerateObjectsWithOptions:NSEnumerationConcurrent
																 usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
																	 id processed = block(obj);
																	 if (!processed)
																	 {
																		 processed = [NSNull null];
																	 }
																	 [sync exec:^{
																		 [result addObject:processed];
																	 }];
																 }];
	return result;
}


/** Behaves like map, but doesn't add NSNull objects if you return nil in the block.
 
 @param block A single-argument, object-returning code block.
 @return Returns an array of the objects returned by the block.
 */
- (NSArray *)bk_compact:(id (^)(id obj))block
{
	NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count];
	BKLock* sync = [[BKLock alloc] init];
	[self.objects enumerateObjectsWithOptions:NSEnumerationConcurrent
																 usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
																	 id processed = block(obj);
																	 if (processed)
																	 {
																		 [sync exec:^{
																			 [result addObject:processed];
																		 }];
																	 }
																 }];
	return result;
}

/** Loops through an array to find whether any object matches the block.
 
 This method is similar to the Scala list `exists`. It is functionally
 identical to bk_match: but returns a `BOOL` instead. It is not recommended
 to use bk_any: as a check condition before executing bk_match:, since it would
 require two loops through the array.
 
 For example, you can find if a string in an array starts with a certain letter:
 
 NSString *letter = @"A";
 BOOL containsLetter = [stringArray bk_any:^(id obj) {
 return [obj hasPrefix:@"A"];
 }];
 
 @param block A single-argument, BOOL-returning code block.
 @return YES for the first time the block returns YES for an object, NO otherwise.
 */
- (BOOL)bk_any:(BOOL (^)(id obj))block
{
	NSInteger index = [self.objects indexOfObjectWithOptions:NSEnumerationConcurrent
																							 passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
																								 BOOL passed = block(obj);
																								 return passed;
																							 }];
	BOOL any = (index != NSNotFound);
	return any;
}


/** Loops through an array to find whether no objects match the block.
 
 This selector performs *literally* the exact same function as bk_all: but in reverse.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns NO for all objects in the array, NO otherwise.
 */
- (BOOL)bk_none:(BOOL (^)(id obj))block
{
	NSInteger indexPassed = [self.objects indexOfObjectWithOptions:NSEnumerationConcurrent
																										 passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
																													BOOL passed = block(obj);
																													return passed;
																										 }];
	BOOL none = (indexPassed == NSNotFound);
	return none;
}

/** Loops through an array to find whether all objects match the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all objects in the array, NO otherwise.
 */
- (BOOL)bk_all:(BOOL (^)(id obj))block
{
	NSInteger indexNonPassed= [self.objects indexOfObjectWithOptions:NSEnumerationConcurrent
																							passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
																								BOOL passed = block(obj);
																								return !passed;
																							}];
	BOOL all = (indexNonPassed == NSNotFound);
	return all;
}

/** Tests whether every element of this array relates to the corresponding element of another array according to match by block.
 
 For example, finding if a list of numbers corresponds to their sequenced string values;
 NSArray *numbers = @[ @(1), @(2), @(3) ];
 NSArray *letters = @[ @"1", @"2", @"3" ];
 BOOL doesCorrespond = [numbers bk_corresponds:letters withBlock:^(id number, id letter) {
 return [[number stringValue] isEqualToString:letter];
 }];
 
 @param list An array of objects to compare with.
 @param block A two-argument, BOOL-returning code block.
 @return Returns a BOOL, true if every element of array relates to corresponding element in another array.
 */
- (BOOL)bk_corresponds:(NSArray *)list withBlock:(BOOL (^)(id obj1, id obj2))block
{
	BOOL corresponds = (list.count == self.count);
	if (corresponds)
	{
		NSInteger nonCorrespondsIndex = [self.objects indexOfObjectWithOptions:NSEnumerationConcurrent
																															 passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
																																 BOOL correspond = block(obj, [list objectAtIndex:idx]);
																																 return !correspond;
																															 }];
		corresponds = (nonCorrespondsIndex == NSNotFound);
	}
	
	return corresponds;
}


/*
 Findes max element with criteriy
 */
- (nullable id)bk_max:(CGFloat(^)(id obj))block
{
	__block id maxObject = self.objects.firstObject;
	
	if (maxObject)
	{
		__block CGFloat maxVal = block(maxObject);
		BKLock* sync = [[BKLock alloc] init];
		[self bk_each:^(id  _Nonnull obj) {
			CGFloat value = block(obj);
			[sync exec:^{
				if (value > maxVal)
				{
					maxVal = value;
					maxObject = obj;
				}
			}];
		}];
	}
	
	return maxObject;
}


/*
 Findes min element with criteriy
 */
- (nullable id)bk_min:(CGFloat(^)(id obj))block
{
	__block id minObject = self.objects.firstObject;
	if (minObject)
	{
		__block CGFloat minVal = block(minObject);
		BKLock* sync = [[BKLock alloc] init];
		[self bk_each:^(id  _Nonnull obj) {
			CGFloat value = block(obj);
			[sync exec:^{
				if (value < minVal)
				{
					minObject = obj;
					minVal = value;
				}
			}];
		}];
	}
	
	return minObject;
}

@end


#pragma mark -
@implementation NSArray (BlocksKit_Concurrent)

- (BKConcurrentArray*)bk_concurrent
{
	BKConcurrentArray* array = [[BKConcurrentArray alloc] initWithArray:[self copy]];
	return array;
}

@end

