//
//  FinancingInfoViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-23.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "FinancingInfoViewController.h"
#import "Globals.h"
#import "Financ.h"
#import "Area.h"
#import "TextInput.h"
#import "KLocation.h"
#import "KLocatePickView.h"
#import "MapViewController.h"
#import "ImageTouchView.h"
#import "ImageViewController.h"
#import "UIImage+Resize.h"
#import "UIImage+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "CameraActionSheet.h"
#import "HelpViewController.h"

@interface FinancingInfoViewController () <MapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  CameraActionSheetDelegate, ImageTouchViewDelegate, UITextFieldDelegate>
{
    UIImage                 * images[4];

    IBOutlet KTextField *company;
    IBOutlet KTextField *address;
    IBOutlet KTextField *serviceTo;
    
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet ImageTouchView *authService;
    IBOutlet ImageTouchView *authID;
    IBOutlet ImageTouchView *authBussiness;
    
    IBOutlet UIView *chargeView;
    IBOutlet UIView *applyView;
    
    IBOutlet KTextField *restCoins;
    IBOutlet UILabel *exchangePrompt;
    
    IBOutlet UIButton *editBtn;
    IBOutlet UIButton *applyBtn;
    IBOutlet UIButton *chargeBtn;
    IBOutlet UIButton *agreeBtn;
    IBOutlet UIButton *protocolBtn;

    NSInteger  serviceCityCode;
}

@property (nonatomic, strong) BMKPoiInfo * bmkPoiInfo;
//@property (nonatomic, strong) BMKPoiInfo * serviceBMKPoiInfo;

@end

@implementation FinancingInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    [company enableBorder];
    [address enableBorder];
    [serviceTo enableBorder];
    [restCoins enableBorder];
    
    [applyBtn commonStyle];
    [editBtn commonStyle];
    [chargeBtn borderStyle];
    
    authService.image = LOADIMAGECACHES(@"btn_room_add");
    authService.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
    authService.tag = @"authService";
    
    authID.image = LOADIMAGECACHES(@"btn_room_add");
    authID.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
    authID.tag = @"authID";
    
    authBussiness.image = LOADIMAGECACHES(@"btn_room_add");
    authBussiness.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
    authBussiness.tag = @"authBussiness";
    
    if (_financ) {
        self.navigationItem.title = @"融资贷款服务信息管理";
        chargeView.hidden = NO;
        applyView.hidden = YES;
        [scrollView setContentSize:CGSizeMake(0, chargeView.bottom)];
    } else {
        chargeView.hidden = YES;
        applyView.hidden = NO;
        self.navigationItem.title = @"融资贷款服务入驻申请";
        [scrollView setContentSize:CGSizeMake(0, applyView.bottom)];
    }
    
    CGRect frame = self.view.frame;
    
    scrollView.size = frame.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isFirstAppear) {
        if (_financ) {
            [self reloadData];
        }
    }
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

- (void)reloadData {
    if (_financ) {
        company.text = _financ.company;
        address.text = _financ.address;
        serviceTo.text = [Area getAreaNameById:_financ.city];
        
        if (_financ.workPaper && _financ.workPaper.length > 3) {
            [Globals imageDownload:^(UIImage *img) {
                authService.image = img;
                images[1] = img;
            } url:_financ.workPaper];
        }

        if (_financ.idcard && _financ.idcard.length > 3) {
            [Globals imageDownload:^(UIImage *img) {
                authID.image = img;
                images[2] = img;
            } url:_financ.idcard];
        }

        if (_financ.certificate && _financ.certificate.length > 3) {
            [Globals imageDownload:^(UIImage *img) {
                authBussiness.image = img;
                images[3] = img;
            } url:_financ.certificate];
        }
    }
}

- (IBAction)doAgree:(UIButton *)sender {
    if (sender.tag == 0) {
        sender.selected = !sender.selected;
    } else {
        HelpViewController* controller = [[HelpViewController alloc] init];
        controller.type = 1;
        [self pushViewController:controller];
    }
}

