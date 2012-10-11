//
//  SimpleViewerController.m
//  SimpleCap
//
//  Created by - on 08/12/19.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "SimpleViewerController.h"
#import "SimpleViewerPanel.h"
#import "SimpleViewerImageView.h"
#import "SimpleViewerInfoView.h"
#import "SimpleViewerBackgroundView.h"
#import "ThinButtonBar.h"
#import "ApplicationButtonPallete.h"
#import "ApplicationButtonCell.h"
#import "AppController.h"
#import "FileManager.h"
#import "ApplicationMenu.h"
#import "FilenameTextField.h"
#import "FileEntry.h"
#import "UserDefaults.h"

enum SV_TAG {
	SV_TAG_TRASH,
	SV_TAG_PREFERENCE,
	SV_TAG_RETAKE,
	SV_TAG_APPLICATION,
	SV_TAG_NEXT_FILE,
	SV_TAG_PREVIOUS_FILE,
	SV_TAG_CLOSE,
	SV_TAG_SAVE,
	SV_TAG_CAPTURE,
	SV_TAG_CONFIG,
	SV_TAG_COPY,
	SV_TAG_CAPTURE_AGAIN,
	SV_TAG_OPERATION,
};

#define FILENAME_TEXTFIELD_HEIGHT	20
#define FILENAME_TEXTFIELD_WRATIO	1.0
#define FILENAME_TEXTFIELD_PADDING_Y 7
#define METALINE_MARGIN_X	0
#define METALINE_MARGIN_Y	3
#define	METALINE_HEIGHT		(FILENAME_TEXTFIELD_HEIGHT+METALINE_MARGIN_Y*2+2)
#define BUTTON_BAR_HEIGHT	(12.0+13)
#define BUTTON_MARGIN_BOTTOM	8
#define	BUTTON_MARGIN_LEFT		5
#define IMAGEVIEW_MARGIN_X	1
#define IMAGEVIEW_MARGIN_Y	1

@implementation SimpleViewerController

#pragma mark -
#pragma mark Handling FSEvent
-(void)showMessage:(NSString*)message
{
	[_app_controller showMessage:message];
}

void fsevents_callback(
					   ConstFSEventStreamRef streamRef,
					   void *userData,
					   size_t numEvents,
					   void *eventPaths,
					   const FSEventStreamEventFlags eventFlags[],
					   const FSEventStreamEventId eventIds[])
{
	
	// debug code
	/*
	int i;
	char **paths = eventPaths;
	NSLog(@"clicentCallBackInfo: %@", userData);
    for (i=0; i<numEvents; i++) {
        printf("Change %llu in %s, flags %lu\n",
			   eventIds[i], paths[i], eventFlags[i]);
	}
	 */
	SimpleViewerController* svc = (SimpleViewerController*)userData;
	if ([svc isOpened] && [svc updateOpendFile]) {
		[svc showMessage:NSLocalizedString(@"FileUpdated", @"")];
	}
}

- (void)updateFSEventStream
{
	if (_fsevent_stream) {
		FSEventStreamStop(_fsevent_stream);
		FSEventStreamInvalidate(_fsevent_stream);
	}

	NSString* path = [UserDefaults valueForKey:UDKEY_IMAGE_LOCATION];
	NSArray* pathsToWatch = [NSArray arrayWithObjects:path, nil];
	void *selfPointer = (void*)self;
	FSEventStreamContext context = {0, selfPointer, NULL, NULL, NULL};
    NSTimeInterval latency = 3.0; /* Latency in seconds */

	/*
	 SimpleCap[28181] (CarbonCore.framework) FSEventStreamCreate: _FSEventStreamCreate: ERROR: could not allocate 0 bytes for array of path strings
	 SimpleCap[28181] (CarbonCore.framework) FSEventStreamScheduleWithRunLoop(): failed assertion 'streamRef != NULL'
	 
	 SimpleCap[28181] (CarbonCore.framework) FSEventStreamStart(): failed assertion 'streamRef != NULL'
	 */
    /* Create the stream, passing in a callback */
	_fsevent_stream = FSEventStreamCreate(NULL,
								 &fsevents_callback,
								 &context,
								 (CFArrayRef)pathsToWatch,
								 kFSEventStreamEventIdSinceNow,
								 latency,
								 kFSEventStreamCreateFlagNone /* Flags explained in reference */
								 );
	
    /* Create the stream before calling this. */
	FSEventStreamScheduleWithRunLoop(_fsevent_stream,
									 CFRunLoopGetCurrent(),
									 kCFRunLoopDefaultMode
									 );
	
	FSEventStreamStart(_fsevent_stream);
	
}

