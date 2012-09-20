//
//  KSVertexBatch.mm
//  World
//
//  Created by Keith Staines on 04/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGVertexBatch.h"
#import "KSGVertex.h"
#import "KSGIndexedAttributes.h"
#import "KSGMaterial.h"
#import "KSGTransformPack.h"
#import "KSCBoundingVolume.h"
#import "KSGUID.h"
#import "KSGColor.h"

@implementation KSGVertexBatch
@synthesize material;
@synthesize boundingVolume;
@synthesize boundingNode;

////////////////////////////////////////////////////////////////////////////////
// initWithCapacity
// This is the designated constructor and so must be overridden
-(id)initWithVertexCapacity:(int)expectedNumberOfVertices
{
    self = [super initWithVertexCapacity:expectedNumberOfVertices];
    if (self) 
    {
        primitiveType = GL_LINES;  
        material = nil;
        KSMVector4 centre = KSMVector4(0.0, 0.0, 0.0, 1.0);
        boundingVolume = [KSCBoundingVolume boundingVolumeWithCentre:centre 
                                                              radius:1.0];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// makeFromBox
+(KSGVertexBatch*)makeVertextBatchFromBoxWithxLength:(double)xExtent 
                                             yLength:(double)yExtent 
                                             zLength:(double)zExtent
{
    // construct vectors to represent each corner of the box
    KSMVector3 halfWidth  = KSMVector3(xExtent, 0.0,    0.0);
    KSMVector3 halfHeight = KSMVector3(0.0,    yExtent, 0.0);
    KSMVector3 halfDepth  = KSMVector3(0.0,     0.0,    zExtent);
    
    KSMVector3 nWidth  = halfWidth.unitVector();
    KSMVector3 nHeight = halfHeight.unitVector();
    KSMVector3 nDepth  = halfDepth.unitVector();
    
    
    KSMVector3 origin = KSMVector3();
    
    // position vectors (pv)
    // Front/Back Top/Bottom Left/Right
    KSMVector3 pvFBL = origin + halfDepth - halfWidth - halfHeight;
    KSMVector3 pvFBR = origin + halfDepth + halfWidth - halfHeight;
    KSMVector3 pvFTL = origin + halfDepth - halfWidth + halfHeight;
    KSMVector3 pvFTR = origin + halfDepth + halfWidth + halfHeight;
    
    KSMVector3 pvBBL = origin - halfDepth - halfWidth - halfHeight;
    KSMVector3 pvBBR = origin - halfDepth + halfWidth - halfHeight;
    KSMVector3 pvBTL = origin - halfDepth - halfWidth + halfHeight;
    KSMVector3 pvBTR = origin - halfDepth + halfWidth + halfHeight;
    
    // normal vectors
    KSMVector3 nvFBL = (     nWidth + nHeight - nDepth).unitVector();
    KSMVector3 nvFBR = (-1 * nWidth + nHeight - nDepth).unitVector();
    KSMVector3 nvFTL = (     nWidth - nHeight - nDepth).unitVector();
    KSMVector3 nvFTR = (-1 * nWidth - nHeight - nDepth).unitVector();
    
    KSMVector3 nvBBL = (     nWidth + nHeight + nDepth).unitVector();
    KSMVector3 nvBBR = (-1 * nWidth + nHeight + nDepth).unitVector();
    KSMVector3 nvBTL = (     nWidth - nHeight + nDepth).unitVector();
    KSMVector3 nvBTR = (-1 * nWidth - nHeight + nDepth).unitVector();

    // colors
    KSGColor cvFront;// = KSMVector4(1.0, 0.0, 0.0, 1.0);
    KSGColor cvBack;//  = KSMVector4(0.0, 1.0, 0.0, 1.0);
    cvFront = [KSGColorFactory makeColorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
    cvBack  = [KSGColorFactory makeColorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f];
    
    KSGVertex* vFBL = [KSGVertex vertexAtVector:pvFBL 
                                                   withNormal:nvFBL 
                                                    withColor:cvFront]; 
    
    KSGVertex* vFBR = [KSGVertex vertexAtVector:pvFBR 
                                                   withNormal:nvFBR 
                                                    withColor:cvFront]; 

    KSGVertex* vFTL = [KSGVertex vertexAtVector:pvFTL 
                                                   withNormal:nvFTL 
                                                    withColor:cvFront]; 

    KSGVertex* vFTR = [KSGVertex vertexAtVector:pvFTR 
                                                   withNormal:nvFTR 
                                                    withColor:cvFront]; 

    KSGVertex* vBBL = [KSGVertex vertexAtVector:pvBBL 
                                                   withNormal:nvBBL 
                                                    withColor:cvBack]; 

    KSGVertex* vBBR = [KSGVertex vertexAtVector:pvBBR 
                                                   withNormal:nvBBR 
                                                    withColor:cvBack]; 

    KSGVertex* vBTL = [KSGVertex vertexAtVector:pvBTL 
                                                   withNormal:nvBTL 
                                                    withColor:cvBack]; 

    KSGVertex* vBTR = [KSGVertex vertexAtVector:pvBTR 
                                                   withNormal:nvBTR 
                                                    withColor:cvBack]; 

    KSGVertexBatch* batch = [KSGVertexBatch vertexBatchWithCapacity:100];
    batch.primitiveType = GL_TRIANGLES;
    
    // front face
    [batch addVertex:vFBL];
    [batch addVertex:vFBR];
    [batch addVertex:vFTL];
    [batch addVertex:vFTL];
    [batch addVertex:vFBR];
    [batch addVertex:vFTR];
    
    // rear face
    [batch addVertex:vBBL];
    [batch addVertex:vBTL];
    [batch addVertex:vBBR];
    [batch addVertex:vBTL];
    [batch addVertex:vBTR];
    [batch addVertex:vBBR];
    
    // left side
    [batch addVertex:vBBL];
    [batch addVertex:vFBL];
    [batch addVertex:vBTL];
    [batch addVertex:vBTL];
    [batch addVertex:vFBL];
    [batch addVertex:vFTL];
    
    // right side
    [batch addVertex:vBBR];
    [batch addVertex:vBTR];
    [batch addVertex:vFBR];
    [batch addVertex:vBTR];
    [batch addVertex:vFTR];
    [batch addVertex:vFBR];
    
    // top side
    [batch addVertex:vBTR];
    [batch addVertex:vBTL];
    [batch addVertex:vFTL];
    [batch addVertex:vFTL];
    [batch addVertex:vFTR];
    [batch addVertex:vBTR];    
    
    // bottom side
    [batch addVertex:vBBR];
    [batch addVertex:vFBL];
    [batch addVertex:vBBL];
    [batch addVertex:vFBL];
    [batch addVertex:vBBR];        
    [batch addVertex:vFBR];
    
    [batch close];
    
    return batch;
}

////////////////////////////////////////////////////////////////////////////////
// vertexBatch
// convenience method
+(id)vertexBatch
{
    KSGVertexBatch * b = [[[self class] alloc] init];
    return b;
}

////////////////////////////////////////////////////////////////////////////////
// vertexBatchWithCapacity
// convenience method
+(id)vertexBatchWithCapacity:(int)expectedNumberOfVertices
{
    KSGVertexBatch * newObj = [[[self class] alloc] 
                               initWithVertexCapacity:expectedNumberOfVertices];
        
    return newObj;
}


////////////////////////////////////////////////////////////////////////////////
// sendToGL.  
// We don't want to transfer vertices from client to GPU
// on every draw, so we send the vertex data to the GPU where it will be
// cached. This is an excellent optimisation for data that changes rarely.
// Note that for most objects, the vertex data never changes. Rotations and
// translations are handled by matrix transformations. We will also wrap the 
// whole GL state in a vertex array buffer, to make switching to other objects
// a breeze
-(void) sendToGL
{
    // We can't allow any more vertices to be added to this batch, as the data
    // will now be stored in the GPU 
    isClosed=YES;
   
    // Wrap the entire GL state in a vertex array object, which makes
    // setting state inside the actual draw call a piece of cake
    glGenVertexArrays(numberOfObjectsToReserve, vertexArrayName); // 1 array
	glBindVertexArray(vertexArrayName[0]);
    
    ////////////////////////////////////////////////////////////////////////////
    // Now configure the attributes "within" the vertex array object
    
    // how many vertices do we need to send to the GPU?
    NSUInteger vertextCount = [self count];
    
    // Reserve names (actually integers) for the data buffers on the GPU
    // For the moment, we are only going to reserve one 
    // of each type of objectname...
    glGenBuffers(numberOfObjectsToReserve, vertexBufferName);     // 1 buffer
    
    // Now bind the name(s) we just reserved to the objects. 
    // Note that this also makes these objects the current objects of their type
    // NB later calls to glBindBuffer using this id will make the specified
    // buffer the active buffer
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferName[0]);    
    
    // tell GPU to reserve the memory the buffer requires, and hint that this
    // data isn't going to change much but will be used often
    glBufferData(GL_ARRAY_BUFFER, 
                 sizeof(float) * 9 * vertextCount, 
                 NULL, 
                 GL_STATIC_DRAW);    
    
    // Obtain a pointer to the GPU buffer, so that we can copy data to it
    float *pMapped = (float *)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
    
    // Copy the vertex data to the GPU vertex buffer
    for (KSGVertex *vert in [self vertices]) 
    {
        *pMapped++ = vert.x;
        *pMapped++ = vert.y;
        *pMapped++ = vert.z;
        *pMapped++ = vert.normalX;
        *pMapped++ = vert.normalY;
        *pMapped++ = vert.normalZ;
        *pMapped++ = vert.red;
        *pMapped++ = vert.green;
        *pMapped++ = vert.blue;
    }
    
    // Unmap the buffer as we are done writing to it
    glUnmapBuffer(GL_ARRAY_BUFFER);
    *pMapped = 0;  // pointer now invalid
    
    int numberOfElements = 9; // 9 = 6 position + 3 color
    int vertexPosSize = numberOfElements * sizeof(float);
    
    // setup pointer to vertex position attribute
    float *p = 0;
    
    glEnableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_VERTEX);
    glVertexAttribPointer(KSGL_SHADER_ATTRIBUTE_VERTEX, 
                          3, 
                          GL_FLOAT, 
                          GL_FALSE, 
                          vertexPosSize, 
                          p );  
    
    // setup pointer to vertex normal attribute
    glEnableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_NORMAL);
    glVertexAttribPointer(KSGL_SHADER_ATTRIBUTE_NORMAL, 
                          3, 
                          GL_FLOAT, 
                          GL_FALSE, 
                          vertexPosSize, 
                          p + 3);    

    // setup pointer to vertex color attribute
    glEnableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_COLOR);
    glVertexAttribPointer(KSGL_SHADER_ATTRIBUTE_COLOR, 
                          3, 
                          GL_FLOAT, 
                          GL_FALSE, 
                          vertexPosSize, 
                          p + 6 );     

    
