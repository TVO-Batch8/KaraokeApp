//
//  ListRecorder.h
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/17/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import "listSongCell.h"
#import "RecordFile.h"

@interface ListRecorder : UIViewController<AVAudioRecorderDelegate, AVAudioPlayerDelegate,UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableListRecorder;
@property (strong, nonatomic) NSArray *arrRecord;
@end
