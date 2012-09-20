//
//  OpenGLView.m
//  World
//
//  Created by Keith Staines on 04/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "OpenGLView.h"

#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import "KSGWorld.h"

////////////////////////////////////////////////////////////////////////////////
// Globals
////////////////////////////////////////////////////////////////////////////////

// Holds the OpenGL version and graphics card info
const char *szOpenGLVersionString;
const char *szOpenGLSLVersionString;

const NSTimeInterval runloopTimerInterval = 1.0 / 60.0;

// global holds the world start time
CFAbsoluteTime gStartTime = 0.0;
CFAbsoluteTime gOldTime = 0.0;
CFAbsoluteTime gFrameCountStartTime = 0.0;
CFAbsoluteTime gCurrentTime = 0.0;
int nframes = 0;


////////////////////////////////////////////////////////////////////////////////
// End Globals
////////////////////////////////////////////////////////////////////////////////

@implementation OpenGLView


////////////////////////////////////////////////////////////////////////////////
// initWithFrame (Override)
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        world = [[KSGWorld alloc] init];
        
        // Get a pixelformat (the pf we are requesting
        // specifies OpenGL 3.2, so after these two calls, we have
        // the right version. Note that the pixel format is
        // returned already autoreleased and we are passing it 
        // on to super, so we don't need to retain it
        NSOpenGLPixelFormat * pf = [self createPixelFormat];
        
        // init with frame and pixelformat
        self = [super initWithFrame: frame pixelFormat: pf];
            
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// drawRect (Override)
-(void) drawRect:(NSRect)dirtyRect
{
    // keep track of frame rate
    nframes++;
    if (nframes > 1000)
    {
        gFrameCountStartTime = CFAbsoluteTimeGetCurrent ();
        nframes = 0;
    }
    
    // determine how much time has elapsed since the last frame
    gCurrentTime = CFAbsoluteTimeGetCurrent();
    
    // calculate the time increment since the last frame
    NSTimeInterval dt = gCurrentTime - gOldTime;
    
    // do the physics, that happens in this time increment
    [world updateWorld:dt];    
    
    // move time forward a step
    gOldTime = gCurrentTime;
    
    // commit all drawing instructions to GPU (but still asynchronous,
    // so we can get on doing physics and stuff for next grame
    // while this frame finishes drawing)
    glFlush();
}

////////////////////////////////////////////////////////////////////////////////
// accepteFirstResponder (Override)
-(BOOL) acceptsFirstResponder
{
    [[self window] makeFirstResponder:self];
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
// becomesFirstResponder (Override)
-(BOOL) becomeFirstResponder
{
    return YES;
}



////////////////////////////////////////////////////////////////////////////////
// resignFirstResponder (Override)
-(BOOL) resignFirstResponder    
{
    return YES;
}



////////////////////////////////////////////////////////////////////////////////
// keyDown  (Override)
-(void) keyDown:(NSEvent*)event
{
    // pass on the user input
    [world keyDown:event];
}

////////////////////////////////////////////////////////////////////////////////
// mouseUp  (Override)
-(void) mouseUp:(NSEvent *)theEvent:(NSEvent*)event
{
    
}


////////////////////////////////////////////////////////////////////////////////
// mouseDown  (Override)
-(void) mouseDown:(NSEvent *)theEvent
{
    
}

////////////////////////////////////////////////////////////////////////////////
// mouseDragged  (Override)
-(void) mouseDragged:(NSEvent *)theEvent
{
    
}


////////////////////////////////////////////////////////////////////////////////
// prepareOpenGL (Override)
-(void) prepareOpenGL
{                
    // Now we do the deferred test to ensure that we do have the right version
    // of OpenGL!
    szOpenGLVersionString = (const char *)glGetString(GL_VERSION); 
    NSLog(@"OpenGL Version: %@ \n" , 
          [NSString stringWithCString:szOpenGLVersionString 
                             encoding:NSUTF8StringEncoding]);
    
    szOpenGLSLVersionString = (const char *)glGetString(GL_SHADING_LANGUAGE_VERSION);
    NSLog(@"OpenGLSL Version: %@ \n" , 
          [NSString stringWithCString:szOpenGLSLVersionString 
                             encoding:NSUTF8StringEncoding]);   
    
    // turn on back face culling
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    // turn on depth testing
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glDepthFunc(GL_LEQUAL);
    glDepthRange(0.0f, 1.0f);
    
    // pass on this call to super
    [super prepareOpenGL];
    
    // and now we are ready to initialise the run loop
    [self initialiseRunLoop];
}

////////////////////////////////////////////////////////////////////////////////
// prepareOpenGL (Override)
-(void)initialiseRunLoop
{
    // load the world
    [world loadWorld];
    
    // setup the runloop timer
    pTimer = [NSTimer timerWithTimeInterval:(runloopTimerInterval) 
                                     target:self 
                                   selector:@selector(idle:) 
                                   userInfo:nil 
                                    repeats:YES];
    
    // setup the runloop
    [self setStartTime];
    gOldTime = gStartTime;
    
    // we don't retain the timer because we are passing it on to the runloop
    [[NSRunLoop currentRunLoop] addTimer:pTimer forMode:NSDefaultRunLoopMode];    
}


////////////////////////////////////////////////////////////////////////////////
// idle (Override)
// Respond to the timer firing
-(void)idle:(NSTimer *)pTimer
{
    [self drawRect:[self bounds]];
}


////////////////////////////////////////////////////////////////////////////////
// clearGLContext (Override)
// Do openGL related cleanup
-(void) clearGLContext
{
    // Do openGL cleanup
    
}


////////////////////////////////////////////////////////////////////////////////
// reshape (Override)
// Respond to the window resizing
-(void) reshape
{
    NSRect rect = [self bounds];
    glViewport(0, 0, rect.size.width, rect.size.height);
    [world reshapeToWidth:rect.size.width Height:rect.size.height];
}


////////////////////////////////////////////////////////////////////////////////
// setStartTime
// Sets the world start time
-(void) setStartTime 
{   
    gStartTime = CFAbsoluteTimeGetCurrent ();
    gFrameCountStartTime = gStartTime;
}


////////////////////////////////////////////////////////////////////////////////
// return float elpased time in seconds since the set start time
- (CFAbsoluteTime) getElapsedTime 
{   
    return CFAbsoluteTimeGetCurrent () - gStartTime;
}


////////////////////////////////////////////////////////////////////////////////
// createPixelFormat
// Returns an OpenGL pixelformat (already autoreleased)
- (NSOpenGLPixelFormat*) createPixelFormat
{
    NSOpenGLPixelFormatAttribute attributes[]=
    {
        NSOpenGLPFAOpenGLProfile, 
        NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 32,
        NSOpenGLPFAAccelerated, 
        0
    };
    
    NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] 
                                         initWithAttributes:attributes];
    
    return pixelFormat;
}

@end

