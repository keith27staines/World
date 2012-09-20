//
//  KSGVertex.h
//  World
//
//  Created by Keith Staines on 06/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"
#import "KSGColor.h"


@interface KSGVertex : NSObject
{
    @protected
    
    // vertex position 
    float x, y, z;
    
    // normal, color components and texture coordinates are stored in single precision
    float normalX, normalY, normalZ;
    float red, green, blue;
    float textureX, textureY, textureZ;
}

// vertex position 
@property float x;
@property float y;
@property float z;

// vertex normal 
@property float normalX;
@property float normalY;
@property float normalZ;

// 
@property float red;
@property float green;
@property float blue;

@property float textureX;
@property float textureY;
@property float textureZ;

// designated constructor
- (id)initAtX:(float)xPos
            Y:(float)yPos
            Z:(float)zPos;

// convenience constructor returns a new autoreleased instance
+(id) vertex;

// convenience constructor returns a new autoreleased instance
+(id) vertexAtVector:(KSMVector3 &)v 
                  withNormal:(KSMVector3 &)normal 
                   withColor:(KSGColor &)color;

// convenience constructor returns a new autoreleased instance
+(id) vertexAtX:(float)x
              Y:(float)y
              Z:(float)z;

// convenience constructor returns a new autoreleased instance
+(id) vertexAtPosX:(float)px
              PosY:(float)py
              PosZ:(float)pz
       WithNormalX:(float)nx 
           NormalY:(float)ny 
           NormalZ:(float)nz 
       AndColorRed:(float)red 
        ColorGreen:(float)green 
         ColorBlue:(float)blue;

+(KSMVector3)makeVectorFromVertex:(KSGVertex*)vertex;

-(KSMVector3)vector3;
-(KSMVector4)vector4;

@end
