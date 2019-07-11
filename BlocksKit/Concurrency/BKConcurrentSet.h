//
//  BKConcurrentSet.h
//  BlocksKit
//
//  Created by Andrew Romanov on 11/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKConcurrentSet <ObjectType> : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSet:(NSSet*)set;


- (NSUInteger)count;

/** Loops through a set and executes the given block with each object.
 
 @param block A single-argument, void-returning code block.
 */
- (void)bk_each:(void (^)(ObjectType obj))block;

/** Enumerates through a set concurrently and executes
 the given block once for each object.
 
 Enumeration will occur on appropriate background queues. This
 will have a noticeable speed increase, especially on dual-core
 devices, but you *must* be aware of the thread safety of the
 objects you message from within the block.
 
 @param block A single-argument, void-returning code block.
 */
- (void)bk_apply:(void (^)(ObjectType obj))block __attribute((deprecated("Use bk_each")));

/** Loops through a set to find the object matching the block.
 
 bk_match: is functionally identical to bk_select:, but will stop and return
 on the match.
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns the object if found, `nil` otherwise.
 @see bk_select:
 */
- (nullable ObjectType)bk_match:(BOOL (^)(ObjectType obj))block;

/** Loops through a set to find the objects matching the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns a set of the objects found.
 @see bk_match:
 */
- (NSSet<ObjectType> *)bk_select:(BOOL (^)(ObjectType obj))block;

/** Loops through a set to find the objects not matching the block.
 
 This selector performs *literally* the exact same function as select, but in reverse.
 
 This is useful, as one may expect, for removing objects from a set:
 NSSet *new = [reusableWebViews bk_reject:^BOOL(id obj) {
 return ([obj isLoading]);
 }];
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of all objects not found.
 */
- (NSSet<ObjectType> *)bk_reject:(BOOL (^)(ObjectType obj))block;

/** Call the block once for each object and create a set of the return values.
 
 This is sometimes referred to as a transform, mutating one of each object:
 NSSet *new = [mimeTypes bk_map:^id(id obj) {
 return [@"x-company-" stringByAppendingString:obj]);
 }];
 
 @param block A single-argument, object-returning code block.
 @return Returns a set of the objects returned by the block.
 */
- (NSSet *)bk_map:(id (^)(ObjectType obj))block;


/** Loops through a set to find whether any object matches the block.
 
 This method is similar to the Scala list `exists`. It is functionally
 identical to bk_match: but returns a `BOOL` instead. It is not recommended
 to use bk_any: as a check condition before executing bk_match:, since it would
 require two loops through the array.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES for the first time the block returns YES for an object, NO otherwise.
 */
- (BOOL)bk_any:(BOOL (^)(ObjectType obj))block;

/** Loops through a set to find whether no objects match the block.
 
 This selector performs *literally* the exact same function as bk_all: but in reverse.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns NO for all objects in the set, NO otherwise.
 */
- (BOOL)bk_none:(BOOL (^)(ObjectType obj))block;

/** Loops through a set to find whether all objects match the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all objects in the set, NO otherwise.
 */
- (BOOL)bk_all:(BOOL (^)(ObjectType obj))block;

/*
 Findes max element with criteriy
 */
- (nullable ObjectType)bk_max:(CGFloat(^)(ObjectType obj))block;

/*
 Findes min element with criteriy
 */
- (nullable ObjectType)bk_min:(CGFloat(^)(ObjectType obj))block;

@end


@interface NSSet <ObjectType> (BlocksKit_Concurrent)

- (BKConcurrentSet<ObjectType>*)bk_concurrent;

@end

NS_ASSUME_NONNULL_END
