//
//  KSGBatch.h
//  World
//
//  Created by Keith Staines on 08/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
#import "KSMMaths.h"

@class KSGTransformPack;

const GLuint    numberOfObjectsToReserve = 1;

@interface KSGBatch : NSObject
{
  @protected
    BOOL                   isClosed;
    GLint                  openGLProgramId;
    GLuint                 vertexArrayName[numberOfObjectsToReserve];
    GLuint                 vertexBufferName[numberOfObjectsToReserve];
    GLenum                 primitiveType;
    NSString*              name; 
    float                  scale;
}


 @property (readonly)    BOOL                isClosed;
 @property (copy)        NSString*           name;
 @property (strong)      NSMutableArray*     vertices;
 @property (assign)      GLenum              primitiveType;
 @property (assign)      GLint               openGLProgramId;
 @property (assign)      float               scale;


////////////////////////////////////////////////////////////////////////////////
// initWithCapacity
-(id)initWithVertexCapacity:(int)expectedNumberOfVertices;

////////////////////////////////////////////////////////////////////////////////
// bindGeometry 
// sends vertices and associated data to the GPU
-(void) sendToGL;

////////////////////////////////////////////////////////////////////////////////
// drawUsingModelCameraProjection
// draw geometry using the specified projection
-(void) drawUsingTransformPack:(KSGTransformPack *)modelCameraProjection;

////////////////////////////////////////////////////////////////////////////////
// count
// returns the number of vertices held in the batch
-(NSUInteger) count;

////////////////////////////////////////////////////////////////////////////////
// close
//
// Seals off the batch and makes it ready for copying to OpenGL. Vertices
// already in the batch can be changed and uploaded to OpenGL, but new
// vertices cannot be added
-(void) close;



@end