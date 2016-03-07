//
//  ViewController.m
//  ActionSheetDemo
//
//  Created by Michael_Ju on 16/3/4.
//  Copyright © 2016年 ciwong. All rights reserved.
//

#import "ViewController.h"
#import "CWActionSheetView.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)sender:(id)sender {
    
    __weak typeof(self) wself = self;
    [CWActionSheetView showWithItemsBlock:^(id<CWSelectionItemsProtocol> items) {
        [items addItemWithLabelText:@"加入列表" imageName:@"homeAddList" shouldDismiss:YES];
        [items addItemWithLabelText:@"下载" imageName:@"downloaded_icon" shouldDismiss:YES];
        
    } selectBlock:^(NSInteger selectIndex) {
        NSLog(@"%ld",selectIndex);
        [wself showTipsWithSelectedIndex:selectIndex];
    }];
}

- (void)showTipsWithSelectedIndex:(NSInteger)selectedIndex
{
    NSDictionary *tipsInfoDic = @{@0 : @"加入列表",
                                  @1 : @"下载中..."
                                  };
    NSString *tipsMessage = tipsInfoDic[@(selectedIndex)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:tipsMessage preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }];
    
}
- (IBAction)alertControl:(id)sender {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"UIAlertController + UIAlertAction" preferredStyle:UIAlertControllerStyleAlert];

    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        NSLog(@"取消时间处理");
    }];
    UIAlertAction *ac = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击确定");
    }];
    [alertC addAction:action];
    [alertC addAction:ac];
    
    [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入用户名";
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入密码";
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    
    
    [self presentViewController:alertC animated:YES completion:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
