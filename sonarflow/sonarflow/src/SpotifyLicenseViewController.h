//
//  SpotifyLicenseViewController.h
//  sonarflow
//
//  Created by Bojan Tosic on 6/14/12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpotifyLicenseViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIWebView *webView;

- (void)closeWindow;

@end
