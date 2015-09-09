//inside CTColumnView.m
#import "CTColumnView.h"

@implementation CTColumnView {
    CTFrameRef ctFrame;
    NSMutableArray* images;
}

@synthesize images;

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.images = [NSMutableArray array];
	}
	return self;
}

-(void)dealloc
{
	CFRelease(ctFrame);
    self.images = nil;
    [super dealloc];
}

-(void)setCTFrame:(CTFrameRef)frame
{
	CFRetain(frame);
    ctFrame = frame;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw(ctFrame, context);
    
    for (NSArray* imageData in self.images) {
        UIImage* img = [imageData objectAtIndex:0];
        CGRect imgBounds = CGRectFromString([imageData objectAtIndex:1]);
        CGContextDrawImage(context, imgBounds, img.CGImage);
    }
}

@end