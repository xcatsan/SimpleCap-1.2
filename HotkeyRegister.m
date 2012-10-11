//
//  HotkeyRegister.m
//

#import "HotkeyRegister.h"
#import "HotKey.h"
#define SC_HOTKEY_SIGNATURE	'schk'

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);

static HotkeyRegister* _hotkey_register = nil;
static UInt32 _hotkey_id = 0;

@implementation HotkeyRegister
@synthesize hotkey_set = _hotkey_set;

- (void)unregistAll
{
	for (Hotkey* hotkey in _hotkey_set) {
		[self unregistHotkey:hotkey];
	}
	[_hotkey_set removeAllObjects];

}


+ (HotkeyRegister*)sharedRegister
{
	if (!_hotkey_register) {
		
		_hotkey_register = [[HotkeyRegister alloc] init];
		_hotkey_register.hotkey_set = [[NSMutableSet alloc] init];
		EventTypeSpec eventTypeSpecList[] ={
			{ kEventClassKeyboard, kEventHotKeyPressed }
		};
		
		InstallApplicationEventHandler(
			   &hotKeyHandler, GetEventTypeCount(eventTypeSpecList),
			   eventTypeSpecList, self, NULL);
	}

	return _hotkey_register;
}


// Hot key handler
OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	EventHotKeyID hotKeyID;
	GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL,
					  sizeof(hotKeyID), NULL, &hotKeyID);
	
	if (hotKeyID.signature == SC_HOTKEY_SIGNATURE) {
		
		for (Hotkey* hotkey in _hotkey_register.hotkey_set) {
			if (hotKeyID.id == hotkey.keyid) {
				if (hotkey.target && [hotkey.target respondsToSelector:@selector(hotkeyDown:)]) {
					[hotkey.target performSelector:@selector(hotkeyDown:) withObject:hotkey];
				} else {
					NSLog(@"WARNING: Hotkey.target is null, or Hotkey.target instance does not implement hotkeyDown:(Htokey*), you should write the method on Hotkey.target");
					NSLog(@"Hotkey: %@", hotkey);
					NSLog(@"Hotkey.target: %@", hotkey.target);	
				}
			}
		}
	}	
	return noErr;
}

- (BOOL)unregistHotkey:(Hotkey*)hotkey
{
	OSStatus status = UnregisterEventHotKey(hotkey.ref);
	
	if (status != noErr) {
		NSLog(@"UnregisterEventHotKey() was failed : %d", status);
		return NO;
	}
	return YES;
}

- (BOOL)registHotkey:(Hotkey*)hotkey
{
	// replace
	if (hotkey.ref) {
		if (![self unregistHotkey:hotkey]) {
			return NO;
		}
	}
	
	/*
	if ([_hotkey_set containsObject:hotkey]) {
		// same hotkey exists, then replace it
		if (![self unregistHotkey:hotkey]) {
			// error
			return NO;
		}
	}
	*/

	EventHotKeyID hotKeyID;
	hotKeyID.id = _hotkey_id++;
	hotKeyID.signature = SC_HOTKEY_SIGNATURE;
	OSStatus status;
	EventHotKeyRef hotkeyRef;
	
	status = RegisterEventHotKey(hotkey.code, hotkey.modifier, hotKeyID,
								 GetApplicationEventTarget(), 0, &hotkeyRef);
	hotkey.ref = hotkeyRef;
	hotkey.keyid = hotKeyID.id;

	if (status != noErr) {
		NSLog(@"RegsiterEventHotKey() was failed : %d", status);
		return NO;
	}
	
	[_hotkey_set addObject:hotkey];

	return YES;
	
}

@end
