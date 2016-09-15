//
//  BookmarksViewController.m
//  RockStar
//
//  Created by Patrice Roux on 15/09/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//

#import "BookmarksViewController.h"
#import "ContactCell.h"

@interface BookmarksViewController (){
    
    __weak IBOutlet UITableView *_tableView;
    NSString *_emptyString;
}
@property (strong, nonatomic) NSMutableArray *contactsArray;
@property (strong, nonatomic) NSMutableDictionary *loadedImagesDictionnary;



@end

@implementation BookmarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _contactsArray = [NSMutableArray array];
    [self setupUI];
}
- (void)viewWillAppear:(BOOL)animated{
    
    // get Bookmarks from plist
    
    [self getContactsArray];
    [_tableView reloadData];
    [super viewWillAppear:animated];
    
}
- (void)getContactsArray{
    [_contactsArray removeAllObjects];
    NSDictionary *conactsFromCache = [PlistManager sharedInstance].contactsDictionnary[@"contacts"];
    [_contactsArray addObjectsFromArray:conactsFromCache.allKeys];
    if (!_contactsArray.count) {
        _emptyString = NSLocalizedString(@"Contacts_empty", nil);
    }
}

- (void)setupUI{
    self.title = NSLocalizedString(@"BookMarks_Title", nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    _emptyString = @"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --
#pragma mark TableView Delegate && Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 140.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (_contactsArray.count) ? _contactsArray.count : 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_contactsArray.count) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Empty Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = _emptyString;
        return cell;
    }
    NSDictionary *contact = [PlistManager sharedInstance].contactsDictionnary[@"contacts"][_contactsArray[indexPath.row]];
    ContactCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:nil options:nil] lastObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //////******** set RockStar properties ****////
    NSString *name = [NSString stringWithFormat:@"%@ %@",contact[@"firstname"],contact[@"lastname"]];
    cell.rockStarNameLabel.text = name;
    cell.rockStarStatusLabel.text = [NSString stringWithFormat:@"%@", contact[@"status"]];
    [cell.addToBookMarkButton setImage:[UIImage imageNamed:@"basket"] forState:UIControlStateNormal];
    [cell.addToBookMarkButton addTarget:self action:@selector(deleteBookMarkAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.addToBookMarkButton.tag = indexPath.row;
    
    //////*********** Get Image Methode ***///////
    NSData *hisFace = contact[@"hisface"];
    cell.activityIndicator.hidden = YES;
    cell.rockStarImageView.image = [UIImage imageWithData:hisFace];
    
    return cell;
    
}

- (void)deleteBookMarkAction:(UIButton *)button{

    // delete bookmark form plist and relaod data
    
    NSString *key =_contactsArray[button.tag];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: nil
                                                                             message:NSLocalizedString(@"Delete_message", nil)
                                                                      preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *validateAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                          style: UIAlertActionStyleDefault
                                                        handler: ^(UIAlertAction *action) {
                                                            [[PlistManager sharedInstance].contactsDictionnary[@"contacts"] removeObjectForKey:key];
                                                            [self getContactsArray];
                                                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                [_tableView reloadData];
                                                            });
                                                            
                                                        }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                          style: UIAlertActionStyleCancel
                                                        handler: ^(UIAlertAction *action) {
                                                            
                                                        }];
    
    [alertController addAction: validateAction];
    [alertController addAction: cancelAction];

    
    [self presentViewController: alertController animated: YES completion: nil];

}
@end
