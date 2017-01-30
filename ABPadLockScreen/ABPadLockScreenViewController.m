// ABPadLockScreenViewController.m
//
// Copyright (c) 2014 Aron Bury - http://www.aronbury.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ABPadLockScreenViewController.h"
#import "ABPadLockScreenView.h"
#import "ABPinSelectionView.h"
#import "MorphologyOfFamilyLanguages.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ABPadLockScreenViewController ()

@property (nonatomic, copy) NSString *lockedOutString;
@property (nonatomic, copy) NSString *pluralAttemptsLeftString;
@property (nonatomic, copy) NSString *fewAttemptsLeftText;
@property (nonatomic, copy) NSString *singleAttemptLeftString;

- (BOOL)isPinValid:(NSString *)pin;

- (void)unlockScreen;
- (void)processFailure;
- (void)lockScreen;

@end

@implementation ABPadLockScreenViewController
#pragma mark -
#pragma mark - Init Methods
- (instancetype)initWithDelegate:(id<ABPadLockScreenViewControllerDelegate>)delegate complexPin:(BOOL)complexPin
{
    self = [super initWithComplexPin:complexPin];
    if (self)
    {
        self.delegate = delegate;
        _lockScreenDelegate = delegate;
        _remainingAttempts = -1;

        _lockedOutString = NSLocalizedString(@"You have been locked out.", @"");
        _pluralAttemptsLeftString = NSLocalizedString(@"attempts left", @"");
        _fewAttemptsLeftText = NSLocalizedString(@"attempts left", @"");
        _singleAttemptLeftString = NSLocalizedString(@"attempt left", @"");
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

- (void)setFewAttemptsLeftText:(NSString *)title
{
    _fewAttemptsLeftText = title;
}

- (void)setSingleAttemptLeftText:(NSString *)title
{
    _singleAttemptLeftString = title;
}

#pragma mark -
#pragma mark - Pin Processing
- (void)processPin
{
    if ([self isPinValid:self.currentPin])
    {
        [self unlockScreen];
    }
    else
    {
        [self processFailure];
    }
}

- (void)unlockScreen
{
    if ([self.lockScreenDelegate respondsToSelector:@selector(unlockWasSuccessfulForPadLockScreenViewController:)])
    {
        [self.lockScreenDelegate unlockWasSuccessfulForPadLockScreenViewController:self];
    }
}

- (void)updateDetailLabelTitleByRemainingAttempts:(NSNumber *)attempts
{
    NSInteger attemptsCount = attempts.integerValue;
    MorphologyOfFamilyLanguages *morphology = [MorphologyOfFamilyLanguages createWithLanguageSetting:self.currentLanguageSetting];
    NSString *suffix = [morphology chooseStringCount:attemptsCount betweenMany:self.pluralAttemptsLeftString orFew:self.fewAttemptsLeftText orSingle:self.singleAttemptLeftString];
    NSString *detailLabelTitle = [NSString stringWithFormat:@"%ld %@", attemptsCount, suffix];
    [self.lockScreenView updateDetailLabelWithString:detailLabelTitle animated:YES completion:nil];
}

- (void)processFailure
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

    if ([self.lockScreenDelegate respondsToSelector:@selector(unlockWasUnsuccessful:afterAttemptNumber:padLockScreenViewController:)])
    {
        [self.lockScreenDelegate unlockWasUnsuccessful:self.currentPin afterAttemptNumber:self.totalAttempts padLockScreenViewController:self];
    }
    self.currentPin = @"";

    if (self.errorVibrateEnabled)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (BOOL)isPinValid:(NSString *)pin
{
    if ([self.lockScreenDelegate respondsToSelector:@selector(padLockScreenViewController:validatePin:)])
    {
        return [self.lockScreenDelegate padLockScreenViewController:self validatePin:pin];
    }
    return NO;
}

#pragma mark -
#pragma mark - Pin Selection
- (void)lockScreen
{
    [self.lockScreenView updateDetailLabelWithString:[NSString stringWithFormat:@"%@", self.lockedOutString] animated:YES completion:nil];
    [self.lockScreenView lockViewAnimated:YES completion:nil];

    if ([self.lockScreenDelegate respondsToSelector:@selector(attemptsExpiredForPadLockScreenViewController:)])
    {
        [self.lockScreenDelegate attemptsExpiredForPadLockScreenViewController:self];
    }
}

@end
