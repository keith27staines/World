//
//  KSGTriangle.mm
//  World
//
//  Created by Keith Staines on 10/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSMMaths.h"
#import "KSGTriangle.h"
#import "KSGVertex.h"

@implementation KSGTriangle

@synthesize triangleIndex;
@synthesize normalWeight1;
@synthesize normalWeight2;
@synthesize normalWeight3;

// designated constructor
-(id)initFromVertex1:(KSGVertex*)firstVertex 
              index1:(NSUInteger)firstIndex
             vertex2:(KSGVertex*)secondVertex 
              index2:(NSUInteger)secondIndex
             vertex3:(KSGVertex*)thirdVertex
              index3:(NSUInteger)thirdIndex
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setVerticesVertex1:firstVertex 
                          index1:firstIndex
                         vertex2:secondVertex
                          index2:secondIndex
                         vertex3:thirdVertex
                          index3:thirdIndex];
    }
    
    return self;
}

// override deisgnated constructor of base class
-(id)init
{
    KSGVertex* u = [KSGVertex vertexAtX:1.0 Y:0.0 Z:0.0];
    KSGVertex* v = [KSGVertex vertexAtX:0.0 Y:1.0 Z:0.0];
    KSGVertex* w = [KSGVertex vertexAtX:0.0 Y:0.0 Z:1.0];
    
    return [self initFromVertex1:u 
                          index1:1 
                         vertex2:v 
                          index2:2 
                         vertex3:w 
                          index3:3];
}

// convenience constructor
+(id)triangleFromVertex1:(KSGVertex*)firstVertex 
                  index1:(NSUInteger)firstIndex
                 vertex2:(KSGVertex*)secondVertex
                  index2:(NSUInteger)secondIndex
                 vertex3:(KSGVertex*)thirdVertex 
                  Index3:(NSUInteger)thirdIndex
{
    id newInstance = [[[self class] alloc] initFromVertex1:firstVertex
                                                    index1:firstIndex
                                                   vertex2:secondVertex
                                                    index2:secondIndex
                                                   vertex3:thirdVertex
                                                    index3:thirdIndex];

    return newInstance;
}

-(KSMVector3)normal
{
    return normal;
}

////////////////////////////////////////////////////////////////////////////////
// sets each of the three vertices and triggers a calculation of the normal
// and area
-(void)setVerticesVertex1:(KSGVertex*)firstVertex
                   index1:(NSUInteger)firstIndex
                  vertex2:(KSGVertex*)secondVertex 
                   index2:(NSUInteger)secondIndex
                  vertex3:(KSGVertex*)thirdVertex
                   index3:(NSUInteger)thirdIndex
{
    // record the indices assigned to the vertices
    index[0] = firstIndex;
    index[1] = secondIndex;
    index[2] = thirdIndex;    
    
    // convert the vertices into vectors so we can do maths on them
    vector[0] = [KSGVertex makeVectorFromVertex:firstVertex];
    vector[1] = [KSGVertex makeVectorFromVertex:secondVertex];
    vector[2] = [KSGVertex makeVectorFromVertex:thirdVertex];
    
    // now we construct the normal vector, assuming that anticlockwise
    // progression of the edge vectors defines the positive direction
    
    // we begin by defining vectors representing the three edges of the triangle
    KSMVector3 u[3];
    u[0] = vector[1] - vector[0]; 
    u[1] = vector[2] - vector[1];
    u[2] = vector[0] - vector[2]; 
    u[0].normalise();
    u[1].normalise();
    u[2].normalise();
    
    // we can now calculate an outward pointing normal from any pair of u vectors
    // We will arbitrarily choose the first two now, but we might revise the
    // choice later because vectors nearer to 90 degrees will give a more
    // accurate normal
    KSMVector3 outwardPointingNormal = u[0] % u[1];  

    // we have everything we need to calculate the area so we do that now
    area = abs(0.5 * outwardPointingNormal.magnitude());
    
    // Now calculate the interior angle of each corner (which will also be used
    // to weight the returned normal
    a[0] = u[0] * u[1]; 
    a[0] = a[0] > 0 ? acos(a[0]): PI - acos(a[0]);
    
    a[1] = u[1] * u[2]/ (u[0].magnitude() * u[1].magnitude()); 
    a[1] = a[1] > 0 ? acos(a[1]): PI - acos(a[1]);
    
    a[2] = u[2] * u[0]; 
    a[2] = a[2] > 0 ? acos(a[2]): PI - acos(a[2]);
    
    // calculate the differences between the interior angles and 90 degrees.
    // The two side vectors closest to 90 degress will be most appropriate for
    // calculating the normal
    double d90[3];
    d90[0] = fabs(a[0] - PIBY2);
    d90[1] = fabs(a[1] - PIBY2);
    d90[2] = fabs(a[2] - PIBY2);
    
    // simple sort to find the best two vectors
    int i = 0;
    int j = 1;
    int k = 2;
    
    if (d90[j] < d90[i]) swap(i, j);
    
    if (d90[k] < d90[i]) swap(k, i);
       
    if (d90[k] < d90[j]) swap(k, j);
    
    // i and j now represent the two edge vectors closest to 90 degrees
    // and therefore most suitable for forming the cross product
    normal = u[i] % u[j];
    
    // almost done, but we must ensure that we have got the normal pointing in
    // the "out" direction defined by the cross product of v1 and v2.
    // Note that we could have taken this as the normal without all the sorting
    // but as this stuff is performed as part of the load and not during frame
    // updates we can afford to take our time and get the most accurate result
    if (outwardPointingNormal * normal < 0) 
    {
        // negative dot product implies our normal needs to be reversed
        normal.reverse();
    }
    normal.normalise();
}

-(KSMVector3)weightedNormalAtIndex:(NSUInteger)anIndex;
{
    // find the weight associated with the given index
    for (int i=0; i<3; i++) 
    {
        if (index[i]==anIndex)
        {
            // found the right vertex, so weight the normal with the angle
            // the vertex subtends in this triangle
            return a[i] * normal;
        }
    }

    // the specified vertex is not associated with this triangle
    NSAssert(NO, 
             @"the specified vertex index is not associated with this triangle.");
    
    // the only half way sensible thing we can do in this circumstance (other 
    // than throw an exception) is to return the triangle's normal vector
    return normal;
}

// return the unsigned area of the triangle
-(double)area
{
    return area;
}


@end
