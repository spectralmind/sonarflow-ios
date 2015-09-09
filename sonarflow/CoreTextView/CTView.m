//
//  CTView.m
//  CoreTextMagazine
//
//  Created by Marin Todorov on 8/11/11.
//  Copyright 2011 Marin Todorov. All rights reserved.
//

#import "CTView.h"
#import <CoreText/CoreText.h>
#import "CTColumnView.h"

@interface CTView ()

- (void)buildFrames;
- (void)attachImagesWithFrame:(CTFrameRef)f inColumnView:(CTColumnView*)col;

@property (retain, nonatomic) NSAttributedString* attString;
@property (retain, nonatomic) NSArray* images;

@end


@implementation CTView {
	CGRect oldBounds;
    NSAttributedString* attString;
    
    NSMutableArray* frames;
    NSArray* images;
	BOOL areFramesBuilt;
}

@synthesize inset;
@synthesize frameWidth;
@synthesize frameSpacing;

@synthesize images;

-(void)dealloc
{
    self.attString = nil;
    self.images = nil;
    [super dealloc];
}

@synthesize attString;
- (void)setAttString:(NSAttributedString *)newAttString {
	if ([attString isEqual:newAttString]) {
        return;
    }
	
	[attString release];
	attString = [newAttString retain];

	areFramesBuilt = NO;
	[self setNeedsLayout];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		//self.pagingEnabled = YES;
		self.frameWidth = 100.f;
    }
    return self;
}

- (void)layoutSubviews
{
	// layout subviews is also called when the uiscrollview is being scrolled, so we ignore the origin
	// as we have a fixed column width, a changing width can be ignored - the prevents relayouting on rotation
	if(oldBounds.size.height != self.bounds.size.height || !areFramesBuilt) {
		oldBounds = self.bounds;
		[self buildFrames];
	}
}

- (void)buildFrames
{
	for (UIView *view in self.subviews) {
		if ([view isKindOfClass:[CTColumnView class]]) {
			[view removeFromSuperview];
		}
	}
	
	if (attString == nil) {
		return;
	}
	if (self.frameWidth < 1.f) {
		return;
	}

    CGRect textFrame = CGRectMake(self.bounds.origin.x + self.inset.left,
								  self.bounds.origin.y + self.inset.top,
								  self.bounds.size.width - self.inset.left - self.inset.right,
								  self.bounds.size.height - self.inset.top - self.inset.bottom);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    int textPos = 0;
    int columnIndex = 0;
    
    while (textPos < [attString length]) {
		//this would be for a fixed-columns-per-page layout
        //CGPoint colOffset = CGPointMake( (columnIndex+1)*self.frameSpacing + columnIndex*(textFrame.size.width/2), 20 );
        //CGRect colRect = CGRectMake(0, 0 , textFrame.size.width/2-10, textFrame.size.height-40);

        CGPoint colOffset = CGPointMake( columnIndex * (self.frameWidth + self.frameSpacing), self.inset.top );
        CGRect colRect = CGRectMake(0.f, 0.f, self.frameWidth, textFrame.size.height);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, colRect);
        
        //use the column path
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0.f), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        
        //create an empty column view
        CTColumnView* content = [[CTColumnView alloc] initWithFrame: CGRectMake(0.f, 0.f, self.contentSize.width, self.contentSize.height)];
        content.backgroundColor = [UIColor clearColor];
        content.frame = CGRectMake(colOffset.x, colOffset.y, colRect.size.width, colRect.size.height) ;
        
		//set the column view contents and add it as subview
        [content setCTFrame:frame]; 
        [self attachImagesWithFrame:frame inColumnView:content];
        [self addSubview: content];
		[content release];
        
        //prepare for next frame
        textPos += frameRange.length;
        
        CFRelease(frame);
        CFRelease(path);
		
        columnIndex++;
    }
	
	CFRelease(framesetter);
    
    //set the total width of the scroll view
	//this would be for a fixed-columns-per-page layout
    //int totalPages = (columnIndex+1) / 2;
    //self.contentSize = CGSizeMake(totalPages*self.bounds.size.width, textFrame.size.height);

    self.contentSize = CGSizeMake(columnIndex * (self.frameWidth + self.frameSpacing), textFrame.size.height);
	
	areFramesBuilt = YES;
}

-(void)setAttString:(NSAttributedString *)string withImages:(NSArray*)imgs
{
    self.attString = string;
    self.images = imgs;
}

-(void)attachImagesWithFrame:(CTFrameRef)f inColumnView:(CTColumnView*)col
{
	if (self.images == nil || [self.images count] == 0) {
		return;
	}
	
    //drawing images
    NSArray *lines = (NSArray *)CTFrameGetLines(f);
    
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(f, CFRangeMake(0, 0), origins);
    
    int imgIndex = 0;
    NSDictionary* nextImage = [self.images objectAtIndex:imgIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] intValue];
    
    //find images for the current column
    CFRange frameRange = CTFrameGetVisibleStringRange(f);
    while ( imgLocation < frameRange.location ) {
        imgIndex++;
        if (imgIndex>=[self.images count]) return; //quit if no images for this column
        nextImage = [self.images objectAtIndex:imgIndex];
        imgLocation = [[nextImage objectForKey:@"location"] intValue];
    }
    
    NSUInteger lineIndex = 0;
    for (id lineObj in lines) {
        CTLineRef line = (CTLineRef)lineObj;
        
        for (id runObj in (NSArray *)CTLineGetGlyphRuns(line)) {
            CTRunRef run = (CTRunRef)runObj;
            CFRange runRange = CTRunGetStringRange(run);
            
            if ( runRange.location <= imgLocation && runRange.location+runRange.length > imgLocation ) {
	            CGRect runBounds;
	            CGFloat ascent;//height above the baseline
	            CGFloat descent;//height below the baseline
	            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
	            runBounds.size.height = ascent + descent;
                
	            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
	            runBounds.origin.x = origins[lineIndex].x + self.frame.origin.x + xOffset + self.inset.left;
	            runBounds.origin.y = origins[lineIndex].y + self.frame.origin.y + self.inset.top;
	            runBounds.origin.y -= descent;
                
                UIImage *img = [UIImage imageNamed: [nextImage objectForKey:@"fileName"] ];
                CGPathRef pathRef = CTFrameGetPath(f);
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                
                CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x - self.inset.left - self.contentOffset.x, colRect.origin.y - self.inset.top - self.frame.origin.y);
                [col.images addObject:
                 [NSArray arrayWithObjects:img, NSStringFromCGRect(imgBounds) , nil]
                 ]; 
                //load the next image
                imgIndex++;
                if (imgIndex < [self.images count]) {
                    nextImage = [self.images objectAtIndex: imgIndex];
                    imgLocation = [[nextImage objectForKey: @"location"] intValue];
                }
                
            }
        }
        lineIndex++;
    }
}

@end
