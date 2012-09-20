//
//  KSGIndexedTriangleBatch.mm
//  World
//
//  Created by Keith Staines on 08/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGIndexedTriangleBatch.h"
#import "KSGTriangle.h"
#import "KSGVertex.h"
#import "KSGIndexedAttributes.h"
#import "KSGTransformPack.h"
#import "KSGMaterial.h"

@implementation KSGIndexedTriangleBatch

////////////////////////////////////////////////////////////////////////////////
// initWithCapacity
// This is the designated constructor and so must be overridden
-(id)initWithVertexCapacity:(int)expectedNumberOfVertices
{
    self = [super initWithVertexCapacity:expectedNumberOfVertices];
    if (self) 
    {
        triangleVertices = [[NSMutableArray alloc] 
                         initWithCapacity:expectedNumberOfVertices];
        
        smoothingGroups = [[NSMutableArray alloc] 
                           initWithCapacity:expectedNumberOfVertices];
        
        primitiveType = GL_TRIANGLES;        
    }
    return self;
}

-(void)close
{
    [super close];
    [self calculateNormalVectors];
}

////////////////////////////////////////////////////////////////////////////////
// AddIndex
// Add an index pointing into the vertices array that identifies the (possibly
// shared) vertex associated with a particular corner of the triangle. A triangle
// is therefore fully described by three indices, each pointing to a different
// vertex
-(NSUInteger)AddIndex:(NSUInteger)anIndex
{
    // if this batch is closed we cannot allow more vertices to be added
    if ([self isClosed]) return 0;
    
    // not closed so safe to add new vertex
    [triangleVertices addObject:[NSNumber numberWithInteger:anIndex]];
    
    return [triangleVertices count];  
}

////////////////////////////////////////////////////////////////////////////////
// AddSmoothingGroups
// Add an integer encoding the smoothing groups for the triangle
-(NSUInteger)AddSmoothingGroups:(int)groups
{
    // if this batch is closed we cannot allow more vertices to be added
    if ([self isClosed]) return 0;
    
    // not closed so safe to add new vertex
    [smoothingGroups addObject:[NSNumber numberWithInteger:groups]];
    
    return [smoothingGroups count];  
}


