//
//  listSongViewController.m
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/9/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import "listSongViewController.h"
#import <Parse/Parse.h>

@interface listSongViewController ()

@property (strong, nonatomic) CoredataHelper *coreDataHelper;
@end


@implementation listSongViewController
int indexOfSong;
bool isSearch=NO;
//    -----------------ActionSheet for cell click
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==0){
        
        [self performSegueWithIdentifier:@"pushToOnlySing" sender:self];
        
    }
    else if(buttonIndex==1){
        KaraokeSong *song=[self.arrSongsList objectAtIndex:indexOfSong];
        if([self checkIsFavourite:song]==true)
        {
            [self insertFavouriteSong:song.nameSong idSong:song.idSong];
        }
        else{
            UIAlertView *aleart=[[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Your song have been in favourite list! Please try with another song!",nil] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [aleart show];
        }
        
    }else if(buttonIndex==2){
        
        [self performSegueWithIdentifier:@"pushToSingAndRecord" sender:self];
        
    }else if(buttonIndex==3){
        
        [self performSegueWithIdentifier:@"pushToFavouriteList" sender:self];
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    KaraokeSong *song = [self.arrSongsList objectAtIndex:indexOfSong];
    
    if ([segue.identifier isEqualToString:@"pushToOnlySing"]){
        ViewController *nextController = segue.destinationViewController;
        nextController.idOfSong=song.idSong;
    }
    if ([segue.identifier isEqualToString:@"pushToSingAndRecord"]){
        ViewController *nextController = segue.destinationViewController;
        nextController.idOfSong=song.idSong;
    }
    if ([segue.identifier isEqualToString:@"pushToFavouriteSong"]){
        ViewController *nextController = segue.destinationViewController;
        nextController.idOfSong=song.idSong;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate=self;
    [self initData];
    [self deleteAllInCoreData];
    [self requestToServerYoutubeAPI];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    //    [self deleteAllInCoreData];
    [super viewDidAppear:animated];
    
    self.arrSongsList = [self fetchListSong];
    
    if([self.arrSongsList count]>1)
    {
        [self.tableListSong reloadData];
    }
    else
    {
        NSLog(@"No attribute for this entity!");
    }
    
    
}
-(NSArray*)fetchListSong{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //[[NSFetchRequest alloc] initWithEntityName:@"KaraokeSong" inManagedObjectContext:managedOb;jectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KaraokeSong" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    NSError *requestError=nil;
    return [managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
}
-(void)deleteAllInCoreData{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest * allSong = [[NSFetchRequest alloc] init];
    [allSong setEntity:[NSEntityDescription entityForName:@"KaraokeSong" inManagedObjectContext:context]];
    [allSong setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * songs = [context executeFetchRequest:allSong error:&error];
    //error handling goes here
    for (NSManagedObject * song in songs) {
        [context deleteObject:song];
    }
    NSError *saveError = nil;
    [context save:&saveError];
}
-(void)initData{
    self.arrSongsList =[[NSMutableArray alloc] init];
    self.request=[[NSMutableDictionary alloc]init];
    self.arrSongs=[[NSMutableArray alloc] init];
    self.Items=[[NSMutableDictionary alloc] init];
}
//--------------------------------Get JSON from youtube API playlist
-(void)requestToServerYoutubeAPI{
    NSString *stringRequest=@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=PLJLnKbQ3yimePWSbqifs43MPHUj1zn4sL&key=AIzaSyA3Nwlz6uormK9I1fab0NnqE3atMadSQLQ";
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:stringRequest ] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if(!theConnection){
        self.request =nil;
    }
    [theConnection start];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *aleart=[[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Can't connect to server %@",error] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [aleart show];
};
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    NSString *absoluteURL = [connection.currentRequest.URL absoluteString];
    
    NSMutableData *receiveData = [self.receiverDatawithURL objectForKey:absoluteURL];
    
    if(receiveData){
        [receiveData appendData:data];
    }
};
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *absoluteURL = [connection.currentRequest.URL absoluteString];
    
    NSMutableData *receiveData = [self.receiverDatawithURL objectForKey:absoluteURL];
    
    self.request = [self parseJSON:receiveData];
    
    [self.receiverDatawithURL removeObjectForKey:absoluteURL];
    
    self.arrSongs=[self.request objectForKey:@"items"];
    
    NSLog(@"%ld",self.arrSongs.count);
    for(int i=0 ;i<self.arrSongs.count;i++)
    {
        [self insertArrSongs:[[[self.arrSongs objectAtIndex:i] objectForKey:@"snippet"] objectForKey:@"title"] idSong:[[[[self.arrSongs objectAtIndex:i] objectForKey:@"snippet"] objectForKey:@"resourceId"] objectForKey:@"videoId"]];
        NSLog(@"%@ -%@",[[[self.arrSongs objectAtIndex:i] objectForKey:@"snippet"] objectForKey:@"title"],[[[[self.arrSongs objectAtIndex:i] objectForKey:@"snippet"] objectForKey:@"resourceId"] objectForKey:@"videoId"]);
    }
    self.arrSongsList = [self fetchListSong];
    [self.tableListSong reloadData];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void)insertArrSongs:(NSString*)nameSong idSong:(NSString*)idSong
{
    NSManagedObjectContext *context= [self managedObjectContext];
    KaraokeSong *song = [NSEntityDescription
                         insertNewObjectForEntityForName:@"KaraokeSong"
                         inManagedObjectContext:context];
    if (song != nil){
        song.nameSong = nameSong;
        song.idSong = idSong;
        NSError *savingError = nil;
        if ([context save:&savingError]){ NSLog(@"Successfully saved the song.");
        } else {
            NSLog(@"Failed to save the context. Error = %@", savingError);
        }
    } else {
        NSLog(@"Failed to create the new song.");
    }
}

-(void)insertFavouriteSong:(NSString*)nameSong idSong:(NSString*)idSong
{
    NSManagedObjectContext *context= [self managedObjectContext];
    Favourite *fsong = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Favourite"
                        inManagedObjectContext:context];
    if (fsong != nil){
        fsong.nameSong = nameSong;
        fsong.idSong = idSong;
        NSError *savingError = nil;
        if ([context save:&savingError]){ NSLog(@"Successfully saved the context.");
        } else {
            NSLog(@"Failed to save the context. Error = %@", savingError);
        }
    } else {
        NSLog(@"Failed to create the new favourite song.");
    }
}

- (NSDictionary*)parseJSON:(NSData*)data {
    NSError *jsonParsingError = nil;
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0 error:&jsonParsingError];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    NSString *absoluteURL = [connection.currentRequest.URL absoluteString];
    
    
    NSLog(@"Request URL");
    
    if(!self.receiverDatawithURL)
    {
        self.receiverDatawithURL = [NSMutableDictionary dictionary];
    }
    
    //create recieve data for this URL
    NSMutableData *recieveData = [NSMutableData data];
    [self.receiverDatawithURL setObject:recieveData forKey:absoluteURL];
};
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if(!isSearch)
        return self.arrSongsList.count;
    else
        return self.searchResults.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    listSongCell *cell = [self.tableListSong dequeueReusableCellWithIdentifier:@"cellID"];
    
    if(!cell)
    {
        [self.tableListSong registerNib:[UINib nibWithNibName:@"listSongCell" bundle:nil] forCellReuseIdentifier:@"cellID"];
        cell =[self.tableListSong dequeueReusableCellWithIdentifier:@"cellID"];
        
    }
    if(!isSearch)
    {
        KaraokeSong *song = [self.arrSongsList objectAtIndex:indexPath.row];
        cell.nameSong.text=song.nameSong;
    }
    else
    {
        Favourite *fsong=[self.searchResults objectAtIndex:indexPath.row];
        cell.nameSong.text=fsong.nameSong;
    }
    return cell;
}

-(BOOL)checkIsFavourite:(KaraokeSong *)song
{
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Favourite"];
    
    NSError *requestError=nil;
    
    NSArray *arrFavourite = [managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    
    for(Favourite *fsong in arrFavourite)
    {
        if([fsong.nameSong isEqualToString:song.nameSong])
            return false;
    }
    return true;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    isSearch=YES;
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"KaraokeSong" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSLog(@"%@",searchBar.text);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nameSong contains[c] %@", searchBar.text];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    
    self.searchResults = [context executeFetchRequest:fetchRequest error:&error];
    if([self.searchResults count] >0)
    {
        [self.tableListSong reloadData];
    }
    else
    {
        UIAlertView *aleart=[[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Can't find your song! Please try again!",nil] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [aleart show];
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearch=NO;
    [self.tableListSong reloadData];
    searchBar.text =@"";
    [self.view endEditing:YES];
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to do with the file?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Only sing"
                                                    otherButtonTitles:@"Add to favourite list", @"Sing and record",@"Go to Favourite List",nil];
    indexOfSong=(int)indexPath.row;
    [actionSheet showInView:self.view];
}

@end