//    // setup pointer to vertex texture 0
//    glEnableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_TEXTURE0);
//    glVertexAttribPointer(KSGL_SHADER_ATTRIBUTE_TEXTURE0, 
//                          numberOfElements, 
//                          GL_FLOAT, 
//                          GL_FALSE, 
//                          vertexPosSize, 
//                          (char *)NULL + (9));    
//
//    // setup pointer to vertex texture 1
//    glEnableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_TEXTURE1);
//    glVertexAttribPointer(KSGL_SHADER_ATTRIBUTE_TEXTURE1, 
//                          numberOfElements, 
//                          GL_FLOAT, 
//                          GL_FALSE, 
//                          vertexPosSize, 
//                          (char *)NULL + (12)); 
//    
//    // setup pointer to vertex texture 2
//    glEnableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_TEXTURE2);
//    glVertexAttribPointer(KSGL_SHADER_ATTRIBUTE_TEXTURE2, 
//                          numberOfElements, 
//                          GL_FLOAT, 
//                          GL_FALSE, 
//                          vertexPosSize, 
//                          (char *)NULL + (15));    
//
//    // setup pointer to vertex texture 3
//    glEnableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_TEXTURE3);
//    glVertexAttribPointer(KSGL_SHADER_ATTRIBUTE_TEXTURE3, 
//                          numberOfElements, 
//                          GL_FLOAT, 
//                          GL_FALSE, 
//                          vertexPosSize, 
//                          (char *)NULL + (18));    

    
//    // don't need these for now...
//    
//    //glDisableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_NORMAL);
//    //glDisableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_COLOR);
//    glDisableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_TEXTURE0);
//    glDisableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_TEXTURE1);
//    glDisableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_TEXTURE2);
//    glDisableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_TEXTURE3);
}

