//
//  SpotifyLicenseViewController.m
//  sonarflow
//
//  Created by Bojan Tosic on 6/14/12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SpotifyLicenseViewController.h"

@implementation SpotifyLicenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Licenses";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeWindow)];
	self.navigationItem.rightBarButtonItem = doneButton;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"spotify-licenses" ofType:@"xhtml"];
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    if (htmlData) {
        [self.webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@"http://www.spotify.com/"]];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// deprecated in iOS 6
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)closeWindow {
    [self dismissModalViewControllerAnimated:YES];
}

@end
