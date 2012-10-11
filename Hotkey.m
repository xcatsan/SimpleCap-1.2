//
//  Hotkey.m
//

#import "Hotkey.h"
#import <Carbon/Carbon.h>

static const struct {
	UInt32		keycode;
	NSString*	description;
	NSString*	string;
	BOOL		is_hotkey;
}
_keymap[] = {
{ 0xffffffff				, @"Unkown"			, @"Unkown"			, NO  },
{ kVK_ANSI_A				, @"A"				, @"A"				, YES },
{ kVK_ANSI_S				, @"S"				, @"S"				, YES },
{ kVK_ANSI_D				, @"D"				, @"D"				, YES },
{ kVK_ANSI_F				, @"F"				, @"F"				, YES },
{ kVK_ANSI_H				, @"H"				, @"H"				, YES },
{ kVK_ANSI_G				, @"G"				, @"G"				, YES },
{ kVK_ANSI_Z				, @"Z"				, @"Z"				, YES },
{ kVK_ANSI_X				, @"X"				, @"X"				, YES },
{ kVK_ANSI_C				, @"C"				, @"C"				, YES },
{ kVK_ANSI_V				, @"V"				, @"V"				, YES },
{ kVK_ANSI_B				, @"B"				, @"B"				, YES },
{ kVK_ANSI_Q				, @"Q"				, @"Q"				, YES },
{ kVK_ANSI_W				, @"W"				, @"W"				, YES },
{ kVK_ANSI_E				, @"E"				, @"E"				, YES },
{ kVK_ANSI_R				, @"R"				, @"R"				, YES },
{ kVK_ANSI_Y				, @"Y"				, @"Y"				, YES },
{ kVK_ANSI_T				, @"T"				, @"T"				, YES },
{ kVK_ANSI_1				, @"1"				, @"1"				, YES },
{ kVK_ANSI_2				, @"2"				, @"2"				, YES },
{ kVK_ANSI_3				, @"3"				, @"3"				, YES },
{ kVK_ANSI_4				, @"4"				, @"4"				, YES },
{ kVK_ANSI_6				, @"6"				, @"6"				, YES },
{ kVK_ANSI_5				, @"5"				, @"5"				, YES },
{ kVK_ANSI_Equal			, @"Equal"			, @"="				, YES },
{ kVK_ANSI_9				, @"9"				, @"9"				, YES },
{ kVK_ANSI_7				, @"7"				, @"7"				, YES },
{ kVK_ANSI_Minus			, @"Minus"			, @"-"				, YES },
{ kVK_ANSI_8				, @"8"				, @"8"				, YES },
{ kVK_ANSI_0				, @"0"				, @"0"				, YES },
{ kVK_ANSI_RightBracket		, @"RightBracket"	, @"]"				, YES },
{ kVK_ANSI_O				, @"O"				, @"O"				, YES },
{ kVK_ANSI_U				, @"U"				, @"U"				, YES },
{ kVK_ANSI_LeftBracket		, @"LeftBracket"	, @"["				, YES },
{ kVK_ANSI_I				, @"I"				, @"I"				, YES },
{ kVK_ANSI_P				, @"P"				, @"P"				, YES },
{ kVK_ANSI_L				, @"L"				, @"L"				, YES },
{ kVK_ANSI_J				, @"J"				, @"J"				, YES },
{ kVK_ANSI_Quote			, @"Quote"			, @"'"				, YES },
{ kVK_ANSI_K				, @"K"				, @"K"				, YES },
{ kVK_ANSI_Semicolon		, @"Semicolon"		, @";"				, YES },
{ kVK_ANSI_Backslash		, @"Backslash"		, @"\\"				, YES },
{ kVK_ANSI_Comma			, @"Comma"			, @","				, YES },
{ kVK_ANSI_Slash			, @"Slash"			, @"/"				, YES },
{ kVK_ANSI_N				, @"N"				, @"N"				, YES },
{ kVK_ANSI_M				, @"M"				, @"M"				, YES },
{ kVK_ANSI_Period			, @"Period"			, @"."				, YES },
{ kVK_ANSI_Grave			, @"Grave"			, @"`"				, YES },
{ kVK_ANSI_KeypadDecimal	, @"KeypadDecimal"	, @"Decimal"		, YES },
{ kVK_ANSI_KeypadMultiply	, @"KeypadMultiply"	, @"*"				, YES },
{ kVK_ANSI_KeypadPlus		, @"KeypadPlus"		, @"+"				, YES },
{ kVK_ANSI_KeypadClear		, @"KeypadClear"	, @"Clear"			, YES },
{ kVK_ANSI_KeypadDivide		, @"KeypadDivide"	, @"/"				, YES },
{ kVK_ANSI_KeypadEnter		, @"KeypadEnter"	, @"\u2305"			, YES },
{ kVK_ANSI_KeypadMinus		, @"KeypadMinus"	, @"-"				, YES },
{ kVK_ANSI_KeypadEquals		, @"KeypadEquals"	, @"="				, YES },
{ kVK_ANSI_Keypad0			, @"Keypad0"		, @"0"				, YES },
{ kVK_ANSI_Keypad1			, @"Keypad1"		, @"1"				, YES },
{ kVK_ANSI_Keypad2			, @"Keypad2"		, @"2"				, YES },
{ kVK_ANSI_Keypad3			, @"Keypad3"		, @"3"				, YES },
{ kVK_ANSI_Keypad4			, @"Keypad4"		, @"4"				, YES },
{ kVK_ANSI_Keypad5			, @"Keypad5"		, @"5"				, YES },
{ kVK_ANSI_Keypad6			, @"Keypad6"		, @"6"				, YES },
{ kVK_ANSI_Keypad7			, @"Keypad7"		, @"7"				, YES },
{ kVK_ANSI_Keypad8			, @"Keypad8"		, @"8"				, YES },
{ kVK_ANSI_Keypad9			, @"Keypad9"		, @"9"				, YES },
{ kVK_Return				, @"Return"			, @"\u21a9"			, YES },
{ kVK_Tab					, @"Tab"			, @"\u21e5"			, NO  },
{ kVK_Space					, @"Space"			, @"Space"			, YES },
{ kVK_Delete				, @"Delete"			, @"\u232b"			, NO  },
{ kVK_Escape				, @"Escapse"		, @"\u238b"			, YES },
{ kVK_Command				, @"Command"		, @"\u2318"			, NO  },
{ kVK_Shift					, @"Shift"			, @"\u21e7"			, NO  },
{ kVK_CapsLock				, @"CapsLock"		, @"CapsLock"		, NO  },
{ kVK_Option				, @"Option"			, @"\u2325"			, NO  },
{ kVK_Control				, @"Control"		, @"\u2302"			, NO  },
{ kVK_RightShift			, @"RightShift"		, @"\u21e7"			, NO  },
{ kVK_RightOption			, @"RightOption"	, @"\u2325"			, NO  },
{ kVK_RightControl			, @"RightControl"	, @"\u2302"			, NO  },
{ kVK_Function				, @"Function"		, @"Function"		, NO  },
{ kVK_F17					, @"F17"			, @"F17"			, NO  },
{ kVK_VolumeUp				, @"VolumeUp"		, @"VolumeUp"		, NO  },
{ kVK_VolumeDown			, @"VolumeDown"		, @"VolumeDown"		, NO  },
{ kVK_Mute					, @"Mute"			, @"Mute"			, NO  },
{ kVK_F18					, @"F18"			, @"F18"			, YES },
{ kVK_F19					, @"F19"			, @"F19"			, YES },
{ kVK_F20					, @"F20"			, @"F20"			, YES },
{ kVK_F5					, @"F5"				, @"F5"				, YES },
{ kVK_F6					, @"F6"				, @"F6"				, YES },
{ kVK_F7					, @"F7"				, @"F7"				, YES },
{ kVK_F3					, @"F3"				, @"F3"				, YES },
{ kVK_F8					, @"F8"				, @"F8"				, YES },
{ kVK_F9					, @"F9"				, @"F9"				, YES },
{ kVK_F11					, @"F11"			, @"F11"			, YES },
{ kVK_F13					, @"F13"			, @"F13"			, YES },
{ kVK_F16					, @"F16"			, @"F16"			, YES },
{ kVK_F14					, @"F14"			, @"F14"			, YES },
{ kVK_F10					, @"F10"			, @"F10"			, YES },
{ kVK_F12					, @"F12"			, @"F12"			, YES },
{ kVK_F15					, @"F15"			, @"F15"			, YES },
{ kVK_Help					, @"Help"			, @"\u225f"			, NO  },
{ kVK_Home					, @"Home"			, @"\u2196"			, NO  },
{ kVK_PageUp				, @"PageUp"			, @"\u21de"			, NO  },
{ kVK_ForwardDelete			, @"ForwardDelete"	, @"\u2326"			, NO  },
{ kVK_F4					, @"F4"				, @"F4"				, YES },
{ kVK_End					, @"End"			, @"\u2198"			, NO  },
{ kVK_F2					, @"F2"				, @"F2"				, YES },
{ kVK_PageDown				, @"PageDown"		, @"\u21df"			, NO  },
{ kVK_F1					, @"F1"				, @"F1"				, YES },
{ kVK_LeftArrow				, @"LeftArrow"		, @"\u2190"			, YES },
{ kVK_RightArrow			, @"RightArrow"		, @"\u2192"			, YES },
{ kVK_DownArrow				, @"DownArrow"		, @"\u2193"			, YES },
{ kVK_UpArrow				, @"UpArrow"		, @"\u2191"			, YES },
{ kVK_ISO_Section			, @"Section"		, @"Section"		, NO  },
{ kVK_JIS_Yen				, @"Yen"			, @"\u00a5"			, YES },
{ kVK_JIS_Underscore		, @"Underscore"		, @"_"				, YES },
{ kVK_JIS_KeypadComma		, @"KeypadComma"	, @","				, YES },
{ kVK_JIS_Eisu				, @"Eisu"			, @"Eisu"			, NO  },
{ kVK_JIS_Kana				, @"Kana"			, @"Kana"			, NO  }
};


