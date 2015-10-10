//
//  AddGoodViewController.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/13.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "AddGoodViewController.h"
#import "Globals.h"
#import "picture.h"
#import "UIImage+Resize.h"
#import "UIImage+FlatUI.h"
#import "UIImageView+WebCache.h"
#import "UIColor+FlatUI.h"
#import "CameraActionSheet.h"
#import "ImageViewController.h"
#import "TextInput.h"
#import "BaseTableViewCell.h"
#import "Good.h"
#import "ImageTouchView.h"
#import "MapViewController.h"
#import "ShopCategroyListController.h"
#import "ShopCategroy.h"
#import "QRcodeReaderViewController.h"

@interface AddGoodViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraActionSheetDelegate, ImageTouchViewDelegate, UITextFieldDelegate, ShopCategroyDelegate, UITextViewDelegate, QRcodeReaderViewDelegate>
{
    NSMutableArray          * picArr;
    NSMutableArray          * buttonSArr;
    IBOutlet UIScrollView   * scrollView;
    IBOutlet KTextField     * textFieldtype;
    IBOutlet KTextField     * textFieldprice;
    IBOutlet KTextField     * textFieldname;
    IBOutlet KTextField     * txtBarcode;
    IBOutlet KTextView      * infoView;
    IBOutlet KTextView      * paramsView;
    IBOutlet ImageTouchView * touchViewlogo;
    IBOutlet ImageTouchView * touchView;
    UIImage                 * hasImage;
    NSString                * categoryid;
    NSString                * currentId;
    IBOutlet UIButton       *btnScanBarcode;
    
    NSInteger               openMode;
}

- (IBAction)scanBarcode:(UIButton *)sender;

@end

@implementation AddGoodViewController

- (void)goodsForEdit {
    if (_goods) {
        currentId = _goods.id;
        
        textFieldname.text = _goods.name;
        textFieldprice.text = _goods.price;
        
        categoryid = _goods.categoryid;
        textFieldtype.text = [ShopCategroy getCategoryNameByCategoryid:categoryid.integerValue];
        
        txtBarcode.text = _goods.barcode;
        infoView.text = _goods.content;
        paramsView.text = _goods.parameter;
        
        [touchViewlogo sd_setImageWithUrlString:_goods.logo
                               placeholderImage:[Globals getImageGoodHeadDefault]];
        
        hasImage = touchViewlogo.image;
        
        if (_goods.picture && _goods.picture.count) {
            [_goods.picture enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                picture *pic = obj;
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pic.smallUrl]];
                UIImage *img = [UIImage imageWithData:imgData];
                [picArr addObject:img];
            }];
            
            [self refresh];
        }
        
        self.title = @"编辑商品";
        openMode = 1;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"发布商品";
    openMode = 0;
    
    picArr = [[NSMutableArray alloc] init];
    buttonSArr = [[NSMutableArray alloc] init];
    
    [self setEdgesNone];
    
    [textFieldtype enableBorder];
    [textFieldprice enableBorder];
    [textFieldname enableBorder];
    [txtBarcode enableBorder];
    
    [infoView enableBorder];
    [paramsView enableBorder];
    touchView.image = LOADIMAGECACHES(@"btn_room_add");
    touchView.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
    touchView.tag = @"touchView";
    
    touchViewlogo.image = LOADIMAGECACHES(@"btn_room_add");
    touchViewlogo.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
    touchViewlogo.tag = @"touchViewlogo";
    [scrollView setContentSize:CGSizeMake(0, paramsView.bottom + 10)];
    infoView.placeholder = @"商品详细 选填";
    paramsView.placeholder = @"规格参数 选填";
    [self setRightBarButtonImage:LOADIMAGE(@"OK") highlightedImage:nil selector:@selector(sendNewGood)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __block BaseViewController *blockSelf = self;
    [blockSelf.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        if (opening) {
            if (currentInputView.tag == 4) {
                
                scrollView.top = -180;
            } else if (currentInputView.tag == 5) {
                scrollView.top = -240;
            }
        }
        if (closing) {
            scrollView.top = 0;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self goodsForEdit];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self resignAllKeyboard:self.view];
}

