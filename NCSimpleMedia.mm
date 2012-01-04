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
    NCDualPressButton *nextButton;
    NCDualPressButton *prevButton;
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
    [_view release];
    [super dealloc];
}

- (UIView *)view 
{
    if (_view == nil)
    {
        mediaController = [objc_getClass("SBMediaController") sharedInstance];

        // [mediaController changeTrack:+/-1]; selects next/prev track
        _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [self viewHeight])];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // Application icon
        iconView = [[UIImageView alloc] initWithFrame: CGRectMake(10,4,57,57)];
        [_view addSubview:iconView];

        // Buttons
        prevButton = [[NCDualPressButton alloc] initWithFrame:CGRectMake(160 - 24 - 48 - 4, 10, 48, 48) holdDelay:1.0];
        [prevButton setImage:[UIImage imageNamed:@"MCPrev.png"] forState:UIControlStateNormal];
        [prevButton setImage:[UIImage imageNamed:@"MCPrev_p.png"] forState:UIControlStateHighlighted];
        [prevButton setImage:[UIImage imageNamed:@"MCPrev_d.png"] forState:UIControlStateDisabled];
        [prevButton setTarget:self pressEndAction:@selector(prevPressed:)
                                  holdStartAction:@selector(prevHeldStart:)
                                    holdEndAction:@selector(prevHeldEnd:)];
        [_view addSubview:prevButton];

        playButton = [[NCDualPressButton alloc] initWithFrame:CGRectMake(160 - 24, 10, 48, 48) holdDelay:1.0];
        [playButton setImage:[UIImage imageNamed:@"MCPlay.png"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"MCPlay_p.png"] forState:UIControlStateHighlighted];
        [playButton setImage:[UIImage imageNamed:@"MCPlay_d.png"] forState:UIControlStateDisabled];
        [playButton setTarget:self pressEndAction:@selector(playPausePressed:)
                                  holdStartAction:@selector(playPauseHeld:)
                                    holdEndAction:@selector(playPauseHeld:)];
        [_view addSubview:playButton];

        nextButton = [[NCDualPressButton alloc] initWithFrame:CGRectMake(160 + 24 + 4, 10, 48, 48) holdDelay:1.0];
        [nextButton setImage:[UIImage imageNamed:@"MCNext.png"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"MCNext_p.png"] forState:UIControlStateHighlighted];
        [nextButton setImage:[UIImage imageNamed:@"MCNext_d.png"] forState:UIControlStateDisabled];
        [nextButton setTarget:self pressEndAction:@selector(nextPressed:)
                                  holdStartAction:@selector(nextHeldStart:)
                                    holdEndAction:@selector(nextHeldEnd:)];
        [_view addSubview:nextButton];

        // Playing title
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0,65,320,15)];
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
- (void)playPauseHeld: (UIGestureRecognizer *)recognizer {}
- (void)playPausePressed: (UIGestureRecognizer *)recognizer
{
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
    [mediaController togglePlayPause];
}

- (id)getAppIcon:(id)appId
{
    return [(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] applicationIconForDisplayIdentifier:appId] getIconImage:2];
}

- (void)updateDisplayInfo
{
    [iconView setImage: [self getAppIcon:[[mediaController nowPlayingApplication] displayIdentifier]]];
    [titleView setText: [mediaController nowPlayingTitle]];
}

- (void)viewDidAppear
{
    [self updateDisplayInfo];
}

- (float)viewHeight
{
    return 80;
}

@end