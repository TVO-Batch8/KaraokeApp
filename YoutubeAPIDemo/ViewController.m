//
//  ViewController.m
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/1/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface ViewController (){
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}
    // --------------------CREATE YOUTUBE PLAYER------------------------
@property (strong, nonatomic) IBOutlet YTPlayerView *youtubePlayer;
@property (weak, nonatomic) IBOutlet YTPlayerView *viewPlayer;

@end

@implementation ViewController

- (IBAction)playVideo:(id)sender {
    [self.viewPlayer playVideo];
}

- (IBAction)stopVideo:(id)sender {
    [self.viewPlayer stopVideo];
}
- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStatePlaying:
        {
            NSLog(@"Started playback");
        }
            break;
        case kYTPlayerStatePaused:
        {
            NSLog(@"Paused playback");
        }
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewPlayer.delegate = self;
//    [self.viewPlayer loadWithVideoId:@"emfGE2hy51Q"];
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 };
//    self.idOfSong=@"PgVwzSAMnrI";
    NSLog(@"%@",self.idOfSong);
    [self.viewPlayer loadWithVideoId:[NSString stringWithFormat:@"%@",self.idOfSong] playerVars:playerVars];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