#pragma mark -
#pragma mark Handling KVO event
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	// keyPath=values.General_ImageLocation
	[self updateFSEventStream];
}

#pragma mark -
#pragma mark Initialization and deallocation
- (id)init
{
	self = [super init];
	if (self) {
		_panel = [[SimpleViewerPanel alloc] initWithController:self];
		[_panel setDelegate:self];
	
		_button_bar = [[[ThinButtonBar alloc] initWithFrame:NSZeroRect] autorelease];

/*
		[_button_bar addButtonWithImageResource:@"viewer_close"
							 alterImageResource:@"viewer_close2"
											tag:SV_TAG_CLOSE
										tooltip:NSLocalizedString(@"ViewerClose", @"")
										  group:nil];
*/
		[_button_bar addButtonWithImageResource:@"viewer_trash"
							 alterImageResource:@"viewer_trash2"
											tag:SV_TAG_TRASH
										tooltip:NSLocalizedString(@"ViewerTrash", @"")
										  group:nil
							   isActOnMouseDown:NO];

		[_button_bar addButtonWithImageResource:@"viewer_repeat"
							 alterImageResource:@"viewer_repeat2"
											tag:SV_TAG_CAPTURE_AGAIN
										tooltip:NSLocalizedString(@"ViewerRepeat", @"")
										  group:@"REPEAT"
							   isActOnMouseDown:NO];
		
		[_button_bar addButtonWithImageResource:@"viewer_repeat"
							 alterImageResource:@"viewer_repeat2"
											tag:SV_TAG_RETAKE
										tooltip:NSLocalizedString(@"ViewerRepeat", @"")
										  group:@"REPEAT"
							   isActOnMouseDown:NO];
		
		[_button_bar addButtonWithImageResource:@"viewer_config"
							 alterImageResource:@"viewer_config2"
											tag:SV_TAG_CONFIG
										tooltip:NSLocalizedString(@"ViewerConfig", @"")
										  group:nil
							   isActOnMouseDown:YES];
		
		/*
		[_button_bar addButtonWithImageResource:@"viewer_preference"
							 alterImageResource:@"viewer_preference2"
											tag:SV_TAG_PREFERENCE
										tooltip:NSLocalizedString(@"ViewerPreference", @"")
										  group:nil];
*/
 /*
		[_button_bar addButtonWithImageResource:@"viewer_retake"
							 alterImageResource:@"viewer_retake2"
											tag:SV_TAG_RETAKE
										tooltip:NSLocalizedString(@"ViewerRetake", @"")
										  group:nil];
 */
/*
		[_button_bar addButtonWithImageResource:@"viewer_application"
							 alterImageResource:@"viewer_application2"
											tag:SV_TAG_APPLICATION
										tooltip:NSLocalizedString(@"ViewerApplication", @"")
										  group:nil
							   isActOnMouseDown:YES];
*/
/*
		[_button_bar addButtonWithImageResource:@"viewer_copy"
							 alterImageResource:@"viewer_copy2"
											tag:SV_TAG_COPY
										tooltip:NSLocalizedString(@"ViewerCopy", @"")
										  group:nil];
*/
		[_button_bar addButtonWithImageResource:@"viewer_capture"
							 alterImageResource:@"viewer_capture2"
											tag:SV_TAG_CAPTURE
										tooltip:NSLocalizedString(@"ViewerCapture", @"")
										  group:nil
							   isActOnMouseDown:YES];

		[_button_bar addButtonWithImageResource:@"viewer_operation"
							 alterImageResource:@"viewer_operation2"
											tag:SV_TAG_OPERATION
										tooltip:NSLocalizedString(@"ViewerOperation", @"")
										  group:nil
							   isActOnMouseDown:YES];
		
		[_button_bar addButtonWithImageResource:@"viewer_left"
							 alterImageResource:@"viewer_left2"
											tag:SV_TAG_PREVIOUS_FILE
										tooltip:NSLocalizedString(@"ViewerPreviousFile", @"")
										  group:nil
							   isActOnMouseDown:NO];

		[_button_bar addButtonWithImageResource:@"viewer_right"
							 alterImageResource:@"viewer_right2"
											tag:SV_TAG_NEXT_FILE
										tooltip:NSLocalizedString(@"ViewerNextFile", @"")
										  group:nil
							   isActOnMouseDown:NO];

		_button_bar2 = [[[ThinButtonBar alloc] initWithFrame:NSZeroRect] autorelease];
/*		[_button_bar2 addButtonWithImageResource:@"viewer_save"
							  alterImageResource:@"viewer_save2"
											 tag:SV_TAG_SAVE
										 tooltip:NSLocalizedString(@"ViewerSave", @"")
										   group:nil];
*/		
		_image_view = [[[SimpleViewerImageView alloc] 
						initWithFrame:NSZeroRect withController:self] autorelease];
		
		_info_view = [[[SimpleViewerInfoView alloc] initWithFrame:NSZeroRect] autorelease];
		
		_background_view = [[[SimpleViewerBackgroundView alloc] initWithFrame:NSZeroRect] autorelease];
		
		_filename_textfiled = [[[FilenameTextField alloc] initWithController:self] autorelease];

		NSView* content_view = [_panel contentView];
		[content_view addSubview:_background_view];
		[content_view addSubview:_image_view];
		[content_view addSubview:_info_view];
		[content_view addSubview:_filename_textfiled];
		[content_view addSubview:_button_bar];			// must be top of view hierarchy
		[content_view addSubview:_button_bar2];
		
		[_button_bar setDelegate:self];
		[_button_bar setPosition:SC_BUTTON_POSITION_LEFT_TOP];
		[_button_bar setDrawOffset:NSMakePoint(-BUTTON_MARGIN_LEFT, -BUTTON_MARGIN_BOTTOM)];
		[_button_bar setButtonBarWithFrame:[content_view frame]];
		[_button_bar show];

		[_button_bar2 setDelegate:self];
		[_button_bar2 setPosition:SC_BUTTON_POSITION_RIGHT_TOP];
		[_button_bar2 setDrawOffset:NSMakePoint(0, -BUTTON_MARGIN_BOTTOM)];
		[_button_bar2 setButtonBarWithFrame:[content_view frame]];
		[_button_bar2 show];
		
		[_info_view setDirInfoOffsetX:[_button_bar size].width];
		
		_is_init_panel_position = YES;

		NSString* path = [[NSBundle mainBundle] pathForImageResource:@"dummy.png"];
		_app_menu = [[ApplicationMenu alloc] initWithTargetPath:path
													   Delegate:self];
		
		_app_pallete = [[ApplicationButtonPallete alloc] init];
		_app_pallete.action = @selector(clickApplicationPalleteAtRow:withCell:);
		_app_pallete.target = self;		
		[_app_pallete addToView:content_view];
		
	}
	return self;
}

