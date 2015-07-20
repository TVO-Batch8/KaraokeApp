//
//  listSongViewController.h
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/9/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Coredata/CoreData.h>
#import "listSongCell.h"
#import "KaraokeSong.h"
#import "CoredataHelper.h"
#import "ViewController.h"
//
@interface listSongViewController : UIViewController<UISearchBarDelegate,NSURLConnectionDataDelegate, NSURLConnectionDelegate,UITableViewDataSource,UITableViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableListSong;
@property (strong, nonatomic) NSDictionary *request;
@property (strong, nonatomic) NSMutableArray *arrSongs;
@property (strong, nonatomic) NSArray *arrSongsList;
@property (strong, nonatomic) NSMutableDictionary *Items;
@property (strong, nonatomic) NSArray* searchResults;
@property (strong, nonatomic) NSMutableDictionary *receiverDatawithURL;//save recvieve data follow request URL String
@end
