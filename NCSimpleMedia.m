#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "BBWeeAppController-Protocol.h"
#import "SBMediaController.h"
#import "SBApplication.h"
#import "SBIconModel.h"
#import "SBIcon.h"

#import "NCDualPressButton.h"

@interface SimpleMediaController : NSObject <BBWeeAppController>
{
    UIView *mainView;
    SBMediaController *mediaController;
    UIImageView *iconView;
    UILabel *titleView;
    NCDualPressButton *prevButton;
    NCDualPressButton *playButton;
    NCDualPressButton *nextButton;
}

+ (void)initialize;
- (UIView *)view;
- (float)viewHeight;
- (void)viewDidAppear;
- (void)viewDidDisappear;
- (id)getAppIcon:(id)appId;
- (void)updateDisplayInfo:(id)mediaController;

@end

@implementation SimpleMediaController

+ (void)initialize {}
- (float)viewHeight { return 90; }
- (UIView *)view 
{
    if (mainView == nil)
    {
        mediaController = [objc_getClass("SBMediaController") sharedInstance];
        CGRect mainFrame = [[UIScreen mainScreen] applicationFrame];
        mainFrame.size.height = [self viewHeight];

        mainView = [[UIView alloc] initWithFrame:mainFrame];
        mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        // Shaded background
        {
            UIImage *bg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleMedia.bundle/WeeAppBackground.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
            UIImageView *bgView = [[UIImageView alloc] initWithImage:bg];
            bgView.frame = CGRectMake(2, 0, mainFrame.size.width - 4, mainFrame.size.height);
            bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            [mainView addSubview:bgView];
            [bgView release];
        }

        // Media Application icon
        {
            float iconSize = 57;
            float iconMargin = ([self viewHeight] - iconSize)/2;
            iconView = [[UIImageView alloc] initWithFrame: CGRectMake(iconMargin,iconMargin,iconSize,iconSize)];
            iconView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;

            [mainView addSubview:iconView];
        }

        // Central buttons
        {
            float buttonHeight = ([self viewHeight] - 48)/2;

            // Previous track / Seek backwards button
            prevButton = [[NCDualPressButton alloc] initWithFrame:CGRectMake(160 - 24 - 48 - 4, buttonHeight, 48, 48) holdDelay:1.0];
            [prevButton setImage:[UIImage imageNamed:@"MCPrev.png"] forState:UIControlStateNormal];
            [prevButton setImage:[UIImage imageNamed:@"MCPrev_p.png"] forState:UIControlStateHighlighted];
            [prevButton setImage:[UIImage imageNamed:@"MCPrev_d.png"] forState:UIControlStateDisabled];
            [prevButton setTarget:self pressEndAction:@selector(prevPressed:)
                                      holdStartAction:@selector(prevHeldStart:)
                                        holdEndAction:@selector(prevHeldEnd:)];
            prevButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [mainView addSubview:prevButton];

            // Play / Pause button
            playButton = [[NCDualPressButton alloc] initWithFrame:CGRectMake(160 - 24, buttonHeight, 48, 48) holdDelay:1.0];
            [playButton setImage:[UIImage imageNamed:@"MCPlay.png"] forState:UIControlStateNormal];
            [playButton setImage:[UIImage imageNamed:@"MCPlay_p.png"] forState:UIControlStateHighlighted];
            [playButton setImage:[UIImage imageNamed:@"MCPlay_d.png"] forState:UIControlStateDisabled];
            [playButton setTarget:self pressEndAction:@selector(playPausePressed:)
                                      holdStartAction:nil
                                        holdEndAction:nil];
            playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [mainView addSubview:playButton];

            // Next track / Seek forwards button
            nextButton = [[NCDualPressButton alloc] initWithFrame:CGRectMake(160 + 24 + 4, buttonHeight, 48, 48) holdDelay:1.0];
            [nextButton setImage:[UIImage imageNamed:@"MCNext.png"] forState:UIControlStateNormal];
            [nextButton setImage:[UIImage imageNamed:@"MCNext_p.png"] forState:UIControlStateHighlighted];
            [nextButton setImage:[UIImage imageNamed:@"MCNext_d.png"] forState:UIControlStateDisabled];
            [nextButton setTarget:self pressEndAction:@selector(nextPressed:)
                                      holdStartAction:@selector(nextHeldStart:)
                                        holdEndAction:@selector(nextHeldEnd:)];
            nextButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [mainView addSubview:nextButton];
        }

        // Track title
        {
            float textPosition = [self viewHeight] - 18;
            titleView = [[UILabel alloc] initWithFrame:CGRectMake(7,textPosition,306,15)];
            titleView.font = [UIFont boldSystemFontOfSize:12];
            titleView.textColor = [UIColor whiteColor];
            titleView.backgroundColor = [UIColor clearColor];
            titleView.textAlignment = UITextAlignmentCenter;
            titleView.numberOfLines = 1;
            titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [mainView addSubview:titleView];
        }
    }
    return mainView;
}

- (void)dealloc
{
    [mainView release];
    [iconView release];
    [titleView release];
    [prevButton release];
    [playButton release];
    [nextButton release];
    [super dealloc];
}

- (id)getAppIcon:(id)appId
{
    return [(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] applicationIconForDisplayIdentifier:appId] getIconImage:2];
}

- (void)updateDisplayInfo:(id)_mediaController
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

    [prevButton setEnabled:![mediaController isFirstTrack]];
    [playButton setEnabled:[mediaController hasTrack]];
    [nextButton setEnabled:![mediaController isLastTrack]];
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

- (void)prevHeldStart:(NCDualPressButton *)button { [mediaController beginSeek:-1]; }
- (void)prevHeldEnd:(NCDualPressButton *)button { [mediaController endSeek:-1]; }
- (void)prevPressed:(NCDualPressButton *)button { [mediaController changeTrack:-1]; }
- (void)nextHeldStart:(NCDualPressButton *)button { [mediaController beginSeek:1]; }
- (void)nextHeldEnd:(NCDualPressButton *)button { [mediaController endSeek:1]; }
- (void)nextPressed:(NCDualPressButton *)button { [mediaController changeTrack:1]; }
- (void)playPausePressed:(NCDualPressButton *)button { [mediaController togglePlayPause]; };

@end