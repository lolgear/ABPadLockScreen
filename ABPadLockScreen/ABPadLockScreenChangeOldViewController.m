//
//  ABPadLockScreenChangeOldViewController.m
//  ABPadLockScreenDemo
//
//  Created by Lobanov Dmitry on 21.06.15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import "ABPadLockScreenChangeOldViewController.h"
#import "ABPadLockScreenView.h"
#import "ABPinSelectionView.h"
#import <AudioToolbox/AudioToolbox.h>

#define lockScreenView ((ABPadLockScreenView *) [self view])

@interface ABPadLockScreenChangeOldViewController ()

@property (nonatomic, strong) NSString *oldPin;
@property (nonatomic, strong) NSString *enteredOldPin;
@property (nonatomic, strong) NSString *futurePin;
@property (nonatomic, strong) NSString *enteredPin;

@property (nonatomic, strong) NSString *lockedOutString;
@property (nonatomic, strong) NSString *pluralAttemptsLeftString;
@property (nonatomic, strong) NSString *singleAttemptLeftString;

- (void)startPinConfirmation;
- (void)validateConfirmedPin;


@end

@implementation ABPadLockScreenChangeOldViewController

#pragma mark -
#pragma mark - Init Methods
- (instancetype)initWithDelegate:(id<ABPadLockScreenDelegate>)delegate
{
    self = [self initWithDelegate:delegate complexPin:NO];
    return self;
}

