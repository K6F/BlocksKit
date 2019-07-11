//
//  BKLock.h
//  BlocksKit
//
//  Created by Andrew Romanov on 11/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKLock : NSObject

- (void)exec:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
