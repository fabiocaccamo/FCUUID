FCUUID [![Pod version](https://badge.fury.io/co/FCUUID.svg)](http://badge.fury.io/co/FCUUID)
===================
iOS **UUID** library as alternative to the old good **UDID** and **identifierForVendor**.  

This library provides the simplest API to obtain **universally unique identifiers with different persistency levels**.  
All methods can be called as static methods or via the shared instance.  

It's possible to retrieve the **UUIDs created for all devices of the same user**, in this way with a little bit of server-side help **it's possible manage guest accounts across multiple devices easily.**

##Requirements & dependencies
- iOS >= 5.0
- ARC enabled
- Key-value storage enabled *(target / Capabilities / iCloud / Key-value storage)*
- Security.framework
- [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore)
- *(optional)* KeyChain sharing enabled (entitlements and provisioning profile) if you need to share the same uuidForDevice / uuidsOfUserDevices values accross multiple apps with the same bundle seed.

##Installation

####CocoaPods:
`pod 'FCUUID'`

####Manual install:
- Copy `FCUUID.h` and `FCUUID.m` to your project.
- Manual install [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore)

##Usage setup
- Add an observer to the **FCUUIDsOfUserDevicesDidChangeNotification** to be notified about user devices changes.
- Call `[FCUUID sharedInstance]` or any other method in *applicationDidFinishLaunchingWithOptions* to start iCloud sync.

##API
All the following methods (excluding the last one) return a different Universally Unique Identifier, each one with its own persistency level.

```objective-c
//changes each time (no persistent)
+(NSString *)uuid;

//changes each time the app gets launched (persistent to session)
+(NSString *)uuidForSession;

//changes each time the app gets installed (persistent to installation)
+(NSString *)uuidForInstallation;

//changes each time all the apps of the same vendor are uninstalled (this works exactly as identifierForVendor)
+(NSString *)uuidForVendor;

//changes only on system reset, this is the best replacement to the good old udid (persistent to device)
+(NSString *)uuidForDevice;

//returns the list of all uuidForDevice of the same user
//in this way it's possible manage guest accounts across multiple devices easily.
+(NSArray *)uuidsOfUserDevices;
```

Enjoy :)
