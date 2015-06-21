//
//  ABPadLockScreenView+CustomAccessors.m
//  ABPadLockScreenDemo
//
//  Created by Lobanov Dmitry on 21.06.15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import "ABPadLockScreenView+CustomAccessors.h"

@implementation ABPadLockScreenView (CustomAccessors)

- (UIView *)backgroundBlurringView {
    return [self valueForKey:@"_backgroundBlurringView"];
}

- (void)setIsBlurOverBackground:(BOOL)isBlurOverBackground {
    if (isBlurOverBackground) {
        self.backgroundBlurringView.frame = self.backgroundView.frame;
    }
}

- (BOOL)isBlurOverBackground {
    return CGRectEqualToRect(self.backgroundView.frame, self.backgroundBlurringView.frame);
}

- (void)setIsBlurHidden:(BOOL)isBlurHidden {
    self.backgroundBlurringView.hidden = isBlurHidden;
}

- (BOOL)isBlurHidden {
    return self.backgroundBlurringView.hidden;
}

@end
