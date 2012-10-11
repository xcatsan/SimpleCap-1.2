//
//  DialogMessage.h
//  SimpleCap
//
//  Created by - on 09/01/12.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DialogMessage : NSObject {

	NSDictionary* _attribute;
	NSShadow* _shadow;
}

+ (DialogMessage*)defaultMessage;
- (NSSize)sizeOfMessage:(NSString*)message;
- (void)drawMessage:(NSString*)message atPoint:(NSPoint)p;
@end
