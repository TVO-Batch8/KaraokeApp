//
//  CoredataHelper.h
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/8/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "KaraokeSong.h"
#import "Favourite.h"

@class KaraokeSong;
@class Favourite;

@interface CoredataHelper : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

- (NSArray*)fetchSong;

- (NSArray*)fetchFavourite;

- (BOOL)deleteSongInFavourite:(Favourite*)object;

- (KaraokeSong*)queryKaraokeWithName:(NSString*)nameSong;

- (void)saveContext;

@end
