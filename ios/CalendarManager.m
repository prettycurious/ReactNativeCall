//
//  CalendarManager.m
//  ReactNativeCall
//
//  Created by user on 2019/2/25.
//  Copyright © 2019 Facebook. All rights reserved.
//

// CalendarManager.m
#import "CalendarManager.h"
#import <React/RCTLog.h>
#import <React/RCTConvert.h>

@implementation CalendarManager

// To export a module named CalendarManager
RCT_EXPORT_MODULE();

// This would name the module AwesomeCalendarManager instead
// RCT_EXPORT_MODULE(AwesomeCalendarManager);

RCT_EXPORT_METHOD(addInfo:(NSString *)phone details:(NSDictionary *)details)
{
  NSString *label = [RCTConvert NSString:details[@"label"]];
  RCTLogInfo(@"手机号码：%@ 标签：%@", phone, label);
  RCTLogInfo(@"标签：%@",details);
}

@end
