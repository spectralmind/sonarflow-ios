//
//  ImageUploader.h
//  sonarflow
//
//  Created by Raphael Charwot on 29.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GSTwitPicEngine.h"

@protocol ImageUploaderDelegate;

@interface ImageUploader : NSObject
		<GSTwitPicEngineDelegate> {
	id<ImageUploaderDelegate> __weak delegate;
	GSTwitPicEngine *twitPicEngine;
}

@property (nonatomic, weak) id<ImageUploaderDelegate> delegate;

- (void)uploadImage:(UIImage *)image withMessage:(NSString *)message;

@end

@protocol ImageUploaderDelegate

- (void)imageUploaderSucceededWithThumbnailUrl:(NSString *)thumbnailUrl pageUrl:(NSString *)pageUrl;
- (void)imageUploaderFailed;

@end