@implementation Hotkey

@synthesize keyid = _keyid;
@synthesize modifier = _modifier;
@synthesize code = _code;
@synthesize ref = _ref;
@synthesize target = _target;
@synthesize savekey = _savekey;

- (BOOL)isEqual:(id)anObject
{
	if (anObject == self) {
		return YES;
	}
	if (!anObject || ![anObject isKindOfClass:[self class]]) {
		return NO;
	}
	if (self.code == [anObject code] && self.modifier == [anObject modifier]) {
		return YES;
	}
	return NO;
}

+ (NSNumber*)numberValueWithKeycode:(UInt32)code modifier:(UInt32)modifier
{
	return [NSNumber numberWithUnsignedInt:(modifier<<16|code)];
}

- (NSNumber*)numberValue
{
	return [Hotkey numberValueWithKeycode:self.code modifier:self.modifier];
}

- (id)initWithSavekey:(NSString*)savekey number:(NSNumber*)number target:(id)target
{
	self = [super init];
	if (self) {
		UInt32 value = [number unsignedIntValue];
		self.savekey = savekey;
		self.modifier = value >> 16;
		self.code = value & 0xffff;
		self.target = target;
	}
	return self;
}

/*
- (id)initWithCode:(UInt32)code modifier:(UInt32)modifier target:(id)target
{
	self = [super init];
	if (self) {
		self.modifier = modifier;
		self.code = code;
		self.target = target;
	}
	return self;
}


+ (id)hotkeyWithCode:(UInt32)code modifier:(UInt32)modifier target:(id)target
{
	return [[[Hotkey alloc] initWithCode:code modifier:modifier target:target] autorelease];
}
*/

