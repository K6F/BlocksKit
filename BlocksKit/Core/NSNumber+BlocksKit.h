//
//  NSNumber+BlocksKit.h
//  BlocksKit
//

#import <Foundation/Foundation.h>

/** Block extensions for NSNumber.

 Both inspired by and resembling Smalltalk syntax, these utilities
 allows for iteration of an array in a concise way that
 saves quite a bit of boilerplate code for performing a task a fixed number of
 times.

 Includes code by the following:

- [Colin T.A. Gray](https://github.com/colinta)
 */
@interface NSNumber (BlocksKit)

/** Performs a block `self` number of times

 @param block A void-returning code block that accepts no arguments.
 */
- (void)bk_times:(void (^)(void))block;

/** Performs a block `self` number of times concurrently
 
 @param block A void-returning code block that accepts no arguments.
*/
- (void)bk_concurrently:(void(^)(void))block;
/**
 Performs a block `self` number of times
 @param block A void-returning code block that accepts NSInteger argument.
 from 0 to MAX(self-1, 0)
 */
- (void)bk_enumerate:(void(^)(NSInteger))block;


@end
