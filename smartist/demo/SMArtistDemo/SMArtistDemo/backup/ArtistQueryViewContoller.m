//
//  ArtistQuery.m
//  SMArtist
//
//  Created by Fabian on 23.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "ArtistQueryViewContoller.h"
#import "SMArtist.h"
#import "ResponseTimes.h"

@interface ArtistQueryViewContoller ()
    @property (retain) SMArtist *info;
@end

@implementation ArtistQueryViewContoller

@synthesize info;
@synthesize resultTextLastfm, resultTextEchonest, resultTextCombined, artistNameTextInput;
@synthesize responseTimeInfo, responseTimeLabelLastfm, responseTimeLabelEchonest;

- (void)dealloc
{
    self.info = nil;
    self.resultTextLastfm = nil;
    self.resultTextEchonest = nil;
    self.artistNameTextInput = nil;
    self.responseTimeInfo = nil;
    self.responseTimeLabelLastfm = nil;
    self.responseTimeLabelEchonest = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.info = [SMArtist smartistWithDelegate:self];        
        _chosenDetail = 0;
        UIViewController *vc = [[ResponseTimes alloc] init];
        _popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [vc release];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)doRequestWithArtistName:(NSString *)artistName
{
    self.resultTextLastfm.text = @"";
    self.resultTextEchonest.text = @"";
    self.resultTextCombined.text = @"";
    
    switch (_chosenDetail) {
        case kArtistBios:
            [info getArtistBiosWithArtistName:artistName withClientId:@"test"];
            break;
        case kArtistSimilarity:
            [info getArtistSimilarityWithArtistName:artistName withClientId:@"test"];
            break;
        case kArtistImages:
            [info getArtistImagesWithArtistName:artistName withClientId:@"test"];
            break;
            
        default:
            break;
    }
}


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


#pragma mark - Target Action Methods

- (IBAction)doInfoRequest:(id)sender
{
    self.artistNameTextInput.text = @"cher";
    [self doRequestWithArtistName:@"cher"];
}

-(IBAction)textfieldInput:(UITextField *)sender
{
    [self doRequestWithArtistName:sender.text];
}

-(IBAction)timesTooltip:(id)sender
{
    //self.responseTimeInfo.hidden = !self.responseTimeInfo.hidden;
    
    [_popover presentPopoverFromRect:responseTimeLabelEchonest.contentStretch
                              inView:responseTimeLabelEchonest
            permittedArrowDirections:UIPopoverArrowDirectionDown
                            animated:YES];
}

-(IBAction)selectWantedDetail:(UISegmentedControl *)sender
{
    _chosenDetail = sender.selectedSegmentIndex;
}


#pragma mark - Private Methods

- (void)displayResultsForLastfm:(NSString *)lastfmInfo andEchonest:(NSString *)echonestInfo
{
    // TODO timing / proper
    
    self.resultTextLastfm.text = lastfmInfo;
    [self.resultTextLastfm setContentOffset:CGPointZero animated:YES];
    [self.resultTextLastfm flashScrollIndicators];
    
    self.resultTextEchonest.text = echonestInfo;
    [self.resultTextEchonest setContentOffset:CGPointZero animated:YES];
    [self.resultTextEchonest flashScrollIndicators];
}

- (void)displayResultsForLastfm:(NSString *)lastfmInfo andEchonest:(NSString *)echonestInfo andCombined:(NSString *)combinedInfo
{
    [self displayResultsForLastfm:lastfmInfo andEchonest:echonestInfo];
    
    self.resultTextCombined.text = combinedInfo;
    [self.resultTextCombined setContentOffset:CGPointZero animated:YES];
    [self.resultTextCombined flashScrollIndicators];
}


#pragma mark - Delegate Methods

- (void)doneWebRequestWithArtistBiosResult:(SMArtistBiosResult *)theResult
{
    NSLog(@"doneWebRequestWithArtistBiosResult");
    
    if (theResult.error) {
        NSLog(@"there is an error in the result: %@",[theResult.error localizedDescription]);
    }
    
    [self displayResultsForLastfm:[theResult.resultLastfm.result description] andEchonest:[theResult.resultEchonest.result description] andCombined:[theResult description]];
    
    self.responseTimeLabelLastfm.text = [[self formatResponseTimesFromTimes:[theResult.resultLastfm.info objectForKey:@"time taken"] ] componentsJoinedByString:@" / "];
    self.responseTimeLabelEchonest.text = [[self formatResponseTimesFromTimes:[theResult.resultEchonest.info objectForKey:@"time taken"] ] componentsJoinedByString:@" / "];
}

- (void)doneWebRequestWithArtistSimilarityResult:(SMArtistSimilarityResult *)theResult
{
    NSLog(@"doneWebRequestWithArtistSimilarityResult");
    
    //NSLog(@"%@",[theResult.similarArtists description]);
    //NSLog(@"clientId = %@",theResult.clientId);
    
    if (theResult.error) {
        NSLog(@"there is an error in the result: %@",[theResult.error localizedDescription]);
    }
    
    [self displayResultsForLastfm:[theResult.resultLastfm.result description] andEchonest:[theResult.resultEchonest.result description] andCombined:[theResult description]];
    
    NSLog(@"%@",[theResult.similarArtists lastObject]);
    
    self.responseTimeLabelLastfm.text = [[self formatResponseTimesFromTimes:[theResult.resultLastfm.info objectForKey:@"time taken"] ] componentsJoinedByString:@" / "];
    self.responseTimeLabelEchonest.text = [[self formatResponseTimesFromTimes:[theResult.resultEchonest.info objectForKey:@"time taken"] ] componentsJoinedByString:@" / "];
}

- (void)doneWebRequestWithArtistImagesResult:(SMArtistImagesResult *)theResult
{
    NSLog(@"doneWebRequestWithArtistImagesResult");
    
    if (theResult.error) {
        NSLog(@"there is an error in the result: %@",[theResult.error localizedDescription]);
    }
    
    [self displayResultsForLastfm:[theResult.resultLastfm.result description] andEchonest:[theResult.resultEchonest.result description] andCombined:[theResult description]];
    
    self.responseTimeLabelLastfm.text = [[self formatResponseTimesFromTimes:[theResult.resultLastfm.info objectForKey:@"time taken"] ] componentsJoinedByString:@" / "];
    self.responseTimeLabelEchonest.text = [[self formatResponseTimesFromTimes:[theResult.resultEchonest.info objectForKey:@"time taken"] ] componentsJoinedByString:@" / "];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // needed for clickable links
    self.resultTextLastfm.editable = NO;
    self.resultTextLastfm.dataDetectorTypes = UIDataDetectorTypeAll;
    self.resultTextEchonest.editable = NO;
    self.resultTextEchonest.dataDetectorTypes = UIDataDetectorTypeAll;
    self.resultTextCombined.editable = NO;
    self.resultTextCombined.dataDetectorTypes = UIDataDetectorTypeAll;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
