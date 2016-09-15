//
//  PlistManager.h
//  RockStar
//
//  Created by Patrice Roux on 15/09/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistManager : NSObject

@property (strong, nonatomic) NSMutableDictionary *contactsDictionnary;

+ (instancetype)sharedInstance;
- (void)saveToCache;
- (NSMutableDictionary *)loadContatcsFromCache;


@end
