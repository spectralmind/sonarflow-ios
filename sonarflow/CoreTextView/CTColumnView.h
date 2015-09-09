//inside CTColumnView.h

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface CTColumnView : UIView

@property (retain, nonatomic) NSMutableArray* images;

-(void)setCTFrame:(CTFrameRef)frame;

@end
