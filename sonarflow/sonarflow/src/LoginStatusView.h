#import <UIKit/UIKit.h>

typedef enum {
	LoginStatusViewStateDefault,
	LoginStatusViewStateVerifying,
	LoginStatusViewStateError,
} LoginStatusViewState;

@interface LoginStatusView : UIView

@property (nonatomic, strong) NSString *defaultText;
@property (nonatomic, assign) LoginStatusViewState state;

@end