////////////////////////////////////////////////////////////////////////////////
// draws the geometry this batch defines
-(void) drawUsingTransformPack:(KSGTransformPack *)transformPack
{
    // select the shader we are going to use
    GLint pID = [self openGLProgramId];
    glUseProgram(pID);

    // set the GL state (attributes, etc)
    glBindVertexArray(vertexArrayName[0]);              
    
    // get a handle on the modelviewprojection matrix uniform in the GPU
    GLuint mp4 = glGetUniformLocation(pID, "mp4Matrix");
    
    // copy the data in model to projection matrix to GPU
    float * mp4Data = floatsFromDoubles([transformPack modelToProjection].d, 16);

    glUniformMatrix4fv(mp4, 1, GL_FALSE, mp4Data);
    
    delete[] mp4Data;
    
    // ok, all ready, tell GPU to go do it
   	glDrawArrays(primitiveType, 0, (GLsizei)[self count]);    
}


////////////////////////////////////////////////////////////////////////////////
// addVertex
-(NSUInteger) addVertex:(KSGVertex*)vertex
{
    // if this batch is closed we cannot allow more vertices to be added
    if ([self isClosed]) return 0;
    
    // not closed so safe to add new vertex
    NSMutableArray * vertices = [self vertices];
    [vertices addObject:vertex];

    return [vertices count];
}

