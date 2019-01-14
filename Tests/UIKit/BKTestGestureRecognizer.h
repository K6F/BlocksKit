//
//  BKTestGestureRecognizer.h
//  MobileBlocksKitTests
//
//  Created by Andrew Romanov on 14/01/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKTestGestureRecognizer : UIGestureRecognizer

- (void)sendEventWithState:(UIGestureRecognizerState)state;

@end

NS_ASSUME_NONNULL_END