- (void) dealloc
{
	[_app_controller release];
	[_app_menu release];
	[_panel release];
	[_filename release];
	[_app_pallete release];
	[super dealloc];
}

-(void)awakeFromNib
{
	[_capture_app_menu setDelegate:self];
	[_config_menu setDelegate:self];
	[_context_menu setDelegate:self];
	[_operation_menu setDelegate:self];

	// initialize FSEvent handler
	[self updateFSEventStream];
	[UserDefaults addObserver:self forKey:UDKEY_IMAGE_LOCATION];
}
- (void)menuWillOpen:(NSMenu *)menu
{
	if (menu == _capture_app_menu) {
		[_app_controller updateApplicationMenu:_capture_app_menu];
	}
}

//
// private methods
//
- (void)updateInfomation
{
	int index = [[_app_controller fileManager] index];
	int count = [[_app_controller fileManager] count];
	if (count == 0) {
		index = 0;
	} else {
		index++;
	}
	NSString* dir_info = [NSString stringWithFormat:@"%d / %d", index, count];
	[_info_view setDirectoryInfomation:dir_info];
	
}

- (void)layoutViews
{
	NSRect frame_content_view = [[_panel contentView] frame];

	NSRect frame_image_view = frame_content_view;

	frame_image_view.size.height -= BUTTON_BAR_HEIGHT + METALINE_HEIGHT;
	frame_image_view.origin.y += BUTTON_BAR_HEIGHT + METALINE_HEIGHT;
	[_background_view setFrame:frame_image_view];

	frame_image_view.size.width -= IMAGEVIEW_MARGIN_X*2;
	frame_image_view.origin.x += IMAGEVIEW_MARGIN_X;
	frame_image_view.size.height -= IMAGEVIEW_MARGIN_Y*2;
	frame_image_view.origin.y += IMAGEVIEW_MARGIN_Y;
	[_image_view setFrame:frame_image_view];

	NSRect header_frame = frame_content_view;
	header_frame.size.height = FILENAME_TEXTFIELD_HEIGHT;
	header_frame.size.width = (int)(frame_content_view.size.width*FILENAME_TEXTFIELD_WRATIO)-METALINE_MARGIN_X*2;
	header_frame.origin.x = METALINE_MARGIN_X;
	header_frame.origin.y += BUTTON_BAR_HEIGHT + FILENAME_TEXTFIELD_PADDING_Y;
	[_filename_textfiled setFrame:header_frame];

	NSRect frame_info_view = frame_content_view;
	frame_info_view.size.height = BUTTON_BAR_HEIGHT + METALINE_HEIGHT;
	[_info_view setFrame:frame_info_view];
	[_info_view setRatio:[_image_view reductionRatio]];

	CGFloat margin = [_info_view infoStringSize].width+2.0;
	[_button_bar2 setButtonBarWithFrame:frame_content_view];
	[_button_bar2 setDrawOffset:NSMakePoint(-margin, -BUTTON_MARGIN_BOTTOM)];
	
	[_app_pallete updateLayout];
}

