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
#import "MorphologyOfFamilyLanguages.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ABPadLockScreenChangeOldViewController () {
    struct {
        NSUInteger attemptsExpired : 1;
        NSUInteger pinSet : 1;
        NSUInteger validatePin : 1;
        NSUInteger unlockWasSuccessful : 1;
        NSUInteger unlockWasUnsuccessfulAfterAttemptNumber : 1;
        NSUInteger unlockWasCancelled : 1;
    }_delegateFlags;
}

@property (nonatomic, strong) NSString *oldPin;
@property (nonatomic, strong) NSString *enteredOldPin;
@property (nonatomic) BOOL oldPinValid;
@property (nonatomic, strong) NSString *enteredPin;

@property (nonatomic, copy) NSString *lockedOutString;
@property (nonatomic, copy) NSString *pluralAttemptsLeftString;
@property (nonatomic, copy) NSString *fewAttemptsLeftString;
@property (nonatomic, copy) NSString *singleAttemptLeftString;

- (void)startPinConfirmation;
- (void)validateConfirmedPin;


@end

@implementation ABPadLockScreenChangeOldViewController

#pragma mark -
#pragma mark - Delegates setup

- (void) setLockScreenDelegate:(id<ABPadLockScreenChangeOldViewControllerDelegate>)lockScreenDelegate {

    _delegateFlags.attemptsExpired = [lockScreenDelegate respondsToSelector:@selector(attemptsExpiredForPadLockScreenViewController:)] + 0;
    _delegateFlags.pinSet = [lockScreenDelegate respondsToSelector:@selector(pinSet:padLockScreenSetupViewController:)] + 0;
    _delegateFlags.validatePin = [lockScreenDelegate respondsToSelector:@selector(padLockScreenViewController:validatePin:)] + 0;
    _delegateFlags.unlockWasCancelled = [lockScreenDelegate respondsToSelector:@selector(unlockWasCancelledForPadLockScreenViewController:)] + 0;
    _delegateFlags.unlockWasSuccessful = [lockScreenDelegate respondsToSelector:@selector(unlockWasSuccessfulForPadLockScreenViewController:)] + 0;
    _delegateFlags.unlockWasUnsuccessfulAfterAttemptNumber = [lockScreenDelegate respondsToSelector:@selector(unlockWasUnsuccessful:afterAttemptNumber:padLockScreenViewController:)] + 0;

    _lockScreenDelegate = lockScreenDelegate;
}

#pragma mark -
#pragma mark - Init Methods
- (instancetype)initWithDelegate:(id<ABPadLockScreenChangeOldViewControllerDelegate>)delegate
{
    self = [self initWithDelegate:delegate complexPin:NO];
    return self;
}

- (instancetype)initWithDelegate:(id<ABPadLockScreenChangeOldViewControllerDelegate>)delegate complexPin:(BOOL)complexPin
{
    self = [super initWithComplexPin:complexPin];
    if (self)
    {
        self.delegate = delegate;
        self.lockScreenDelegate = delegate;
        _remainingAttempts = -1;
        _enteredOldPin = nil;
        _enteredPin = nil;
        [self setDefaultTexts];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<ABPadLockScreenChangeOldViewControllerDelegate>)delegate complexPin:(BOOL)complexPin subtitleLabelText:(NSString *)subtitleLabelText
{
    self = [self initWithDelegate:delegate complexPin:complexPin];
    if (self)
    {
        _subtitleLabelText = subtitleLabelText;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.lockScreenView updateDetailLabelWithString:_subtitleLabelText animated:NO completion:nil];
        });
    }
    return self;
}

- (instancetype)initWithDelegate:(id<ABPadLockScreenChangeOldViewControllerDelegate>)delegate complexPin:(BOOL)complexPin subtitleLabelText:(NSString *)subtitleLabelText oldPin:(NSString *)oldPin {
    self = [self initWithDelegate:delegate complexPin:complexPin subtitleLabelText:subtitleLabelText];

    if (self)
    {
        _oldPin = [oldPin copy];
    }
    return self;
}

#pragma mark - Default Language Settings
- (NSString *)currentLanguageSetting {
    if (!_currentLanguageSetting) {
        _currentLanguageSetting = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    }
    return _currentLanguageSetting;
}

