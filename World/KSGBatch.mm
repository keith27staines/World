//
//  KSGBatch.mm
//  World
//
//  Created by Keith Staines on 08/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGBatch.h"
#import "KSCBoundingVolume.h"

@implementation KSGBatch
{
    
}

@synthesize primitiveType;
@synthesize isClosed;
@synthesize name;
@synthesize vertices;
@synthesize openGLProgramId;
@synthesize scale;


////////////////////////////////////////////////////////////////////////////////
// init
- (id)init
{
    
    // a thousand vertices for a single batch is probably excessive
    // but that is why we include an initWithCapacity method too
    self = [self initWithVertexCapacity:1024];
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// initWithCapacity
-(id)initWithVertexCapacity:(int)expectedNumberOfVertices
{
    self = [super init];
    if (self) 
    {
        if (expectedNumberOfVertices <= 0) expectedNumberOfVertices = 1024;
        
        vertices = [[NSMutableArray alloc] 
                    initWithCapacity:expectedNumberOfVertices];
        
        NSAssert(vertices == [self vertices], @"assignment failed");
        
        isClosed = NO;
        primitiveType = GL_LINES;
        
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// drawUsingModelCameraProjection
// draw geometry using the specified projection. 
// Subclasses must override this method.
-(void) drawUsingTransformPack:(KSGTransformPack *)transformPack
{}

////////////////////////////////////////////////////////////////////////////////
// bindGeometry 
// sends vertices and associated data to the GPU. 
// Subclasses must override this method
-(void) sendToGL
{}

////////////////////////////////////////////////////////////////////////////////
// close
-(void) close
{
    isClosed = YES;
}

////////////////////////////////////////////////////////////////////////////////
// count
-(NSUInteger)count
{
    return vertices.count;
}

@end
