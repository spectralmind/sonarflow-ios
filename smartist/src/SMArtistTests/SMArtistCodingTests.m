//
//  SMArtistJSONTests.m
//  SMArtist
//
//  Created by Manuel Maly on 13.12.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "SMArtistCodingTests.h"
#import "SMArtistResult+Private.h"
#import "SMArtistBiosResult.h"
#import "SMArtistBio.h"
#import "SMArtistImage.h"
#import "SMArtistImagesResult.h"
#import "SMArtistSimilarityMatrixResult.h"
#import "SMSimilarArtist.h"
#import "SMArtistSimilarityResult.h"
#import "SMResultCache.h"
#import "SMArtistRequest.h"

#define kDataKey @"dataKey"

@implementation SMArtistCodingTests

- (void)testSMArtistResultCodification {
    NSString *recognizedArtistName = @"someArtist";
    NSInteger servicesUsedMask = 100;
    SMArtistResult *result1 = [[SMArtistResult alloc] init];
    result1.recognizedArtistName = recognizedArtistName;
    result1.servicesUsedMask = servicesUsedMask;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];          
    [archiver encodeObject:result1 forKey:kDataKey];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SMArtistResult *result2 = [unarchiver decodeObjectForKey:kDataKey];
    
    STAssertEqualObjects(result2.recognizedArtistName, recognizedArtistName, @"recognizedArtistName should be the same");
    STAssertTrue(result2.servicesUsedMask == servicesUsedMask, @"servicesUsedMask should be the same");
    
}


- (void)testSMArtistBiosResultCodification {
    NSString *recognizedArtistName = @"someArtist";
    NSInteger servicesUsedMask = 100;
    SMArtistBiosResult *result1 = [[SMArtistBiosResult alloc] init];
    result1.recognizedArtistName = recognizedArtistName;
    result1.servicesUsedMask = servicesUsedMask;
    NSMutableArray *bios = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        SMArtistBio *bio = [[SMArtistBio alloc] init];
        bio.fulltext = [NSString stringWithFormat:@"%i", i];
        bio.previewText = [NSString stringWithFormat:@"%i", i+1];
        bio.sourceName = [NSString stringWithFormat:@"%i", i+2];
        bio.url = [NSString stringWithFormat:@"%i", i+3];
        [bios addObject:bio];
    }
    result1.bios = bios;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];          
    [archiver encodeObject:result1 forKey:kDataKey];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SMArtistBiosResult *result2 = [unarchiver decodeObjectForKey:kDataKey];
    
    STAssertEqualObjects(result2.recognizedArtistName, recognizedArtistName, @"recognizedArtistName should be the same");
    STAssertTrue(result2.servicesUsedMask == servicesUsedMask, @"servicesUsedMask should be the same");
    for (int i = 0; i < 10; i++) {
        SMArtistBio *bio = [result2.bios objectAtIndex:i];
        STAssertEqualObjects(bio.fulltext, ([NSString stringWithFormat:@"%i", i]), @"fullText should be %i", i);
        STAssertEqualObjects(bio.previewText, ([NSString stringWithFormat:@"%i", i+1]), @"previewText should be %i", i+1);
        STAssertEqualObjects(bio.sourceName, ([NSString stringWithFormat:@"%i", i+2]), @"sourceName should be %i", i+2);
        STAssertEqualObjects(bio.url, ([NSString stringWithFormat:@"%i", i+3]), @"url should be %i", i+3);
    }
    [unarchiver finishDecoding];
}

