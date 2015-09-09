//
//  ImageSubmitController.h
//  sonarflow
//
//  Created by Raphael Charwot on 17.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageSubmitter.h"
#import "UIPlaceHolderTextView.h"

typedef void (^SharingDoneBlock) (BOOL shared);

@interface ImageSubmitController : UIViewController
		<ImageSubmitterDelegate>

@property (nonatomic, strong) IBOutlet UIView *contentContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *imagePreview;
@property (nonatomic, weak) IBOutlet UIView *messageContainerView;
@property (nonatomic, weak) IBOutlet UIPlaceHolderTextView *messageView;

@property (nonatomic, weak) IBOutlet UIView *shareView;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *messageBackground;

@property (nonatomic, strong) ImageSubmitter *imageSubmitter;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *messagePlaceholder;

@property (nonatomic, assign) WebService service;

@property (nonatomic,copy) SharingDoneBlock doneBlock;

- (IBAction)submitImage;

@end
