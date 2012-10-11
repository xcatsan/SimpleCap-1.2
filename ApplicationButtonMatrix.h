//
//  ApplicationButtonMatrix.h
//  MatrixSample
//
//  Created by - on 09/12/08.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ApplicationButtonCell;
@interface ApplicationButtonMatrix : NSMatrix {

	ApplicationButtonCell* pushedCell;
	ApplicationButtonCell* overedCell;
	NSTrackingArea* trackingArea;
}
@property (retain) NSTrackingArea* trackingArea;

@end
