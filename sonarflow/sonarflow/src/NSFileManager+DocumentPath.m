#import "NSFileManager+DocumentPath.h"

@implementation NSFileManager (DocumentPath)

+ (NSString *)pathForDocumentFile:(NSString *)filename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	[self createDirectoryIfMissing:documentsDirectory];
	return [documentsDirectory stringByAppendingPathComponent:filename];
}

+ (void)createDirectoryIfMissing:(NSString *)directory {
	NSError *error = nil;
	BOOL ok = [[self defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
	if(ok == NO) {
		NSLog(@"cannot create directory %@: %@", directory, error);
	}
}

@end
