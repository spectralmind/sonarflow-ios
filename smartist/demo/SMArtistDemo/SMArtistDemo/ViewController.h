//
//  ViewController.h
//  SMArtistDemo
//
//  Created by Fabian on 02.12.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMArtist.h"


// same order as segmented control on frontend
enum WantedDetail {
	kArtistBios,
    kArtistSimilarity,
    kArtistSimilarityMatrix,
    kArtistImages,
    kArtistVideos,
    kArtistAudio,
    kArtistUrls,
    kArtistEvents,
    kArtistTags,
    kArtistSearch
};
typedef enum WantedDetail WantedDetail;


@interface ViewController : UIViewController <SMArtistDelegate>
{
    UITextView *resultTextCombined;
    UITextField *artistNameTextInput;
@private
    SMArtist *info;
    WantedDetail _chosenDetail;
}


@property (retain) IBOutlet UITextView *resultTextCombined;
@property (retain) IBOutlet UITextField *artistNameTextInput;

-(IBAction)doInfoRequest:(id)sender;
-(IBAction)textfieldInput:(UITextField *)sender;

-(IBAction)selectWantedDetail:(UISegmentedControl *)sender;

- (IBAction)purgeCache:(id)sender;

@end
