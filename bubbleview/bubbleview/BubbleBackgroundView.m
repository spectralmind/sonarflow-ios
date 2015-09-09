#import "BubbleBackgroundView.h"

@interface BubbleBackgroundView ()

- (NSArray *)newImageViews:(NSUInteger)count;
- (void)updateImageVisibility;

@end


@implementation BubbleBackgroundView

- (id)initWithSizes:(NSArray *)theSizes {
    self = [super init];
    if (self) {
		sizes = theSizes;
		imageViews = [self newImageViews:[sizes count]];
		
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)willBeEnqueuedToCache {
	for(NSUInteger i = 0; i != [imageViews count]; ++i) {
		UIImageView *view = [imageViews objectAtIndex:i];
		[view removeFromSuperview];
	}
}

- (NSArray *)newImageViews:(NSUInteger)count {
	NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:count];
	for(NSUInteger i = 0; i != count; ++i) {
		UIImageView *view = [[UIImageView alloc] initWithFrame:self.bounds];
		view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:view];
		[views addObject:view];
	}

	return views;
}

- (void)setImages:(NSArray *)newImages {
	NSAssert([newImages count] == [imageViews count], @"Invalid number of images");

	if(images != newImages) {
		images = newImages;

		for(NSUInteger i = 0; i != [imageViews count]; ++i) {
			UIImageView *view = [imageViews objectAtIndex:i];
			if(view.superview != nil) {
				view.image = [images objectAtIndex:i];
			}
		}
	}
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];
	[self updateImageVisibility];
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self updateImageVisibility];
}

- (void)updateImageVisibility {
	if([imageViews count] == 0) {
		return;
	}

	CGFloat size = CGRectGetWidth(self.bounds);
	NSUInteger bestIndex = 0;
	for(NSUInteger i = 0; i != [imageViews count]; ++i) {
		if([[sizes objectAtIndex:i] floatValue] < size) {
			break;
		}
		bestIndex = i;
	}

	UIImageView *bestView = [imageViews objectAtIndex:bestIndex];
	if(bestView.superview == nil) {
		UIImage *image = [images objectAtIndex:bestIndex];
		if(bestView.image != image) {
			bestView.image = image;
		}

		bestView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
		bestView.bounds = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
		[self addSubview:bestView];
	}

	bestView.hidden = NO;
	
	for(UIImageView *view in imageViews) {
		if(view != bestView && view.superview != nil) {
			view.hidden = YES;
		}
	}
}

@end
