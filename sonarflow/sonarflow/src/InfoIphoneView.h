//
//  InfoIphoneView.h
//  sonarflow
//
//  Created by Fabian on 06.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	InfoIphoneViewSectionStateLoading,
	InfoIphoneViewSectionStateFailed,
	InfoIphoneViewSectionStateLoaded,
} InfoIphoneViewSectionState;

@protocol InfoIphoneViewDelegate;

@interface InfoIphoneView : UIView

@property (nonatomic, weak) id<InfoIphoneViewDelegate> infoIphoneViewDelegate;

- (void)reloadData;
- (void)populateTabBar;

- (void)showPageAtIndex:(NSInteger)pageIndex;

@end


@protocol InfoIphoneViewDelegate <NSObject>

@required
- (NSUInteger)infoIphoneViewNumberOfPages:(InfoIphoneView *)infoIphoneView;
- (NSString *)infoIphoneView:(InfoIphoneView *)infoIphoneView tabTitleForPageWithIndex:(NSUInteger)index;
- (UIImage *)infoIphoneView:(InfoIphoneView *)infoIphoneView tabImageForPageWithIndex:(NSUInteger)index;
- (UIView *)infoIphoneView:(InfoIphoneView *)infoIphoneView contentViewForPageWithIndex:(NSUInteger)index;

@optional
- (InfoIphoneViewSectionState)infoIphoneView:(InfoIphoneView *)infoIphoneView stateOfPageWithIndex:(NSUInteger)index;
- (NSString *)infoIphoneView:(InfoIphoneView *)infoIphoneView failedMessageOfPageWithIndex:(NSUInteger)index;
- (void)infoIphoneView:(InfoIphoneView *)infoIphoneView didShowPageWithIndex:(NSUInteger)pageindex;

@end