-(void)close
{
    if ([self isClosed]) return;
 
    // calculate a reasonable bounding volume. We will use the centroid of the
    // vertices as the centre of a bounding sphere and determine the radius
    // from the vertex most distant from the centroid. Possible to do better
    // (as in generate a smaller sphere at least some of the time) but I believe
    // this is as fast as it gets 
    KSMVector4 centroid = KSMVector4(0.0, 0.0, 0.0, 1.0);
    for (KSGVertex* vertex in [self vertices]) 
    {
        centroid = centroid + [vertex vector4];
    }    
    
    NSInteger nVertices = [[self vertices] count];
    if (nVertices) 
    {
        double normalize = 1.0 / nVertices;
        centroid *= normalize;
    }
    
    // The radius is determined by the vertex most distant from the centroid
    double radius = 0.0;
    for (KSGVertex* vertex in [self vertices]) 
    {
        KSMVector4 d2 = (centroid - [vertex vector4]);

        if ( radius < d2.length2() ) 
        {
            radius = d2.length2(); 
        }
    }    

    radius = sqrt(radius);
    [self setBoundingVolume:[KSCBoundingVolume boundingVolumeWithCentre:centroid 
                                                          radius:radius]];
}

-(KSGUID*)uid
{
    return uid;
}


@end
