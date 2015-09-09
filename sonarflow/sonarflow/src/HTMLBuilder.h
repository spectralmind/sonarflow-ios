#import <Foundation/Foundation.h>

@interface HTMLBuilder : NSObject

+ (HTMLBuilder *)htmlBuilder;

- (NSString *)htmlString;

- (void)appendHeadLine:(NSString *)headLine;
- (void)appendStyleLine:(NSString *)styleLine;
- (void)appendScriptLine:(NSString *)scriptLine;
- (void)appendBodyLine:(NSString *)bodyLine;

@end
