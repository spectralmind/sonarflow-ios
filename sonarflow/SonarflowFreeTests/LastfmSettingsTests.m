#import "LastfmSettingsTests.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "LastfmSettings.h"

@implementation LastfmSettingsTests

- (void)testEquals {
	NSString *username = @"Testuser";
	NSString *password = @"Testpassword";
	assertThat([LastfmSettings settingsWithScrobble:YES username:username password:password],
			   equalTo([LastfmSettings settingsWithScrobble:YES username:[username mutableCopy] password:[password mutableCopy]]));
	STAssertEquals([[LastfmSettings settingsWithScrobble:YES username:username password:password] hash],[[LastfmSettings settingsWithScrobble:YES username:[username mutableCopy] password:[password mutableCopy]] hash], @"Should have equal hash");

	assertThat([LastfmSettings settingsWithScrobble:YES username:username password:password],
			   isNot(equalTo([LastfmSettings settingsWithScrobble:NO username:username password:password])));
	assertThat([LastfmSettings settingsWithScrobble:YES username:username password:password],
			   isNot(equalTo([LastfmSettings settingsWithScrobble:YES username:@"Other" password:password])));
	assertThat([LastfmSettings settingsWithScrobble:YES username:username password:password],
			   isNot(equalTo([LastfmSettings settingsWithScrobble:YES username:username password:@"Other"])));
}

@end
