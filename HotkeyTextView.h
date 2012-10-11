//
//  HotkeyTextView.h
//

#import <Cocoa/Cocoa.h>

@class Hotkey;
@interface HotkeyTextView : NSTextView {

	BOOL _is_editing;
	Hotkey* _hotkey;
	
	id _target;
}

@property (retain) Hotkey* hotkey;
@property (retain) id target;

- (void)endEdit;

@end
