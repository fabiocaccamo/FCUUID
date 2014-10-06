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
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *theUUIDString = (__bridge_transfer NSString *)string;
    theUUIDString = [theUUIDString lowercaseString];
    theUUIDString = [theUUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return theUUIDString;
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
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_uuidForInstallation forKey:_uuidForInstallationKey];
            [defaults synchronize];
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
    
    if( _uuidForDevice == nil ){
        _uuidForDevice = [UICKeyChainStore stringForKey:_uuidForDeviceKey];
        
        if( _uuidForDevice == nil ){
            _uuidForDevice = [[NSUserDefaults standardUserDefaults] stringForKey:_uuidForDeviceKey];
            
            if( _uuidForDevice == nil ){
                _uuidForDevice = [self uuid];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:_uuidForDevice forKey:_uuidForDeviceKey];
                [defaults synchronize];
            }
            
            [UICKeyChainStore setString:_uuidForDevice forKey:_uuidForDeviceKey];
        }
    }
    
    return _uuidForDevice;
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
        
        NSDictionary *iCloudDict = [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
        //NSLog(@"uuidsOfUserDevicesSync: %@", iCloudDict);
        
        [iCloudDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSString *uuidKey = (NSString *)key;
            
            if([uuidKey rangeOfString:_uuidForDeviceKey].location == 0)
            {
                if([obj isKindOfClass:[NSString class]])
                {
                    NSString *uuidValue = (NSString *)obj;
                    
                    if([uuidKey rangeOfString:uuidValue].location != NSNotFound && [uuidValue length] >= 32)
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
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_uuidsOfUserDevices forKey:_uuidsOfUserDevicesKey];
            [defaults synchronize];
            
            [UICKeyChainStore setString:_uuidsOfUserDevices forKey:_uuidsOfUserDevicesKey];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[self uuidsOfUserDevices] forKey:@"uniqueIdentifiersOfUserDevices"];
            [[NSNotificationCenter defaultCenter] postNotificationName:FCUUIDsOfUserDevicesDidChangeNotification object:self userInfo:userInfo];
        }
    }
}


-(NSArray *)uuidsOfUserDevices
{
    if( _uuidsOfUserDevices == nil ){
        _uuidsOfUserDevices = [UICKeyChainStore stringForKey:_uuidsOfUserDevicesKey];
        
        if( _uuidsOfUserDevices == nil ){
            _uuidsOfUserDevices = [[NSUserDefaults standardUserDefaults] stringForKey:_uuidsOfUserDevicesKey];
            
            if( _uuidsOfUserDevices == nil ){
                _uuidsOfUserDevices = [self uuidForDevice];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:_uuidsOfUserDevices forKey:_uuidsOfUserDevicesKey];
                [defaults synchronize];
            }
            
            [UICKeyChainStore setString:_uuidsOfUserDevices forKey:_uuidsOfUserDevicesKey];
        }
    }
    
    return [_uuidsOfUserDevices componentsSeparatedByString:@"|"];
}


+(NSString *)uuid
{
    return [[self sharedInstance] uuid];
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


+(NSArray *)uuidsOfUserDevices
{
    return [[self sharedInstance] uuidsOfUserDevices];
}


@end