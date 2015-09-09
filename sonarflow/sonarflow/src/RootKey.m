#import "RootKey.h"

@implementation RootKey {
	id key;
	BubbleType type;
}

- (id)initWithKey:(id)theKey type:(BubbleType)theType {
    self = [super init];
    if (self) {
		NSAssert(theKey != nil, @"cannot create nil root key");
		key = [theKey copy];
		type = theType;
    }
    return self;
}

+ (id)rootKeyWithKey:(id)theKey type:(BubbleType)theType {
	RootKey *rootKey;
	rootKey = [[RootKey alloc] initWithKey:theKey type:theType];
	return rootKey;
}

@synthesize key;
@synthesize type;

- (BOOL)isEqual:(id)object {
	if(self == object) {
		return true;
	}

	if([object isKindOfClass:[RootKey class]] == false) {
		return false;
	}
	RootKey *other = (RootKey *)object;
	return [self.key isEqual:other.key] && self.type == other.type;
}

- (NSUInteger)hash {
	return [self.key hash] ^ [[NSNumber numberWithInt:type] hash];
}

- (id)copyWithZone:(NSZone *)zone {
	RootKey *newKey = [[[self class] allocWithZone:zone] initWithKey:self.key type:self.type];
	return newKey;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"RootKey of type %d for %@", self.type, self.key];
}

@end
