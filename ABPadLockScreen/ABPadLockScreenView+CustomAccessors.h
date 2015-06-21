//
//  ABPadLockScreenView+CustomAccessors.h
//  ABPadLockScreenDemo
//
//  Created by Lobanov Dmitry on 21.06.15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import "ABPadLockScreenView.h"

@interface ABPadLockScreenView (CustomAccessors)

@property (strong,nonatomic,readonly) UIView *backgroundBlurringView;
@property (assign,nonatomic) BOOL isBlurOverBackground;
@property (assign,nonatomic) BOOL isBlurHidden;

@end
