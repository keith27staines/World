//
//  KSGIndexedTriangleBatch.h
//  World
//
//  Created by Keith Staines on 08/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGVertexBatch.h"
#import "KSMMaths.h"

@interface KSGIndexedTriangleBatch : KSGVertexBatch
{
 @protected
    NSMutableArray* triangleVertices;
    NSMutableArray* smoothingGroups;
    GLuint indexBufferName[numberOfObjectsToReserve];
}

////////////////////////////////////////////////////////////////////////////////
// initWithCapacity
// This is the designated constructor and so must be overridden
-(id)initWithVertexCapacity:(int)expectedNumberOfVertices;

-(NSUInteger)AddIndex:(NSUInteger)anIndex;
-(NSUInteger)AddSmoothingGroups:(int)groups;
-(void)calculateNormalVectors;
-(NSUInteger)triangleCount;

@end