- (NSSize)minimumContentSize
{
	NSSize size = NSMakeSize(340.0, 200.0);
	return size;
}

- (NSSize)maximumContentSize
{
	NSRect frame = [[NSScreen mainScreen] visibleFrame];
	NSSize size;
	size.width  = (int)(frame.size.width  * 0.8);
	size.height = (int)(frame.size.height * 0.8);
	return size;
}

- (NSSize)adjustContentSize:(NSSize)content_size
{
	NSSize min_size = [self minimumContentSize];

	if (content_size.width  < min_size.width) {
		content_size.width = min_size.width;
	}
	if (content_size.height < min_size.height) {
		content_size.height = min_size.height;
	}
	return content_size;
}

- (void)adjustPanelFrameWithContentSize:(NSSize)content_size
{
	// (1) adjust size
	NSSize max_size = [self maximumContentSize];

	CGFloat ratio_w = max_size.width  / content_size.width;
	CGFloat ratio_h = max_size.height / content_size.height;
	if (ratio_w < 1.0 || ratio_h < 1.0) {
		CGFloat ratio = fminf(ratio_w, ratio_h);
		content_size.width *= ratio;
		content_size.height *= ratio;
	}
	
	NSRect rect = NSZeroRect;
	rect.size = [self adjustContentSize:content_size];
	rect.size.height += BUTTON_BAR_HEIGHT;
	NSRect panel_frame = [_panel frameRectForContentRect:rect];		
	
	// (2) adjust position
	NSRect screen_frame = [[NSScreen mainScreen] visibleFrame];

	panel_frame.origin.x = (screen_frame.size.width - panel_frame.size.width) / 2.0;
	panel_frame.origin.y = (screen_frame.size.height - panel_frame.size.height) / 2.0;
	panel_frame.origin.y += screen_frame.origin.y;	// for Dock Height

	[_panel setFrame:panel_frame display:YES];

}

//
// delegate for SimpleViewerPanel
//
- (void)windowDidResize:(NSNotification *)notification
{
//	_is_operating = NO;
	[self layoutViews];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
	
	NSRect rect = [sender frame];
	rect.size = frameSize;
	rect = [sender contentRectForFrameRect:rect];
	rect.size.height -= BUTTON_BAR_HEIGHT;
	rect.size = [self adjustContentSize:rect.size];
	rect.size.height += BUTTON_BAR_HEIGHT;
	rect = [sender frameRectForContentRect:rect];

	return rect.size;
}
-(NSString*)title
{
	/*
	NSSize size = [[_image_view image] size];
	NSDate* created = [[_app_controller fileManager] currentFile].created;
	NSString* title = [NSString stringWithFormat:@"%@   (%dx%d, %@)",
					   [_filename lastPathComponent],
					   (int)size.width, (int)size.height,
	[created descriptionWithCalendarFormat:@"%m-%d %H:%M"
								  timeZone:nil locale:nil]];
	NSString* title = [NSString stringWithFormat:@"%@ (%@)",
					   [_filename lastPathComponent],
					   [[_app_controller fileManager] currentFile].created];
	 */
	NSString* title = [_filename lastPathComponent];
	return title;
}

-(NSDate*)fileModificationDateWithPath:(NSString*)path
{
	NSFileManager* fm = [NSFileManager defaultManager];
	NSError* error = nil;
	NSDictionary* attrs = [fm attributesOfItemAtPath:path error:&error];
	if (error) {
		NSLog(@"error: %@, %@", path, error);
	}
	return [attrs fileModificationDate];
}

