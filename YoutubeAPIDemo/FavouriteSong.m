//
//  FavouriteSong.m
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/14/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import "FavouriteSong.h"

@interface FavouriteSong ()

@end

@implementation FavouriteSong
int indexSong;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arrFavouriteList =[[NSMutableArray alloc] init];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.arrFavouriteList=[self loadFavouriteList];
    if([self.arrFavouriteList count]>1)
    {
        
        for(Favourite *fsong in self.arrFavouriteList){
            NSLog(@"%@ - %@", fsong.nameSong, fsong.idSong);
        }
        
        [self.FavouriteList reloadData];
    }
    else
    {
        NSLog(@"No attribute for this entity!");
    }
}

-(NSArray*)loadFavouriteList{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Favourite"];
    NSError *requestError=nil;
    NSArray *arr=[managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    return arr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Favourite *fsong = [self.arrFavouriteList objectAtIndex:indexSong];
    
    if ([segue.identifier isEqualToString:@"gotoSing"]){
        ViewController *nextController = segue.destinationViewController;
        nextController.idOfSong=fsong.idSong;
    }
    if ([segue.identifier isEqualToString:@"gotoSingAndRecord"]){
         SingAndRecord *nextController = segue.destinationViewController;
        nextController.idOfSong=fsong.idSong;
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
    return self.arrFavouriteList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    listSongCell *cell = [self.FavouriteList dequeueReusableCellWithIdentifier:@"cellID"];
    
    if(!cell)
    {
        [self.FavouriteList registerNib:[UINib nibWithNibName:@"listSongCell" bundle:nil] forCellReuseIdentifier:@"cellID"];
        cell =[self.FavouriteList dequeueReusableCellWithIdentifier:@"cellID"];
        
    }
    Favourite *fsong = [self.arrFavouriteList objectAtIndex:indexPath.row];
    cell.nameSong.text=fsong.nameSong;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to do with the file?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:@"Move",@"Sort by name",@"Only Sing",@"Sing and record", nil];
//    indexOfSong=indexPath.row;
    [actionSheet showInView:self.view];
    indexSong=(int)indexPath.row;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld",(long)buttonIndex);
    if(buttonIndex==0)
    {
        /* Create the fetch request first */
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                        initWithEntityName:@"Favourite"];
        NSError *requestError = nil;
        /* And execute the fetch request on the context */
        NSArray *arrFavourite =
        [self.managedObjectContext executeFetchRequest:fetchRequest
                                                 error:&requestError];
        /* Make sure we get the array */
        if ([arrFavourite count] > 0){
            /* Delete the favourite song in the array */
            Favourite *fsong = [arrFavourite objectAtIndex:indexSong];
            [self.managedObjectContext deleteObject:fsong];
            NSError *savingError = nil;
            if ([self.managedObjectContext save:&savingError]){
                UIAlertView *aleart=[[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Succes delete song"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [aleart show];
                //----------Reload data-------------
                self.arrFavouriteList =[self loadFavouriteList];
                [self.FavouriteList reloadData];
            } else {
                UIAlertView *aleart=[[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Failed to delete song in favourite list."] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [aleart show];
            }
        } else {
            UIAlertView *aleart=[[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Could not find any song in favourite list"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [aleart show];
        }
    }else if(buttonIndex==1)
    {
        
    }else if(buttonIndex==2)
    {
        /* Create the fetch request first */
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                        initWithEntityName:@"Favourite"];
        NSSortDescriptor *nameSort =
        [[NSSortDescriptor alloc] initWithKey:@"nameSong"
                                    ascending:YES];
        fetchRequest.sortDescriptors = @[nameSort];
        NSError *requestError = nil;
        [self.managedObjectContext executeFetchRequest:fetchRequest
                                                 error:&requestError];
        /* And execute the fetch request on the context */
        
        if(!requestError){
            self.arrFavouriteList =nil;
            
            NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
            self.arrFavouriteList = [[managedObjectContext executeFetchRequest:fetchRequest error:&requestError] mutableCopy];
            NSError *err;
            [self.managedObjectContext save:&err];
            if(err)
            {
                NSLog(@"%@",err);
            }
            if([self.arrFavouriteList count]>1)
            {
                [self.FavouriteList reloadData];
            }
        }
    }else if (buttonIndex==3)
    {
        [self performSegueWithIdentifier:@"gotoSing" sender:self];
    }else if (buttonIndex==4)
    {
        [self performSegueWithIdentifier:@"gotoSingAndRecord" sender:self];
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
