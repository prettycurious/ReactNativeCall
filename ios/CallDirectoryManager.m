//
//  CallDirectoryManager.m
//  ReactNativeCall
//
//  Created by user on 2019/2/25.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "CallDirectoryManager.h"

#import <React/RCTLog.h>
#import <React/RCTConvert.h>

@interface CallDirectoryManager ()

/** externsion的Bundle ID **/
@property (nonatomic, strong) NSString *externsionIdentifier;
/** APP Groups的ID **/
@property (nonatomic, strong) NSString *groupIdentifier;
/** 存储待写入电话号码与标识，key：号码，value：标识 **/
@property (nonatomic, strong) NSMutableDictionary *dataList;
/** 带国家码的手机号 **/
@property (nonatomic, strong) NSPredicate *phoneNumberWithNationCodePredicate;
/** 不带国家码的手机号 **/
@property (nonatomic, strong) NSPredicate *phoneNumberWithoutNationCodePredicate;

@end

@implementation CallDirectoryManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(addPhone:(NSString *)phone details:(NSDictionary *)details)
{
  NSString *label = [RCTConvert NSString:details[@"label"]];
  [self.dataList setObject:label forKey:phone];
  NSLog(@"%@", self.dataList);
}

RCT_EXPORT_METHOD(addInfo:(NSString *)phone details:(NSDictionary *)details)
{
  NSString *externsionIdentifier = @"net.stec.demo.CallDirectory";
  self.externsionIdentifier = externsionIdentifier;
  NSString *groupIdentifier = @"group.net.stec.CallKitDemo";
  self.groupIdentifier = groupIdentifier;
  NSString *label = [RCTConvert NSString:details[@"label"]];
  RCTLogInfo(@"手机号码：%@ 标签：%@", phone, label);
  
//  [self.dataList setObject:label forKey:phone];
  CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
  
  [manager getEnabledStatusForExtensionWithIdentifier:@"net.stec.demo.CallDirectory"
    completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error) {
      if (error) {
        RCTLogInfo(@"权限状态error：%zd", enabledStatus);
        return;
      }
      
      if (enabledStatus == CXCallDirectoryEnabledStatusUnknown) {
        RCTLogInfo(@"权限状态CXCallDirectoryEnabledStatusUnknown：%zd", enabledStatus);
      } else if (enabledStatus == CXCallDirectoryEnabledStatusDisabled) {
        RCTLogInfo(@"权限状态CXCallDirectoryEnabledStatusDisabled：%zd", enabledStatus);
      } else if (enabledStatus == CXCallDirectoryEnabledStatusEnabled) {
        RCTLogInfo(@"权限状态CXCallDirectoryEnabledStatusEnabled：%zd", enabledStatus);
        if (self.dataList.count == 0) {
          RCTLogInfo(@"dataList：%zd", self.dataList.count);
        }
        
        RCTLogInfo(@"dataList：%@", self.dataList);
        
        if (![self writeDataToAppGroupFile]) {
          RCTLogInfo(@"writeDataToAppGroupFile：%@", [self writeDataToAppGroupFile]?@"YES":@"NO");
        }
        // 有权限，调用reload
        [manager reloadExtensionWithIdentifier:@"net.stec.demo.CallDirectory" completionHandler:^(NSError * _Nullable error) {
          if (error) {
            // CXErrorCodeCallDirectoryManagerError
            RCTLogInfo(@"错误：%@", error);
          } else {
            RCTLogInfo(@"成功：%@", @"成功");
          }
        }];
      }
  }];
}

- (instancetype)initWithExtensionIdentifier:(NSString *)externsionIdentifier ApplicationGroupIdentifier:(NSString *)groupIdentifier {
  if (self = [super init]) {
    self.externsionIdentifier = externsionIdentifier;
    self.groupIdentifier = groupIdentifier;
  }
  return self;
}

- (void)getEnableStatus:(void (^)(CXCallDirectoryEnabledStatus enabledStatus, NSError * error))completion {
  CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
  [manager
   getEnabledStatusForExtensionWithIdentifier:self.externsionIdentifier
   completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error) {
     completion(enabledStatus, error);
   }];
}

