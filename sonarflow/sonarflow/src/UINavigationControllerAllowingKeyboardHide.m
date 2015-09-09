#import "UINavigationControllerAllowingKeyboardHide.h"

@implementation UINavigationControllerAllowingKeyboardHide

// fixes keyboard not disappearing on iPad when this VC is presenten on a UIModalPresentationFormSheet and resignFirstResponder is called
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

@end
