//
//  FavouriteSong.h
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/14/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Coredata/CoreData.h>
#import "listSongCell.h"
#import "Favourite.h"
#import "ViewController.h"
#import "SingAndRecord.h"

@interface FavouriteSong : UIViewController<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *FavouriteList;
@property (strong, nonatomic) NSArray *arrFavouriteList;
@end
