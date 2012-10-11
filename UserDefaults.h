//
//  UserDefaults.h
//  SimpleCap
//
//  Created by - on 08/09/14.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define UDKEY_FILENAME_DATE		@"FilenameDate"
#define UDKEY_FILENAME_NUMBER	@"FilenameNumber"

// General
#define UDKEY_IMAGE_FORMAT		@"General_ImageFormat"
#define UDKEY_IMAGE_LOCATION	@"General_ImageLocation"
#define UDKEY_PLAY_SOUND		@"General_PlaySound"
#define UDKEY_OPEN_APPLICATION	@"General_OpenApplication"
#define UDKEY_CURSOR_METHOD		@"General_CursorMethod"
#define UDKEY_USE_SIMPLEVIEWER	@"General_UseSimpleViewer"
#define UDKEY_HOT_KEY_ENABLE	@"General_HotKeyEnable"
#define UDKEY_HOT_KEY			@"General_HotKey"

// Applications
#define UDKEY_APPLICATION1		@"Application1"
#define UDKEY_APPLICATION2		@"Application2"
#define UDKEY_APPLICATION3		@"Application3"
#define UDKEY_APPLICATION4		@"Application4"
#define UDKEY_APPLICATION5		@"Application5"

// Output Options
#define UDKEY_MOUSE_CURSOR		@"ImageOptions_MouseCursor"
#define UDKEY_WINDOW_SHADOW		@"ImageOptions_WindowShadow"
#define UDKEY_BACKGROUND		@"ImageOptions_Background"

// Selection Options
#define UDKEY_SELECTION_WHITE_FRAME	@"SelectionOptions_WhiteFrame"
#define UDKEY_SELECTION_SHADOW		@"SelectionOptions_Shadow"
#define UDKEY_SELECTION_ROUND_RECT	@"SelectionOptions_RoundRect"
#define UDKEY_SELECTION_EXCLUDE_ICONS	@"SelectionOption_ExcludeIcons"

// Viewer Options
#define UDKEY_VIEWER_BACKGROUND	@"ViewerOptions_Background"
#define UDKEY_VIEWER_IMAGEBOUNDS	@"ViewerOptions_ImageBounds"

// Screen Options
#define UDKEY_SCREEN_EXCLUDE_ICONS	@"ScreenOption_ExcludeIcons"

// Selection Options
#define UDKEY_MENU_ACTUAL_WIDTH		@"MenuOption_ActualWidth"

// Selection History
//#define	UDKEY_SELECTION_HISTORY	@"SelectionHistory"

// Selection Size
#define UDKEY_SELECTION_WIDTH1	@"SelectionWidth1"
#define UDKEY_SELECTION_WIDTH2	@"SelectionWidth2"
#define UDKEY_SELECTION_WIDTH3	@"SelectionWidth3"
#define UDKEY_SELECTION_WIDTH4	@"SelectionWidth4"
#define UDKEY_SELECTION_WIDTH5	@"SelectionWidth5"
#define UDKEY_SELECTION_HEIGHT1	@"SelectionHeight1"
#define UDKEY_SELECTION_HEIGHT2	@"SelectionHeight2"
#define UDKEY_SELECTION_HEIGHT3	@"SelectionHeight3"
#define UDKEY_SELECTION_HEIGHT4	@"SelectionHeight4"
#define UDKEY_SELECTION_HEIGHT5	@"SelectionHeight5"
#define UDKEY_SELECTION_NAME1	@"SelectionName1"
#define UDKEY_SELECTION_NAME2	@"SelectionName2"
#define UDKEY_SELECTION_NAME3	@"SelectionName3"
#define UDKEY_SELECTION_NAME4	@"SelectionName4"
#define UDKEY_SELECTION_NAME5	@"SelectionName5"

// Timer
#define UDKEY_TIMER_SECOND		@"Timer_Second"
#define DEFAULT_TIMER_TIMES		10

@interface UserDefaults : NSObject {

}

+ (void)setup;
+ (NSUserDefaults*)values;
+ (id)valueForKey:(NSString*)key;

+ (void)setValue:(id)value forKey:(NSString*)key;
+ (void)save;

+ (void)resetValueForKey:(NSString*)key;

+ (void)addObserver:(id)observer forKey:(NSString*)key;
+ (void)removeObserver:(id)observer forKey:(NSString*)key;
@end
