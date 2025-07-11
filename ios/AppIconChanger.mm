#import "AppIconChanger.h"
#import <React/RCTLog.h>
#import <React/RCTConvert.h>
#import <objc/runtime.h>

@implementation AppIconChanger

RCT_EXPORT_MODULE(DynamicIconManager);

RCT_REMAP_METHOD(getActiveIcon,
                 activeResolver:(RCTPromiseResolveBlock)resolve
                 activeRejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{
      if (![[UIApplication sharedApplication] supportsAlternateIcons]) {
          reject(@"ERROR", @"iOS: Alternate icons are not supported on this device.", nil);
          return;
      }

      NSString *currentIcon = [[UIApplication sharedApplication] alternateIconName];
      if (currentIcon == nil) {
          resolve(@"Default");
      } else {
          resolve(currentIcon);
      }
  });
}

RCT_REMAP_METHOD(getAllAlternativeIcons,
                 allIconsResolver:(RCTPromiseResolveBlock)resolve
                 allIconsRejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{
      if (![[UIApplication sharedApplication] supportsAlternateIcons]) {
          reject(@"ERROR", @"iOS: Alternate icons are not supported on this device.", nil);
          return;
      }

      @try {
          NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
          NSDictionary *icons = infoPlist[@"CFBundleIcons"];
          NSDictionary *alternateIcons = icons[@"CFBundleAlternateIcons"];

          if (!alternateIcons) {
              resolve(@[@"Default"]);
              return;
          }

          NSMutableArray *iconList = [NSMutableArray arrayWithObject:@"Default"];
          for (NSString *iconName in alternateIcons) {
              [iconList addObject:iconName];
          }

          resolve(iconList);
      } @catch (NSException *exception) {
          reject(@"ERROR", @"Failed to retrieve icons from Info.plist.", nil);
      }
  });
}

RCT_REMAP_METHOD(setIcon,
                 iconName:(NSString *)iconName
                 setResolver:(RCTPromiseResolveBlock)resolve
                 setRejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{
      if (![[UIApplication sharedApplication] supportsAlternateIcons]) {
          reject(@"ERROR", @"iOS: Alternate icons are not supported on this device.", nil);
          return;
      }

      if (iconName == nil || [iconName isEqualToString:@""]) {
          reject(@"ERROR", @"Invalid iconName: iconName cannot be nil or empty.", nil);
          return;
      }

      NSString *currentIcon = [[UIApplication sharedApplication] alternateIconName];

      if ([iconName isEqualToString:currentIcon]) {
          reject(@"ERROR", @"iOS: The specified icon is already in use.", nil);
          return;
      }

      NSString *newIconName = [iconName isEqualToString:@"Default"] ? nil : iconName;

      NSLog(@"Changing icon to %@", newIconName ?: @"Default");

      // Use the private method approach
      typedef void (*SetAlternateIconNameIMP)(id, SEL, NSString*, void(^)(NSError*));

      NSString *selectorString = @"_setAlternateIconName:completionHandler:";
      SEL selector = NSSelectorFromString(selectorString);

      IMP methodIMP = [[UIApplication sharedApplication] methodForSelector:selector];

      if (methodIMP) {
          SetAlternateIconNameIMP method = (SetAlternateIconNameIMP)methodIMP;
          method([UIApplication sharedApplication], selector, newIconName, ^(NSError *error) {
              if (error) {
                  reject(@"ERROR", error.localizedDescription, nil);
              } else {
                  resolve([NSString stringWithFormat:@"Icon changed to %@", iconName]);
              }
          });
      } else {
          // Fallback to the standard method
          [[UIApplication sharedApplication] setAlternateIconName:newIconName completionHandler:^(NSError * _Nullable error) {
              if (error) {
                  reject(@"ERROR", error.localizedDescription, nil);
              } else {
                  resolve([NSString stringWithFormat:@"Icon changed to %@", iconName]);
              }
          }];
      }
  });
}

RCT_REMAP_METHOD(resetIcon,
                 resetResolver:(RCTPromiseResolveBlock)resolve
                 resetRejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{
      if (![[UIApplication sharedApplication] supportsAlternateIcons]) {
          reject(@"ERROR", @"iOS: Alternate icons are not supported on this device.", nil);
          return;
      }

      NSLog(@"Resetting icon to Default");

      // Use the private method approach for reset as well
      typedef void (*SetAlternateIconNameIMP)(id, SEL, NSString*, void(^)(NSError*));

      NSString *selectorString = @"_setAlternateIconName:completionHandler:";
      SEL selector = NSSelectorFromString(selectorString);

      IMP methodIMP = [[UIApplication sharedApplication] methodForSelector:selector];

      if (methodIMP) {
          SetAlternateIconNameIMP method = (SetAlternateIconNameIMP)methodIMP;
          method([UIApplication sharedApplication], selector, nil, ^(NSError *error) {
              if (error) {
                  NSLog(@"Failed to reset to default icon: %@", error.localizedDescription);
                  reject(@"ERROR", error.localizedDescription, nil);
              } else {
                  NSLog(@"Successfully reset to default icon.");
                  resolve(@"Icon reset to default.");
              }
          });
      } else {
          // Fallback to the standard method
          [[UIApplication sharedApplication] setAlternateIconName:nil completionHandler:^(NSError * _Nullable error) {
              if (error) {
                  NSLog(@"Failed to reset to default icon: %@", error.localizedDescription);
                  reject(@"ERROR", error.localizedDescription, nil);
              } else {
                  NSLog(@"Successfully reset to default icon.");
                  resolve(@"Icon reset to default.");
              }
          }];
      }
  });
}

@end
