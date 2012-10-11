//
//  PreferedApplications.h
//  FindingAllApps
//
//  Created by - on 08/10/29.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ApplicationMenu : NSObject {

	id _delegate;
	NSArray* _menu_items;
	NSMenu* _prefered_menu;
	NSMenuItem* _prefered_menu_item;
}
- (id)initWithTargetPath:(NSString*)path Delegate:(id)delegate;
- (NSArray*)menuItems;
- (NSMenu*)menu;
- (NSInteger)indexForPath:(NSString*)path;
- (NSString*)pathAtIndex:(NSInteger)index;

@end
