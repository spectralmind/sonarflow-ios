#import <Foundation/Foundation.h>

@protocol SFIPhoneHelpView <NSObject>

@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

- (void)scrollToPartners;

@end
