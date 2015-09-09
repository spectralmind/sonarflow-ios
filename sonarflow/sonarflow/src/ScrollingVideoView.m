#import "ScrollingVideoView.h"
#import "NSString+CGLogging.h"
#import "HTMLBuilder.h"
#import "Notifications.h"

static const CGFloat defaultVideoSpacing = 10.f;

typedef enum {
	ScrollingVideoViewScrollDirectionHorizontal,
	ScrollingVideoViewScrollDirectionVertical
} ScrollingVideoViewScrollDirection;


@implementation NSString (Length)

- (NSString *)stringByTruncatingTo:(NSUInteger)maxLength {
	if(self.length <= maxLength) {
		return self;
	}
	
	return [[self substringToIndex:maxLength-3] stringByAppendingString:@"..."];
}

@end

@interface ScrollingVideoView () <UIWebViewDelegate>

@end


@implementation ScrollingVideoView {
@private
	UIWebView *webView;
	ScrollingVideoViewScrollDirection scrollDirection;
	CGFloat videoSpacing;
	BOOL postponedLayouting;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	// remove if UIWebView has weak delegate property
	webView.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withScrollDirection:ScrollingVideoViewScrollDirectionHorizontal withVideoSpacing:defaultVideoSpacing];
}

- (id)initWithFrame:(CGRect)frame horizontallyScrollingWithVideoSpacing:(CGFloat)theVideoSpacing
{
    return [self initWithFrame:frame withScrollDirection:ScrollingVideoViewScrollDirectionHorizontal withVideoSpacing:theVideoSpacing];
}

- (id)initWithFrame:(CGRect)frame verticallyScrollingWithVideoSpacing:(CGFloat)theVideoSpacing
{
    return [self initWithFrame:frame withScrollDirection:ScrollingVideoViewScrollDirectionVertical withVideoSpacing:theVideoSpacing];
}

- (id)initWithFrame:(CGRect)frame withScrollDirection:(ScrollingVideoViewScrollDirection)theScrollDirection withVideoSpacing:(CGFloat)theVideoSpacing
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		scrollDirection = theScrollDirection;
		videoSpacing = theVideoSpacing;
		webView = [[UIWebView alloc] initWithFrame:frame];
		webView.opaque = NO;
		webView.backgroundColor = [UIColor clearColor];
		webView.delegate = self;
		[self webviewScrollSubview].scrollEnabled = NO;
		[self addSubview:webView];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStopYoutubeNotification:) name:SFStopYoutubeNotification object:nil];
	}
    return self;
}

- (void)layoutSubviews
{
	if(postponedLayouting) {
		[self reloadData];
		postponedLayouting = NO;
	}
}


#pragma mark - Public Methods

- (void)reloadData
{
	if (CGRectIsEmpty(self.bounds)) {
		postponedLayouting = YES;
		return;
	}
	
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		CGRect newRect = self.superview.bounds;
		newRect.origin = CGPointZero;
		webView.frame = newRect;
		[webView loadHTMLString:[self htmlWithEmbeddedVideos] baseURL:nil];
	}];
}


#pragma mark - Private Methods

- (UIScrollView *)webviewScrollSubview
{
	for (UIView *subview in [webView subviews]) {
		if ([subview isKindOfClass:NSClassFromString(@"UIScrollView")]) {
			return (UIScrollView *)subview;
		}
	}
	return nil;
}

- (void)postStopLibraryPlayerNotification {
	[[NSNotificationCenter defaultCenter] postNotificationName:SFStopLibraryPlayerNotification object:self userInfo:nil];
}

- (void)handleStopYoutubeNotification:(NSNotification *)note {
	[self stopYoutubeVideos];
}

- (void)stopYoutubeVideos {
	NSString *returnvalue = [webView stringByEvaluatingJavaScriptFromString:@"stopAllPlayers()"];
	if (returnvalue == nil) {
		NSLog(@"Error: could not stop Youtube video playback");
	}
}

- (NSString *)htmlWithEmbeddedVideos {
	HTMLBuilder *htmlBuilder = [HTMLBuilder htmlBuilder];
	[htmlBuilder appendStyleLine:[self commonStyle]];
	[htmlBuilder appendScriptLine:[self youtubeScript]];
	
	if(scrollDirection == ScrollingVideoViewScrollDirectionVertical) {
		[htmlBuilder appendStyleLine:[self specificVerticalStyle]];
		[htmlBuilder appendBodyLine:@"<table>"];
		[htmlBuilder appendBodyLine:[self elementsHtmlWithVideoTemplate:@"<tr><td>%@</td><td>%@</td></tr>"]];
		[htmlBuilder appendBodyLine:@"</table>"];
	}
	else {
		[htmlBuilder appendStyleLine:[self specificHorizontalStyle]];
		[htmlBuilder appendBodyLine:@"<table><tr>"];
		[htmlBuilder appendBodyLine:[self elementsHtmlWithVideoTemplate:@"<td>%@</td><td class='x'>%@</td>"]];
		[htmlBuilder appendBodyLine:@"</tr></table>"];
	}
	[htmlBuilder appendBodyLine:[self youtubeAPI]];
NSLog(@"%@",[htmlBuilder htmlString]);
	return [htmlBuilder htmlString];
}

- (NSString *)commonStyle {
	return @"body {\
		margin: 0px;\
		background-color: transparent;\
		color: white;\
		font: 13pt Helvetica;\
	}\
	table { margin: 0px; padding: 0px; }";
}

