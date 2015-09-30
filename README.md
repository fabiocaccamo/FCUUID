FCUUID ![Pod version](http://img.shields.io/cocoapods/v/FCUUID.svg) ![Pod platforms](http://img.shields.io/cocoapods/p/FCUUID.svg) ![Pod license](http://img.shields.io/cocoapods/l/FCUUID.svg)
===================
iOS **UUID** library as alternative to the old good **UDID** and **identifierForVendor**.  
This library provides the simplest API to obtain **universally unique identifiers with different persistency levels**.  

It's possible to retrieve the **UUIDs created for all devices of the same user**, in this way with a little bit of server-side help **it's possible manage guest accounts across multiple devices easily.**

##Requirements & dependencies
- iOS >= 5.0
- ARC enabled
- Key-value storage enabled *(target / Capabilities / iCloud / Key-value storage)*
- Security.framework
- [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore)
- ***(optional)*** - KeyChain sharing enabled (entitlements and provisioning profile) if you need to **share** the same `uuidForDevice` / `uuidsOfUserDevices` values **across multiple apps with the same bundle seed**.

##Installation

####CocoaPods:
`pod 'FCUUID'`

####Manual install:
- Copy `FCUUID.h` and `FCUUID.m` to your project.
- Manual install [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore)

##Usage setup
It is recommended to do the setup in `applicationDidFinishLaunchingWithOptions` method.
- Add an observer to the `FCUUIDsOfUserDevicesDidChangeNotification` to be notified about uuids of user devices changes.
- If necessary, **migrate from a previously used UUID or UDID** using one of the migrations methods listed in the API section (it's recommended to do migration before calling `uuidForDevice` or `uuidsForUserDevices` methods). Keep in mind that **migration works only if the existing value is a valid uuid and `uuidForDevice` has not been created yet**.
- Call any class method to enforce iCloud sync.

##API
**Get different UUIDs** (each one with its own persistency level) 

```objective-c
//changes each time (no persistent)
+(NSString *)uuid;

//changes each time (no persistent), but allows to keep in memory more temporary uuids
+(NSString *)uuidForKey:(id<NSCopying>)key;

//changes each time the app gets launched (persistent to session)
+(NSString *)uuidForSession;

//changes each time the app gets installed (persistent to installation)
+(NSString *)uuidForInstallation;

//changes each time all the apps of the same vendor are uninstalled (this works exactly as identifierForVendor)
+(NSString *)uuidForVendor;

//changes only on system reset, this is the best replacement to the good old udid (persistent to device)
+(NSString *)uuidForDevice;
```
**Get the list of UUIDs of user devices**
```objective-c
//returns the list of all uuidForDevice of the same user, in this way it's possible manage guest accounts across multiple devices easily
+(NSArray *)uuidsOfUserDevices;
```
**Migrate from a previously stored UUID / UDID**  
Before migrating an existing value it's recommended to **debug it** by simply passing `commitMigration:NO` and logging the returned value.  
When you will be ready for committing the migration, use `commitMigration:YES`.  
After the migration, any future call to `uuidForDevice` will return the migrated value.
```objective-c
//these methods search for an existing UUID / UDID stored in the KeyChain or in UserDefaults for the given key / service / access-group
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup commitMigration:(BOOL)commitMigration;
```
**Check if value is a valid UUID**
```objective-c
+(BOOL)uuidValueIsValid:(NSString *)uuidValue;
```

##Donate
Do you want to support me?

[![Donate](https://www.paypalobjects.com/webstatic/en_US/btn/btn_donate_pp_142x27.png "Buy me a beer! - C.R.E.A.M.")](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=fabio%2ecaccamo%40gmail%2ecom&lc=IT&item_name=Fabio%20Caccamo%20%2d%20Open%20Source%20Projects&item_number=FCUUID&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted "Buy me a beer! - C.R.E.A.M.")

##License
The MIT License (MIT)

Copyright (c) 2015 Fabio Cacccamo - fabio.caccamo@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

