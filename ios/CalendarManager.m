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

@implementation CalendarManager

// To export a module named CalendarManager
RCT_EXPORT_MODULE();

// This would name the module AwesomeCalendarManager instead
// RCT_EXPORT_MODULE(AwesomeCalendarManager);

RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location)
{
  RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);
}

@end