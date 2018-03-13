//
//  UIBaseViewController.m
//  TRSMobileV2
//
//  Created by 廖靖宇 on 2016/12/1.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UIBaseViewController.h"
#import "JrmfRedPacket.h"
#import "Globals.h"

@interface UIBaseViewController ()

@property (strong, nonatomic) NSString *webToken;

@end

@implementation UIBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUIParameters];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initUIParameters {
    
    self.view.backgroundColor = [UIColor colorWithRGB:0xeeeeee alpha:1.0];
    [self initUINavbar];
}

- (void)initUINavbar {
    
    __weak typeof(self) wself = self;
    id clickEvent = ^(NSDictionary *dict, NSInteger index) {
        switch (index) {
            case 0: //测试红包
                //[self redEnvelope];
                [wself.navigationController popViewControllerAnimated:YES];
                break;
            case 1: //我的零钱
                //[wself myWallet];
                break;
            default:
                break;
        }
    };
    _navbar = [NSBundle instanceWithBundleNib:NSStringFromClass([UINavbarView class])];
    _navbar.clickEvent = clickEvent;
    _navbar.backgroundColor = [UIColor colorWithRGB:UIColorThemeDefault];
    [_navbar.barLeft setImage:[UIImage imageNamed:@"normal.bundle/导航_返回.png"] forState:UIControlStateNormal];
    //[_navbar.barRight setImage:[UIImage imageNamed:@"normal.bundle/导航_更多.png"] forState:UIControlStateNormal];
    [self.view addSubview:_navbar];
}

#pragma mark - 运营红包
- (void)redEnvelope {

    //获取用户令牌token
#if 1
    if([AVUser currentUser]) {
        
        [JrmfRedPacket getWebToken:[[AVUser currentUser] objectId]
                          nickName:[[AVUser currentUser] objectForKey:@"nickname"]
                            avatar:[[AVUser currentUser] objectForKey:@"avatar"]
                        completion:^(BOOL success, NSDictionary * _Nullable envelope, NSError * _Nullable error) {
                            
                            if(success) {
                                NSString *respstat = envelope[@"respstat"];
                                if([@"0000" isEqualToString:respstat]) {
                                    
                                    _webToken = envelope[@"webToken"];
                                    
                                    //获取唯一红包 （带用户令牌）
                                    [JrmfRedPacket getOperateRedEnvelope:kPacket_Start webToken:_webToken completion:^(BOOL success, NSDictionary *envelope, NSError *error) {
                                        
                                        //打开红包
                                        if(success) {
                                            
                                            NSString *redEnvelopeUrl = envelope[@"redEnvelopeUrl"];
                                            JrmfMarketLib *manager = [[JrmfMarketLib alloc] init];
                                            [manager doActionPresentOpenRedPacketViewControllerWithUrl:redEnvelopeUrl];
                                        }
                                    } ];
                                }
                            }
                        }];
    }
    else {
    
        //获取唯一红包 （普通）
        [JrmfRedPacket getOperateRedEnvelope:kPacket_Start webToken:nil completion:^(BOOL success, NSDictionary *envelope, NSError *error) {
            
            //打开红包
            if(success) {
                
                NSString *redEnvelopeUrl = envelope[@"redEnvelopeUrl"];
                JrmfMarketLib *manager = [[JrmfMarketLib alloc] init];
                [manager doActionPresentOpenRedPacketViewControllerWithUrl:redEnvelopeUrl];
            }
        } ];
    }
#else
    
    if([AVUser currentUser]) {
        
        [JrmfRedPacket getWebToken:[[AVUser currentUser] objectId]
                          nickName:[[AVUser currentUser] objectForKey:@"nickname"]
                            avatar:[[AVUser currentUser] objectForKey:@"avatar"]
                        completion:^(BOOL success, NSDictionary * _Nullable envelope, NSError * _Nullable error) {
                            
                            if(success) {
                                NSString *respstat = envelope[@"respstat"];
                                if([@"0000" isEqualToString:respstat]) {
                                    
                                    _webToken = envelope[@"webToken"];
                                    
                                    //获取普惠红包
                                    [JrmfRedPacket getCommonRedEnvelope:kPacket_Install webToken:_webToken completion:^(BOOL success, NSDictionary *envelope, NSError *error) {
                                        
                                        //打开红包
                                        if(success) {
                                            
                                            NSString *redEnvelopeUrl = envelope[@"redEnvelopeUrl"];
                                            JrmfMarketLib *manager = [[JrmfMarketLib alloc] init];
                                            [manager doActionPresentOpenRedPacketViewControllerWithUrl:redEnvelopeUrl];
                                        }
                                    } ];
                                }
                            }
                        }];
    }
    else {
        //获取普惠红包
        [JrmfRedPacket getCommonRedEnvelope:kPacket_Install webToken:nil completion:^(BOOL success, NSDictionary *envelope, NSError *error) {
            
            //打开红包
            if(success) {
                
                NSString *redEnvelopeUrl = envelope[@"redEnvelopeUrl"];
                JrmfMarketLib *manager = [[JrmfMarketLib alloc] init];
                [manager doActionPresentOpenRedPacketViewControllerWithUrl:redEnvelopeUrl];
            }
        } ];
    }
#endif

}

- (void)myWallet {

    if([AVUser currentUser]) {
        
        if(_webToken) {
            JrmfMarketLib *manager = [[JrmfMarketLib alloc] init];
            [manager doActionPresentWalletViewControllerWithUrl:kGetWalletUrl WithToken:_webToken];
        }
        else {
            [JrmfRedPacket getWebToken:[[AVUser currentUser] objectId]
                              nickName:[[AVUser currentUser] objectForKey:@"nickname"]
                                avatar:[[AVUser currentUser] objectForKey:@"avatar"]
                            completion:^(BOOL success, NSDictionary * _Nullable envelope, NSError * _Nullable error) {
                                
                                if(success) {
                                    NSString *respstat = envelope[@"respstat"];
                                    if([@"0000" isEqualToString:respstat]) {
                                        _webToken = envelope[@"webToken"];
                                        
                                        JrmfMarketLib *manager = [[JrmfMarketLib alloc] init];
                                        [manager doActionPresentWalletViewControllerWithUrl:kGetWalletUrl WithToken:_webToken];
                                    }
                                }
                            }];
        }
    }
    else {
        [SVProgressHUD showInfoWithStatus:@"请先登录用户"];
    }
}

@end
