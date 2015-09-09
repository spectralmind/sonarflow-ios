#import "HTMLBuilder.h"

@interface HTMLBuilder ()

@property (nonatomic, strong) NSMutableArray *headLines;
@property (nonatomic, strong) NSMutableArray *styleLines;
@property (nonatomic, strong) NSMutableArray *scriptLines;
@property (nonatomic, strong) NSMutableArray *bodyLines;

@end

@implementation HTMLBuilder

- (id)init {
    self = [super init];
    if (self) {
		self.headLines = [NSMutableArray array];
		self.styleLines = [NSMutableArray array];
		self.scriptLines = [NSMutableArray array];
		self.bodyLines = [NSMutableArray array];
    }
    return self;
}

+ (HTMLBuilder *)htmlBuilder {
	return [[HTMLBuilder alloc] init];
}

- (NSString *)htmlString {
	NSString *htmlTemplate = @"<html><head>%@</head><body>%@</body></html>";
	return [NSString stringWithFormat:htmlTemplate,[self headString],[self bodyString]];
}

- (NSString *)headString {
	NSMutableString *headstring = [NSMutableString string];
	[headstring appendString:[self.headLines componentsJoinedByString:@"\n"]];
	[headstring appendString:[self styleString]];
	[headstring appendString:[self scriptString]];
	return headstring;
}

- (NSString *)styleString {
	if ([self.styleLines count] == 0) {
		return @"";
	}
	
	NSMutableString *stylestring = [NSMutableString string];
	[stylestring appendString:@"\n<style type=\"text/css\">\n"];
	[stylestring appendString:[self.styleLines componentsJoinedByString:@"\n"]];
	[stylestring appendString:@"</style>"];
	return stylestring;
}

- (NSString *)scriptString {
	if ([self.scriptLines count] == 0) {
		return @"";
	}
	
	NSMutableString *scriptstring = [NSMutableString string];
	[scriptstring appendString:@"\n<script type='text/javascript'>//<![CDATA[\n"];
	[scriptstring appendString:[self.scriptLines componentsJoinedByString:@"\n"]];
	[scriptstring appendString:@"//]]></script>"];
	return scriptstring;
}

- (NSString *)bodyString {
	return [self.bodyLines componentsJoinedByString:@"\n"];
}


- (void)appendHeadLine:(NSString *)headLine {
	[self.headLines addObject:headLine];
}

- (void)appendStyleLine:(NSString *)styleLine {
	[self.styleLines addObject:styleLine];
}

- (void)appendScriptLine:(NSString *)scriptLine {
	[self.scriptLines addObject:scriptLine];
}

- (void)appendBodyLine:(NSString *)bodyLine {
	[self.bodyLines addObject:bodyLine];
}

@end
