//
//  YMBaseTableViewController.m
//  reSearchDemo
//
//  Created by helfy  on 15-4-15.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "YMBaseTableViewController.h"
#import "YMParametersTableViewCell.h"
#import "YMParameterCellObj.h"

@interface YMBaseTableViewController ()

@end

@implementation YMBaseTableViewController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.isSectionMode = YES;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesNone];
    // Do any additional setup after loading the view.
    [self setupData];
    
    self.tableView  =[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview: self.tableView ];
    self.tableView .delegate = (id)self;
    self.tableView .dataSource = (id)self;
    
    [self.tableView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo (self.view);
        make.right.equalTo (self.view);
        make.top.equalTo (self.view);
        make.bottom.equalTo (self.view);
    }];
    
    [self.tableView  registerClass:[YMParametersTableViewCell class] forCellReuseIdentifier:@"YMParametersTableViewCell"];
    
}


-(void)setupData
{
    self.cellObjs= [NSMutableArray array];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)keyboardWillShow:(NSNotification *)notification{
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float height = rect.size.height;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, height, self.tableView.contentInset.right)];
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    //scroll TO index
    //    NSIndexPath *indexPath;
    int section = 0;
    int row =0;
    
    if(self.isSectionMode == NO)
    {
        for (row =0 ;row<self.cellObjs.count;row++) {
            YMParameterCellObj *obj = self.cellObjs[row];
            if([obj.accessoryView isFirstResponder])
            {
                break;
            }
        }
    }
    else{
        
        BOOL find = NO;
        for (section =0 ;section<self.cellObjs.count;section++) {
            NSArray *sectionArray =self.cellObjs[section];
            for (row =0 ;row<sectionArray.count;row++) {
                YMParameterCellObj *obj = sectionArray[row];
                if([obj.accessoryView isFirstResponder])
                {
                    find = YES;
                    break;
                }
            }
            
            if(find)break;
        }
    }
    //    self.bottomMargin.constant = keyboardHeight;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(void)keyboardWillHide:(NSNotification *)notification{
    [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, 0, self.tableView.contentInset.right)];
}
#pragma mark TableDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMParameterCellObj *obj = nil;
    if (self.isSectionMode) {
        obj =  self.cellObjs[indexPath.section][indexPath.row];
    }
    else{
        obj =self.cellObjs[indexPath.row];
    }
    
    return obj.cellHeigth;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isSectionMode) {
        return self.cellObjs.count;
    }
    else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.isSectionMode) {
        return [self.cellObjs[section] count];
    }
    else{
        return self.cellObjs.count;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier =@"YMParametersTableViewCell";
    
    YMParametersTableViewCell *cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    YMParameterCellObj *obj = nil;
    if (self.isSectionMode) {
        obj =  self.cellObjs[indexPath.section][indexPath.row];
    }
    else{
        obj =self.cellObjs[indexPath.row];
    }
    [cell setupViewFor:obj];
    
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    YMParameterCellObj *obj = nil;
    if (self.isSectionMode) {
        obj =  self.cellObjs[indexPath.section][indexPath.row];
    }
    else{
        obj =self.cellObjs[indexPath.row];
    }
    if(obj.cellAction){
        [self performSelector:obj.cellAction withObject:obj];
    }
    else if(obj.pushToClass)
    {
        UIViewController *controller = [[[obj pushToClass] alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    
}

@end
