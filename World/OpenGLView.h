//
//  OpenGLView.h
//  World
//
//  Created by Keith Staines on 04/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <math.h>

@class KSGWorld;

@interface OpenGLView : NSOpenGLView
{
 @private 
    NSTimer *pTimer;
    KSGWorld *world;
       
}

////////////////////////////////////////////////////////////////////////////////
// Timing functions
-(void) setStartTime;
- (CFAbsoluteTime) getElapsedTime;

////////////////////////////////////////////////////////////////////////////////
// createPixelFormat
// creates a new pixel format and returns it already autoreleased
- (NSOpenGLPixelFormat*) createPixelFormat;

////////////////////////////////////////////////////////////////////////////////
// prepareOpenGL (Override)
-(void)initialiseRunLoop;

@end
