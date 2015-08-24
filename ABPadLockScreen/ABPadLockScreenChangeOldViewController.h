//
//  ABPadLockScreenChangeOldViewController.h
//  ABPadLockScreenDemo
//
//  Created by Lobanov Dmitry on 21.06.15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import "ABPadLockScreenAbstractViewController.h"
#import "ABPadLockScreenChangeOldViewControllerDelegate.h"

@interface ABPadLockScreenChangeOldViewController : ABPadLockScreenAbstractViewController
@property (nonatomic, weak, readonly) id<ABPadLockScreenChangeOldViewControllerDelegate> lockScreenDelegate;
@property (nonatomic, strong, readonly) NSString *subtitleLabelText;
@property (nonatomic, strong) NSString *oldPinPromptText;
@property (nonatomic, strong) NSString *futurePinPromptText;
@property (nonatomic, strong) NSString *oldPinNotMatchedText;
@property (nonatomic, strong) NSString *pinNotMatchedText;
@property (nonatomic, strong) NSString *pinConfirmationText;

@property (nonatomic, assign, readonly) NSInteger totalAttempts;
@property (nonatomic, assign, readonly) NSInteger remainingAttempts;

- (void)setAllowedAttempts:(NSInteger)allowedAttempts;

- (void)setLockedOutText:(NSString *)title;
- (void)setPluralAttemptsLeftText:(NSString *)title;
- (void)setSingleAttemptLeftText:(NSString *)title;

- (instancetype)initWithDelegate:(id<ABPadLockScreenChangeOldViewControllerDelegate>)delegate;
- (instancetype)initWithDelegate:(id<ABPadLockScreenChangeOldViewControllerDelegate>)delegate complexPin:(BOOL)complexPin;
- (instancetype)initWithDelegate:(id<ABPadLockScreenChangeOldViewControllerDelegate>)delegate complexPin:(BOOL)complexPin subtitleLabelText:(NSString *)subtitleLabelText;
- (instancetype)initWithDelegate:(id<ABPadLockScreenChangeOldViewControllerDelegate>)delegate complexPin:(BOOL)complexPin subtitleLabelText:(NSString *)subtitleLabelText oldPin:(NSString *)oldPin;

@end