/// Defines all application-wide notifications that are used by Sonarflow

#define SFNowPlayingItemChangedNotification @"SFNowPlayingItemChangedNotification"

/// Posted whenever the ArtistInfo view should be shown. The userInfo-Dictionary contains the corresponding SFMediaItem object identified by SFShowArtistInfoNotificationArtistKey.
#define SFShowArtistInfoNotification @"SFShowArtistInfoNotification"
#define SFShowArtistInfoNotificationArtistKey @"SFShowArtistInfoNotificationArtist"

#define SFStopYoutubeNotification @"SFStopYoutubeNotification"
#define SFStopLibraryPlayerNotification @"SFStopLibraryPlayerNotification"
