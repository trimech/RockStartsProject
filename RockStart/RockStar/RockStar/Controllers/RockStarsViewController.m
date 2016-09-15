//
//  RockStarsViewController.m
//  RockStar
//
//  Created by Patrice Roux on 15/09/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//

#import "RockStarsViewController.h"
#import "ContactCell.h"

@interface RockStarsViewController (){
    
    __weak IBOutlet UISearchBar *_searchBar;
    __weak IBOutlet UITableView *_tableView;
    NSString *_emptyString;
}

@property (strong, nonatomic) NSMutableArray *dataSourcesArray;
@property (strong, nonatomic) NSMutableArray *contactsArray;
@property (nonatomic) Reachability *internetReachability;

@property (strong, nonatomic) NSMutableDictionary *loadedImagesDictionnary;
@property (strong, nonatomic) UIRefreshControl *refreshControl ;

@end

@implementation RockStarsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ///init variables
    _loadedImagesDictionnary = [NSMutableDictionary dictionary];
    _contactsArray = [NSMutableArray array];
    _dataSourcesArray = [NSMutableArray array];
    
    [self setupUI];
    [self getContactsWithBoolIsNotFromRefrsh:YES];
    
}
- (void)viewWillAppear:(BOOL)animated{
    // reload to check if user delete contact from bookmarks view
    [_tableView reloadData];
    [super viewWillAppear:animated];
}


#pragma mark ---
#pragma mark GetContacts

- (void)getContactsWithBoolIsNotFromRefrsh:(BOOL) isNotFromRefresh{
    
    _searchBar.showsCancelButton = NO;
    [_searchBar resignFirstResponder];
    
    // Connectivity Test
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    if (self.internetReachability.currentReachabilityStatus == NotReachable) {
        [Utilities presentErrorAlertWithTitle:NSLocalizedString(@"Connection_Error_Title", nil) andMessage:NSLocalizedString(@"Connection_Error_Message", nil) andButtonTitle:NSLocalizedString(@"Ok", nil) andParentView:self];
        return;
    }
    
    if (isNotFromRefresh) {
        [SVProgressHUD show];
    }
    /// get contacts from WS and Reinti all array
    [_contactsArray removeAllObjects];
    [_dataSourcesArray removeAllObjects];
    [[RSSManager sharedInstance] getContactswithComplectionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (data) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"json == %@", json);
                if ([json isKindOfClass:[NSDictionary class]]) {
                    [_contactsArray addObjectsFromArray:json[@"contacts"]];
                    [_dataSourcesArray addObjectsFromArray:_contactsArray];
                };
                if (!_contactsArray.count) {
                    _emptyString = NSLocalizedString(@"Contacts_empty", nil);
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Utilities presentErrorAlertWithTitle:nil andMessage:NSLocalizedString(@"Server_Connection_error", nil) andButtonTitle:NSLocalizedString(@"Ok", nil) andParentView:self];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isNotFromRefresh) {
                [SVProgressHUD dismiss];
                
            } else {
                [_refreshControl endRefreshing];
            }
            
        });
    }];
    
}

#pragma mark --
#pragma mark SetupUI

