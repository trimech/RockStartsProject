//
//  PlistManager.m
//  RockStar
//
//  Created by Patrice Roux on 15/09/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//



//******* j'ai utilisé le plist comme DB car les données sont légères et non pas lourds si on a le cas ou on peut utilisé Core Data, Le sauvgarde de données sera fait une seule fois lorsque l'app entre en mode background ou quand on quitte l’app. **////


static NSString *const cacheFileName	=	@"Contacts.plist";


#import "PlistManager.h"

@interface PlistManager ()

@property (strong, nonatomic) NSString *cachePath;

@end

@implementation PlistManager

#pragma mark --
#pragma mark Singleton Methode
+ (instancetype)sharedInstance{
    
    static PlistManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PlistManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark ---
#pragma mark Plist Methods
- (NSString *)cachePath
{
    if (!_cachePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                             NSUserDomainMask,
                                                             YES);
        
        if (!paths || [paths count] == 0) {
            return nil;
        }
        
        _cachePath = [paths objectAtIndex:0];
        
        if (_cachePath) {
            _cachePath = [_cachePath stringByAppendingPathComponent:cacheFileName];
        }
    }
    NSLog(@"cachePath %@",_cachePath);
    return _cachePath;
}

- (void)saveToCache {
    
    NSString *path = [self cachePath];
    
    if (!_contactsDictionnary) {
        return;
    }
    
    [_contactsDictionnary writeToFile:path atomically:YES];
    
}

-(NSMutableDictionary *)loadContatcsFromCache{
    NSString *path = [self cachePath];
    
    NSMutableDictionary * result = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    return result;
}

@end
