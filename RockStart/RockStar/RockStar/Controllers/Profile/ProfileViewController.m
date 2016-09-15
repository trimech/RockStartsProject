//
//  ProfileViewController.m
//  RockStar
//
//  Created by Patrice Roux on 15/09/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    __weak IBOutlet UITextField *_fullNameTextField;
    __weak IBOutlet UIImageView *_profilePictureImage;
    UIButton *_saveButton;
    BOOL _imageIsChanged;
    UIBarButtonItem *_saveButtonItem;
    __weak IBOutlet UIButton *_takePictureButton;
    
}
- (IBAction)takePictureHandelAction:(id)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    self.view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInView)];
    [self.view addGestureRecognizer:tapInView];
    
    _profilePictureImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapInPicture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseImageAction)];
    [_profilePictureImage addGestureRecognizer:tapInPicture];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiedDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setupUI{
    
    self.title = NSLocalizedString(@"Profile_Title", nil);
    
    // enabled button if fullName is changed and image is changed
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_saveButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    _saveButton.frame = CGRectMake(0, 0, 33, 32);
    [_saveButton addTarget:self action:@selector(saveModification) forControlEvents:UIControlEventTouchUpInside];
    
    _saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_saveButton];
    self.navigationItem.rightBarButtonItem = _saveButtonItem;
    _saveButtonItem.enabled = NO;
    // set iinfo if plist contains my profile

    NSMutableDictionary *me = [PlistManager sharedInstance].contactsDictionnary[@"me"];
    if (me) {
        _fullNameTextField.text = me[@"fullName"];
        if (me[@"hisface"]) {
            _profilePictureImage.image = [UIImage imageWithData: me[@"hisface"]];
            _takePictureButton.hidden = YES;
        }
    }


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---
#pragma mark Save Methode

- (void)saveModification{
    
    // save modification to plist
    [self.view endEditing:YES];
    NSMutableDictionary *me = [NSMutableDictionary dictionaryWithDictionary:[PlistManager sharedInstance].contactsDictionnary[@"me"]];
    if (!me) {
        me = [NSMutableDictionary dictionary] ;
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if (allTrim(_fullNameTextField.text).length) {
            me[@"fullName"] = _fullNameTextField.text;
        }
        if (_imageIsChanged) {
            UIImage *resizedImage = [Utilities resizeImageWithImage:_profilePictureImage.image scaledToSize:CGSizeMake(200, 200)];
            me[@"hisface"] = UIImageJPEGRepresentation(resizedImage, 1.0);
        }
        [PlistManager sharedInstance].contactsDictionnary[@"me"] = me;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            _imageIsChanged = NO;
            _saveButtonItem.enabled = NO;

            [Utilities presentErrorAlertWithTitle:@"" andMessage:NSLocalizedString(@"Profile_Updated", nil) andButtonTitle:NSLocalizedString(@"Ok", nil) andParentView:self];
            });
    });

    
}

#pragma mark --
#pragma mark TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}
- (void)textFiedDidChange:(UITextField *)textField{
    _saveButtonItem.enabled = YES;

    
}
#pragma mark --
#pragma mark Gesture Recognizer Methods 

- (void)tapInView{
    [self.view endEditing:YES];
}
- (void)chooseImageAction{
    [self openCamera];

}
- (void) openCamera{
    
    [self.view endEditing:YES];
    
    // open Device don't support camrera to evit crash
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
            [Utilities presentErrorAlertWithTitle:@"" andMessage:NSLocalizedString(@"CAMERA_ERRROR", nil) andButtonTitle:NSLocalizedString(@"Ok", nil) andParentView:self];
        return;
    }
    // open Device Camera
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

#pragma mark --
#pragma mark ImagePicker Controller Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    // get Image from picker
    _imageIsChanged = YES;
    _takePictureButton.hidden = YES;
    if (allTrim(_fullNameTextField.text).length) {
        _saveButtonItem.enabled = YES;
    }

    _profilePictureImage.image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];

    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //dismiss picker
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark --
#pragma mark Buttons Methods
- (IBAction)takePictureHandelAction:(id)sender {
    
    [self openCamera];

}
@end
