//
//  ViewController.h
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/1/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YTPlayerView.h"
@interface ViewController : UIViewController<AVAudioRecorderDelegate, AVAudioPlayerDelegate,YTPlayerViewDelegate>
@property (strong, nonatomic) NSString *idOfSong;

@end