////////////////////////////////////////////////////////////////////////////////
// calculateNormalVectors
// calculates a normal vector for each vertex from the vertex data itself. The
// normal finally assigned is a weighted average using the calculated normals f
// for every triangle sharing the vertex. 
// Note that for the moment, this function does not take into account smoothing
// groups and therefore doesn't produce good normals for vertices on crease lines
-(void)calculateNormalVectors
{
    // We have an array of vertices called vertices.
    
    // Triangles are represented by sequences of three vertices. The 
    // triangleVertices array holds these. Pull three values from the array
    // to define a triangle.
    
    // The object here is to create triangular facets, one triangle represented
    // by three vertices, and then to calculate the vector normal to the 
    // face of the triangle. 
    
    // The normals of all the triangles shared by a given vertex are then
    // averaged (weighting with the interior angle of the triangle at that 
    // vertex). The weighted normal is then assigned as the vertex's normal vector.
    
    // The first step is to create a data structure to hold all the triangle info.
    // We create an array of mutable arrays. Each of these mutable arrays will
    // store all the triangles associated with the vertex to which it corresponds.
    
    // How many vertices are we dealing with?
    NSUInteger numberOfVertices = [triangleVertices count];
    
    // Create the array (of arrays) to hold an array for each vertex
    NSMutableArray* associatedTrianglesArrays = 
        [NSMutableArray arrayWithCapacity:numberOfVertices];
    
    // For each vertex, create an array to hold its associated triangles,
    // and store this array in the array of arrays
    for (int vertexNumber = 0; vertexNumber < numberOfVertices; vertexNumber++) 
    {
        // create a new triangle array and add it to the array of arrays.
        // We don't know how how many triangles this array will have to hold
        // so we will assume 4 and allow the array to grow if necessary
        NSMutableArray* triangles = [NSMutableArray arrayWithCapacity:4];
        [associatedTrianglesArrays addObject:triangles];
    }
    
    // how many triangles are represented? Each triangle is defined by pulling
    // the next three indices from the indices array, so there are 1/3 as many
    // triangles as there are vertices
    NSUInteger numberOfTriangles = numberOfVertices / 3;
    
    KSGVertex *vertex1, *vertex2, *vertex3;
    
    NSMutableArray* vertex1TriangleArray;
    NSMutableArray* vertex2TriangleArray;
    NSMutableArray* vertex3TriangleArray;

    // Now create the triangle objects and add them to their corresponding vertex
    // triangle array.
    // loop through all triangular faces, identify the three vertices making up 
    // the triangle, construct a triangle object and assign to the vertices
    for (NSUInteger triangleNumber = 0; 
         triangleNumber < numberOfTriangles; triangleNumber++) 
    {
        // for each triangle there are three vertices
        NSUInteger vertex1number = 3 * triangleNumber;
        NSUInteger vertex2number = vertex1number+1;
        NSUInteger vertex3number = vertex1number+2;

        // get the three vertex indices that will make up the next triangle
        NSNumber* n1 = [triangleVertices objectAtIndex:vertex1number];
        NSNumber* n2 = [triangleVertices objectAtIndex:vertex2number];
        NSNumber* n3 = [triangleVertices objectAtIndex:vertex3number];
        
        // n1, n2, and n3 are the indexes into the triangleVertices array
        // but we will also need the corresponding indexes into the
        // vertices array
        NSUInteger vertex1index = [n1 unsignedIntValue];
        NSUInteger vertex2index = [n2 unsignedIntValue];
        NSUInteger vertex3index = [n3 unsignedIntValue];
        
        // get the actual vertices from the vertices array
        NSMutableArray * vertices = [self vertices];
        vertex1 = [vertices objectAtIndex:vertex1index];
        vertex2 = [vertices objectAtIndex:vertex2index];
        vertex3 = [vertices objectAtIndex:vertex3index];
        
        // get the array of triangles associated with each of these vertices
        vertex1TriangleArray = [associatedTrianglesArrays objectAtIndex:vertex1number];
        vertex2TriangleArray = [associatedTrianglesArrays objectAtIndex:vertex2number];
        vertex3TriangleArray = [associatedTrianglesArrays objectAtIndex:vertex3number];
        
        // create a triangle object from these vertices
        KSGTriangle* triangle = [KSGTriangle triangleFromVertex1:vertex1 
                                                          index1:vertex1number 
                                                         vertex2:vertex2 
                                                          index2:vertex2number 
                                                         vertex3:vertex3 
                                                          Index3:vertex3number];
        
        // store the triangle in the lists associated with each of the three
        // vertices
        [vertex1TriangleArray addObject:triangle];
        [vertex2TriangleArray addObject:triangle];
        [vertex3TriangleArray addObject:triangle];
        
    }
    
    // loop through the vertices again. For each vertex, average the normal
    // vectors of all of the triangles associated with the vertex, normalise
    // the result and assign to the vertex object
    for (int vertexNumber = 0; vertexNumber < numberOfVertices; vertexNumber++) 
    {
        KSMVector3 averagedNormal;
        NSMutableArray* associatedTriangles = [associatedTrianglesArrays objectAtIndex:vertexNumber];
        
        for (KSGTriangle* triangle in associatedTriangles) 
        {
            averagedNormal += [triangle weightedNormalAtIndex:vertexNumber];
        }
        averagedNormal.normalise();
        
        // get the vertex we want to assign this normal to
        NSNumber* n = [triangleVertices objectAtIndex:vertexNumber];
        NSUInteger vertexIndex = [n unsignedIntValue];
        KSGVertex* vertex = [[self vertices] objectAtIndex:vertexIndex];
        
        // assign the averaged normal to the vertex
        [vertex setNormalX:averagedNormal.x];
        [vertex setNormalY:averagedNormal.y];
        [vertex setNormalZ:averagedNormal.z];
    }
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
    int numberOfElements = 11; 
    glBufferData(GL_ARRAY_BUFFER, 
                 sizeof(float) * numberOfElements * vertextCount, 
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
        *pMapped++ = vert.textureX;
        *pMapped++ = vert.textureY;
    }
    
    // Unmap the buffer as we are done writing to it
    glUnmapBuffer(GL_ARRAY_BUFFER);
    *pMapped = 0;  // pointer now invalid
    
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
    
    
    // setup pointer to vertex texture 0
    glEnableVertexAttribArray(KSGL_SHADER_ATTRIBUTE_TEXTURE0);
    glVertexAttribPointer(KSGL_SHADER_ATTRIBUTE_TEXTURE0, 
                          2, 
                          GL_FLOAT, 
                          GL_FALSE, 
                          vertexPosSize, 
                          p + (9));    
    
    ////////////////////////////////////////////////////////////////////////////
    // now set up index buffer
    NSUInteger verticesCount = [triangleVertices count];
    glGenBuffers(numberOfObjectsToReserve, indexBufferName);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferName[0]);  
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
                 sizeof(GLuint) * 1 * verticesCount, 
                 NULL, 
                 GL_STATIC_DRAW);    
    
    // copy the vertexIndices data into a c array 
    // (inefficient, but made up for later)
    GLuint indices[verticesCount];
    for (int i = 0; i < verticesCount; ++i) 
    {
        indices[i] = [[triangleVertices objectAtIndex:i] unsignedIntValue];
    }    
    
    // copy the data in indices into the buffer - very efficient!
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
                 verticesCount * sizeof(GLuint), 
                 indices, GL_STATIC_DRAW);
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
    
    KSGTexture* texture = [material texture1];
    if (texture) 
    {
        glBindTexture(GL_TEXTURE_2D, [[material texture1] mapID]);
    }
    else
    {
        glBindTexture(GL_TEXTURE_2D, 0);
    }
          
    
    // get the uniform locations for the coordinate transformation matrices
    // mp4Matrix  is the model-view-projection 4x4 transform (inc rot and trans)
    // mv4Matrix  is the model-view 4x4 transform (again includes rot and trans)
    // mv3Matrix  is the model-view 3x3 rotation matrix (excludes trans)
    GLuint mp4  = glGetUniformLocation(pID, "mp4Matrix");
    GLuint mv4  = glGetUniformLocation(pID, "mv4Matrix");
    GLuint mv3  = glGetUniformLocation(pID, "mv3Matrix");
    
    // copy the data in the matrices to the GPU
