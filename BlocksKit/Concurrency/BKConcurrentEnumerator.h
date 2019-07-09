//
//  BKConcurrentEnumerator.h
//  BlocksKit
//
//  Created by Andrew Romanov on 09/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKConcurrentEnumerator <ObjectType> : NSEnumerator

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEnumerator:(NSEnumerator<ObjectType>*)enumerator NS_DESIGNATED_INITIALIZER;

- (nullable ObjectType)nextObject;

@end

NS_ASSUME_NONNULL_END
