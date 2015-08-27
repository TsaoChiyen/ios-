//
//  ApplyShopViewController.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/7.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "ApplyShopViewController.h"
#import "TextInput.h"
#import "MapViewController.h"
#import "ImageTouchView.h"
#import "ImageViewController.h"
#import "UIImage+Resize.h"
#import "UIImage+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "CameraActionSheet.h"
#import "HelpViewController.h"
#import "Area.h"

@interface ApplyShopViewController ()<MapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraActionSheetDelegate, ImageTouchViewDelegate, UITextFieldDelegate, UITextViewDelegate> {
    IBOutlet KTextField * nameLabel;
    IBOutlet KTextField * addressLabel;
    IBOutlet KTextField * personLabel;
    IBOutlet KTextField * phoneLabel;
    IBOutlet KTextView  * noticeView;
    IBOutlet UIButton   * button;
    IBOutlet UIScrollView *scrollView;
    IBOutlet KTextField *labelContactAdress;
    IBOutlet KTextField *labelAccountBank;
    IBOutlet KTextField *labelAccountName;
    IBOutlet KTextField *labelAccount;
    IBOutlet UIButton *btnAgree;
    IBOutlet UIButton *btnAgreeMent;
    
    IBOutlet ImageTouchView *businessLicence;
    IBOutlet ImageTouchView *dealAuthorize;

    UITextField  *selectedAddr;
    
    UIImage                 * images[3];
    
    NSString *cityCode;
}

@property (nonatomic, strong) BMKPoiInfo * selectBMKPoiInfo;

- (IBAction)btnAgree:(UIButton *)sender;
- (IBAction)btnAgreement:(UIButton *)sender;

@end

@implementation ApplyShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"申请成为商户";
    [self setEdgesNone];
    
    [nameLabel enableBorder];
    [addressLabel enableBorder];
    [personLabel enableBorder];
    [phoneLabel enableBorder];
    [labelAccount enableBorder];
    [labelContactAdress enableBorder];
    [labelAccountBank enableBorder];
    [labelAccountName enableBorder];
    [labelAccount enableBorder];
    noticeView.placeholder = @"备注 选填";
    [button commonStyle];

    businessLicence.image = LOADIMAGECACHES(@"btn_room_add");
    businessLicence.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
    businessLicence.tag = @"businessLicence";

    dealAuthorize.image = LOADIMAGECACHES(@"btn_room_add");
    dealAuthorize.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
    dealAuthorize.tag = @"dealAuthorize";

    [scrollView setContentSize:CGSizeMake(0, button.bottom + 10)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    __block BaseViewController *blockSelf = self;
    
    [blockSelf.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        if (opening) {
            if (currentInputView.tag > 3) {
                // 有必要的时候 适应键盘
                CGFloat oy = keyboardFrameInView.origin.y;
                CGFloat dy = currentInputView.bottom - scrollView.contentOffset.y;
                if (dy > oy) {
                    scrollView.top = oy - dy - 20;
                }
            }
        }
        if (closing) {
            scrollView.top = 0;
        }
    }];
}

- (IBAction)applyShop {
    if (!nameLabel.text.hasValue) {
        [self showText:@"请输入商铺名称"];
    } else if (!addressLabel.text.hasValue) {
        [self showText:@"请选择商铺位置"];
    } else if (!personLabel.text.hasValue) {
        [self showText:@"请输入联系人"];
    } else if (!phoneLabel.text.hasValue) {
        [self showText:@"请输入联系手机"];
    } else if (!labelContactAdress.text.hasValue) {
        [self showText:@"请输入联系人地址"];
    } else {
        [super startRequest];
        [client applyShop:nameLabel.text
                  address:addressLabel.text
                 username:personLabel.text
                    phone:phoneLabel.text
              useraddress:labelContactAdress.text
                      lat:@(_selectBMKPoiInfo.pt.latitude).stringValue
                      lng:@(_selectBMKPoiInfo.pt.longitude).stringValue
                     city:cityCode
                     logo:nil
                shoppaper:businessLicence.image
                authpaper:dealAuthorize.image
                     bank:labelAccountBank.text
                 bankuser:labelAccountName.text
                  account:labelAccount.text
                  content:noticeView.text];
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        [self refreshCurrentUser];
        [self popViewController];
    }
    return YES;
}

