//
//  UISettingFontViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/18.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UISettingFontViewController.h"
#import "Globals.h"

@interface UISettingFontCell : UITableViewCell

@property (strong, nonatomic) UILabel   *label1;
@property (strong, nonatomic) UILabel   *label2;
@property (strong, nonatomic) UIButton  *button;

@end

@implementation UISettingFontCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _label1 = [[UILabel alloc] init];
        _label1.textColor = [UIColor blackColor];
        _label1.font = [UIFont systemFontOfSize:17.0];
        [self.contentView addSubview:_label1];
        
        _label2 = [[UILabel alloc] init];
        _label2.textColor = [UIColor lightGrayColor];
        _label2.font = [UIFont systemFontOfSize:13.0];
        [self.contentView addSubview:_label2];

        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor whiteColor];
        _button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGB:0xd9d9d9] cornerRadius:0.0] forState:UIControlStateHighlighted];
        [self.contentView addSubview:_button];
        
        _label1.sd_layout
        .topSpaceToView(self.contentView, 8.0)
        .leftSpaceToView(self.contentView, 20.0)
        .rightSpaceToView(self.contentView, 8.0)
        .heightIs(21.0);
        
        _label2.sd_layout
        .topSpaceToView(_label1, 8.0)
        .bottomSpaceToView(self.contentView, 8.0)
        .leftSpaceToView(self.contentView, 20.0)
        .widthIs(200.0)
        .heightIs(21.0);
        
        _button.sd_layout
        .rightSpaceToView(self.contentView, 20.0)
        .widthIs(64.0)
        .heightIs(32.0)
        .centerYEqualToView(self.contentView);
        
        [_button setCornerWithRadius:CGRectGetHeight(_button.frame)/2.0];
    }
    return self;
}

@end

@interface UISettingFontViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __strong UITableView    *_tableView;
    
    NSMutableArray          *_arrayFonts;
}
@end

@implementation UISettingFontViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initUIControls];
    [self loadFonts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initUIControls {
    
    [self.navbar.barTitle setText:self.dict[@"title"] ];
    [self initUITableView];
}

- (void)initUITableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:[UIView new] ]; //隐藏底部多余的分割线
    [self.view addSubview:_tableView];
    _tableView.sd_layout
    .topSpaceToView(self.navbar, 0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0);
}

#pragma mark -
- (void)loadFonts {

    _arrayFonts = [NSMutableArray arrayWithCapacity:0];
    
    //加载本地字体
    [_arrayFonts addObjectsFromArray:[[NSBundle mainBundle] pathsForResourcesOfType:@".ttf" inDirectory:nil] ];
    [_arrayFonts addObjectsFromArray:[[NSBundle mainBundle] pathsForResourcesOfType:@".ttc" inDirectory:nil] ];
    
    //加载网络提供的字体库...
}

- (void)selectFont:(id)sender {

    NSInteger tag = [(UIButton *)sender tag];
    switch (tag) {
        case 0: //系统字体
            [[UIFontProvider sharedInstance] resetFont];
            break;
        default:
            [[UIFontProvider sharedInstance] setFontPath:_arrayFonts[(tag - 1)] ];
            break;
    }
    if(self.clickEvent) {self.clickEvent(nil, 1);}
    postNotificationName(didUIFontChangeNotification, nil, nil);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0)
        return 1;
    return _arrayFonts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"UISettingFontCell";
    UISettingFontCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[UISettingFontCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell.button addTarget:self action:@selector(selectFont:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.button.tag = indexPath.section + indexPath.row;
    cell.label1.text = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"];
    if(indexPath.section == 0) {
        cell.label2.text = @"系统字体";
    }
    else {
        NSString *path = _arrayFonts[indexPath.row];
        cell.label2.text = path.lastPathComponent.stringByDeletingPathExtension;
    }
    
    NSString *fontPath = [NSUserDefaults settingValueForType:SettingTypeFontFamily];
    BOOL isUse = [fontPath.lastPathComponent.stringByDeletingPathExtension isEqualToString:cell.label2.text];
    if(isUse)
        [cell.button setBorderWithColor:[UIColor clearColor] borderWidth:0];
    else
        [cell.button setBorderWithColor:[UIColor colorWithRGB:0xeeeeee] borderWidth:1.0];
    
    [cell.button setEnabled:!isUse];
    [cell.button setTitle:(isUse ? @"使用中" : @"使用") forState:UIControlStateNormal];
    [cell.button setTitleColor:(isUse ? [UIColor redColor] : [UIColor blackColor])  forState:UIControlStateNormal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