- (IBAction)doCharge:(UIButton *)sender {
    [self showAlert:@"测试期间，暂不提供充值服务" isNeedCancel:NO];
}

- (IBAction)applyDidFinish:(UIButton *)sender {
    [self resignAllKeyboard:self.view];

    if (!company.text.hasValue) {
        [self showText:@"请输入公司名称"];
    } else if (!address.text.hasValue) {
        [self showText:@"请选择公司位置"];
    } else if (!serviceTo.text.hasValue) {
        [self showText:@"请选择服务地区"];
    } else if (!images[1]) {
        [self showText:@"请选择上传相关服务证明照片"];
    } else if (!images[2]) {
        [self showText:@"请选择上传身份证照片"];
    } else if (!images[3]) {
        [self showText:@"请选择上传从业资质证明照片"];
    } else if (!agreeBtn.selected) {
        [self showText:@"请阅读并同意注册协议！"];
    } else {
        [super startRequest];
        
        if (_financ) {
            [client editFinacialShopWithId:_financ.id
                                andCompany:company.text
                                   address:address.text
                                      city:@(serviceCityCode).stringValue
                                       lat:@(_bmkPoiInfo.pt.latitude).stringValue
                                       lng:@(_bmkPoiInfo.pt.longitude).stringValue
                                workPermit:authService.image
                                    idCard:authID.image
                               certificate:authBussiness.image];
        } else {
            [client applyFinacialShop:company.text
                              address:address.text
                                 city:@(serviceCityCode).stringValue
                                  lat:@(_bmkPoiInfo.pt.latitude).stringValue
                                  lng:@(_bmkPoiInfo.pt.longitude).stringValue
                           workPermit:authService.image
                               idCard:authID.image
                          certificate:authBussiness.image];
        }
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if (!sender.hasError) {
            [self refreshCurrentUser];
        }
    }

    [self popViewController];
    return YES;
}

#pragma mark - kPickerView

- (void)showPickerView:(NSInteger)row {
    KLocatePickView *locateView = [[KLocatePickView alloc] initWithTitle:@"选择城市" delegate:self];
    [locateView showInView:self.view];
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        KLocatePickView *locateView = (KLocatePickView *)actionSheet;
        KLocation *location = locateView.locate;
        serviceTo.text = location.city;
        serviceCityCode = location.cityCode;
    }
}

#pragma mark - imageTouchViewDelegate

- (void)imageTouchViewDidSelected:(ImageTouchView *)sender {
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
                    
                    if (itag == 1) {
                        authService.image = LOADIMAGECACHES(@"btn_room_add");
                        authService.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
                    } else if (itag == 2) {
                        authID.image = LOADIMAGECACHES(@"btn_room_add");
                        authID.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
                    } else if (itag == 3) {
                        authBussiness.image = LOADIMAGECACHES(@"btn_room_add");
                        authBussiness.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
                    }
                }
            }];
            
            [self.navigationController pushViewController:con animated:NO];
        } else {
            CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择",  @"拍一张", nil];
            
            if ([sender.tag isEqualToString:@"authService"]) {
                actionSheet.tag = 1;
            } else if ([sender.tag isEqualToString:@"authID"]) {
                actionSheet.tag = 2;
            } else {
                actionSheet.tag = 3;
            }
            
            [actionSheet show];
        }
    }
}

#pragma mark - View Touched

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignAllKeyboard:self.view];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    if (sender == serviceTo) {
        [sender resignFirstResponder];
        KLocatePickView *locateView = [[KLocatePickView alloc] initWithTitle:@"选择城市" delegate:self];
        [locateView showInView:self.view];
        return NO;
    } else if (sender == address) {
        [sender resignFirstResponder];
        
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
    _bmkPoiInfo = selectBMKPoiInfo;
    address.text = selectBMKPoiInfo.address;
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
        
        images[itag] = img;

        if (itag == 1) {
            authService.image = img;
        } else if (itag == 2) {
            authID.image = img;
        } else if (itag == 3) {
            authBussiness.image = img;
        }
    }];
}

@end
