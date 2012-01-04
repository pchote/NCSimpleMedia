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

- (void)onHold: (UIGestureRecognizer *)recognizer
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

- (void)onPressed: (UIGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            [self setForceHighlighted: YES];
        break;
        case UIGestureRecognizerStateEnded:
            [self setForceHighlighted: NO];
            if (holdRecognizer.state != UIGestureRecognizerStateEnded && target && pressAction)
                [target performSelector:pressAction withObject: self];
        break;
        default: break;
    }
}

@end