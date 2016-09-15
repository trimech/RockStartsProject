//
//  Utilities.m
//  ClubBio
//
//  Created by manel hachicha on 12/05/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities


+ (void)presentErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message andButtonTitle:(NSString *)buttonTitle andParentView:(UIViewController *)controller{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: title
                                                                        message:message
                                                                 preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle: buttonTitle
                                                          style: UIAlertActionStyleDefault
                                                        handler: ^(UIAlertAction *action) {
                                                        }];
    
    [alertController addAction: alertAction];
    
    [controller presentViewController: alertController animated: YES completion: nil];
}

+ (UIImage *)resizeImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