- (void)sendNewGood {
    if (!textFieldname.text.hasValue) {
        [self showText:@"请输入商品名字"];
    } else if (!categoryid) {
        [self showText:@"请选择商品类别"];
    } else if (!textFieldprice.text.hasValue) {
        [self showText:@"请输入商品价格"];
    } else if (!hasImage) {
        [self showText:@"请选择商品缩略图"];
    } else {
        [super startRequest];
        
        if (openMode == 0) {
            [client addGoods:categoryid
                        name:textFieldname.text
                       price:textFieldprice.text
                     picture:picArr
                     content:infoView.text
                   parameter:paramsView.text
                        logo:hasImage
                     barcode:txtBarcode.text];
        } else {
            [client editGoodsWithId:currentId
                         categoryId:categoryid
                               name:textFieldname.text
                              price:textFieldprice.text
                            picture:picArr
                            content:infoView.text
                          parameter:paramsView.text
                               logo:hasImage
                            barcode:txtBarcode.text];
             
        }
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        
        if ([self.delegate respondsToSelector:@selector(goodsEditDidFinish:)]) {
            [self.delegate performSelector:@selector(goodsEditDidFinish:) withObject:self];
        }

        [self popViewController];
    }
    
    return YES;
}

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    [self resignAllKeyboard:self.view];
    if ([sender.tag isEqualToString:@"touchViewlogo"]) {
        if (hasImage) {
            CGRect cellF = [scrollView convertRect:sender.frame toView:self.navigationController.view];
            ImageViewController * con = [[ImageViewController alloc] initWithFrameStart:cellF supView:self.navigationController.view pic:nil preview:(id)sender.image];
            con.bkgImage = [self.view screenshot];
            con.lookPictureState = forLookPictureStateDelete;
            [con setBlock:^(BOOL isDel) {
                if (isDel) {
                    hasImage = nil;
                    touchViewlogo.image = LOADIMAGECACHES(@"btn_room_add");
                    touchViewlogo.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
                }
            }];
            [self.navigationController pushViewController:con animated:NO];
        } else {
            CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择",  @"拍一张", nil];
            actionSheet.tag = 1;
            [actionSheet show];
        }
        
    } else if ([sender.tag isEqualToString:@"touchView"]) {
        CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择",  @"拍一张", nil];
        actionSheet.tag = 2;
        [actionSheet show];
    } else {
        CGRect cellF = [scrollView convertRect:sender.frame toView:self.navigationController.view];
        ImageViewController * con = [[ImageViewController alloc] initWithFrameStart:cellF supView:self.navigationController.view pic:nil preview:(id)sender.image];
        con.bkgImage = [self.view screenshot];
        con.lookPictureState = forLookPictureStateDelete;
        [con setBlock:^(BOOL isDel) {
            if (isDel) {
                [picArr removeObjectAtIndex:sender.tag.intValue];
                ImageTouchView * sbItem = [buttonSArr objectAtIndex:sender.tag.intValue];
                [sbItem removeFromSuperview];
                [buttonSArr removeObjectAtIndex:sender.tag.intValue];
                [UIView animateWithDuration:0.35 animations:^{
                    [buttonSArr enumerateObjectsUsingBlock:^(ImageTouchView * imageView, NSUInteger idx, BOOL *stop) {
                        imageView.left = idx*(imageView.width+10) + 5;
                    }];
                    
                    touchView.left = 10;
                    if (buttonSArr.count != 0) {
                        touchView.left += buttonSArr.count*(touchView.width+10);
                    }
                }];
                if (picArr.count > 5) {
                    touchView.hidden = YES;
                } else {
                    touchView.hidden = NO;
                }
            }
        }];
        [self.navigationController pushViewController:con animated:NO];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignAllKeyboard:scrollView];
    scrollView.userInteractionEnabled = YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    if (sender == textFieldtype) {
        ShopCategroyListController * con = [[ShopCategroyListController alloc] init];
        con.delegate = self;
        [self pushViewController:con];
        return NO;
    }
    currentInputView = sender;
    scrollView.userInteractionEnabled = NO;
    return YES;
}

- (void)shopCategroyFinished:(NSString*)_categoryid _category:(NSString*)_category {
    categoryid = _categoryid;
    textFieldtype.text = _category;
}

#pragma mark - textViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)sender
{
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

#pragma mark - CameraActionSheetDelegate

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex
{
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
        if (picker.view.tag == 1) {
            hasImage = img;
            touchViewlogo.image = img;
        } else {
            [picArr addObject:img];
            [self refresh];
        }
    }];
}

- (void)refresh {
    CGRect frame = touchView.frame;
    ImageTouchView* sbItem = [[ImageTouchView alloc] initWithFrame:frame delegate:self];
    sbItem.layer.masksToBounds = YES;
    sbItem.layer.cornerRadius = 2;
    frame.origin.x += frame.size.width+5;
    [UIView animateWithDuration:0.25 animations:^{
        touchView.frame = frame;
    }];
    UIImage *image = [picArr lastObject];
    sbItem.image = image;
    sbItem.tag = [NSString stringWithFormat:@"%d", (int)buttonSArr.count];
    [buttonSArr addObject:sbItem];
    [scrollView addSubview:sbItem];
    if (picArr.count > 5) {
        touchView.hidden = YES;
    } else {
        touchView.hidden = NO;
    }
}

- (IBAction)scanBarcode:(UIButton *)sender {
    QRcodeReaderViewController *tmpCon = [[QRcodeReaderViewController alloc] init];

    if ([tmpCon isKindOfClass:[UIViewController class]]) {
        tmpCon.delegate = self;
        UIViewController* con = (UIViewController*)tmpCon;
        [self presentModalController:con animated:YES];
    }
}

- (void)QRcodeReaderDidFinish:(UIView *)sender data:(NSString *)data {
    if (data) {
        txtBarcode.text = data;
        _goods.barcode = [NSString stringWithFormat:@"%@", data];
    }
}

@end
