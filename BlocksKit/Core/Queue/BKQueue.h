//
//  BKQueue.h
//  BlocksKit
//
//  Created by Andrew Romanov on 06/07/2017.
//  Copyright © 2017 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@interface BKQueue : NSObject

+ (void)execSyncOnMainQueue:(void(^)(void))block;
+ (void)execAsyncOnMainQueue:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
