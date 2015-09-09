//
//  SMArtistViewController.h
//  SMArtist
//
//  Created by Fabian on 17.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMArtist.h"

@interface SimilarityTestViewController : UIViewController <SMArtistDelegate>
{
    UILabel *limitLabel;
    UITextField *artistField;
    UITextView *resultTextLastfm;
    UITextView *resultTextEchonest;
    UILabel *responseTimeLabelLastfm;
    UILabel *responseTimeLabelEchonest;
@private
    SMArtist *info;
    NSInteger _fetchLimit;
    BOOL _stripResponse;
}

@property (retain) IBOutlet UILabel *limitLabel;
@property (retain) IBOutlet UITextField *artistField;
@property (retain) IBOutlet UITextView *resultTextLastfm;
@property (retain) IBOutlet UITextView *resultTextEchonest;
@property (retain) IBOutlet UILabel *responseTimeLabelLastfm;
@property (retain) IBOutlet UILabel *responseTimeLabelEchonest;
@property (retain) IBOutlet UILabel *stripInfo;


-(IBAction)fetchJsonData:(id)sender;
-(IBAction)textfieldInput:(UITextField *)sender;
-(IBAction)setFetchLimit:(UISlider *)sender;
//-(IBAction)selectSource:(UISegmentedControl *)sender;
-(IBAction)stripResponse:(UISwitch *)sender;
-(IBAction)timesTooltip:(id)sender;

@end
