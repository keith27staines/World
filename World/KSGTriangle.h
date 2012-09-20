//
//  KSGTriangle.h
//  World
//
//  Created by Keith Staines on 10/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"

@class KSGVertex;

@interface KSGTriangle : NSObject
{
 @protected
    NSUInteger triangleIndex;

    KSMVector3 vector[3];
    KSMVector3 normal;
    double area;
    
    NSUInteger index[3]; // indices associated with vertices
    double      a[3];     // angles associated with vertices
    
}
@property NSUInteger triangleIndex;
@property (readonly) KSMVector3 normal;
@property (readonly) double area;
@property (readonly) double normalWeight1;
@property (readonly) double normalWeight2;
@property (readonly) double normalWeight3;

// convenience constructor
+(id)triangleFromVertex1:(KSGVertex*)firstVertex 
                  index1:(NSUInteger)firstIndex
                 vertex2:(KSGVertex*)secondVertex
                  index2:(NSUInteger)secondIndex
                 vertex3:(KSGVertex*)thirdVertex 
                  Index3:(NSUInteger)thirdIndex;

// desgnated standard constructor
-(id)initFromVertex1:(KSGVertex*)firstVertex 
              index1:(NSUInteger)firstIndex
             vertex2:(KSGVertex*)secondVertex 
              index2:(NSUInteger)secondIndex
             vertex3:(KSGVertex*)thirdVertex
              index3:(NSUInteger)thirdIndex;

// returns the area of the triangle
-(double)area;

// assigns all three vertices
-(void)setVerticesVertex1:(KSGVertex*)firstVertex
                   index1:(NSUInteger)firstIndex
                  vertex2:(KSGVertex*)secondVertex
                   index2:(NSUInteger)secondIndex
                  vertex3:(KSGVertex*)thirdVertex
                   index3:(NSUInteger)thirdIndex;

-(KSMVector3)weightedNormalAtIndex:(NSUInteger)anIndex;

@end
