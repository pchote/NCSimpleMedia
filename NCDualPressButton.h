#import <UIKit/UIButton.h>

@interface NCDualPressButton : UIButton <UIGestureRecognizerDelegate>
{
    id target;
    SEL pressAction;
    SEL holdStartAction;
    SEL holdEndAction;
    BOOL forceHighlighted;
    
    UILongPressGestureRecognizer *pressRecognizer;
    UILongPressGestureRecognizer *holdRecognizer;
}

- (id)initWithFrame:(CGRect)frame holdDelay:(float)delay;
- (void)setTarget:(id) target pressEndAction:(SEL)_pressAction holdStartAction:(SEL)_holdStartAction holdEndAction:(SEL)_holdEndAction;
@end