- (void)setDefaultTexts
{
    _lockedOutString = NSLocalizedString(@"You have been locked out.", @"");
    _pluralAttemptsLeftString = NSLocalizedString(@"attempts left", @"");
    _fewAttemptsLeftString = NSLocalizedString(@"attempts left", @"");
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

- (void)setFewAttemptsLeftString:(NSString *)title
{
    _fewAttemptsLeftString = title;
}

- (void)setSingleAttemptLeftText:(NSString *)title
{
    _singleAttemptLeftString = title;
}


#pragma mark -
#pragma mark - Pin Processing
- (void)processPin
{

    if (self.oldPinValid) {
        [self processNewPin];
    }
    else {
        [self validateOldPin];
    }
}

- (void)processNewPin
{
    if (!self.enteredPin)
    {
        [self startPinConfirmation];
    }
    else
    {
        [self validateConfirmedPin];
    }
}

- (void)processFuturePin
{
    self.currentPin = @"";
    [self.lockScreenView updateDetailLabelWithString:self.futurePinPromptText animated:YES completion:nil];
    [self.lockScreenView resetAnimated:YES];
}

- (void)updateDetailLabelTitleByRemainingAttempts:(NSNumber *)attempts
{
    NSInteger attemptsCount = attempts.integerValue;
    MorphologyOfFamilyLanguages *morphology = [MorphologyOfFamilyLanguages createWithLanguageSetting:self.currentLanguageSetting];
    NSString *suffix = [morphology chooseStringCount:attemptsCount betweenMany:self.pluralAttemptsLeftString orFew:self.fewAttemptsLeftString orSingle:self.singleAttemptLeftString];
    NSString *detailLabelTitle = [NSString stringWithFormat:@"%ld %@", attemptsCount, suffix];
    [self.lockScreenView updateDetailLabelWithString:detailLabelTitle animated:YES completion:nil];
}

- (void)processOldPinFailure
{
    _remainingAttempts --;
    _totalAttempts ++;
    [self.lockScreenView resetAnimated:YES];
    [self.lockScreenView animateFailureNotification];

    if (self.remainingAttempts != 0) {
        [self updateDetailLabelTitleByRemainingAttempts:@(self.remainingAttempts)];
    }
    else {
        [self lockScreen];
    }


    if (_delegateFlags.unlockWasUnsuccessfulAfterAttemptNumber)
    {
        [self.lockScreenDelegate unlockWasUnsuccessful:self.currentPin afterAttemptNumber:self.totalAttempts padLockScreenViewController:self];
    }
}

- (BOOL)isOldPin:(NSString *)oldPin validToPin:(NSString *)enteredOldPin
{
    if (_delegateFlags.validatePin) {
        return [self.lockScreenDelegate padLockScreenViewController:self validatePin:enteredOldPin];
    }
    else {
        return [oldPin isEqualToString:enteredOldPin];
    }
}

- (void)validateOldPin
{

    if (!self.enteredOldPin) {
        self.enteredOldPin = [self.currentPin copy];
    }

    self.oldPinValid = [self isOldPin:self.oldPin validToPin:self.enteredOldPin];
    if (!self.oldPinValid)
    {
        [self.lockScreenView updateDetailLabelWithString:self.oldPinNotMatchedText animated:YES completion:nil];
        [self.lockScreenView animateFailureNotification];
        [self.lockScreenView resetAnimated:YES];
        self.enteredOldPin = nil;
        self.currentPin = @"";
        [self processOldPinFailure];
    }
    else {
        [self processFuturePin];

        if (_delegateFlags.unlockWasSuccessful)
        {
            [self.lockScreenDelegate unlockWasSuccessfulForPadLockScreenViewController:self];
        }
    }
}

- (void)startPinConfirmation
{
    self.enteredPin = [self.currentPin copy];
    self.currentPin = @"";
    [self.lockScreenView updateDetailLabelWithString:self.pinConfirmationText animated:YES completion:nil];
    [self.lockScreenView resetAnimated:YES];
}

- (void)validateConfirmedPin
{
    if ([self.currentPin isEqualToString:self.enteredPin])
    {
        if (_delegateFlags.pinSet)
        {
            [self.lockScreenDelegate pinSet:self.currentPin padLockScreenSetupViewController:self];
        }
    }
    else
    {
        [self.lockScreenView updateDetailLabelWithString:self.pinNotMatchedText animated:YES completion:nil];
        [self.lockScreenView animateFailureNotification];
        [self.lockScreenView resetAnimated:YES];
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
    [self.lockScreenView updateDetailLabelWithString:self.lockedOutString animated:YES completion:nil];
    [self.lockScreenView lockViewAnimated:YES completion:nil];

    if (_delegateFlags.attemptsExpired)
    {
        [self.lockScreenDelegate attemptsExpiredForPadLockScreenViewController:self];
    }
}

@end
