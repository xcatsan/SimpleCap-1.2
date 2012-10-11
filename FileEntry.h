//
//  FileEntry.h
//  SimpleCap
//
//  Created by - on 09/01/18.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FileEntry : NSObject
{
	NSString* _name;
	NSDate* _created;
}
@property (retain) NSString* name;
@property (retain) NSDate* created;
- (id)initWithFilename:(NSString*)filename fileAttributes:(NSDictionary*)attrs;
@end
