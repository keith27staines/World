//
//  KSGTexture.h
//  World
//
//  Created by Keith Staines on 03/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
#import "KSGManagedResourceBase.h"

enum KSG_TextureType 
{
    KSG_Texture_1 = 0,
    KSG_Texture_2,
    KSG_Texture_Bump,   
    KSG_Texture_Normal,
    KSG_Texture_Reflection
};

@interface KSGTexture : KSGManagedResourceBase
{
    GLuint      mapID;
    BOOL        tile;
    BOOL        mirror;
    float       uOffset;
    float       vOffset;
    float       uScale;
    float       vScale;
    float       rotAngle;
}

@property GLuint     mapID;
@property BOOL       tile;
@property BOOL       mirror;
@property float     uOffset;
@property float     vOffset;
@property float     uScale;
@property float     vScale;
@property float     rotAngle;

////////////////////////////////////////////////////////////////////////////////
// sendToGL
// Copies texture map and its attributes to GL texture object
-(void)sendToGL;

// PRIVATE - refactor into category
-(GLint)textureMapFromFile:(NSString*)filename;
-(NSBitmapImageRep*)bitmapFromFile:(NSString*)filename;

@end