-(void)setFilename:(NSString*)filename
{
	[filename retain];
	[_filename release];
	_filename = filename;
	
	[_filename_textfiled setStringValue:[self title]];
//	[_panel setTitle:@"SimpleCap Viewer"];

	[_file_lastmodified release];
	if (_filename) {
		_file_lastmodified = [[self fileModificationDateWithPath:_filename] retain];
	} else {
		_file_lastmodified = nil;
	}
}
- (NSString*)filename
{
	return _filename;
}

-(BOOL)updateOpendFile
{
	NSString* filename = [self filename];
	NSDate* date = [self fileModificationDateWithPath:filename];
	if ([date compare:_file_lastmodified] == NSOrderedDescending) {
		[self showFile:filename isFitToImage:NO withDirection:SV_TRANTYPE_UPDATE];
		return YES;
	}
	return NO;
}


//
// for client code
//
- (void)showFile:(NSString*)filename isFitToImage:(BOOL)is_fit withDirection:(int)direction
{
	NSImage* image = [[[NSImage alloc] initWithContentsOfFile:filename] autorelease];
	NSString* title;

	[_image_view setImage:image withDirection:direction];

	if (!filename || ![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
		filename = nil;
		title = @"";
	}
	
	// show content
	if (is_fit) {
		if (_is_init_panel_position) {
			[self adjustPanelFrameWithContentSize:[image size]];
			_is_init_panel_position = NO;
		}
	}
	[self layoutViews];
	
	[self setFilename:filename];
	

	CGFloat margin = [_info_view infoStringSize].width + 2;
	[_button_bar2 setButtonBarWithFrame:[[_panel contentView] frame]];
	[_button_bar2 setDrawOffset:NSMakePoint(-margin, -BUTTON_MARGIN_BOTTOM)];

	[self updateInfomation];

	[_image_view setNeedsDisplay:YES];
	[_info_view setNeedsDisplay:YES];
}

- (void)openWithFile:(NSString*)filename isNew:(BOOL)new_flag
{
	int dir;
	if (new_flag) {
		dir = SV_TRANTYPE_NEW;
	} else {
		dir = SV_TRANTYPE_OPEN;
	}
	[self showFile:filename isFitToImage:YES withDirection:dir];
	[_panel show];
}

- (void)show
{
	[self flagsChanged:nil];
	[_panel show];
}

-(void)close
{
	[_panel hide];
}
- (BOOL)isOpened
{
	return [_panel isOpened];
}

// manage filename changing
- (void)endEditFilenameIsCancel:(BOOL)is_cancel
{
	if (![_filename_textfiled isEnabled]) {
		return;
	}

	if (is_cancel) {
		[_filename_textfiled setStringValue:[self title]];
		[_filename_textfiled setDisable];
		
	} else {

		NSString* input_value = [_filename_textfiled stringValue];
		if ([input_value isEqualToString:@""] ||
			[input_value rangeOfString:@"/"].location != NSNotFound ||
			[input_value hasPrefix:@"."]) {
			[_panel makeFirstResponder:_filename_textfiled];
			return;
		}

		NSString* ext = [_filename pathExtension];
		NSString* new_filename = [input_value stringByAppendingPathExtension:ext];
		NSString* new_path = [[_filename stringByDeletingLastPathComponent]
							  stringByAppendingPathComponent:new_filename];

		if ([[_app_controller fileManager] isExistPath:new_path]) {
			// *TODO* show message
			// @"ViewerFileExists"
			[_panel makeFirstResponder:_filename_textfiled];
			return;
		}

			BOOL is_set_disable = YES;
		if (![[_filename lastPathComponent] isEqualToString:new_filename]) {
			if ([[_app_controller fileManager] renameFrom:_filename
													   To:new_path]) {
				[self setFilename:new_path];
			} else {
				is_set_disable = NO;
			}
		}
		if (is_set_disable) {
			[_filename_textfiled setDisable];
		} else {
			[_panel makeFirstResponder:_filename_textfiled];
		}
	}

}

// handling buttons
-(void)clickedAtTag:(NSNumber*)tag event:(NSEvent*)event
{
	if ([_filename_textfiled isEditing]) {
		[_filename_textfiled textDidEndEditing:nil];
	}

	NSString* other_filename;
	CGFloat ratio;
	NSBitmapImageRep* bitmap;
	NSString* new_filename;

	switch ([tag intValue]) {
		case SV_TAG_TRASH:
			if ([[_app_controller fileManager] count] > 0) {
				other_filename = [[_app_controller fileManager] filenameAfterDeleteFilename:_filename];
				[[_app_controller fileManager] moveToTrash:_filename]; // must be in this order
				[_app_controller showMessage:
				 [NSString stringWithFormat:NSLocalizedString(@"FileDeleted", @""), [_filename lastPathComponent]]];
				
				
				if (other_filename) {
					[self showFile:other_filename isFitToImage:NO withDirection:SV_TRANTYPE_TRASH];
				} else {
					// "no files"
				}
			}
			break;
			
		case SV_TAG_PREFERENCE:
			[_app_controller openPereferecesWindow:_app_controller];
			break;

		case SV_TAG_RETAKE:
			[self close];
//			[[_app_controller fileManager] moveToTrash:_filename];
			[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_TRASH] event:nil];

			[_app_controller captureByLastHandler];
			break;
			
		case SV_TAG_APPLICATION:
			[NSMenu popUpContextMenu:[_app_menu menu] withEvent:event forView:nil];
			break;
			
		case SV_TAG_PREVIOUS_FILE:
			other_filename = [[_app_controller fileManager] previousFilenameInSaveFolderWithCurrentFilename:_filename];
			if (other_filename && ![_filename isEqualToString:other_filename]) {
				[self showFile:other_filename isFitToImage:NO withDirection:SV_TRANTYPE_PREVIOUS];
			}
			break;
			
		case SV_TAG_NEXT_FILE:
			other_filename = [[_app_controller fileManager] nextFilenameInSaveFolderWithCurrentFilename:_filename];
			if (other_filename && ![_filename isEqualToString:other_filename]) {
				[self showFile:other_filename isFitToImage:NO withDirection:SV_TRANTYPE_NEXT];
			}
			break;
			
		case SV_TAG_CLOSE:
			[self close];
			break;
			
		case SV_TAG_SAVE:
			ratio = [self reductionRatio];
			if (ratio < 1.0) {
				//[[_app_controller fileManager] moveToTrash:_filename];
				new_filename = [NSString stringWithFormat:@"%@/%@-%d%%.%@",
								[_filename stringByDeletingLastPathComponent],
								[[_filename lastPathComponent] stringByDeletingPathExtension],
								(int)(ratio*100),
								[_filename pathExtension]];
				[[_app_controller fileManager] saveImage:[self currentBitmapImageRepIsReduction:YES]
											withFilename:new_filename];
				[_app_controller showMessage:
				 [NSString stringWithFormat:NSLocalizedString(@"SavedAsRatio", @""), (int)(100*ratio)]];
				
				// reload
				[[_app_controller fileManager] lastFilename];
				[self showFile:new_filename isFitToImage:NO withDirection:SV_TRANTYPE_NEW];
			}
			break;
			
		case SV_TAG_CAPTURE:
			/*
			 [self close];
			 [_app_controller captureByLastHandler];
			 */
			[NSMenu popUpContextMenu:_capture_menu withEvent:event forView:nil];
			//			[[_app_controller fileManager] lastFilename];	// only to update directory info
			break;
			
		case SV_TAG_CAPTURE_AGAIN:
			 [self close];
			 [_app_controller captureByLastHandler];
			break;
			
		case SV_TAG_COPY:
			bitmap = [self currentBitmapImageRepIsReduction:NO];
			if (bitmap) {
				[_app_controller copyImageWithBitmapImageRep:bitmap];
				[_app_controller showMessage:NSLocalizedString(@"CopiedObjects", @"")];
			}
			break;
			
		case SV_TAG_CONFIG:
			[NSMenu popUpContextMenu:_config_menu withEvent:event forView:nil];
			break;

		case SV_TAG_OPERATION:
			[NSMenu popUpContextMenu:_operation_menu withEvent:event forView:nil];
			break;
			
	}

	[self endEditFilenameIsCancel:NO];
}

