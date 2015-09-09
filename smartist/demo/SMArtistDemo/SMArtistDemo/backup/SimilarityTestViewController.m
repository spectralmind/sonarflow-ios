//
//  SMArtistViewController.m
//  SMArtist
//
//  Created by Fabian on 17.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SimilarityTestViewController.h"

@interface SimilarityTestViewController ()
@property (retain) SMArtist *info;
@end

@implementation SimilarityTestViewController

@synthesize limitLabel, artistField, resultTextLastfm, resultTextEchonest, responseTimeLabelLastfm, responseTimeLabelEchonest, stripInfo;
@synthesize info;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.info = [SMArtist smartistWithDelegate:self];
    _fetchLimit = 1;
    //_chosenService = kLastfm;
    
    _stripResponse = YES;
    
    // needed for clickable links
    self.resultTextLastfm.editable = NO;
    self.resultTextLastfm.dataDetectorTypes = UIDataDetectorTypeAll;
    self.resultTextEchonest.editable = NO;
    self.resultTextEchonest.dataDetectorTypes = UIDataDetectorTypeAll;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.info = nil;
    self.limitLabel = nil;
    self.artistField = nil;
    self.resultTextLastfm = nil;
    self.resultTextEchonest = nil;
    self.responseTimeLabelLastfm = nil;
    self.responseTimeLabelEchonest = nil;
    // TODO release all
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - IBActions

// text entered, return pressed
/*
-(IBAction)userDoneEnteringText:(id)sender
{
    NSLog(@"userDoneEnteringText");
}
*/

/*
-(IBAction)selectSource:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            _chosenService = kLastfm;
            NSLog(@"Last.fm Selected");
            break;
        case 1:
            _chosenService = kEchonest;
            NSLog(@"Echo Nest Selected");
            break;
            
        default:
            break;
    };
}
 */

-(IBAction)stripResponse:(UISwitch *)sender
{
    _stripResponse = sender.on;
}

// Test fetch JSON data
-(IBAction)fetchJsonData:(id)sender
{
    //NSLog(@"bla");
    self.resultTextLastfm.text = @"";
    self.resultTextEchonest.text = @"";
    self.artistField.text = @"cher";
    //_fetchLimit _stripResponse
    [self.info getArtistSimilarityWithArtistName:@"cher" withClientId:@"test"];
}


-(IBAction)textfieldInput:(UITextField *)sender
{
    NSLog(@"textfieldInput: %@",sender.text);
    self.resultTextLastfm.text = @"";
    self.resultTextEchonest.text = @"";
    //_fetchLimit _stripResponse
    [self.info getArtistSimilarityWithArtistName:sender.text withClientId:@"test"];
}

-(IBAction)setFetchLimit:(UISlider *)sender
{
    _fetchLimit = (NSInteger)sender.value;
    self.limitLabel.text = [NSString stringWithFormat:@"%i",_fetchLimit];
    //NSLog(@"%d",_fetchLimit);
}


-(IBAction)timesTooltip:(id)sender
{
    self.stripInfo.hidden = !self.stripInfo.hidden;
}


#pragma mark - Private Methods

- (NSArray *)formatResponseTimesFromTimes:(NSArray *)times
{
    NSMutableArray *formatted = [NSMutableArray arrayWithObjects:nil];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:3];
    
    for(NSNumber *num in times) {
        [formatted addObject:[formatter stringFromNumber:num]];
    }
    
    [formatter release];
    
    return formatted;
}


#pragma mark - Delegate methods

- (void)doneWebRequestWithArtistBiosResult:(SMArtistBiosResult *)theResult
{

}

- (void)doneWebRequestWithArtistSimilarityResult:(SMArtistSimilarityResult *)theResult
{
    // TODO timing / proper
    NSString *displayString;
    
    displayString = [theResult.resultLastfm.result description];
    self.resultTextLastfm.text = displayString;
    [self.resultTextLastfm setContentOffset:CGPointZero animated:YES];
    self.responseTimeLabelLastfm.text = [[self formatResponseTimesFromTimes:[theResult.resultLastfm.info objectForKey:@"time taken"] ] componentsJoinedByString:@" / "];
    
    displayString = [theResult.resultEchonest.result description];
    self.resultTextEchonest.text = displayString;
    [self.resultTextEchonest setContentOffset:CGPointZero animated:YES];
    self.responseTimeLabelEchonest.text = [[self formatResponseTimesFromTimes:[theResult.resultEchonest.info objectForKey:@"time taken"] ] componentsJoinedByString:@" / "];
}

- (void)doneWebRequestWithArtistImagesResult:(SMArtistImagesResult *)theResult
{

}

/*
- (void) doneWebRequestWithResult: (ArtistWebInfoResult *)result
{
    NSLog(@"doneWebRequestWithResult");
    
    
    // TODO timing / proper
    NSString *displayString;
    
    displayString = [result.resultLastfm.result description];
    self.resultTextLastfm.text = displayString;
    [self.resultTextLastfm setContentOffset:CGPointZero animated:YES];
    
    displayString = [result.resultEchonest.result description];
    self.resultTextEchonest.text = displayString;
    [self.resultTextEchonest setContentOffset:CGPointZero animated:YES];
    
    
    / *
    NSLog(@"Request: %@",result.request);
    NSLog(@"Result: %@",result.result);
    NSLog(@"Info: %@",result.info);
    NSLog(@"Error: %@",result.error);
    
    
    NSArray *times = [[result info] objectForKey:@"time taken"];
    
    //NSLog(@"time elements: %@",times);
    
    // format to 2 decimal places - no easier way?
    NSMutableArray *formatted = [NSMutableArray arrayWithObjects:nil];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:3];
    
    for(NSNumber *num in times) {
        [formatted addObject:[formatter stringFromNumber:num]];
    }
    
    // order most probably is:
    // 1) url request setoff
    // 2) url response
    // 3) receiving finished
    // 4) parse finished
    
    NSString *displayString;
    
    if (result.result) {
        if (result.request.parameters && 
            [[result.request.parameters objectForKey:@"strip"] boolValue]) {
            NSMutableString *artistStrings = [NSMutableString string];
            for(NSDictionary *artist in [result.result objectForKey:@"artists"]) {
                //NSLog(@"Object: %@",artist);
                NSString *name = [artist objectForKey:@"name"];
                NSString *match = [artist objectForKey:@"match"];
                if (name) {
                    [artistStrings appendString:name];
                }
                if (match) {
                    [artistStrings appendFormat:@" - %@",match];
                }
                if (name || match) {
                    [artistStrings appendString:@"\n"];
                }
            }
            
            displayString = [NSString stringWithString:artistStrings];
        } else {
            displayString = [[result result] description];
        }
    } else {
        displayString = [[result error] description];
    }
    
    
    
    WebService ws = result.request.service; // TODO nil
    
    switch (ws) {
        case kLastfm:
            self.resultTextLastfm.text = displayString;
            [self.resultTextLastfm setContentOffset:CGPointZero animated:YES];
            self.responseTimeLabelLastfm.text = [formatted componentsJoinedByString:@" / "];
            break;
        case kEchonest:
            self.resultTextEchonest.text = displayString;
            [self.resultTextEchonest setContentOffset:CGPointZero animated:YES];
            self.responseTimeLabelEchonest.text = [formatted componentsJoinedByString:@" / "];
            break;
            
        default:
            break;
    }
    * /
}*/


@end