#pragma mark - imageTouchViewDelegate

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    [self resignAllKeyboard:self.view];
    if ([sender isKindOfClass:[ImageTouchView class]]) {
        NSInteger itag = [sender.tag integerValue];
        
        if (images[itag]) {
            CGRect cellF = [scrollView convertRect:sender.frame toView:self.navigationController.view];
            ImageViewController * con = [[ImageViewController alloc] initWithFrameStart:cellF supView:self.navigationController.view pic:nil preview:(id)sender.image];
            con.bkgImage = [self.view screenshot];
            con.lookPictureState = forLookPictureStateDelete;
            [con setBlock:^(BOOL isDel) {
                if (isDel) {
                    images[itag] = nil;
                    businessLicence.image = LOADIMAGECACHES(@"btn_room_add");
                    businessLicence.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
                }
            }];
            [self.navigationController pushViewController:con animated:NO];
        } else {
            CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择",  @"拍一张", nil];
            
            if ([sender.tag isEqualToString:@"businessLicence"]) {
                actionSheet.tag = 1;
            } else {
                actionSheet.tag = 2;
            }
            
            [actionSheet show];
        }
    }
}

#pragma mark - View Touched

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignAllKeyboard:self.view];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)sender {
    currentInputView = sender;
    scrollView.userInteractionEnabled = NO;
    [sender resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView*)sender shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    scrollView.userInteractionEnabled = YES;
    currentInputView = nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    if (sender == addressLabel || sender == labelContactAdress) {
        selectedAddr = sender;
        
        MapViewController * con = [[MapViewController alloc] initWithDelegate:self];
        if (currentInputView) {
            [currentInputView resignFirstResponder];
        }

        [self pushViewController:con];
        return NO;
    }

    currentInputView = sender;
    return YES;
}

#pragma mark - 更新 地理位置
- (void)mapViewControllerSetPoiInfo:(BMKPoiInfo *)selectBMKPoiInfo {
    _selectBMKPoiInfo = selectBMKPoiInfo;
    selectedAddr.text = _selectBMKPoiInfo.address;
    selectedAddr = nil;

    cityCode = [Area getAreaIdByAddress:_selectBMKPoiInfo.city];
    cityCode = [Area getCombinedAddressByAreaId:cityCode];
    
//    NSLog(@"Name:%@", _selectBMKPoiInfo.name);
//    NSLog(@"UID:%@", _selectBMKPoiInfo.uid);
//    NSLog(@"Address:%@", _selectBMKPoiInfo.address);
//    NSLog(@"City:%@", _selectBMKPoiInfo.city);
//    NSLog(@"Phone:%@", _selectBMKPoiInfo.phone);
//    NSLog(@"Epoitype:%d", _selectBMKPoiInfo.epoitype);
//    NSLog(@"lat:%f lng:%f", _selectBMKPoiInfo.pt.latitude, _selectBMKPoiInfo.pt.longitude);
}
#pragma mark -

- (IBAction)btnAgree:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)btnAgreement:(UIButton *)sender {
    HelpViewController* controller = [[HelpViewController alloc] init];
    controller.type = 1;
    [self pushViewController:controller];
}

#pragma mark - CameraActionSheetDelegate

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        return;
    }
 
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.view.tag = sender.tag;
    picker.delegate = self;

    if (buttonIndex == 0){
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            [self showText:@"无法打开相机"];
        }
    }
    
    [self presentModalController:picker animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        img = [UIImage rotateImage:img];
        img = [img resizeImageGreaterThan:1024];
        NSInteger itag = picker.view.tag;
        
        if (itag == 1) {
            images[itag] = img;
            businessLicence.image = img;
        } else if (itag == 2) {
            images[itag] = img;
            dealAuthorize.image = img;
        }
    }];
}

@end
