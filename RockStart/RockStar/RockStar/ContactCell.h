//
//  ContactCell.h
//  RockStar
//
//  Created by Patrice Roux on 15/09/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *rockStarImageView;
@property (weak, nonatomic) IBOutlet UILabel *rockStarNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rockStarStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *addToBookMarkButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
