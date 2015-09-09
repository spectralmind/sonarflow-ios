#import <Foundation/Foundation.h>

#import <Facebook.h>

#import "AppStatusObserver.h"
#import "ImageUploader.h"

@class SFAppIdentity;

enum WebService {
	kFacebook,
	kTwitter
};
typedef enum WebService WebService;

@protocol ImageSubmitterDelegate

- (void)didFinishSubmittingImage;
- (void)didCancelSubmittingImage;
- (void)didFailSubmittingImage;
- (void)didFailToUseServiceWithMessage:(NSString *)failMessage;

@end

@interface ImageSubmitter : NSObject
		<FBSessionDelegate, FBRequestDelegate,
			AppStatusObserverDelegate, ImageUploaderDelegate>

@property (weak, nonatomic, readonly) Facebook *facebook;
@property (nonatomic, weak) id<ImageSubmitterDelegate> delegate;

@property (nonatomic, strong) NSString *tradedoublerProgramID;
@property (nonatomic, strong) NSString *tradedoublerWebsiteID;


- (id)initWithAppIdentity:(SFAppIdentity *)theAppIdentity;

- (BOOL)isWebserviceAvailable:(WebService)webservice withErrorString:(NSString **)error;

- (void)submitToWebservice:(WebService)webservice withImage:(UIImage *)image withText:(NSString *)text;
- (void)submitToWebservice:(WebService)webservice withImage:(UIImage *)image withText:(NSString *)text withTrackTitle:(NSString *)trackTitle withArtist:(NSString *)artist withAlbum:(NSString *)album;

@end