- (CGFloat)reductionRatio
{
	return [_image_view reductionRatio];
}

- (NSBitmapImageRep*)currentBitmapImageRepIsReduction:(BOOL)is_reduction
{
	NSImage* image = [_image_view image];
	
	if (!image) {
		return nil;
	}

	CGFloat ratio;
	
	if (is_reduction) {
		ratio = [self reductionRatio];
	} else {
		ratio = 1.0;
	}

	NSRect rect = NSZeroRect;
	NSRect new_rect = NSZeroRect;
	rect.size = [image size];
	new_rect.size.width = (int)(rect.size.width * ratio);
	new_rect.size.height = (int)(rect.size.height * ratio);
	
	NSImage* new_image = [[[NSImage alloc] initWithSize:new_rect.size] autorelease];
	
	[new_image lockFocus];
	[NSGraphicsContext saveGraphicsState];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	[image drawInRect:new_rect
			 fromRect:NSZeroRect
			operation:NSCompositeSourceOver
			 fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
	[new_image unlockFocus];

	NSData* data = [new_image TIFFRepresentation];
	return [NSBitmapImageRep imageRepWithData:data];

}
- (void)keyDown:(id)theEvent
{
	int is_command = [theEvent modifierFlags] & NSCommandKeyMask;
	int is_alternate = [theEvent modifierFlags] & NSAlternateKeyMask;
//	int is_shift = [theEvent modifierFlags] & NSShiftKeyMask;
	switch ([theEvent keyCode]) {
		case 126:
			// key up
			break;
		case 125:
			// key down
			break;
		case 124:
			// key right
			[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_NEXT_FILE] event:nil];
			break;
		case 123:
			// key left
			[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_PREVIOUS_FILE] event:nil];
			break;
		case 53:
			// esc
			[self close];
			break;

		case 117:
		case 51:
			[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_TRASH] event:nil];
			// delete
			break;
		case 49:
			// space key
			if (is_alternate) {
				[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_RETAKE] event:nil];
			} else {
				[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_CAPTURE_AGAIN] event:nil];			}
			break;
		case 36:
		case 76:
			// 36:return
			// 76:enter
			[_filename_textfiled startEdit];
			break;
		case 1:
			// 's'
			if (is_command) {
				// command + 's'
				[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_SAVE] event:nil];
			}
			break;
		case 2:
			// 'd'
			if (is_command) {
				// command + 'd'
				[self clickedDuplicate:nil];
			}
			break;
		case 8:
			// 'c'
			if (is_command) {
				// command + 'c'
				[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_COPY] event:nil];
			}
			break;
		case 13:
			// 'w'
			if (is_command) {
				// command + 'w'
				[self close];
			}
			break;
	}
}

