//
//  Utilities.h
//  ClubBio
//
//  Created by manel hachicha on 12/05/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utilities : NSObject

+ (void)presentErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message andButtonTitle:(NSString *)buttonTitle andParentView:(UIViewController *)controller;
+ (UIImage *)resizeImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