- (NSString*)dump
{
	NSString* desc = [NSString stringWithFormat:@"keyid=%x, modifier=%x, code=%x, ref=%x, \n target=%@", self.keyid, self.modifier, self.code, self.ref, self.target];

	return desc;
}

+ (UInt32)indexOfKeymapForKeycode:(UInt32)keycode
{
	UInt32 index;
	UInt32 max = sizeof(_keymap)/sizeof(_keymap[0]);
	for (index=0; index < max; index++) {
		if (_keymap[index].keycode == keycode) {
			break;
		}
	}
	if (index == max) {
		index = 0;	// DUMMY
	}
	return index;
}

- (UInt32)indexOfKeymap
{
	return [Hotkey indexOfKeymapForKeycode:self.code];
}

- (NSString*)string
{
	NSString* key_desc = @"";
	
	if (self.modifier & controlKey) {
		key_desc = [key_desc stringByAppendingFormat:@"%C", kControlUnicode];
	}
	if (self.modifier & optionKey) {
		key_desc = [key_desc stringByAppendingFormat:@"%C", kOptionUnicode];
	}
	if (self.modifier & cmdKey) {
		key_desc = [key_desc stringByAppendingFormat:@"%C", kCommandUnicode];
	}
	if (self.modifier & shiftKey) {
		key_desc = [key_desc stringByAppendingFormat:@"%C", kShiftUnicode];
	}
	key_desc = [key_desc stringByAppendingFormat:@"%@", _keymap[[self indexOfKeymap]].string];
	
	return key_desc;
}

- (BOOL)isHotkey
{
	UInt32 index = [self indexOfKeymap];
	return _keymap[index].is_hotkey;
}

+ (BOOL)isHotKeyForKeyCode:(UInt32)keycode
{
	UInt32 index = [Hotkey indexOfKeymapForKeycode:keycode];
	return _keymap[index].is_hotkey;
}

+ (BOOL)isHotKeyForModifier:(UInt32)modifier
{
	if (modifier & (cmdKey | optionKey | controlKey)) {
		return YES;
	} else {
		return NO;
	}
}

@end