- (void)setupUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    //Refresh Control to Refresh tableView
    if (self.tabBarController.selectedIndex == 0) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(getContactsWithBoolIsNotFromRefrsh:) forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:_refreshControl];
    }
    
    _emptyString = @"";
    self.title = NSLocalizedString(@"RockStar_Title", nil);
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
    return (_dataSourcesArray.count) ? _dataSourcesArray.count : 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_dataSourcesArray.count) {
        // if the contacts is empty
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Empty Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = _emptyString;
        return cell;
    }
    NSDictionary *contact = _dataSourcesArray[indexPath.row];
    ContactCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:nil options:nil] lastObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //////******** set RockStar properties ****////
    NSString *name = [NSString stringWithFormat:@"%@ %@",contact[@"firstname"],contact[@"lastname"]];
    cell.rockStarNameLabel.text = name;
    cell.rockStarStatusLabel.text = [NSString stringWithFormat:@"%@", contact[@"status"]];
    [cell.addToBookMarkButton addTarget:self action:@selector(addBookmarkHandelAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.addToBookMarkButton.tag = indexPath.row;
    ///set button state if dict contains the object
    cell.addToBookMarkButton.selected = ([PlistManager sharedInstance].contactsDictionnary[@"contacts"][name]) ? 1 :0;
    //////*********** Get Image Methode ***///////
    NSString *hisFace = contact[@"hisface"];
    NSLog(@"hisFace class == %@", [hisFace class]);
    
    if (! _loadedImagesDictionnary[hisFace] ){
        // downlaod the picture

        cell.activityIndicator.hidden = NO;
        [cell.activityIndicator startAnimating];
        NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
                                                       downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",BASE_URL,hisFace]] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                           
                                                           UIImage *downloadedImage = [UIImage imageWithData:
                                                                                       [NSData dataWithContentsOfURL:location]];
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               cell.rockStarImageView.image = downloadedImage;
                                                               _loadedImagesDictionnary[hisFace]  = cell.rockStarImageView.image;
                                                               cell.activityIndicator.hidden = YES;
                                                               [cell.activityIndicator stopAnimating];
                                                               
                                                           });
                                                           
                                                       }];
        
        [downloadPhotoTask resume];
    } else {
        cell.rockStarImageView.image =  _loadedImagesDictionnary[hisFace];
        cell.activityIndicator.hidden = YES;
        [cell.activityIndicator stopAnimating];
    }
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [_searchBar resignFirstResponder];
}

#pragma mark ---
#pragma mark addBookmarkHandelAction
- (void)addBookmarkHandelAction:(UIButton *)button{
    
    // whe have too Object in plist Contacts to Bookmars and me to my Profile
    NSMutableDictionary *contact = [NSMutableDictionary dictionaryWithDictionary:_dataSourcesArray[button.tag]];
    button.selected = !button.selected;
    NSString *key = [NSString stringWithFormat:@"%@ %@",contact[@"firstname"],contact[@"lastname"]];
    
    NSMutableDictionary *contacts = [PlistManager sharedInstance].contactsDictionnary[@"contacts"];
    if (!contacts) {
        contacts = [NSMutableDictionary dictionary];
    }
    
    if (contacts[key]) {
        // delete from bookmarks
        [contacts removeObjectForKey:key];
        [PlistManager sharedInstance].contactsDictionnary[@"contacts"] = contacts;
        
    } else {
        [SVProgressHUD show];
        // add to bookmarks
        ///***** I used the GDC because the methodhe data With url block the application, and with it we will have asynchrounous medthod ***////
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",BASE_URL,contact[@"hisface"]]]];
            contact[@"hisface"] = data;
            contacts[key] = contact;
            [PlistManager sharedInstance].contactsDictionnary[@"contacts"] = contacts;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [SVProgressHUD dismiss];
            });
        });
        
    }
}


#pragma mark --
#pragma mark SearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // predicate to search with first Name and last name
    _searchBar.showsCancelButton = YES;
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"firstname CONTAINS[c] %@ OR lastname CONTAINS[c] %@", searchText,searchText];
    NSMutableArray *filteredArray =[NSMutableArray arrayWithArray:[_contactsArray filteredArrayUsingPredicate:searchPredicate]];
    NSLog(@"filteredArray == %@",filteredArray);
    [self setDataSourceArrayWithArray:filteredArray];
    
    
}
// reinit the tableView Data Source array
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self setDataSourceArrayWithArray:_contactsArray];
    _searchBar.showsCancelButton = NO;
    _searchBar.text = @"";
    [self.view endEditing:YES];
    
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}


// methode to set tableView DataSource Array

- (void)setDataSourceArrayWithArray:(NSMutableArray *)array{
    
    [_dataSourcesArray removeAllObjects];
    [_dataSourcesArray addObjectsFromArray:array];
    if (!_dataSourcesArray.count) {
        _emptyString = NSLocalizedString(@"Contacts_empty", nil);
    }
    [_tableView reloadData];
}
@end
