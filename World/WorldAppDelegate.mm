//
//  WorldAppDelegate.mm
//  World
//
//  Created by Keith Staines on 04/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "WorldAppDelegate.h"

@implementation WorldAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Initialisation code here
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender 
{
    return YES;
}

@end
