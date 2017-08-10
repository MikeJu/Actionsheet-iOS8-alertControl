//
//  CWActionSheetView.h
//  ActionSheetDemo
//
//  Created by Michael_Ju on 16/3/4.
//  Copyright © 2016年 ciwong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef  void(^selectIndexBlock)(NSInteger selectIndex);
#define kSelectionCellHeight 58
#define KSelectionViewMaxHeight 320

@protocol CWSelectionItemsProtocol <NSObject>

@required
- (void)addItemWithLabelText:(NSString *)labelText imageName:(NSString *)imageName shouldDismiss:(BOOL)shouldDismiss;

@end
@interface CWActionSheetView : UIView


//@property (nonatomic, weak) id <CWSelectionItemsProtocol>delegate;

+ (void)showWithItemsBlock:(void(^)(id <CWSelectionItemsProtocol> items))itemBlock selectBlock:(selectIndexBlock)selectBlock;


@end
