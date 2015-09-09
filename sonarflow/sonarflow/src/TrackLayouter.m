#import "TrackLayouter.h"
#import "Bubble.h"

@implementation TrackLayouter

static const float kA = 2.42;
static const float kBubbleDistance = 1.0;

static CGFloat length(CGPoint vector);

@synthesize A;

- (id)init {
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	A = kA;
    return self;
}

CGPoint mirrorPointAtAxis(CGPoint vectorFromOrigin, CGFloat radius) {
    CGFloat len = length(vectorFromOrigin);
    
    CGPoint normalized = CGPointMake(vectorFromOrigin.x / len, vectorFromOrigin.y / len);
    CGPoint transposed = CGPointMake(normalized.y, -normalized.x);
    
    return CGPointMake(vectorFromOrigin.x + transposed.x * radius, vectorFromOrigin.y + transposed.y * radius);
}

- (NSArray *)buildTheodorusSpiralWithBubbles:(NSArray *)bubbles inRadius:(CGFloat)radius {
    CGPoint cursor = CGPointMake(3, 0);
    CGPoint center = CGPointMake(-radius/7.0, radius/7.0);
    
    CGFloat lastRadius = 0.0;
    for(Bubble *bubble in bubbles) {
        CGPoint nextCursor = mirrorPointAtAxis(cursor, bubble.radius + lastRadius);
        bubble.origin = CGPointMake(center.x + nextCursor.x, center.y + nextCursor.y);
        cursor =  mirrorPointAtAxis(nextCursor, kBubbleDistance);
        lastRadius = bubble.radius;
    }
    
    return bubbles;
}

static CGPoint archimedeanPoint(CGFloat a, CGFloat phi) {
    return CGPointMake(a * phi * cos(phi), a * phi * sin(phi));
}


static CGPoint involuteOfCircle(CGFloat a, CGFloat t) {
    return CGPointMake(a * (cos(t) + t * sin(t)), a * (sin(t) + t * cos(t)));
}

static CGFloat length(CGPoint vector) {
    return sqrt(vector.x*vector.x + vector.y*vector.y);
}


- (NSArray *)buildArchimedeanSpiralWithBubbles:(NSArray *)bubbles {
    CGFloat lastRadius = 0.0;
    CGFloat t = M_PI_2 + M_PI_4;
    CGPoint lastOrigin = CGPointMake(0, INFINITY);
    
    for(Bubble *bubble in bubbles) {
        CGPoint origin;
        do {
            origin = archimedeanPoint(A, t);
            
            CGPoint vec = CGPointMake(origin.x - lastOrigin.x, origin.y - lastOrigin.y);
            if(length(vec) >= lastRadius + bubble.radius) {
                break;
            }
            
            t += 0.05;
        }while(1);
        
        bubble.origin = origin;
        lastRadius = bubble.radius;
        bubble.origin = origin;
        lastOrigin = origin;
    }
    
    return bubbles;
}

- (NSArray *)sortAndLayoutBubbles:(NSArray *)bubbles inRadius:(CGFloat)radius avoidingBubbles:(NSArray *)theBubblesToAvoid {
	NSAssert([theBubblesToAvoid count] == 0, @"Track layouter cannot avoid bubbles");
    if(bubbles == nil || bubbles.count == 0) {
        return bubbles;
    }
    
    return [self buildArchimedeanSpiralWithBubbles:bubbles];
}

@end
