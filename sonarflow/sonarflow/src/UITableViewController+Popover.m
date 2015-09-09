//
//  UITableViewController+Popover.m
//  Sonarflow
//
//  Created by Raphael Charwot on 06.11.10.
//  Copyright 2010 Charwot. All rights reserved.
//

#import "UITableViewController+Popover.h"


@implementation UITableViewController (Popover)

- (void)updatePopoverSizeWithMinHeight:(NSUInteger)standardRowsMinHeight {
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.tableView layoutIfNeeded];
		float rowHeight = self.tableView.rowHeight;
		float wantedHeight = ceil(fmaxf(self.tableView.contentSize.height + rowHeight * 0.6, rowHeight * standardRowsMinHeight));
		self.contentSizeForViewInPopover = CGSizeMake(320, wantedHeight);
	}
}

@end
