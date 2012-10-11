//
//  FileList.h
//  SimpleCap
//
//  Created by - on 09/01/18.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FileEntry;
@interface FileList : NSObject {
	NSMutableArray* _list;
}

-(void)setPath:(NSString*)path;
- (int)count;
- (int)indexWithFilename:(NSString*)filename;
- (FileEntry*)fileEntryAtIndex:(int)index;
- (void)removeAtIndex:(int)index;
@end
