//
//  InfoIphoneView.m
//  sonarflow
//
//  Created by Fabian on 06.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "InfoIphoneView.h"

#import "InfoIphoneViewPage.h"

static const CGFloat tabBarHeight = 49.f;
static const CGFloat tabBarSpacing = 0.f;

@interface InfoIphoneView () <UITabBarDelegate>

@property (nonatomic, strong) InfoIphoneViewPage *pageView;
@property (nonatomic, strong) UITabBar *tabBar;

@end


@implementation InfoIphoneView
{
@private
	CGRect oldBounds;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		
		CGRect pageFrame = frame;
		pageFrame.size.height -= tabBarHeight + tabBarSpacing;
		
		self.pageView = [[InfoIphoneViewPage alloc] initWithFrame:pageFrame];
		self.pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.pageView.backgroundColor = [UIColor clearColor];
		self.pageView.opaque = NO;
		[self addSubview:self.pageView];
		
		CGRect tabBarFrame = frame;
		tabBarFrame.origin.x = 0.0;
		tabBarFrame.size.height = tabBarHeight;
		tabBarFrame.origin.y = frame.size.height - tabBarHeight;
		self.tabBar = [[UITabBar alloc] initWithFrame:tabBarFrame];
		self.tabBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		self.tabBar.delegate = self;
		
		if ([self.tabBar respondsToSelector:@selector(setSelectedImageTintColor:)]) {
			[self.tabBar setSelectedImageTintColor:[UIColor whiteColor]];
		}
		
		[self addSubview:self.tabBar];
    }
    return self;
}

#pragma mark - Public Methods

- (void)showPageAtIndex:(NSInteger)pageIndex
{
	NSArray *items = self.tabBar.items;
	
	if ([items count] == 0) {
		return;
	}
	
	UITabBarItem *selectedItem = [items objectAtIndex:0];
	
	[self.tabBar setSelectedItem:selectedItem];
	[self tabBar:self.tabBar didSelectItem:selectedItem];
}

- (void)populateTabBar {
	NSMutableArray *items = [NSMutableArray array];
	UITabBarItem *selectedItem = nil;
	NSUInteger numberOfPages = [self.infoIphoneViewDelegate infoIphoneViewNumberOfPages:self];
	for (int i = 0; i < numberOfPages; i++) {
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:[self.infoIphoneViewDelegate infoIphoneView:self tabTitleForPageWithIndex:i]
														   image:[self.infoIphoneViewDelegate infoIphoneView:self tabImageForPageWithIndex:i]
															 tag:i];
		[items addObject:item];
		if (selectedItem == nil) {
			selectedItem = item;
		}
	}

	[self.tabBar setItems:items animated:NO];
	
	if (self.tabBar.selectedItem == nil) {
		[self.tabBar setSelectedItem:selectedItem];
		[self tabBar:self.tabBar didSelectItem:selectedItem];
	}
}

- (void)reloadData {
	[self tabBar:self.tabBar didSelectItem:self.tabBar.selectedItem];
}

#pragma mark Pages

- (void)removeSubviewsFromContainerView:(UIView *)containerView
{
	for (UIView *v in containerView.subviews) {
		[v removeFromSuperview];
	}
}

- (void)placeView:(UIView *)view inContainerView:(UIView *)containerView
{
	if (![containerView.subviews containsObject:view]) {
		[self removeSubviewsFromContainerView:containerView];
		[containerView addSubview:view];
		CGRect rect = containerView.bounds;
		rect.origin = CGPointZero;
		[view setFrame:rect];
	}
}



#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	InfoIphoneViewSectionState state = InfoIphoneViewSectionStateLoaded;
	if([self.infoIphoneViewDelegate respondsToSelector:@selector(infoIphoneView:stateOfPageWithIndex:)]) {
		state = [self.infoIphoneViewDelegate infoIphoneView:self stateOfPageWithIndex:item.tag];
	}
	
	switch (state) {
		case InfoIphoneViewSectionStateLoading:
			[self removeSubviewsFromContainerView:self.pageView.containerView];
			self.pageView.errorLabel.text = @"";
			[self.pageView.spinner startAnimating];
			break;
			
		case InfoIphoneViewSectionStateFailed:
			[self removeSubviewsFromContainerView:self.pageView.containerView];
			[self.pageView.spinner stopAnimating];
			if([self.infoIphoneViewDelegate respondsToSelector:@selector(infoIphoneView:failedMessageOfPageWithIndex:)]) {
				self.pageView.errorLabel.text = [self.infoIphoneViewDelegate infoIphoneView:self failedMessageOfPageWithIndex:item.tag];
			} else {
				self.pageView.errorLabel.text = @"";
			}
			
			break;
			
		case InfoIphoneViewSectionStateLoaded:
			[self.pageView.spinner stopAnimating];
			self.pageView.errorLabel.text = @"";
			[self placeView:[self.infoIphoneViewDelegate infoIphoneView:self contentViewForPageWithIndex:item.tag] inContainerView:self.pageView.containerView];
			break;
			
		default:
			break;
	}

	if ([self.infoIphoneViewDelegate respondsToSelector:@selector(infoIphoneView:didShowPageWithIndex:)]) {
		[self.infoIphoneViewDelegate infoIphoneView:self didShowPageWithIndex:item.tag];
	}
}


@end
