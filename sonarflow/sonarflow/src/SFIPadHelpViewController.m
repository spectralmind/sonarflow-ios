#import "SFIPadHelpViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "ArtistInfoIpadViewController.h"
#import "NSString+CGLogging.h"

@interface SFIPadHelpViewController () <InfoIpadViewCloseDelegate>

@end

@implementation SFIPadHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.titleView.title = @"Help and Info";
	self.titleView.infoIpadViewCloseDelegate = self;
	
	CGSize scrollableContentSize = self.scrollView.contentSize;
	scrollableContentSize.height = self.contentView.frame.size.height;
	scrollableContentSize.width = 6.66;	// workaround needed for scrollRectToVisible
	self.scrollView.contentSize = scrollableContentSize;

	self.howtoScrollView.contentSize = self.howtoView.frame.size;
	self.socialScrollView.contentSize = self.socialView.frame.size;
	self.contactScrollView.contentSize = self.contactView.frame.size;
}

- (void)viewDidUnload
{
	[self setContentView:nil];
    [self setHowtoScrollView:nil];
    [self setHowtoView:nil];
	[self setContactScrollView:nil];
	[self setContactView:nil];
	[self setLastfmAccountCell:nil];
	[self setLastfmSettingsButton:nil];
    [self setSocialScrollView:nil];
    [self setSocialView:nil];
	[self setVersionLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// deprecated in iOS 6
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)setInfoIpadViewDelegate:(id<InfoIpadViewDelegate>)theInfoIpadViewDelegate {
	self.titleView.infoIpadViewCloseDelegate = theInfoIpadViewDelegate;
}

- (void)scrollToPartners {
	CGRect targetRect = [self.contentView convertRect:self.lastfmSettingsButton.bounds fromView:self.lastfmSettingsButton];
	targetRect.origin.y += self.titleView.frame.size.height;	
	targetRect.origin.x = 0;
	targetRect.size.width = 1;
	
	[self.scrollView scrollRectToVisible:targetRect animated:YES];
}

#pragma mark - InfoIpadViewCloseDelegate Delegate

- (void)closeView {
	[self.closeRequestDelegate dismissOverlay:self];
}


@end
