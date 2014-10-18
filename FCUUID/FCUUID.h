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
    NSMutableDictionary *_uuidForKey;
    NSString *_uuidForSession;
    NSString *_uuidForInstallation;
    NSString *_uuidForDevice;
    NSString *_uuidsOfUserDevices;
    NSMutableOrderedSet *_uuidsOfUserDevicesSet;
}

+(NSString *)uuid;
+(NSString *)uuidForKey:(id<NSCopying>)key;
+(NSString *)uuidForSession;
+(NSString *)uuidForInstallation;
+(NSString *)uuidForVendor;
+(NSString *)uuidForDevice;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup commitMigration:(BOOL)commitMigration;
+(NSArray *)uuidsOfUserDevices;

+(BOOL)uuidValueIsValid:(NSString *)uuidValue;

@end