- (BOOL)addPhoneNumber:(NSString *)phoneNumber label:(NSString *)label {
  if (!phoneNumber || ![phoneNumber isKindOfClass:[NSString class]] ||
      !label || ![label isKindOfClass:[NSString class]] || label.length == 0) {
    return NO;
  }
  
  NSString *handledPhoneNumber = [self handlePhoneNumber:phoneNumber];
  if (!handledPhoneNumber) {
    return NO;
  }
  
  if (self.dataList[handledPhoneNumber]) { // 已经设置过这个phoneNumber
    return NO;
  }
  
  [self.dataList setObject:label forKey:handledPhoneNumber];
  return YES;
}

- (BOOL)reload:(void (^)(NSError *error))completion {
  if (self.dataList.count == 0) {
    return NO;
  }
  
  if (![self writeDataToAppGroupFile]) {
    return NO;
  }
  
  CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
  [manager reloadExtensionWithIdentifier:self.externsionIdentifier completionHandler:^(NSError * _Nullable error) {
    completion(error);
  }];
  
  return YES;
}

#pragma mark -
#pragma mark -Inner Method

- (void)clearPhoneNumber {
  [self.dataList removeAllObjects];
}

/**
 处理手机号码
 自动加上国家码，如果号码不合规返回nil
 */
- (NSString *)handlePhoneNumber:(NSString *)phoneNumber {
  if ([self.phoneNumberWithNationCodePredicate evaluateWithObject:phoneNumber]) {
    return phoneNumber;
  }
  
  if ([self.phoneNumberWithoutNationCodePredicate evaluateWithObject:phoneNumber]) {
    return [NSString stringWithFormat:@"86%@", phoneNumber];
  }
  
  return nil;
}

/**
 对dataList中的记录进行升序排序，然后转换为string
 */
- (NSString *)dataToString {
  NSMutableArray *phoneArray = [NSMutableArray arrayWithArray:[self.dataList allKeys]];
  [phoneArray sortUsingSelector:@selector(compare:)];
  NSMutableString *dataStr = [[NSMutableString alloc] init];
  
  for (NSString *phone in phoneArray) {
    NSString *label = self.dataList[phone];
    NSString *dicStr = [NSString stringWithFormat:@"{\"%@\":\"%@\"}\n", phone, label];
    [dataStr appendString:dicStr];
  }
  
  return [dataStr copy];
}

/**
 将数据写入APP Group指定文件中
 */
- (BOOL)writeDataToAppGroupFile {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.net.stec.CallKitDemo"];
  containerURL = [containerURL URLByAppendingPathComponent:@"CallDirectoryData"];
  NSString* filePath = containerURL.path;
  
  if (!filePath || ![filePath isKindOfClass:[NSString class]]) {
    return NO;
  }
  
  if([fileManager fileExistsAtPath:filePath]) {
    [fileManager removeItemAtPath:filePath error:nil];
  }
  
  if (![fileManager createFileAtPath:filePath contents:nil attributes:nil]) {
    return NO;
  }
  
  BOOL result = [[self dataToString] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
  [self clearPhoneNumber];
  
  return result;
}

#pragma mark -
#pragma mark -Getter

- (NSMutableDictionary *)dataList {
  if (!_dataList) {
    _dataList = [NSMutableDictionary dictionary];
  }
  return _dataList;
}

- (NSPredicate *)phoneNumberWithNationCodePredicate {
  if (!_phoneNumberWithNationCodePredicate) {
    NSString *mobileWithNationCodeRegex = @"^861[0-9]{10}$";
    _phoneNumberWithNationCodePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileWithNationCodeRegex];
  }
  return _phoneNumberWithNationCodePredicate;
}

- (NSPredicate *)phoneNumberWithoutNationCodePredicate {
  if (!_phoneNumberWithoutNationCodePredicate) {
    NSString *mobileWithoutNationCodeRegex = @"^1[0-9]{10}$";
    _phoneNumberWithoutNationCodePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileWithoutNationCodeRegex];
  }
  return _phoneNumberWithoutNationCodePredicate;
}

@end
