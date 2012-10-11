//
//  Hotkey.h
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface Hotkey : NSObject {

	// Hotkey attrs
	UInt32 _keyid;	//TODO: id
	UInt32 _modifier;
	UInt32 _code;
	EventHotKeyRef _ref;
	NSString* _savekey;
	
	// Handler attrs
	id _target;

	// keydown:(Hotkey*)hotkey;
}

@property UInt32 keyid;
@property UInt32 modifier;
@property UInt32 code;
@property EventHotKeyRef ref;
@property (retain) NSString* savekey;
@property (retain) id target;

+ (NSNumber*)numberValueWithKeycode:(UInt32)code modifier:(UInt32)modifier;
- (NSNumber*)numberValue;
- (id)initWithSavekey:(NSString*)savekey number:(NSNumber*)number target:(id)target;
//- (id)initWithCode:(UInt32)code modifier:(UInt32)modifier target:(id)target;
//+ (id)hotkeyWithCode:(UInt32)code modifier:(UInt32)modifier target:(id)target;

- (NSString*)string;
- (BOOL)isHotkey;

+ (BOOL)isHotKeyForKeyCode:(UInt32)keycode;
+ (BOOL)isHotKeyForModifier:(UInt32)modifier;

- (NSString*)dump;


@end
