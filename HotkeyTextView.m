//
//  HotkeyTextView.m
//

#import "HotkeyTextView.h"
#import "Hotkey.h"
#import <Carbon/Carbon.h>

@implementation HotkeyTextView

@synthesize target = _target;

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self) {
		_is_editing = NO;
		[self setSelectable:NO];
		[self setFocusRingType:NSFocusRingTypeExterior];
		
	}
	return self;
}

- (void)redraw
{
	[self setString:[_hotkey string]];
}


- (void) dealloc
{
	[_hotkey release];
	[super dealloc];
}

- (void)startEdit
{
	[[self window] makeFirstResponder:self];
	[self setSelectable:YES];
	_is_editing = YES;
	NSRange range = NSMakeRange(0, [[self string] length]);
	[self setSelectedRange:range];
}

- (void)endEdit
{
	[self setSelectable:NO];
	_is_editing = NO;
	[self redraw];
}

- (void)mouseDown:(id)theEvent
{
	if ([theEvent clickCount] >= 2) {
		[self startEdit];
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	if (!_is_editing) {
		return;
	}
	
	UInt32 modifier = 0;
	UInt32 keycode = [theEvent keyCode];

	UInt32 old_modifier = _hotkey.modifier;
	UInt32 old_code = _hotkey.code;

	NSUInteger modifier_flags = [theEvent modifierFlags];
	if (modifier_flags & NSShiftKeyMask) {
		modifier |= shiftKey;
	}
	if (modifier_flags & NSCommandKeyMask) {
		modifier |= cmdKey;
	}
	if (modifier_flags & NSAlternateKeyMask) {
		modifier |= optionKey;
	}
	if (modifier_flags & NSControlKeyMask) {
		modifier |= controlKey;
	}
	
	if (!([Hotkey isHotKeyForModifier:modifier])) {
		if (keycode == kVK_Escape) {
			[self redraw];
		}
		// abort
		return;
	}
	
	 if (![Hotkey isHotKeyForKeyCode:keycode]) {
		 // abort
		 return;
	 }
	
	if (self.target && [self.target respondsToSelector:@selector(hotkeyShouldChange:)]) {

		_hotkey.modifier = modifier;
		_hotkey.code = keycode;
		
		SEL selector = @selector(hotkeyShouldChange:);
		NSMethodSignature* signature =
			[[self.target class] instanceMethodSignatureForSelector:selector];
		NSInvocation *invocation =
			[NSInvocation invocationWithMethodSignature:signature];
		BOOL result;
		[invocation setSelector:selector];
		[invocation setTarget:self.target];
		[invocation setArgument:&_hotkey atIndex:2];
		[invocation invoke];
		[invocation getReturnValue:&result];

		if (result) {
			[self redraw];
		} else {
			_hotkey.modifier = old_modifier;
			_hotkey.code = old_code;
		}
		
	} else {
		NSLog(@"WARNING: HotkeyTextView.target is null, HotkeyTextView.target instance does not implement changedHotkey:(Htokey*), you should write the method on HotkeyTextView.target");
		NSLog(@"Hotkey: %@", self.hotkey);
		NSLog(@"HotkeyTextView.target: %@", self.target);
	}
}

- (Hotkey*)hotkey
{
	return _hotkey;
}

- (void)setHotkey:(Hotkey*)hotkey
{
	[hotkey retain];
	[_hotkey release];
	_hotkey = hotkey;
	[self redraw];
}

- (BOOL)resignFirstResponder
{
	[self endEdit];
	return YES;
}


@end
