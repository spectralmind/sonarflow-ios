//
//  ArtistQuery.h
//  SMArtist
//
//  Created by Fabian on 23.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMArtist.h"

// same order as segmented control on frontend
enum WantedDetail {
	kArtistBios,
    kArtistSimilarity,
    kArtistImages,
    kArtistVideo,
    kArtistAudio,
    kArtistUrls,
    kArtistEvents,
    kArtistTags,
    kArtistSearch
};
typedef enum WantedDetail WantedDetail;

@interface ArtistQueryViewContoller : UIViewController <SMArtistDelegate>
{
    UITextView *resultTextLastfm;
    UITextView *resultTextEchonest;
    UITextView *resultTextCombined;
    UITextField *artistNameTextInput;
    UILabel *responseTimeLabelLastfm;
    UILabel *responseTimeLabelEchonest;
    UILabel *responseTimeInfo;
@private
    SMArtist *info;
    WantedDetail _chosenDetail;
    UIPopoverController *_popover;
}

@property (retain) IBOutlet UITextView *resultTextLastfm;
@property (retain) IBOutlet UITextView *resultTextEchonest;
@property (retain) IBOutlet UITextView *resultTextCombined;
@property (retain) IBOutlet UITextField *artistNameTextInput;
@property (retain) IBOutlet UILabel *responseTimeLabelLastfm;
@property (retain) IBOutlet UILabel *responseTimeLabelEchonest;
@property (retain) IBOutlet UILabel *responseTimeInfo;

-(IBAction)doInfoRequest:(id)sender;
-(IBAction)textfieldInput:(UITextField *)sender;
-(IBAction)timesTooltip:(id)sender;

-(IBAction)selectWantedDetail:(UISegmentedControl *)sender;

@end
