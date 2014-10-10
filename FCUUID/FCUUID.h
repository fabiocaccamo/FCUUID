//
//  FCUUID
//
//  Created by Fabio Caccamo on 26/06/14.
//  Copyright (c) 2014 Fabio Caccamo - http://www.fabiocaccamo.com/ - All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FCUUIDsOfUserDevicesDidChangeNotification;

@interface FCUUID : NSObject
{
    NSString *_uuidForSession;
    NSString *_uuidForInstallation;
    NSString *_uuidForDevice;
    NSString *_uuidsOfUserDevices;
    NSMutableOrderedSet *_uuidsOfUserDevicesSet;
}

+(NSString *)uuid;
+(NSString *)uuidForSession;
+(NSString *)uuidForInstallation;
+(NSString *)uuidForVendor;
+(NSString *)uuidForDevice;
+(NSArray *)uuidsOfUserDevices;

@end