// Panel delegate
- (void)windowDidResignKey:(NSNotification *)notification
{
	[self endEditFilenameIsCancel:NO];
}

// Filename delegate
- (BOOL)control:(NSControl *)control
	   textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
	if (command == @selector(cancel:)) {
		[self endEditFilenameIsCancel:YES];
		return YES;
	}
	return NO;
}

// for Application Menu
- (void)openPereferecesWindow:(id)tab_index
{
	[_app_controller openPereferecesWindow:tab_index];
}

// for SimpleViewerImageView
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return _context_menu;
}
- (void)copyFileTo:(NSURL*)dst_url
{
	id dst_path = [[dst_url relativePath]
				   stringByAppendingPathComponent:[_filename lastPathComponent]];
	[[NSFileManager defaultManager] copyPath:_filename 
									  toPath:dst_path
									 handler:nil];
}

// for IB
- (IBAction)clickedCopy:(id)sender
{
	[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_COPY] event:nil];
}

- (IBAction)clickedMoveToTrash:(id)sender
{
	[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_TRASH] event:nil];
}

- (IBAction)clickedSave:(id)sender
{
	[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_SAVE] event:nil];
}
- (IBAction)clickedPrevious:(id)sender
{
	[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_PREVIOUS_FILE] event:nil];
}

- (IBAction)clickedNext:(id)sender
{
	[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_NEXT_FILE] event:nil];
}

- (IBAction)clickedCaptureAgain:(id)sender
{
	[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_CAPTURE_AGAIN] event:nil];
}

- (IBAction)clickedRetake:(id)sender
{
	[self clickedAtTag:[NSNumber numberWithInt:SV_TAG_RETAKE] event:nil];
}

- (IBAction)clickedOpenWithApplication:(id)sender
{
	// *not implemented*
}

-(NSString*)dupFilename:(NSString*)baseFilename extension:(NSString*)ext path:(NSString*)path number:(NSUInteger)num
{
	NSString* filename = [NSString stringWithFormat:@"%@/%@(%d).%@",
						  path, baseFilename, num, ext];
	NSFileManager* fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:filename]) {
		filename = [self dupFilename:baseFilename extension:ext path:path number:num+1];
	}
	return filename;
}

