//
//  CalendarManager.m
//  TestNative
//
//  Created by PascalSun on 31/7/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

// CalendarManager.m
#import "CalendarManager.h"
#import <React/RCTLog.h>

@implementation CalendarManager

// To export a module named CalendarManager
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location)
{
  RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);
}
@end
