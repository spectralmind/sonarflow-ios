//
//  ViewController.m
//  SMArtistDemo
//
//  Created by Fabian on 02.12.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "ViewController.h"

#define kEchonestKey @"YV4GJANNDGN3MWBQG"
#define kLastfmKey @"fce4ee314339e5192fe28938e4795b9b"

@interface ViewController ()
@property (retain) SMArtist *info;
- (void)setupSMArtist;
@end

@implementation ViewController

@synthesize info;
@synthesize resultTextCombined, artistNameTextInput;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        // initialize what you need here
		_chosenDetail = 0;
		[self setupSMArtist];
    }
	
    return self;
}

- (void)setupSMArtist
{
	SMArtistConfiguration *config = [SMArtistConfiguration defaultConfiguration];
	
	config.echonestKey = kEchonestKey;
	config.lastfmKey = kLastfmKey;
	config.servicesMaskAllRequests = SMArtistWebServicesNone;
	config.servicesMaskBiosRequests = SMArtistWebServicesLastfm;
	config.servicesMaskSimilarityRequests = SMArtistWebServicesLastfm;
	config.servicesMaskImagesRequests = SMArtistWebServicesEchonest;
	config.servicesMaskVideosRequests = SMArtistWebServicesYoutube;
	
	self.info = [SMArtist smartistWithDelegate:self withConfiguration:config];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	// needed for clickable links
    self.resultTextCombined.editable = NO;
    self.resultTextCombined.dataDetectorTypes = UIDataDetectorTypeAll;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}




- (void)doRequestWithArtistName:(NSString *)artistName
{
	NSLog(@"doing request");
	
    self.resultTextCombined.text = @"";
    
    switch (_chosenDetail) {
        case kArtistBios:
            [info getArtistBiosWithArtistName:artistName withClientId:@"test"];
            break;
        case kArtistSimilarity:
            [info getArtistSimilarityWithArtistName:artistName withClientId:@"test"];
            break;
        case kArtistSimilarityMatrix:
		{
			NSMutableArray *artistNames = [NSMutableArray arrayWithObjects:
										   @"cher",
										   @"madonna",
										   @"celine dion",
										   @"red hot chili peppers",
										   @"pink",
										   nil];
            [info getArtistSimilarityMatrixWithArtistNames:artistNames withClientId:@"test"];
            break;
		}
        case kArtistImages:
            [info getArtistImagesWithArtistName:artistName withClientId:@"test"];
            break;
            
        case kArtistVideos:
            [info getArtistVideosWithArtistName:artistName withClientId:@"test"];
            break;
            
        default:
            break;
    }
	
	NSLog(@"done request");
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

-(IBAction)selectWantedDetail:(UISegmentedControl *)sender
{
    _chosenDetail = sender.selectedSegmentIndex;
}

- (IBAction)purgeCache:(id)sender {
	[info purgeCompleteCache];
}


#pragma mark - Private Methods

- (void)displayResult:(NSString *)combinedInfo
{
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
	
	NSLog(@"matched artist: %@",theResult.recognizedArtistName);
	NSLog(@"c: %@",theResult.clientId);
    
    [self displayResult:[theResult description]];
}

- (void)doneWebRequestWithArtistSimilarityResult:(SMArtistSimilarityResult *)theResult
{
    NSLog(@"doneWebRequestWithArtistSimilarityResult");
    
    //NSLog(@"%@",[theResult.similarArtists description]);
    //NSLog(@"clientId = %@",theResult.clientId);
    
    if (theResult.error) {
        NSLog(@"there is an error in the result: %@",[theResult.error localizedDescription]);
    }
    
	NSLog(@"matched artist: %@",theResult.recognizedArtistName);
	NSLog(@"c: %@",theResult.clientId);

    [self displayResult:[theResult description]];
    
    NSLog(@"%@",[theResult.similarArtists lastObject]);
}

- (void)doneWebRequestWithArtistSimilarityMatrixResult:(SMArtistSimilarityMatrixResult *)theResult
{
    NSLog(@"doneWebRequestWithArtistSimilarityMatrixResult");

    //NSLog(@"%@",[theResult.similarArtists description]);
    //NSLog(@"clientId = %@",theResult.clientId);
    
    if (theResult.error) {
        NSLog(@"there is an error in the result: %@",[theResult.error localizedDescription]);
    }
    
	NSLog(@"matched artist: %@",theResult.recognizedArtistName);
	NSLog(@"c: %@",theResult.clientId);
	
    [self displayResult:[theResult description]];
    
    NSLog(@"%@",theResult.similarityMatrix);
}

- (void)doneWebRequestWithArtistImagesResult:(SMArtistImagesResult *)theResult
{
    NSLog(@"doneWebRequestWithArtistImagesResult");
    
    if (theResult.error) {
        NSLog(@"there is an error in the result: %@",[theResult.error localizedDescription]);
    }
    
	NSLog(@"matched artist: %@",theResult.recognizedArtistName);
	NSLog(@"c: %@",theResult.clientId);

    [self displayResult:[theResult description]];
}

- (void)doneWebRequestWithArtistVideosResult:(SMArtistVideosResult *)theResult
{
    NSLog(@"doneWebRequestWithArtistVideosResult");
    
    if (theResult.error) {
        NSLog(@"there is an error in the result: %@",[theResult.error localizedDescription]);
    }
    
	NSLog(@"matched artist: %@",theResult.recognizedArtistName);
	NSLog(@"c: %@",theResult.clientId);
	
    [self displayResult:[theResult description]];
}


@end
