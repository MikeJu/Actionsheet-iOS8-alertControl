//
//  CWActionSheetView.m
//  ActionSheetDemo
//
//  Created by Michael_Ju on 16/3/4.
//  Copyright © 2016年 ciwong. All rights reserved.
//

#import "CWActionSheetView.h"

#define kColorWithHex(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f]
static NSString *const kSelectCellImageNameKey = @"kSelectCellImageNameKey";
static NSString *const kSelectCellNameKey = @"kSelectCellNameKey";
static NSString *const kSelectionViewShouldDismissKey = @" kSelectionViewShouldDismissKey";


#pragma mark - CWSelectionItems;

@interface CWSelectionItems : NSObject<CWSelectionItemsProtocol>

@property (nonatomic, strong) NSMutableArray *itemArray;
- (NSInteger)count;

@end


@implementation CWSelectionItems

-(instancetype)init
{
    if (self = [super init]) {
        self.itemArray = [NSMutableArray array];
    }
    return self;
}
- (void)addItemWithLabelText:(NSString *)labelText imageName:(NSString *)imageName shouldDismiss:(BOOL)shouldDismiss
{
    if (labelText && [labelText isKindOfClass:[NSString class]] && imageName && [imageName isKindOfClass:[NSString class]]) {
        NSDictionary *itemDic = [NSDictionary dictionaryWithObjectsAndKeys:labelText,kSelectCellNameKey,imageName,kSelectCellImageNameKey,@(shouldDismiss),kSelectionViewShouldDismissKey,nil];
        [self.itemArray addObject:itemDic];
        
    }
}
- (NSInteger)count
{
    return self.itemArray.count;
}
@end

#pragma mark - CWSelectionCell

@interface CWSelectionCell : UITableViewCell

@property (nonatomic, strong)UILabel *textLbl;
@property (nonatomic, strong)UIView *lineView;
@property (nonatomic, strong)UIImageView *picIV;
@property (nonatomic, strong)NSDictionary *infoDic;

@end

@implementation CWSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //图片
        UIImageView *picIV = [[UIImageView alloc] init];
        self.picIV = picIV;
        picIV.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:picIV];
        
        //文字
        UILabel *textLbl = [UILabel new];
        self.textLbl = textLbl;
        textLbl.backgroundColor = [UIColor clearColor];
        textLbl.textColor = [UIColor blackColor];
        [self.contentView addSubview:textLbl];
        
        //下划线
        UIView *lineView= [[UIView alloc] init];
        self.lineView = lineView;
        lineView.backgroundColor = [UIColor clearColor];
        lineView.backgroundColor = kColorWithHex(0xd2d5d9);
        [self.contentView addSubview:lineView];
        
        self.contentView.backgroundColor = kColorWithHex(0xffffff);
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat picH = 24;
    CGFloat picW = 24;
    CGFloat picX = 8;
    CGFloat picY = self.bounds.size.height*0.5 - picH*0.5;
    self.picIV.frame = CGRectMake(picX, picY, picW, picH);
    
    
    CGFloat lblX = CGRectGetMaxX(self.picIV.frame) + 8;
    CGFloat lblY = 0;
    CGFloat lblH = self.bounds.size.height;
    CGFloat lblW = self.bounds.size.width - lblX;
    self.textLbl.frame = CGRectMake(lblX, lblY, lblW, lblH);
    
    CGFloat lineX = 0;
    CGFloat lineW = self.bounds.size.width - lineX;
    CGFloat lineH = 1;
    CGFloat lineY = self.bounds.size.height - lineH;
    self.lineView.frame = CGRectMake(lineX, lineY, lineW, lineH);
    
}

-(void)setInfoDic:(NSDictionary *)infoDic
{
    _infoDic = infoDic;
    NSString *imageName = infoDic[kSelectCellImageNameKey];
    if (imageName && [imageName isKindOfClass:[NSString class]] && imageName.length) {
        self.picIV.image = [UIImage imageNamed:imageName];
    }
    
    NSString *nameStr = infoDic[kSelectCellNameKey];
    self.textLbl.text = [nameStr description];
    
}

@end

#pragma mark - CWSelectCancelCell

@interface CWSelectionCancelCell : UITableViewCell

@property (nonatomic, strong) UILabel *cancelLbl;

@end

