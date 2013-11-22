/*
* Copyright (c) 2012, Paul Chote
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
* list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright notice,
* this list of conditions and the following disclaimer in the documentation
* and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "NCDualPressButton.h"

@implementation NCDualPressButton

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (id)initWithFrame:(CGRect)frame holdDelay:(float)delay
{
    if((self = [super initWithFrame:frame]))
    {   
        [self setShowsTouchWhenHighlighted:YES];

		// Held in
        holdRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onHold:)] autorelease];
        [holdRecognizer setMinimumPressDuration: delay];
        [holdRecognizer setDelegate: self];
        [self addGestureRecognizer:holdRecognizer];

        // Pressed (no delay)
        pressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPressed:)] autorelease];
        [pressRecognizer setMinimumPressDuration: 0.0];
        [pressRecognizer setDelegate: self];
        [self addGestureRecognizer:pressRecognizer];

        pressAction = nil;
        holdStartAction = nil;
        holdEndAction = nil;
	}
	return self;
}

- (void)setTarget:(id)_target pressEndAction:(SEL)_pressAction holdStartAction:(SEL)_holdStartAction holdEndAction:(SEL)_holdEndAction
{
    target = _target;
    pressAction = _pressAction;
    holdStartAction = _holdStartAction;
    holdEndAction = _holdEndAction;
}

// Override superclass changing the highlight flag without our permission
// Use setForceHighlighted to actually change the highlight flag
- (void)setHighlighted:(BOOL)val
{
    [super setHighlighted: forceHighlighted];
}

- (void)setForceHighlighted:(BOOL)val
{
    forceHighlighted = val;
    [super setHighlighted: val];
    [self setNeedsDisplay];
}

- (void)onHold:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            if (target && holdStartAction)
                [target performSelector:holdStartAction withObject: self];
            [self setForceHighlighted: YES];
        break;
        case UIGestureRecognizerStateEnded:
            [self setForceHighlighted: NO];
            if (target && holdEndAction)
                [target performSelector:holdEndAction withObject: self];
            break;
        default: break;
    }
}

- (void)onPressed:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            [self setForceHighlighted: YES];
        break;
        case UIGestureRecognizerStateEnded:
            [self setForceHighlighted: NO];
            if ((!holdEndAction || holdRecognizer.state != UIGestureRecognizerStateEnded) && target && pressAction)
                [target performSelector:pressAction withObject: self];
        break;
        default: break;
    }
}

@end