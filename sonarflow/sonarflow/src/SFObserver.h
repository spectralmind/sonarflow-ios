#import <Foundation/Foundation.h>

@protocol SFObserverDelegate;

@interface SFObserver : NSObject

- (id)initWithObject:(NSObject *)theObject keyPath:(NSString *)theKeyPath delegate:(id<SFObserverDelegate>)theDelegate;

@property (nonatomic, readonly) NSObject *object;
@property (weak, nonatomic, readonly) id<SFObserverDelegate> delegate;

- (void)handleChange:(NSDictionary *)change ofKind:(NSKeyValueChange)changeKind from:(id)oldValue to:(id)newValue;
@end

@protocol SFObserverDelegate <NSObject>

@optional
- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue;

@end
