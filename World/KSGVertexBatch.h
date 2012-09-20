//
//  KSGVertexBatch.h
//  World
//
//  Created by Keith Staines on 04/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
#import "KSMMaths.h"
#import "KSGBatch.h"
#import "KSCBody.h"


@class KSGVertex;
@class KSGMaterial;
@class KSCBoundingVolume;
@class KSGUID;

@interface KSGVertexBatch : KSGBatch <KSCBody>
{
    @protected
    KSGUID            * uid;
    KSGMaterial       * material;
    KSCBoundingVolume * boundingVolume;
    KSCBVHNode        * __weak boundingNode;
}

@property (strong) KSGMaterial * material;
@property (strong) KSCBoundingVolume * boundingVolume;
@property (strong, readonly) KSGUID* uid;
@property (weak) KSCBVHNode * boundingNode;

////////////////////////////////////////////////////////////////////////////////
// initWithCapacity
// This is the designated constructor and so must be overridden
-(id)initWithVertexCapacity:(int)expectedNumberOfVertices;

////////////////////////////////////////////////////////////////////////////////
// makeFromBox
+(KSGVertexBatch*)makeVertextBatchFromBoxWithxLength:(double)xExtent 
                                             yLength:(double)yExtent 
                                             zLength:(double)zExtent;

////////////////////////////////////////////////////////////////////////////////
// vertexBatch
// convenience method
+(KSGVertexBatch*)vertexBatch;


////////////////////////////////////////////////////////////////////////////////
// vertexBatchWithCapacity
// convenience method
+(KSGVertexBatch*)vertexBatchWithCapacity:(int)expectedNumberOfVertices;

////////////////////////////////////////////////////////////////////////////////
// addVertex
//
// Adds the vertex and return the new number of vertices if successful,
// otherwise returns zero.
-(NSUInteger) addVertex:(KSGVertex*)vertexVector;


@end
