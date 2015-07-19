//
//  ListRecorder.m
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/17/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import "ListRecorder.h"

@interface ListRecorder ()
{
    AVAudioPlayer *player;
}
@end

@implementation ListRecorder
int indexFile;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arrRecord= [self loadListRecord];
    [self readAllDocumentContent];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// Read all text content file in folder


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
-(NSArray*)loadListRecord{
    NSManagedObjectContext *managedObjectContext= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RecordFile"];
    NSError *requestError=nil;
    NSArray *listRecord = [managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    return listRecord;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld",(long)buttonIndex);
    if(buttonIndex==0)
    {
        [self removeInCoreData];
    }
    if(buttonIndex==1)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                        initWithEntityName:@"RecordFile"];
        NSError *requestError = nil;
        
        /* And execute the fetch request on the context */
        
        NSArray *listRecord =
        [self.managedObjectContext executeFetchRequest:fetchRequest
                                                 error:&requestError];
        RecordFile *rfile = [listRecord objectAtIndex:indexFile];
        NSURL *url =[NSURL URLWithString:rfile.url];
        @try {
            
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
            [player setDelegate:self];
            [player play];
        }
        @catch (NSException *exception) {
            NSLog(@"Can't play this record file!");
        }
    }
    if(buttonIndex==2)
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Rename your file name"
                                  message:@"Please enter your new file name:"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Ok", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        /* Display a numerical keypad for this text field */
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypeDefault;
    }
}
#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.arrRecord.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    listSongCell *cell = [self.tableListRecorder dequeueReusableCellWithIdentifier:@"cellID"];
    
    if(!cell)
    {
        [self.tableListRecorder registerNib:[UINib nibWithNibName:@"listSongCell" bundle:nil] forCellReuseIdentifier:@"cellID"];
        cell =[self.tableListRecorder dequeueReusableCellWithIdentifier:@"cellID"];
        
    }
    RecordFile *rfile = [self.arrRecord objectAtIndex:indexPath.row];
    cell.nameSong.text=rfile.fileName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to do with the file?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Remove"
                                                    otherButtonTitles:@"Listen",@"Rename", nil];
    //    indexOfSong=indexPath.row;
    [actionSheet showInView:self.view];
    indexFile=(int)indexPath.row;
}


-(void)removeInCoreData{
    /* Create the fetch request first */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:@"RecordFile"];
    NSError *requestError = nil;
    /* And execute the fetch request on the context */
    NSArray *listRecord =
    [self.managedObjectContext executeFetchRequest:fetchRequest
                                             error:&requestError];
    /* Make sure we get the array */
    if ([listRecord count] > 0){
        /* Delete the favourite song in the array */
        RecordFile *rfile = [listRecord objectAtIndex:indexFile];
        [self.managedObjectContext deleteObject:rfile];
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError])
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            BOOL success=[fileManager removeItemAtPath:rfile.url error:&error];
            if(success){
                UIAlertView *aleart=[[UIAlertView alloc]initWithTitle:@"Sucess" message:[NSString stringWithFormat:@"Succes delete record file"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [aleart show];
                
                //----------Reload data-------------
                self.arrRecord =[self loadListRecord];
                [self.tableListRecorder reloadData];
            }
            else{
                NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
            }
        }
        else
        {
            UIAlertView *aleart=[[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Failed to delete record file."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [aleart show];
        }
        
    }
    else{
        UIAlertView *aleart=[[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Failed to load entity Record File."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [aleart show];
    }
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

// Read all text content file in folder
- (void)readAllDocumentContent
{
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentPath = [documentPaths lastObject];
    
    [self loopSearchContentInDirectory:documentPath];
}

// Loop to search content
- (void)loopSearchContentInDirectory:(NSString*)directoryPath
{
    for(NSString *folderName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil])
    {
        
        NSLog(@"folder name: %@", folderName);
        
        //Check folder or file
        NSString *folderPath = [directoryPath stringByAppendingPathComponent:folderName];
        
        [self readContentFromPath:folderPath];
        
    }
}

//Check & load content of folder || file
- (void)readContentFromPath:(NSString*)filePath
{
    BOOL isFOlder = NO;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isFOlder])
    {
        if(isFOlder)
        {
            [self loopSearchContentInDirectory:filePath];
        }
        else
        {
            //read file content
            [self readFileInfoWithPath:filePath];
        }
    }
}

// Read file info with path
- (void)readFileInfoWithPath:(NSString*)filePath
{
    NSString *fileName = [filePath lastPathComponent];
    
    // Read informations of file
    
    // Check type of file.
    if([fileName containsString:@".m4a"])
    {
        //read string data
        NSError *error = nil;
        
        NSString *textContent = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:&error];
        
        if(textContent && !error)
        {
            NSLog(@"Content of file name [%@] is \n %@", fileName, textContent);
        }
    }
    else
    {
        //the other way to access file data. Read more from apple
        //https://developer.apple.com/library/prerelease/ios/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/AccessingFilesandDirectories/AccessingFilesandDirectories.html#//apple_ref/doc/uid/TP40010672-CH3-SW1
    }
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
