//
//  RSSManager.h
//  RockStar
//
//  Created by Patrice Roux on 15/09/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSManager : NSObject



+ (nonnull instancetype)sharedInstance;

#pragma mark --
#pragma mark WS METHODS

- (void)getContactswithComplectionBlock:(void (^ _Nonnull )(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error)) complectionBlock;

@end