- (void)testSMArtistImagesResultCodification {
    NSString *recognizedArtistName = @"someArtist";
    NSInteger servicesUsedMask = 100;
    SMArtistImagesResult *result1 = [[SMArtistImagesResult alloc] init];
    result1.recognizedArtistName = recognizedArtistName;
    result1.servicesUsedMask = servicesUsedMask;
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        SMArtistImage *image = [[SMArtistImage alloc] init];
        image.imageUrl = [NSString stringWithFormat:@"%i", i];
        image.imageSize = [NSString stringWithFormat:@"%i", i+1];
        [images addObject:image];
    }
    result1.images = images;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];          
    [archiver encodeObject:result1 forKey:kDataKey];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SMArtistImagesResult *result2 = [unarchiver decodeObjectForKey:kDataKey];
    
    STAssertEqualObjects(result2.recognizedArtistName, recognizedArtistName, @"recognizedArtistName should be the same");
    STAssertTrue(result2.servicesUsedMask == servicesUsedMask, @"servicesUsedMask should be the same");
    for (int i = 0; i < 10; i++) {
        SMArtistImage *image = [result2.images objectAtIndex:i];
        STAssertEqualObjects(image.imageUrl, ([NSString stringWithFormat:@"%i", i]), @"imageUrl should be %i", i);
        STAssertEqualObjects(image.imageSize, ([NSString stringWithFormat:@"%i", i+1]), @"imageSize should be %i", i+1);
    }
    [unarchiver finishDecoding];
}

- (void)testSMArtistSimilarityMatrixResultCodification {
    NSString *recognizedArtistName = @"someArtist";
    NSInteger servicesUsedMask = 100;
    SMArtistSimilarityMatrixResult *result1 = [[SMArtistSimilarityMatrixResult alloc] init];
    result1.recognizedArtistName = recognizedArtistName;
    result1.servicesUsedMask = servicesUsedMask;
    NSMutableDictionary *matrix = [NSMutableDictionary dictionary];
    for (int i = 0; i < 10; i++) {
        NSString *currentString = [NSString stringWithFormat:@"%i", i];
        SMSimilarArtist *artist = [[SMSimilarArtist alloc] init];
        artist.artistName = currentString;
        artist.matchValue = i;
        [matrix setValue:artist forKey:currentString];
    }
    result1.similarityMatrix = matrix;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];          
    [archiver encodeObject:result1 forKey:kDataKey];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SMArtistSimilarityMatrixResult *result2 = [unarchiver decodeObjectForKey:kDataKey];
    
    STAssertEqualObjects(result2.recognizedArtistName, recognizedArtistName, @"recognizedArtistName should be the same");
    STAssertTrue(result2.servicesUsedMask == servicesUsedMask, @"servicesUsedMask should be the same");
    for (int i = 0; i < 10; i++) {
        NSString *currentString = [NSString stringWithFormat:@"%i", i];
        SMSimilarArtist *artist = [result2.similarityMatrix objectForKey:currentString];
        STAssertEqualObjects(artist.artistName, currentString, @"artistName should be %i", i);
        STAssertEqualsWithAccuracy(artist.matchValue, (CGFloat)i, 0.001, @"matchValue should be %i", i);
    }
    [unarchiver finishDecoding];
}

- (void)testSMArtistSimilarityResultCodification {
    NSString *recognizedArtistName = @"someArtist";
    NSInteger servicesUsedMask = 100;
    SMArtistSimilarityResult *result1 = [[SMArtistSimilarityResult alloc] init];
    result1.recognizedArtistName = recognizedArtistName;
    result1.servicesUsedMask = servicesUsedMask;
    NSMutableArray *similarArtists = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        SMSimilarArtist *artist = [[SMSimilarArtist alloc] init];
        artist.artistName = [NSString stringWithFormat:@"%i", i];
        artist.matchValue = i;
        [similarArtists addObject:artist];
    }
    result1.similarArtists = similarArtists;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];          
    [archiver encodeObject:result1 forKey:kDataKey];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SMArtistSimilarityResult *result2 = [unarchiver decodeObjectForKey:kDataKey];
    
    STAssertEqualObjects(result2.recognizedArtistName, recognizedArtistName, @"recognizedArtistName should be the same");
    STAssertTrue(result2.servicesUsedMask == servicesUsedMask, @"servicesUsedMask should be the same");
    for (int i = 0; i < 10; i++) {
        SMSimilarArtist *artist = [result2.similarArtists objectAtIndex:i];
        STAssertEqualObjects(artist.artistName, ([NSString stringWithFormat:@"%i", i]), @"artistName should be %i", i);
        STAssertEqualsWithAccuracy(artist.matchValue, (CGFloat)i, 0.001, @"matchValue should be %i", i);
    }
    [unarchiver finishDecoding];
}

@end
