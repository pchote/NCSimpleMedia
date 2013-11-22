/*
* Copyright (c) 2012, Paul Chote
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
* list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright notice,
* this list of conditions and the following disclaimer in the documentation
* and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "BBWeeAppController-Protocol.h"
#import "SBMediaController.h"
#import "SBApplication.h"
#import "SBIconModel.h"
#import "SBIcon.h"
#import "SBUIController.h"
#import "SBBulletinListController.h"

#import "NCDualPressButton.h"

@interface SimpleMediaController : NSObject <BBWeeAppController>
{
    UIView *mainView;
    SBMediaController *mediaController;
    SBIcon *activeAppIcon;
    NCDualPressButton *iconButton;
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
            CGRect iconFrame = CGRectMake(iconMargin,iconMargin,iconSize,iconSize);
            iconButton = [[NCDualPressButton alloc] initWithFrame: iconFrame holdDelay:1.0];
            [iconButton setTarget:self pressEndAction:@selector(appIconPressed:)
                                      holdStartAction:nil
                                        holdEndAction:nil];
            [mainView addSubview:iconButton];
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
    [iconButton release];
    [titleView release];
    [prevButton release];
    [playButton release];
    [nextButton release];
    [super dealloc];
}

- (SBIcon *)activeMediaApp
{
    id appId = [[mediaController nowPlayingApplication] displayIdentifier];
    if (appId == nil)
        appId = @"com.apple.mobileipod";
    return [[objc_getClass("SBIconModel") sharedInstance] applicationIconForDisplayIdentifier:appId];
}

- (void)updateDisplayInfo:(id)_mediaController
{
    activeAppIcon = [self activeMediaApp];
    // TODO: Work out what image frame we want to use in different situations
    [iconButton setImage:[activeAppIcon getIconImage:2] forState:UIControlStateNormal];
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
- (void)playPausePressed:(NCDualPressButton *)button { [mediaController togglePlayPause]; }
- (void)appIconPressed:(NCDualPressButton *)button
{
    [(SBUIController*)[objc_getClass("SBUIController") sharedInstance] activateApplicationFromSwitcher:[activeAppIcon application]];
    // The dropdown doesn't dismiss if the app was already open, so explicitly close it
    [[objc_getClass("SBBulletinListController") sharedInstance] hideListViewAnimated:YES];
}
@end