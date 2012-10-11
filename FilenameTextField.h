//
//  FilenameTextField.h
//  SimpleCap
//
//  Created by - on 09/01/22.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SimpleViewerController;
@interface FilenameTextField : NSTextField {

	SimpleViewerController* _controller;
	
	int _state;
}
- (id)initWithController:(SimpleViewerController*)controller;
- (void)setDisable;
- (void)startEdit;
- (BOOL)isEditing;
@end
