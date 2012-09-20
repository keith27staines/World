//
//  KSGImage.mm
//  World
//
//  Created by Keith Staines on 05/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGImage.h"

@implementation KSGImage


-(id)initWithName:(NSString*)aName
{
    self = [super initWithName:aName];
    if (self)
    {
        // Add KSGImage-specific initialisation here
        
        // Create the img from file
        NSImage * img = [NSImage imageNamed:aName];
        NSAssert1(img, @"image could not be loaded from file %@", img);
        
        // create a bitmap from the image
        NSSize imgSize = [img size];
        NSRect imgRect = NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height);
        [img lockFocus];
        bmp = [[NSBitmapImageRep alloc] initWithFocusedViewRect:imgRect];
        [img unlockFocus];
        NSAssert1(bmp, @"failed to create bitmap for %@", aName);
        
        //
        
    }
    return self;
}



@end
