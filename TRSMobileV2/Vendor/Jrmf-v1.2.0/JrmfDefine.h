//
//  JrmfDefine.h
//
//  Created by 一路财富 on 16/4/27.
//  Copyright © 2016年 JYang. All rights reserved.
//  说明：一些配置文件信息

#ifndef JrmfDefine_h
#define JrmfDefine_h

//生产环境定义
#define IsProduction    1

/******************************************** 渠道信息 *******************************************/

#if IsProduction

//生产后台
#define BASE_URL        @"http://api.jrmf360.com"

//商户ID
#define kPartnerID      @"liangshanyunbao"

//商户名称(红包名称)
#define kPartnerName    @"凉山云报"

//商户密钥
#define kPartnerSecKey  @"f9f021d9-3c77-4482-b428-78b289badaae"

#else

//预生产后台
#define BASE_URL        @"http://yun-test.jrmf360.com"

//商户ID
#define kPartnerID      @"tuoerso"

//商户名称(红包名称)
#define kPartnerName    @"凉山云报"

//商户密钥
#define kPartnerSecKey  @"cef7ea5b-251c-498b-9f21-d7ce8c20e09f"

#endif

/******************************************** 红包埋点 *******************************************/

//启动红包（唯一红包）
#define kPacket_Start       @"52"

//安装红包 (普惠红包)
#define kPacket_Install     @"1"

/******************************************** 接口信息 *******************************************/

//获取用户令牌
#define kGetWebTokenUrl         [NSString stringWithFormat:@"%@%@", BASE_URL, @"/api/v1/redEnvelope/getWebToken.shtml"]

//发送唯一红包
#define kOperateRedEnvelopeUrl  [NSString stringWithFormat:@"%@%@", BASE_URL, @"/api/v1/redEnvelope/getOperateRedEnvelopeUrl.shtml"]

//发送普惠红包
#define kCommonRedEnvelopeUrl   [NSString stringWithFormat:@"%@%@", BASE_URL, @"/api/v1/redEnvelope/getCommonRedEnvelopeUrl.shtml"]

//发送卡券红包
#define kGetCardCouponUrl       [NSString stringWithFormat:@"%@%@", BASE_URL, @"/api/v1/redEnvelope/getCardCouponUrl.shtml"]

//我的钱包地址
#define kGetWalletUrl           [NSString stringWithFormat:@"%@%@", BASE_URL, @"/h5/v1/redEnvelope/wallets/index.shtml"]

//响应码成功标志位
#define kSuccessFlag            @"0000"

/******************************************** 设备信息 *******************************************/

#define KEY_IDFV        [[UIDevice currentDevice].identifierForVendor UUIDString]


#endif /* JrmfDefine_h */
