//
//  RSSManager.m
//  RockStar
//
//  Created by Patrice Roux on 15/09/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//

#import "RSSManager.h"

#define POST @"POST"
#define GET @"GET"
#define PUT @"PUT"


#define CONTACTS @"contacts.json"

@implementation RSSManager

#pragma mark --
#pragma mark Singleton Methode
+ (instancetype)sharedInstance{
    
    static RSSManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RSSManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark ---
#pragma mark NSURLSESSION INITIALIZATION METHODS

- (NSURLSession *)getSession{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config];
    return urlSession;
}

- (NSMutableURLRequest *)getRequestWithHttpMethod:(NSString *)httpMethod path:(NSString *)path {
    NSString *urlStr = [BASE_URL stringByAppendingString:[NSString stringWithFormat:@"/%@",path] ];
        NSURL *url = [NSURL URLWithString:urlStr];
    NSLog(@"url == %@",url.absoluteString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    
    request.HTTPMethod = httpMethod;
    
    return request;
}


-(void) performRequest:(NSString*)method path :(NSString*) path   withParams:(NSDictionary*) params  andCallback:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error)) callback{
    
    if (params && [method isEqualToString:GET]){
        NSString *appendPath = [self generatePostStringWith:params];
        if (appendPath) {
            path = [path stringByAppendingString:appendPath];
            
        }
    }
    
    
    NSMutableURLRequest *request = [self getRequestWithHttpMethod:method path:path ];
    
    
    if (params && ([method isEqualToString:POST] || [method isEqualToString:PUT])){
        NSError *error = nil;
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        [request setHTTPBody:data];
        
    }
    NSURLSession *session = [self getSession];
    NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request completionHandler:callback];
    [downloadTask resume];
}

- (NSString *)generatePostStringWith:(NSDictionary *)params{
    NSString *postString = nil;
    for (NSString *key in params) {
        NSString *object = params[key];
        if (!postString) {
            postString = [NSString stringWithFormat:@"?%@=%@",key,object];
        } else {
            postString = [postString stringByAppendingFormat:@"&%@=%@",key,object];
        }
        
    }
    NSLog(@"Post String:%@",postString);
    return postString;
}

#pragma mark --
#pragma mark WS METHODS

- (void)getContactswithComplectionBlock:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error)) complectionBlock{
    
    [self performRequest:GET path:CONTACTS withParams:nil andCallback:complectionBlock];

}

@end
