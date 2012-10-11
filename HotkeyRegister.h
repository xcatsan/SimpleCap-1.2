//
//  HotkeyRegister.h
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class Hotkey;
@interface HotkeyRegister : NSObject {
	
	NSMutableSet* _hotkey_set;
}

@property (retain) NSMutableSet* hotkey_set;

+ (HotkeyRegister*)sharedRegister;
- (void)unregistAll;

- (BOOL)registHotkey:(Hotkey*)hotkey;
- (BOOL)unregistHotkey:(Hotkey*)hotkey;

@end
