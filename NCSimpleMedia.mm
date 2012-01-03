#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"
#import <objc/runtime.h>
#import "SBMediaController.h"
#import "SBApplication.h"
#import "SBIconModel.h"
#import "SBIcon.h"


@interface SimpleMediaController : NSObject <BBWeeAppController>
{
    UIView *_view;
    SBMediaController *mediaController;
    UIImageView *iconView;
    UILabel *titleView;
    
    UIButton *playButton;
    UIButton *nextButton;
    UIButton *prevButton;
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
        prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [prevButton setFrame:CGRectMake(160 - 24 - 48 - 4, 10, 48, 48)];
        [prevButton setImage:[UIImage imageNamed:@"MCPrev.png"] forState:UIControlStateNormal];
        [prevButton setImage:[UIImage imageNamed:@"MCPrev_p.png"] forState:UIControlStateHighlighted];
        [prevButton setImage:[UIImage imageNamed:@"MCPrev_d.png"] forState:UIControlStateDisabled];
        [prevButton addTarget:self action:@selector(prevPushed:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:prevButton];

        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setFrame:CGRectMake(160 - 24, 10, 48, 48)];
        [playButton setImage:[UIImage imageNamed:@"MCPlay.png"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"MCPlay_p.png"] forState:UIControlStateHighlighted];
        [playButton setImage:[UIImage imageNamed:@"MCPlay_d.png"] forState:UIControlStateDisabled];
        [playButton addTarget:self action:@selector(playPausePushed:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:playButton];

        nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextButton setFrame:CGRectMake(160 + 24 + 4, 10, 48, 48)];
        [nextButton setImage:[UIImage imageNamed:@"MCNext.png"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"MCNext_p.png"] forState:UIControlStateHighlighted];
        [nextButton setImage:[UIImage imageNamed:@"MCNext_d.png"] forState:UIControlStateDisabled];
        [nextButton addTarget:self action:@selector(nextPushed:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:nextButton];

        // Playing title
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0,65,320,10)];
        titleView.font = [UIFont boldSystemFontOfSize:12];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.textColor = [UIColor whiteColor];
        titleView.textAlignment = UITextAlignmentCenter;
        titleView.numberOfLines = 1;
        [_view addSubview:titleView];
    }

    return _view;
}

- (void)playPausePushed: (id)sender
{
    [mediaController togglePlayPause];
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

- (void)prevPushed: (id)sender
{
    [mediaController changeTrack:-1];
}

- (void)nextPushed: (id)sender
{
    [mediaController changeTrack:1];
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