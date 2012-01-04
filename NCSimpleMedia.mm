#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"
#import <objc/runtime.h>
#import "SBMediaController.h"
#import "SBApplication.h"
#import "SBIconModel.h"
#import "SBIcon.h"

#import "NCDualPressButton.h"

@interface SimpleMediaController : NSObject <BBWeeAppController>
{
    UIView *_view;
    SBMediaController *mediaController;
    UIImageView *iconView;
    UILabel *titleView;
    
    NCDualPressButton *playButton;
}

+ (void)initialize;
- (UIView *)view;

@end

@implementation SimpleMediaController


+ (void)initialize
{
    
}

- (void)dealloc
{
    [iconView release];
    [titleView release];
    [playButton release];
    [_view release];
    [super dealloc];
}

- (float)viewHeight { return 90; }
- (UIView *)view 
{
    if (_view == nil)
    {
        mediaController = [objc_getClass("SBMediaController") sharedInstance];

        // [mediaController changeTrack:+/-1]; selects next/prev track
        _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [self viewHeight])];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        UIImage *bg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/StocksWeeApp.bundle/WeeAppBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        UIImageView *bgView = [[UIImageView alloc] initWithImage:bg];
        bgView.frame = CGRectMake(2, 0, 316, [self viewHeight]);
        [_view addSubview:bgView];
        [bgView release];

        // Application icon
        float iconSize = 57;
        float iconMargin = ([self viewHeight] - iconSize)/2;
        iconView = [[UIImageView alloc] initWithFrame: CGRectMake(iconMargin,iconMargin,iconSize,iconSize)];
        [_view addSubview:iconView];

        // Buttons
        float buttonHeight = ([self viewHeight] - 48)/2;
        NCDualPressButton *prevButton = [[[NCDualPressButton alloc] initWithFrame:CGRectMake(160 - 24 - 48 - 4, buttonHeight, 48, 48) holdDelay:1.0] autorelease];
        [prevButton setImage:[UIImage imageNamed:@"MCPrev.png"] forState:UIControlStateNormal];
        [prevButton setImage:[UIImage imageNamed:@"MCPrev_p.png"] forState:UIControlStateHighlighted];
        [prevButton setImage:[UIImage imageNamed:@"MCPrev_d.png"] forState:UIControlStateDisabled];
        [prevButton setTarget:self pressEndAction:@selector(prevPressed:)
                                  holdStartAction:@selector(prevHeldStart:)
                                    holdEndAction:@selector(prevHeldEnd:)];
        [_view addSubview:prevButton];

        playButton = [[NCDualPressButton alloc] initWithFrame:CGRectMake(160 - 24, buttonHeight, 48, 48) holdDelay:1.0];
        [playButton setImage:[UIImage imageNamed:@"MCPlay.png"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"MCPlay_p.png"] forState:UIControlStateHighlighted];
        [playButton setImage:[UIImage imageNamed:@"MCPlay_d.png"] forState:UIControlStateDisabled];
        [playButton setTarget:self pressEndAction:@selector(playPausePressed:)
                                  holdStartAction:nil
                                    holdEndAction:nil];
        [_view addSubview:playButton];

        NCDualPressButton *nextButton = [[[NCDualPressButton alloc] initWithFrame:CGRectMake(160 + 24 + 4, buttonHeight, 48, 48) holdDelay:1.0] autorelease];
        [nextButton setImage:[UIImage imageNamed:@"MCNext.png"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"MCNext_p.png"] forState:UIControlStateHighlighted];
        [nextButton setImage:[UIImage imageNamed:@"MCNext_d.png"] forState:UIControlStateDisabled];
        [nextButton setTarget:self pressEndAction:@selector(nextPressed:)
                                  holdStartAction:@selector(nextHeldStart:)
                                    holdEndAction:@selector(nextHeldEnd:)];
        [_view addSubview:nextButton];

        // Playing title
        float textPosition = [self viewHeight] - 18;
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(7,textPosition,306,15)];
        titleView.font = [UIFont boldSystemFontOfSize:12];
        titleView.textColor = [UIColor whiteColor];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.textAlignment = UITextAlignmentCenter;
        titleView.numberOfLines = 1;
        [_view addSubview:titleView];
    }

    return _view;
}

- (void)prevHeldStart: (NCDualPressButton *)button { [mediaController beginSeek:-1]; }
- (void)prevHeldEnd: (NCDualPressButton *)button { [mediaController endSeek:-1]; }
- (void)prevPressed: (NCDualPressButton *)button { [mediaController changeTrack:-1]; }
- (void)nextHeldStart: (NCDualPressButton *)button { [mediaController beginSeek:1]; }
- (void)nextHeldEnd: (NCDualPressButton *)button { [mediaController endSeek:1]; }
- (void)nextPressed: (NCDualPressButton *)button { [mediaController changeTrack:1]; }
- (void)playPausePressed: (NCDualPressButton *)button { [mediaController togglePlayPause]; };


- (id)getAppIcon:(id)appId
{
    return [(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] applicationIconForDisplayIdentifier:appId] getIconImage:2];
}

- (void)updateDisplayInfo: (id)_mediaController
{
    [iconView setImage: [self getAppIcon:[[mediaController nowPlayingApplication] displayIdentifier]]];
    [titleView setText: [mediaController nowPlayingTitle]];

    // Seems to be incorrectly named -- isPlaying returns true if paused
    if ([mediaController isPlaying])
    {
        [playButton setImage:[UIImage imageNamed:@"MCPause.png"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"MCPause_p.png"] forState:UIControlStateHighlighted];
        [playButton setImage:[UIImage imageNamed:@"MCPause_d.png"] forState:UIControlStateDisabled];
    } else {
        [playButton setImage:[UIImage imageNamed:@"MCPlay.png"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"MCPlay_p.png"] forState:UIControlStateHighlighted];
        [playButton setImage:[UIImage imageNamed:@"MCPlay_d.png"] forState:UIControlStateDisabled];
    }
}

- (void)viewDidAppear
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector: @selector(updateDisplayInfo:)
               name:@"SBMediaNowPlayingChangedNotification" 
             object:mediaController];
    [self updateDisplayInfo:nil];
}

- (void)viewDidDisappear
{
    [[NSNotificationCenter defaultCenter]
        removeObserver:self 
                  name:@"SBMediaNowPlayingChangedNotification"
                object:mediaController];
}

@end