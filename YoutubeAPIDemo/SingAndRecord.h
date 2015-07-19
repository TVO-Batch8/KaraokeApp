//
//  SingAndRecord.h
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/14/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import "YTPlayerView.h"
#import "ListRecorder.h"
#import "RecordFile.h"

@interface SingAndRecord : UIViewController<AVAudioRecorderDelegate, AVAudioPlayerDelegate,YTPlayerViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) NSString *idOfSong;

- (IBAction)stopTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
@end