- (instancetype)initWithDelegate:(id<ABPadLockScreenDelegate>)delegate complexPin:(BOOL)complexPin
{
    self = [super initWithComplexPin:complexPin];
    if (self)
    {
        self.delegate = delegate;
        _lockScreenDelegate = delegate;
        _remainingAttempts = -1;
        _enteredOldPin = nil;
        _enteredPin = nil;
        [self setDefaultTexts];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<ABPadLockScreenDelegate>)delegate complexPin:(BOOL)complexPin subtitleLabelText:(NSString *)subtitleLabelText
{
    self = [self initWithDelegate:delegate complexPin:complexPin];
    if (self)
    {
        _subtitleLabelText = subtitleLabelText;
        dispatch_async(dispatch_get_main_queue(), ^{
            [lockScreenView updateDetailLabelWithString:_subtitleLabelText animated:NO completion:nil];
        });
    }
    return self;
}

- (instancetype)initWithDelegate:(id<ABPadLockScreenDelegate>)delegate complexPin:(BOOL)complexPin subtitleLabelText:(NSString *)subtitleLabelText oldPin:(NSString *)oldPin {
    self = [self initWithDelegate:delegate complexPin:complexPin subtitleLabelText:subtitleLabelText];
    
    if (self)
    {
        _oldPin = [oldPin copy];
    }
    return self;
}

- (void)setDefaultTexts
{
    _lockedOutString = NSLocalizedString(@"You have been locked out.", @"");
    _pluralAttemptsLeftString = NSLocalizedString(@"attempts left", @"");
    _singleAttemptLeftString = NSLocalizedString(@"attempt left", @"");
    _futurePinPromptText = NSLocalizedString(@"Enter your future pincode", @"");
//    _oldPinConfirmationText = NSLocalizedString(@"Enter your old pincode", @"");
    _oldPinNotMatchedText = NSLocalizedString(@"Old pincode did not match.", @"");
    _pinNotMatchedText = NSLocalizedString(@"Pincode did not match.", @"");
    _pinConfirmationText = NSLocalizedString(@"Re-enter your new pincode", @"");
}

#pragma mark -
#pragma mark - Attempts
- (void)setAllowedAttempts:(NSInteger)allowedAttempts
{
    _totalAttempts = 0;
    _remainingAttempts = allowedAttempts;
}

#pragma mark -
#pragma mark - Localisation Methods
- (void)setLockedOutText:(NSString *)title
{
    _lockedOutString = title;
}

- (void)setPluralAttemptsLeftText:(NSString *)title
{
    _pluralAttemptsLeftString = title;
}

- (void)setSingleAttemptLeftText:(NSString *)title
{
    _singleAttemptLeftString = title;
}


#pragma mark -
#pragma mark - Pin Processing
- (void)processPin
{
    [self validateOldPin];
}

- (void)processNewPin {
    if (!self.futurePin)
    {
        [self processFuturePin];
    }
    else {
        if (!self.enteredPin)
        {
            [self startPinConfirmation];
        }
        else
        {
            [self validateConfirmedPin];
        }
    }
}


- (void)processFuturePin
{
    self.futurePin = [self.currentPin copy];
    self.currentPin = @"";
    [lockScreenView updateDetailLabelWithString:self.futurePinPromptText animated:YES completion:nil];
    [lockScreenView resetAnimated:YES];
}

- (void)startOldPinConfirmation {
    self.enteredOldPin = [self.currentPin copy];
    self.currentPin = @"";
    [lockScreenView updateDetailLabelWithString:self.oldPinPromptText animated:YES completion:nil];
    [lockScreenView resetAnimated:YES];
}

- (void)processOldPinFailure {
    _remainingAttempts --;
    _totalAttempts ++;
    [lockScreenView resetAnimated:YES];
    [lockScreenView animateFailureNotification];
    
    if (self.remainingAttempts > 1)
    {
        [lockScreenView updateDetailLabelWithString:[NSString stringWithFormat:@"%ld %@", (long)self.remainingAttempts, self.pluralAttemptsLeftString]
                                           animated:YES completion:nil];
    }
    else if (self.remainingAttempts == 1)
    {
        [lockScreenView updateDetailLabelWithString:[NSString stringWithFormat:@"%ld %@", (long)self.remainingAttempts, self.singleAttemptLeftString]
                                           animated:YES completion:nil];
    }
    else if (self.remainingAttempts == 0)
    {
        [self lockScreen];
    }
    
//    if ([self.lockScreenDelegate respondsToSelector:@selector(unlockWasUnsuccessful:afterAttemptNumber:padLockScreenViewController:)])
//    {
//        [self.lockScreenDelegate unlockWasUnsuccessful:self.currentPin afterAttemptNumber:self.totalAttempts padLockScreenViewController:self];
//    }
}

- (void)processFuturePinFailure {
    self.futurePin = nil;
    self.currentPin = @"";
    [lockScreenView updateDetailLabelWithString:self.futurePinPromptText animated:YES completion:nil];
    [lockScreenView resetAnimated:YES];
}

- (void)validateOldPin {
    
    if (!self.enteredOldPin) {
        self.enteredOldPin = [self.currentPin copy];
    }
    
    if ([self.enteredOldPin isEqualToString:self.oldPin])
    {
        //
        // good enough
        [self processNewPin];
    }
    else
    {
        [lockScreenView updateDetailLabelWithString:self.oldPinNotMatchedText animated:YES completion:nil];
        [lockScreenView animateFailureNotification];
        [lockScreenView resetAnimated:YES];
        self.enteredOldPin = nil;
        self.currentPin = @"";
        [self processOldPinFailure];
    }
}

- (void)startPinConfirmation
{
    self.enteredPin = self.currentPin;
    self.currentPin = @"";
    [lockScreenView updateDetailLabelWithString:self.pinConfirmationText animated:YES completion:nil];
    [lockScreenView resetAnimated:YES];
}

- (void)validateConfirmedPin
{
    if ([self.currentPin isEqualToString:self.enteredPin])
    {
//        if ([self.setupScreenDelegate respondsToSelector:@selector(pinSet:padLockScreenSetupViewController:)])
//        {
////            [self.setupScreenDelegate pinSet:self.currentPin padLockScreenSetupViewController:self];
//        }
    }
    else
    {
        [lockScreenView updateDetailLabelWithString:self.pinNotMatchedText animated:YES completion:nil];
        [lockScreenView animateFailureNotification];
        [lockScreenView resetAnimated:YES];
        self.enteredPin = nil;
        self.currentPin = @"";
        [self processFuturePin];
        // viberate feedback
        if (self.errorVibrateEnabled)
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

#pragma mark -
#pragma mark - Pin Selection
- (void)lockScreen
{
    [lockScreenView updateDetailLabelWithString:[NSString stringWithFormat:@"%@", self.lockedOutString] animated:YES completion:nil];
    [lockScreenView lockViewAnimated:YES completion:nil];
    
//    if ([self.lockScreenDelegate respondsToSelector:@selector(attemptsExpiredForPadLockScreenViewController:)])
//    {
//        [self.lockScreenDelegate attemptsExpiredForPadLockScreenViewController:self];
//    }
}

@end
