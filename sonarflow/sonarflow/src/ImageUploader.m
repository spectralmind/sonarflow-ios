//
//  ImageUploader.m
//  sonarflow
//
//  Created by Raphael Charwot on 29.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "ImageUploader.h"

#define kAccessToken @"273084635-PxDdlx7O80qOQblYubGu5gypPqy6tn5Q0P8GPYZg"
#define kAccessTokenSecret @"2bIzEV5SWMW8LIxg7sfx4jmV831PONU9qLPbWYpeaE"

@interface ImageUploader ()

- (OAToken *)createAccessToken;

@end


@implementation ImageUploader

@synthesize delegate;

- (id)init {
    self = [super init];
    if(self) {
        twitPicEngine = [GSTwitPicEngine twitpicEngineWithDelegate:self];
		[twitPicEngine setAccessToken:[self createAccessToken]];
    }
    return self;
}


- (OAToken *)createAccessToken {
	OAToken *token = [[OAToken alloc] initWithKey:kAccessToken secret:kAccessTokenSecret];
	return token;
}

- (void)uploadImage:(UIImage *)image withMessage:(NSString *)message {
	[twitPicEngine uploadPicture:image withMessage:message];
}

#pragma mark -
#pragma mark GSTwitPicEngineDelegate

- (void)twitpicDidFinishUpload:(NSDictionary *)response {
	NSString *pageUrl = [response valueForKeyPath:@"parsedResponse.url"];
	NSString *imageName = [response valueForKeyPath:@"parsedResponse.id"];
	NSString *thumbnailUrl = [NSString stringWithFormat:@"http://twitpic.com/show/thumb/%@", imageName];
	[self.delegate imageUploaderSucceededWithThumbnailUrl:thumbnailUrl pageUrl:pageUrl];	
}

- (void)twitpicDidFailUpload:(NSDictionary *)error {
	NSLog(@"TwitPic-Error: %@", error);
	[self.delegate imageUploaderFailed];	
}

@end
