//
//  SingAndRecord.m
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/14/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import "SingAndRecord.h"

@interface SingAndRecord (){
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}
// --------------------CREATE YOUTUBE PLAYER------------------------
@property (strong, nonatomic) IBOutlet YTPlayerView *youtubePlayer;
@property (weak, nonatomic) IBOutlet YTPlayerView *viewPlayer;


@end

@implementation SingAndRecord
@synthesize stopButton, playButton, recordPauseButton;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.viewPlayer.delegate = self;
    //    [self.viewPlayer loadWithVideoId:@"emfGE2hy51Q"];
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 };
    //    self.idOfSong=@"PgVwzSAMnrI";
    NSLog(@"%@",self.idOfSong);
    [self.viewPlayer loadWithVideoId:[NSString stringWithFormat:@"%@",self.idOfSong] playerVars:playerVars];
    
    // count the record in the core data
    int countName=[self countRecord];
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [NSString stringWithFormat:@"myRecord%d.m4a",countName],
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}
-(int)countRecord{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RecordFile"];
    NSError *requestError=nil;
    NSArray *arrRecord = [managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    if([arrRecord count]>0)
        return (int)[arrRecord count];
    return 0;
}

-(bool)checkName:(NSString *)fileName{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RecordFile"];
    NSError *requestError=nil;
    NSArray *arrRecord = [managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    for(RecordFile *rfile in arrRecord)
    {
        if([fileName isEqualToString:rfile.fileName])
            return false;
    }
    return true;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStatePlaying:
        {
            NSLog(@"Started playback");
            [self recordPauseTapped];
        }
            break;
        case kYTPlayerStatePaused:
        {
            NSLog(@"Paused playback");
            [recorder pause];
        }
            break;
        default:
            break;
    }
}

- (void)recordPauseTapped {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        
        NSLog(@"Play recoder");
        
    }
    
}
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
- (IBAction)play:(id)sender {
    
}
-(void)addNewRecordFile:(NSString *)fileName url:(NSString *)url newname:(NSString *)newname
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    RecordFile *rfile = [NSEntityDescription
                         insertNewObjectForEntityForName:@"RecordFile"
                         inManagedObjectContext:managedObjectContext];
    if (rfile != nil){
        rfile.fileName = fileName;
        rfile.url  = url;
        rfile.newname=newname;
        NSError *savingError = nil;
        if ([managedObjectContext save:&savingError])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                            message: @"Sucess to save the record!"
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                            message: [NSString stringWithFormat:@"Fail to save the record! ERROR : %@",savingError]
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else {
        NSLog(@"Failed to create the new record.");
    }
}
- (IBAction)stopTapped:(id)sender {
    [recorder stop];
    
    NSString *urlString = [recorder.url absoluteString];
    [self addNewRecordFile:[NSString stringWithFormat:@"%@",[recorder.url lastPathComponent]] url:urlString newname:@""];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
 
    UIAlertView *aleart=[[UIAlertView alloc]initWithTitle:@"FINISH" message:[NSString stringWithFormat:@"Stop recoding and finish record! %@", recorder.url] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    [aleart show];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoListRecord"]){
        ListRecorder *nextController = segue.destinationViewController;
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [stopButton setEnabled:NO];
    [playButton setEnabled:YES];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
