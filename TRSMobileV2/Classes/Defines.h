//
//  Defines.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/10.
//  Copyright © 2016年 liaojingyu. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

/*
 *此文件为程序常调用使用的宏字段声明文件，与具体应用无关
 *
 */

/*********************************************************************/

/**
 * 程序托管方法
 */
#define GDelegate               ((AppDelegate *)([UIApplication sharedApplication].delegate))


/*********************************************************************/

/*
 *调试日志开关
 */
#if	DEBUG
#define NSLog(format, ...)      NSLog(format, ## __VA_ARGS__)
#else
#define NSLog(format, ...)
#endif

/*********************************************************************/

#endif /* Defines_h */
