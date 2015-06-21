//
//  ABPadLockScreenDelegate.h
//  ABPadLockScreenDemo
//
//  Created by Lobanov Dmitry on 21.06.15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABPadLockScreenAbstractViewController;

@protocol ABPadLockScreenDelegate <NSObject>

@required
- (void)unlockWasCancelledForPadLockScreenViewController:(ABPadLockScreenAbstractViewController *)padLockScreenViewController;

@end