@implementation CWSelectionCancelCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *cancelLbl = [UILabel new];
        cancelLbl.text = @"取消";
        [self.contentView addSubview:cancelLbl];
        self.cancelLbl = cancelLbl;
        cancelLbl.textAlignment = NSTextAlignmentCenter;
        cancelLbl.textColor = [UIColor blueColor];
        cancelLbl.font = [UIFont systemFontOfSize:16];
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat lblX = 0;
    CGFloat lblY = 0;
    CGFloat lblW = self.bounds.size.width;
    CGFloat lblH = self.bounds.size.height;
    self.cancelLbl.frame = CGRectMake(lblX, lblY, lblW, lblH);
}

@end

#pragma mark - CWSelectionView

@interface CWActionSheetView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *selectionTableView;

@property (nonatomic, copy)selectIndexBlock selectBlock;

@property (nonatomic, strong)CWSelectionItems *items;

@end

@implementation CWActionSheetView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        self.frame = keyWindow.bounds;
        
        UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
        maskView.backgroundColor = [UIColor clearColor];
        
        [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)]];
        [self addSubview:maskView];
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [self addSubview:self.selectionTableView];
        
    }
    return self;
}
#pragma mark - pulic method
+ (void)showWithItemsBlock:(void (^)(id<CWSelectionItemsProtocol>))itemBlock selectBlock:(selectIndexBlock)selectBlock
{
    CWActionSheetView *actionSheetView = [[CWActionSheetView alloc] initWithFrame:CGRectZero];
    [actionSheetView showWithItemsBlcok:itemBlock selectBlock:selectBlock];

}

- (void)showWithItemsBlcok:(void(^)(id <CWSelectionItemsProtocol> items))itemsBlock selectBlock:(selectIndexBlock)selectBlock
{
    self.selectBlock = selectBlock;
    itemsBlock(self.items);
    
    CGFloat tableViewHeight = (self.items.count + 1)*kSelectionCellHeight;
    
    if (tableViewHeight <= KSelectionViewMaxHeight) {
        self.selectionTableView.scrollEnabled = YES;
    }else
    {
        self.selectionTableView.scrollEnabled = NO;
    }
    
    tableViewHeight = tableViewHeight > KSelectionViewMaxHeight ? KSelectionViewMaxHeight : tableViewHeight;
    
    self.selectionTableView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, tableViewHeight);
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    self.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect selectionTabFrame = self.selectionTableView.frame;
        selectionTabFrame.origin.y = [UIScreen mainScreen].bounds.size.height - tableViewHeight
        ;
        self.selectionTableView.frame = selectionTabFrame;
    }];
    
}
#pragma mark - event
- (void)hideSelf
{
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor clearColor];
       CGRect selectionTabFrame = self.selectionTableView.frame;
        selectionTabFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
        self.selectionTableView.frame = selectionTabFrame;
    
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
    }];
}

#pragma mark - UITableviewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            return self.items.count;
            break;
        }
        case 1:{
            return 1;
            break;
        }
        default:
            break;
    }
    
    return 0;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *selectionCellID = @"selectionCellID";
    static NSString *selectCancelCellID = @"selectCancelCellID";
    
    UITableViewCell *acell;
    
    switch (indexPath.section) {
        case 0:
        {
            CWSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:selectionCellID];
            if (cell == nil) {
                cell = [[CWSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectionCellID];
                
            }
            
            if (self.items.count > indexPath.row) {
                cell.infoDic = self.items.itemArray[indexPath.row];
            }
            acell =  cell;
            break;
        }
         case 1:
        {
            CWSelectionCancelCell *cell = [tableView dequeueReusableCellWithIdentifier:selectCancelCellID];
            if (cell == nil) {
                cell = [[CWSelectionCancelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectCancelCellID];
                
            }
            acell =  cell;
        }
            break;
        default:
            break;
    }
        
        if (!acell) {
        acell = [[UITableViewCell alloc] init];
    }
    return acell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kSelectionCellHeight;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            if (self.selectBlock) {
                self.selectBlock(indexPath.row);
            }
            BOOL shouldDismiss = [[self.items.itemArray[indexPath.row] objectForKey:kSelectionViewShouldDismissKey] boolValue];
            if ((shouldDismiss)) {
                [self hideSelf];
            }
            break;
          case 1:
            [self hideSelf];
            break;
        default:
            break;
    }
}
#pragma mark - getter
-(UITableView *)selectionTableView
{
    if (!_selectionTableView) {
        _selectionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _selectionTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _selectionTableView.dataSource = self;
        _selectionTableView.delegate = self;
        
    }
    return _selectionTableView;
}
-(CWSelectionItems *)items
{
    if (!_items) {
        _items = [[CWSelectionItems alloc] init];
    }
    return _items;
}

@end


