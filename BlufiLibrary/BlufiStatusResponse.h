//
//  BlufiStatusResponse.h
//  EspBlufi
//
//  Created by AE on 2020/6/9.
//  Copyright © 2020 espressif. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlufiConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlufiStatusResponse : NSObject

@property(assign, nonatomic)OpMode opMode;

@property(assign, nonatomic)SoftAPSecurity softApSecurity;
@property(assign, nonatomic)int softApConnectionCount;
@property(assign, nonatomic)int softApMaxConnection;
@property(assign, nonatomic)int softApChannel;
@property(strong, nonatomic)NSString *softApPassword;
@property(strong, nonatomic)NSString *softApSsid;

@property(assign, nonatomic)int staConnectionStatus;
@property(strong, nonatomic)NSString *staBssid;
@property(strong, nonatomic)NSString *staSsid;
@property(strong, nonatomic)NSString *staPassword;

- (BOOL)isStaConnectWiFi;

/**
블루투스 장치의 상태 정보를 문자열 형태로 반환하는 메소드입니다.
@return 블루투스 장치의 상태 정보를 문자열 형태로 반환합니다.
*/
- (NSString *)getStatusInfo;

@end

NS_ASSUME_NONNULL_END