-(NSString*)dupFilename:(NSString*)filePath
{
	NSString* filename = [filePath lastPathComponent];
	NSString* filenameWithoutExtension = [filename stringByDeletingPathExtension];
	NSString* extension = [filePath pathExtension];
	
	NSRange r1 = [filenameWithoutExtension rangeOfString:@"(" options:NSBackwardsSearch];
	NSRange r2 = [filenameWithoutExtension rangeOfString:@")" options:NSBackwardsSearch];
	NSString* baseFilename = filenameWithoutExtension;
	NSInteger num = 0;
	
	if (r1.location != NSNotFound && r2.location != NSNotFound && r2.location == [filenameWithoutExtension length]-1) {
		NSRange rnum = NSMakeRange(r1.location+r1.length, r2.location-r1.location-1);
		NSRange rbase = NSMakeRange(0, r1.location);
		NSString* numStr = [filenameWithoutExtension substringWithRange:rnum];
		baseFilename = [filenameWithoutExtension substringWithRange:rbase];
		num = [numStr integerValue];
	}
	num++;
	
	NSString* path = [filePath stringByDeletingLastPathComponent];
	NSString* newFilename = [self dupFilename:baseFilename extension:extension path:path number:num];
	
	return newFilename;
}

- (IBAction)clickedDuplicate:(id)sender
{
	NSString* new_filename = [self dupFilename:_filename];
	NSFileManager* fm = [NSFileManager defaultManager];
	NSError* error = nil;

	if ([fm copyItemAtPath:_filename toPath:new_filename error:&error]) {

		[_app_controller showMessage:NSLocalizedString(@"Duplicated", @"")];

		// reload
		[[_app_controller fileManager] lastFilename];
		[self showFile:new_filename isFitToImage:NO withDirection:SV_TRANTYPE_NEW];
		
	} else {
		NSLog(@"%@", error);
	}
}	

// for Context Menu (bindings)
- (BOOL)backgroundBlack
{
	return ([[UserDefaults valueForKey:UDKEY_VIEWER_BACKGROUND] intValue] == 0);
}
- (void)setBackgroundBlack:(BOOL)flag
{
	if (flag) {
		[UserDefaults setValue:[NSNumber numberWithInt:0] forKey:UDKEY_VIEWER_BACKGROUND];
		[self setBackgroundCheckboard:NO];
		[self setBackgroundWhite:NO];
		[UserDefaults save];
	} else if ([[UserDefaults valueForKey:UDKEY_VIEWER_BACKGROUND] intValue] == 0) {
		[self setBackgroundCheckboard:YES];
	}
}
- (BOOL)backgroundCheckboard
{
	return ([[UserDefaults valueForKey:UDKEY_VIEWER_BACKGROUND] intValue] == 1);
}
- (void)setBackgroundCheckboard:(BOOL)flag
{
	if (flag) {
		[UserDefaults setValue:[NSNumber numberWithInt:1] forKey:UDKEY_VIEWER_BACKGROUND];
		[self setBackgroundBlack:NO];
		[self setBackgroundWhite:NO];
		[UserDefaults save];
	} else if ([[UserDefaults valueForKey:UDKEY_VIEWER_BACKGROUND] intValue] == 1) {
		[self setBackgroundWhite:YES];
	}
}
- (BOOL)backgroundWhite
{
	return ([[UserDefaults valueForKey:UDKEY_VIEWER_BACKGROUND] intValue] == 2);
}
- (void)setBackgroundWhite:(BOOL)flag
{
	if (flag) {
		[UserDefaults setValue:[NSNumber numberWithInt:2] forKey:UDKEY_VIEWER_BACKGROUND];
		[self setBackgroundBlack:NO];
		[self setBackgroundCheckboard:NO];
		[UserDefaults save];
	} else if ([[UserDefaults valueForKey:UDKEY_VIEWER_BACKGROUND] intValue] == 2) {
		[self setBackgroundBlack:YES];
	}
}

-(void)openWithApplication:(id)sender
{
	NSDictionary* dict = [sender representedObject];
	[_app_controller openFile:_filename withApplication:[dict objectForKey:@"path"]];
}

-(void)clickApplicationPalleteAtRow:(NSInteger)row withCell:(ApplicationButtonCell*)cell
{
	[_app_controller openFile:_filename withApplication:cell.path];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	NSUInteger modifierFlags = [theEvent modifierFlags];
	
	[_button_bar resetGroup:@"REPEAT"];
	if (modifierFlags & NSAlternateKeyMask) {
		[_button_bar switchGroup:@"REPEAT"];
	}
	[_button_bar setNeedsDisplay:YES];}

@end
