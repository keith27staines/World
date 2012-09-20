//
//  KSGVertex.mm
//  World
//
//  Created by Keith Staines on 06/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGVertex.h"


@implementation KSGVertex

@synthesize x,y,z;
@synthesize normalX, normalY, normalZ;
@synthesize red, green, blue;
@synthesize textureX, textureY, textureZ;

////////////////////////////////////////////////////////////////////////////////
// init
// override in order to use designated constructor
- (id)init
{
    return [self initAtX:0.0
                       Y:0.0
                       Z:0.0];
}

////////////////////////////////////////////////////////////////////////////////
// initAtX:Y:Z:
// designated constructor
- (id)initAtX:(float)xPos
            Y:(float)yPos
            Z:(float)zPos
{
    self = [super init];
    if (self) {
        // Initialization code here.
        x = xPos;
        y = yPos;
        z = zPos;
    }

    return self;    

}

// convenience method returns a new autoreleased instance
+(id) vertex
{
    id vertex = [[[self class] alloc] init];
    return vertex;
}

// convenience method returns a new autoreleased instance
+(id) vertexAtVector:(KSMVector3 &)posVector 
                  withNormal:(KSMVector3 &)normal 
                   withColor:(KSGColor &)color 
{
    id newVertexInstance = [[self class] vertexAtPosX:(float)posVector.x 
                                                 PosY:(float)posVector.y 
                                                 PosZ:(float)posVector.z 
                                          WithNormalX:(float)normal.x 
                                              NormalY:(float)normal.y 
                                              NormalZ:(float)normal.x 
                                          AndColorRed:color.red
                                           ColorGreen:color.green
                                            ColorBlue:color.blue];
    return newVertexInstance;
                       
}

////////////////////////////////////////////////////////////////////////////////
// convenience constructor returns a full alloced, initialised and 
// autoreleased object
+(id) vertexAtX:(float)xPos
              Y:(float)yPos
              Z:(float)zPos
{
    id v = [[[self class] alloc] initAtX:xPos Y:yPos Z:zPos];
    return v;
}


////////////////////////////////////////////////////////////////////////////////
// convenience constructor returns a full alloced, initialised and 
// autoreleased object containing position, normal, and color info
+(id) vertexAtPosX:(float)px
              PosY:(float)py
              PosZ:(float)pz
       WithNormalX:(float)nx 
           NormalY:(float)ny 
           NormalZ:(float)nz 
       AndColorRed:(float)red 
        ColorGreen:(float)green 
         ColorBlue:(float)blue
{
    id newVertexInstance = [[self class] vertexAtX:px Y:py Z:pz];
    
    KSGVertex* v = (KSGVertex*)newVertexInstance;
    v.normalX   = nx;
    v.normalY   = ny;
    v.normalZ   = nz;
    v.red       = red;
    v.green     = green;
    v.blue      = blue;
    return  v;
}

////////////////////////////////////////////////////////////////////////////////
// makeVectorFromVertex
// returns a KSMVector3 with components equal to the coordinates of the vertex
// NB The caller is responsible for freeing the returned vector
+(KSMVector3)makeVectorFromVertex:(KSGVertex*)vertex
{
    return KSMVector3(vertex.x, vertex.y, vertex.z);
}

-(KSMVector3)vector3
{
    return KSMVector3(x, y, z);
}

-(KSMVector4)vector4
{
    return KSMVector4(x, y, z, 1.0);
}


@end
