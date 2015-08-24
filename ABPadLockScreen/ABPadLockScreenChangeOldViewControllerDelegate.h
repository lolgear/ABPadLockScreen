//
//  ABPadLockScreenChangeOldViewControllerDelegate.h
//  ABPadLockScreenDemo
//
//  Created by Lobanov Dmitry on 21.06.15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABPadLockScreenDelegate.h"

@class ABPadLockScreenChangeOldViewController;

@protocol ABPadLockScreenChangeOldViewControllerDelegate <ABPadLockScreenDelegate>

@required

/**
 Called when the unlock was completed successfully
 */
- (void)unlockWasSuccessfulForPadLockScreenViewController:(ABPadLockScreenChangeOldViewController *)padLockScreenViewController;

/**
 Called when an unlock was unsuccessfully, providing the entry code and the attempt number
 */
- (void)unlockWasUnsuccessful:(NSString *)falsePin afterAttemptNumber:(NSInteger)attemptNumber padLockScreenViewController:(ABPadLockScreenChangeOldViewController *)padLockScreenViewController;

/**
 Called when the user cancels the unlock
 */
- (void)unlockWasCancelledForPadLockScreenViewController:(ABPadLockScreenChangeOldViewController *)padLockScreenViewController;


/**
 Called when the user set new pin successfully
 */
- (void)pinSet:(NSString *)pin padLockScreenSetupViewController:(ABPadLockScreenChangeOldViewController *)padLockScreenViewController;


@optional

/**
 Called when pin validation is needed
 */
- (BOOL)padLockScreenViewController:(ABPadLockScreenChangeOldViewController *)padLockScreenViewController validatePin:(NSString*)pin;

/**
 Called when the user has expired their attempts
 */
- (void)attemptsExpiredForPadLockScreenViewController:(ABPadLockScreenChangeOldViewController *)padLockScreenViewController;



@end
