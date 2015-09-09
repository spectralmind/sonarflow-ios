//
//  NSString+DocumentsPath.h
//  Common Code
//
//  Created by Raphael Charwot on 09.10.09.
//  Copyright 2009 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
	Adds a convenience method for getting the path to a file in the
	writable application directory.
 */
@interface NSString(DocumentsPath)

/**
	Creates a string that contains the path to a file within the applications
	documents directory.
	@param fileName The name of the file.
	@returns the full path to the given file within the documents directory.
 */
+ (NSString *)pathForDocumentFile:(NSString *)fileName;


@end
