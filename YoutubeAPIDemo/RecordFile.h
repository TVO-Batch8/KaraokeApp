//
//  RecordFile.h
//  YoutubeAPIDemo
//
//  Created by Gia An on 7/19/15.
//  Copyright (c) 2015 GIAAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecordFile : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * newname;
@property (nonatomic, retain) NSString * url;

@end