//    KSMMatrix4 mp4Matrix = [transformPack modelToProjection];
//    KSMMatrix4 mv4Matrix = [transformPack modelToView];
//    KSMMatrix3 mv3Matrix = [transformPack modelToViewRot];
//    glUniformMatrix4fv(mp4,  1, GL_FALSE, mp4Matrix.d);
//    glUniformMatrix4fv(mv4,  1, GL_FALSE, mv4Matrix.d);
//    glUniformMatrix3fv(mv3,  1, GL_FALSE, mv3Matrix.d);
    
    // underlying data is stored in doubles but we need floats
    float * mp4Data = floatsFromDoubles([transformPack modelToProjection].d, 16);
    float * mv4Data = floatsFromDoubles([transformPack modelToView].d, 16);
    float * mv3Data = floatsFromDoubles([transformPack modelToViewRot].d, 9);

    glUniformMatrix4fv(mp4,  1, GL_FALSE, mp4Data);
    glUniformMatrix4fv(mv4,  1, GL_FALSE, mv4Data);
    glUniformMatrix3fv(mv3,  1, GL_FALSE, mv3Data);
    
    delete[] mp4Data;
    delete[] mv4Data;
    delete[] mv3Data;
    
    // get the names of the uniform data relating to the material
    GLint    v4mAmbientColor   = glGetUniformLocation(pID, "v4mAmbientColor");
    GLint    v4mDiffuseColor   = glGetUniformLocation(pID, "v4mDiffuseColor");
    GLint    v4mSpecularColor  = glGetUniformLocation(pID, "v4mSpecularColor");
    GLint    v4mEmissiveColor  = glGetUniformLocation(pID, "v4mEmissiveColor");
    GLint    mSpecularExponent = glGetUniformLocation(pID, "mExponent");
    
    // set the material properties
    glUniform4fv(v4mAmbientColor,  1, material.ambientColor.f);
    glUniform4fv(v4mDiffuseColor,  1, material.diffuseColor.f);
    glUniform4fv(v4mSpecularColor, 1, material.specularColor.f);
    glUniform4fv(v4mEmissiveColor, 1, material.emissiveColor.f);
    glUniform1f(mSpecularExponent,    material.specularExponent);
    
    // ok, all ready, tell GPU to go do it
    glDrawElements(primitiveType, 
                   (GLuint)[triangleVertices count], 
                   GL_UNSIGNED_INT, 
                   (GLvoid*)((char*)NULL));   
}

-(NSUInteger)triangleCount
{
    return triangleVertices.count;
}


@end
