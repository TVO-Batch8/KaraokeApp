//
//  KaraokeSong.h
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/19/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KaraokeSong : NSManagedObject

@property (nonatomic, retain) NSString * idSong;
@property (nonatomic, retain) NSString * nameSong;

@end
