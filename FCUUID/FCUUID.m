//
//  FCUUID
//
//  Created by Fabio Caccamo on 26/06/14.
//  Copyright (c) 2014 Fabio Caccamo - http://www.fabiocaccamo.com/ - All rights reserved.
//

#import "FCUUID.h"
#import "UICKeyChainStore.h"


@implementation FCUUID


NSString *const FCUUIDsOfUserDevicesDidChangeNotification = @"FCUUIDsOfUserDevicesDidChangeNotification";


NSString *const _uuidForInstallationKey = @"fc_uuidForInstallation";
NSString *const _uuidForDeviceKey = @"fc_uuidForDevice";
NSString *const _uuidsOfUserDevicesKey = @"fc_uuidsOfUserDevices";
NSString *const _uuidsOfUserDevicesToggleKey = @"fc_uuidsOfUserDevicesToggle";


+(FCUUID *)sharedInstance
{
    static FCUUID *instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


-(instancetype)init
{
    self = [super init];
    
    if(self)
    {
        [self uuidsOfUserDevices_iCloudInit];
    }
    
    return self;
}


-(NSString *)uuid
{
    //also known as uuid/universallyUniqueIdentifier
    
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    NSString *uuidValue = (__bridge_transfer NSString *)uuidStringRef;
    uuidValue = [uuidValue lowercaseString];
    uuidValue = [uuidValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuidValue;
}


-(NSString *)uuidForKey:(id<NSCopying>)key
{
    if( _uuidForKey == nil ){
        _uuidForKey = [[NSMutableDictionary alloc] init];
    }
    
    NSString *uuidValue = [_uuidForKey objectForKey:key];
    
    if( uuidValue == nil ){
        uuidValue = [self uuid];
        
        [_uuidForKey setObject:uuidValue forKey:key];
    }
    
    return uuidValue;
}


-(NSString *)uuidForSession
{
    if( _uuidForSession == nil ){
        _uuidForSession = [self uuid];
    }
    
    return _uuidForSession;
}


-(NSString *)uuidForInstallation
{
    if( _uuidForInstallation == nil ){
        _uuidForInstallation = [[NSUserDefaults standardUserDefaults] stringForKey:_uuidForInstallationKey];
        
        if( _uuidForInstallation == nil ){
            _uuidForInstallation = [self uuid];
            
            [[NSUserDefaults standardUserDefaults] setObject:_uuidForInstallation forKey:_uuidForInstallationKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return _uuidForInstallation;
}


-(NSString *)uuidForVendor
{
    return [[[[[UIDevice currentDevice] identifierForVendor] UUIDString] lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}


-(NSString *)uuidForDevice
{
    //also known as udid/uniqueDeviceIdentifier but this doesn't persists to system reset
    
    return [self uuidForDeviceUsingValue:nil];
}


-(NSString *)uuidForDeviceUsingValue:(NSString *)uuidValue
{
    //also known as udid/uniqueDeviceIdentifier but this doesn't persists to system reset
    
    NSString *uuidForDeviceInMemory = _uuidForDevice;
    /*
    //this would overwrite an existing uuid, it could be dangerous
    if( [self uuidValueIsValid:uuidValue] )
    {
        _uuidForDevice = uuidValue;
    }
    */
    if( _uuidForDevice == nil ){
        _uuidForDevice = [UICKeyChainStore stringForKey:_uuidForDeviceKey];
        
        if( _uuidForDevice == nil ){
            _uuidForDevice = [[NSUserDefaults standardUserDefaults] stringForKey:_uuidForDeviceKey];
            
            if( _uuidForDevice == nil )
            {
                if([self uuidValueIsValid:uuidValue] )
                {
                    _uuidForDevice = uuidValue;
                }
                else {
                    _uuidForDevice = [self uuid];
                }
            }
        }
    }
    
    if([self uuidValueIsValid:uuidValue] && ![_uuidForDevice isEqualToString:uuidValue])
    {
        [NSException raise:@"Cannot overwrite uuidForDevice" format:@"uuidForDevice has already been created and cannot be overwritten."];
    }
    
    if(![uuidForDeviceInMemory isEqualToString:_uuidForDevice])
    {
        [[NSUserDefaults standardUserDefaults] setObject:_uuidForDevice forKey:_uuidForDeviceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [UICKeyChainStore setString:_uuidForDevice forKey:_uuidForDeviceKey];
    }
    
    return _uuidForDevice;
}


-(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key commitMigration:(BOOL)commitMigration
{
    return [self uuidForDeviceMigratingValueForKey:key service:nil accessGroup:nil commitMigration:commitMigration];
}


-(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service commitMigration:(BOOL)commitMigration
{
    return [self uuidForDeviceMigratingValueForKey:key service:service accessGroup:nil commitMigration:commitMigration];
}


-(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup commitMigration:(BOOL)commitMigration
{
    NSString *uuidToMigrate = nil;
    
    uuidToMigrate = [UICKeyChainStore stringForKey:key service:service accessGroup:accessGroup];
    
    if( uuidToMigrate == nil )
    {
        uuidToMigrate = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
    
    if( commitMigration )
    {
        if([self uuidValueIsValid:uuidToMigrate])
        {
            return [self uuidForDeviceUsingValue:uuidToMigrate];
        }
        else {
            
            [NSException raise:@"Invalid uuid to migrate" format:@"uuid value should be a string of 32 or 36 characters."];
            
            return nil;
        }
    }
    else {
        return uuidToMigrate;
    }
}


-(void)uuidsOfUserDevices_iCloudInit
{
    if(NSClassFromString(@"NSUbiquitousKeyValueStore"))
    {
        NSUbiquitousKeyValueStore *iCloud = [NSUbiquitousKeyValueStore defaultStore];
        
        if(iCloud)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uuidsOfUserDevices_iCloudChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
            
            //if keychain contains more device identifiers than icloud, maybe that icloud has been empty, so re-write these identifiers to iCloud
            for ( NSString *uuidOfUserDevice in [self uuidsOfUserDevices] )
            {
                NSString *uuidOfUserDeviceAsKey = [NSString stringWithFormat:@"%@_%@", _uuidForDeviceKey, uuidOfUserDevice];
                
                if(![[iCloud stringForKey:uuidOfUserDeviceAsKey] isEqualToString:uuidOfUserDevice]){
                    [iCloud setString:uuidOfUserDevice forKey:uuidOfUserDeviceAsKey];
                }
            }
            
            //toggle a boolean value to force notification on other devices, useful for debug
            [iCloud setBool:![iCloud boolForKey:_uuidsOfUserDevicesToggleKey] forKey:_uuidsOfUserDevicesToggleKey];
            
            [iCloud synchronize];
        }
        else {
            //NSLog(@"iCloud not available");
        }
    }
    else {
        //NSLog(@"iOS < 5");
    }
}


-(void)uuidsOfUserDevices_iCloudChange:(NSNotification *)notification
{
    @synchronized(self){
        
        NSMutableOrderedSet *uuidsSet = [[NSMutableOrderedSet alloc] initWithArray:[self uuidsOfUserDevices]];
        NSInteger uuidsCount = [uuidsSet count];
        
        NSUbiquitousKeyValueStore *iCloud = [NSUbiquitousKeyValueStore defaultStore];
        NSDictionary *iCloudDict = [iCloud dictionaryRepresentation];
        
        //NSLog(@"uuidsOfUserDevicesSync: %@", iCloudDict);
        
        [iCloudDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSString *uuidKey = (NSString *)key;
            
            if([uuidKey rangeOfString:_uuidForDeviceKey].location == 0)
            {
                if([obj isKindOfClass:[NSString class]])
                {
                    NSString *uuidValue = (NSString *)obj;
                    
                    if([uuidKey rangeOfString:uuidValue].location != NSNotFound && [self uuidValueIsValid:uuidValue])
                    {
                        //NSLog(@"uuid: %@", uuidValue);
                        
                        [uuidsSet addObject:uuidValue];
                    }
                    else {
                        //NSLog(@"invalid uuid");
                    }
                }
            }
        }];
        
        if([uuidsSet count] != uuidsCount)
        {
            _uuidsOfUserDevices = [[uuidsSet array] componentsJoinedByString:@"|"];
            
            [[NSUserDefaults standardUserDefaults] setObject:_uuidsOfUserDevices forKey:_uuidsOfUserDevicesKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [UICKeyChainStore setString:_uuidsOfUserDevices forKey:_uuidsOfUserDevicesKey];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[self uuidsOfUserDevices] forKey:@"uuidsOfUserDevices"];
            [[NSNotificationCenter defaultCenter] postNotificationName:FCUUIDsOfUserDevicesDidChangeNotification object:self userInfo:userInfo];
        }
    }
}


-(NSArray *)uuidsOfUserDevices
{
    NSString *uuidsOfUserDevicesInMemory = _uuidsOfUserDevices;
    
    if( _uuidsOfUserDevices == nil ){
        _uuidsOfUserDevices = [UICKeyChainStore stringForKey:_uuidsOfUserDevicesKey];
        
        if( _uuidsOfUserDevices == nil ){
            _uuidsOfUserDevices = [[NSUserDefaults standardUserDefaults] stringForKey:_uuidsOfUserDevicesKey];
            
            if( _uuidsOfUserDevices == nil ){
                _uuidsOfUserDevices = [self uuidForDevice];
            }
        }
    }
    
    if(![uuidsOfUserDevicesInMemory isEqualToString:_uuidsOfUserDevices])
    {
        [[NSUserDefaults standardUserDefaults] setObject:_uuidsOfUserDevices forKey:_uuidsOfUserDevicesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [UICKeyChainStore setString:_uuidsOfUserDevices forKey:_uuidsOfUserDevicesKey];
    }
    
    return [_uuidsOfUserDevices componentsSeparatedByString:@"|"];
}


-(BOOL)uuidValueIsValid:(NSString *)uuidValue
{
    //TODO validation using Regular Expression
    return (uuidValue != nil && (uuidValue.length == 32 || uuidValue.length == 36));
}


+(NSString *)uuid
{
    return [[self sharedInstance] uuid];
}


+(NSString *)uuidForKey:(id<NSCopying>)key
{
    return [[self sharedInstance] uuidForKey:key];
}


+(NSString *)uuidForSession
{
    return [[self sharedInstance] uuidForSession];
}


+(NSString *)uuidForInstallation
{
    return [[self sharedInstance] uuidForInstallation];
}


+(NSString *)uuidForVendor
{
    return [[self sharedInstance] uuidForVendor];
}


+(NSString *)uuidForDevice
{
    return [[self sharedInstance] uuidForDevice];
}


+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key commitMigration:(BOOL)commitMigration
{
    return [[self sharedInstance] uuidForDeviceMigratingValueForKey:key service:nil accessGroup:nil commitMigration:commitMigration];
}


+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service commitMigration:(BOOL)commitMigration
{
    return [[self sharedInstance] uuidForDeviceMigratingValueForKey:key service:service accessGroup:nil commitMigration:commitMigration];
}


+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup commitMigration:(BOOL)commitMigration
{
    return [[self sharedInstance] uuidForDeviceMigratingValueForKey:key service:service accessGroup:accessGroup commitMigration:commitMigration];
}


+(NSArray *)uuidsOfUserDevices
{
    return [[self sharedInstance] uuidsOfUserDevices];
}


+(BOOL)uuidValueIsValid:(NSString *)uuidValue
{
    return [[self sharedInstance] uuidValueIsValid:uuidValue];
}


@end