- (NSString *)specificVerticalStyle {
	return @"td { vertical-align: middle; }";
}

- (NSString *)specificHorizontalStyle {
	return @"td { vertical-align: top; min-width:150px; } \
	td.x { vertical-align: top; padding-right: 30px; }";
}

- (NSString *)youtubeAPI {
	return @"<script type='text/javascript' src='https://www.youtube.com/player_api' async='async'></script>";
}

- (NSString *)youtubeScript {
	return @"\
	function notifyIOS(url) {\
		var iframe = document.createElement('IFRAME');\
		iframe.setAttribute('src', url);\
		document.documentElement.appendChild(iframe);\
		iframe.parentNode.removeChild(iframe);\
		iframe = null;\
	}\
	\
	function onPlayerStateChange(event) {\
		if (event.data == YT.PlayerState.PLAYING) {\
			notifyIOS('youtubestate://playerstatechange/playing');\
		} else if (event.data == YT.PlayerState.PAUSED) {\
			notifyIOS('youtubestate://playerstatechange/paused');\
		} else if (event.data == YT.PlayerState.ENDED) {\
			notifyIOS('youtubestate://playerstatechange/ended');\
		}\
	}\
	\
	function onPlayerError(event) {\
	}\
	\
	var players = {};\
	\
	function onYouTubePlayerAPIReady() {\
	var playeriframes = document.querySelectorAll('iframe');\
	\
	for (var i = playeriframes.length; i--;) {\
		players[playeriframes[i].id] = new YT.Player(playeriframes[i].id, {\
			events: {\
				'onStateChange': onPlayerStateChange,\
				'onError': onPlayerError\
				}\
			});\
		}\
	}\
	\
	function stopAllPlayers() {\
		for (p in players) {\
			players[p].pauseVideo();\
		}\
	}";
}

- (NSString *)elementsHtmlWithVideoTemplate:(NSString *)videoSnip {
	NSMutableString *allEmbeds = [NSMutableString string];
	
	NSUInteger videoCount = [self.scrollingVideoViewDelegate scrollingVideoViewNumberOfVideos:self];
	CGSize videoSize = [self.scrollingVideoViewDelegate scrollingVideoViewSizeOfVideos:self];
	NSString *artistName = [self.scrollingVideoViewDelegate artistNameForScrollingVideoView:self];
	NSString *boldArtistName = [[@"<b>" stringByAppendingString:artistName] stringByAppendingString:@"</b>"];
	
	for (int i = 0; i<videoCount; i++) {
		SMArtistVideo *video = [self.scrollingVideoViewDelegate scrollingVideoView:self videoWithIndex:i];
		
		NSString *truncatedTitle = [video.title stringByTruncatingTo:60];
		NSString *formattedTitle = [truncatedTitle stringByReplacingOccurrencesOfString:artistName withString:boldArtistName options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch range:NSMakeRange(0, [truncatedTitle length])];
		
		[allEmbeds appendFormat:videoSnip, [self iframeForYoutubeEmbedWithUrl:video.videoUrl width:videoSize.width height:videoSize.height iframeID:[NSString stringWithFormat:@"frame%d",i]], formattedTitle];
	}
	
	return allEmbeds;
}

- (NSString *)iframeForYoutubeEmbedWithUrl:(NSString *)url width:(CGFloat)width height:(CGFloat)height iframeID:(NSString *)iframeID {
	return [NSString stringWithFormat:@"<iframe id=%@ type=\"text/html\" src=\"%@?showinfo=0\" width=\"%0.0f\" height=\"%0.0f\" frameborder=\"0\"></iframe>",iframeID,url,width,height];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	CGSize newSize = [aWebView sizeThatFits:CGSizeZero];	
	if(scrollDirection == ScrollingVideoViewScrollDirectionVertical) {
		newSize.width = self.frame.size.width;
	}
	else {
		newSize.height = self.frame.size.height;
	}
	
	CGRect frame = aWebView.frame;
	frame.size = newSize;
	aWebView.frame = frame;
	self.contentSize = newSize;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *URL = [request URL];
	
	if ([[URL scheme] isEqualToString:@"youtubestate"]) {
		NSArray *pathComponents = [URL pathComponents];
		NSAssert([pathComponents count] == 2, @"Error: youtubestate: 2 path components expected: %@",pathComponents);
		NSAssert([[URL host] isEqualToString:@"playerstatechange"], @"Error: youtubestate: invalid host: %@",[URL host]);
		NSAssert([[pathComponents objectAtIndex:0] isEqualToString:@"/"], @"Error: youtubestate: invalid 1st path component: %@",[pathComponents objectAtIndex:0]);

		if ([[pathComponents objectAtIndex:1] isEqualToString:@"playing"]) {
			[self postStopLibraryPlayerNotification];
		}
		else if ([[pathComponents objectAtIndex:1] isEqualToString:@"paused"]) {
			NSLog(@"Youtube video was paused, or transport bar was used");
		}
		else if ([[pathComponents objectAtIndex:1] isEqualToString:@"ended"]) {
			NSLog(@"Youtube video ended playing by itself");
		}
		else {
			NSAssert(NO, @"Error: youtubestate: invalid 2nd path component: %@",[pathComponents objectAtIndex:1]);
		}
		return NO;
	}
	return YES;
}

@end
