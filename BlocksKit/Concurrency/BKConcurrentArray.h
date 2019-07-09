//
//  BKConcurrentArray.h
//  BlocksKit
//
//  Created by Andrew Romanov on 09/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "BKDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface  BKConcurrentArray <ObjectType> : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithArray:(NSArray<__GENERICS_TYPE(ObjectType)>*)objects;

- (NSUInteger)count;
- (__GENERICS_TYPE(ObjectType))objectAtIndex:(NSInteger)index;

@end


@interface BKConcurrentArray <ObjectType> (BlocksKit)

/** Loops through an array and executes the given block with each object.
 
 @param block A single-argument, void-returning code block.
 */
- (void)bk_each:(void (^)(__GENERICS_TYPE(ObjectType) obj))block;

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
- (void)bk_apply:(void (^)(__GENERICS_TYPE(ObjectType) obj))block __attribute((deprecated("Use bk_each")));

/** Loops through an array to find the object matching the block.
 
 bk_match: is functionally identical to bk_select:, but will stop and return
 on the first match.
 
 @param block A single-argument, `BOOL`-returning code block.
 @return Returns the object, if found, or `nil`.
 @see bk_select:
 */
- (nullable id)bk_match:(BOOL (^)(__GENERICS_TYPE(ObjectType) obj))block;

/** Loops through an array to find the objects matching the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of the objects found.
 @see bk_match:
 */
- (NSArray *)bk_select:(BOOL (^)(__GENERICS_TYPE(ObjectType) obj))block;

/** Loops through an array to find the objects not matching the block.
 
 This selector performs *literally* the exact same function as bk_select: but in reverse.
 
 This is useful, as one may expect, for removing objects from an array.
 NSArray *new = [computers bk_reject:^BOOL(id obj) {
 return ([obj isUgly]);
 }];
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of all objects not found.
 */
- (NSArray *)bk_reject:(BOOL (^)(__GENERICS_TYPE(ObjectType) obj))block;

/** Call the block once for each object and create an array of the return values.
 
 This is sometimes referred to as a transform, mutating one of each object:
 NSArray *new = [stringArray bk_map:^id(id obj) {
 return [obj stringByAppendingString:@".png"]);
 }];
 
 @param block A single-argument, object-returning code block.
 @return Returns an array of the objects returned by the block.
 */
- (NSArray *)bk_map:(id (^)(__GENERICS_TYPE(ObjectType) obj))block;

/** Behaves like map, but doesn't add NSNull objects if you return nil in the block.
 
 @param block A single-argument, object-returning code block.
 @return Returns an array of the objects returned by the block.
 */
- (NSArray *)bk_compact:(id (^)(__GENERICS_TYPE(ObjectType) obj))block;

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
- (BOOL)bk_any:(BOOL (^)(__GENERICS_TYPE(ObjectType) obj))block;

/** Loops through an array to find whether no objects match the block.
 
 This selector performs *literally* the exact same function as bk_all: but in reverse.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns NO for all objects in the array, NO otherwise.
 */
- (BOOL)bk_none:(BOOL (^)(__GENERICS_TYPE(ObjectType) obj))block;

/** Loops through an array to find whether all objects match the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all objects in the array, NO otherwise.
 */
- (BOOL)bk_all:(BOOL (^)(__GENERICS_TYPE(ObjectType) obj))block;

/** Tests whether every element of this array relates to the corresponding element of another array according to match by block.
 
 For example, finding if a list of numbers corresponds to their sequenced string values;
 NSArray *numbers = @[ @(1), @(2), @(3) ];
 NSArray *letters = @[ @"1", @"2", @"3" ];
 BOOL doesCorrespond = [numbers bk_corresponds:letters withBlock:^(id number, id letter) {
 return [[number stringValue] isEqualToString:letter];
 }];
 
 @param list An array of objects to compare with, should be ready for reading from any threads.
 @param block A two-argument, BOOL-returning code block.
 @return Returns a BOOL, true if every element of array relates to corresponding element in another array.
 */
- (BOOL)bk_corresponds:(NSArray *)list withBlock:(BOOL (^)(__GENERICS_TYPE(ObjectType) obj1, id obj2))block;

/*
 Findes max element with criteriy
 */
- (nullable __GENERICS_TYPE(ObjectType))bk_max:(CGFloat(^)(__GENERICS_TYPE(ObjectType) obj))block;

/*
 Findes min element with criteriy
 */
- (nullable __GENERICS_TYPE(ObjectType))bk_min:(CGFloat(^)(__GENERICS_TYPE(ObjectType) obj))block;

@end


@interface NSArray <ObjectType> (BlocksKit_Concurrent)

- (BKConcurrentArray<ObjectType>*)bk_concurrent;

@end


NS_ASSUME_NONNULL_END
