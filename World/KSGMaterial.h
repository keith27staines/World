//
//  KSGMaterial.h
//  World
//
//  Created by Keith Staines on 20/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"
#import "KSGManagedResourceBase.h"
#import "KSGTexture.h"
#import "KSGColor.h"

enum KSG_MaterialType 
{
    KSG_Material_Steel = 0,
    KSG_Material_SteelPolished,
    KSG_Material_Wood,   
    KSG_Material_Glass,
    KSG_Material_Plastic,
    KSG_Material_Stone,
    KSG_Material_StonePolished,
    KSG_Material_Default = KSG_Material_Plastic
};

@interface KSGMaterial : KSGManagedResourceBase
{
    KSGColor ambientColor;
    KSGColor diffuseColor;
    KSGColor specularColor;
    KSGColor emissiveColor;
    
    double      specularExponent;
    double      opacity;
    
    // textures will be weak references (assumed retained in the texture manager)
    KSGTexture* __weak texture1;
    KSGTexture* __weak texture2;
    KSGTexture* __weak textureBump;
    KSGTexture* __weak textureReflection;
    KSGTexture* __weak textureNormal;
}

@property (assign) double     specularExponent;
@property (assign) double     opacity;

@property (weak) KSGTexture* texture1;
@property (weak) KSGTexture* texture2;
@property (weak) KSGTexture* textureBump;
@property (weak) KSGTexture* textureReflection;
@property (weak) KSGTexture* textureNormal;

-(void)setTexture:(KSGTexture*)aTexture ofType:(KSG_TextureType)type;
-(KSGTexture*)textureOfType:(KSG_TextureType)type;

-(KSGColor) ambientColor;
-(KSGColor) diffuseColor;
-(KSGColor) specularColor;
-(KSGColor) emissiveColor;

-(void) setAmbientColor:(const KSGColor&)color;
-(void) setDiffuseColor:(const KSGColor&)color;
-(void) setSpecularColor:(const KSGColor&)color;
-(void) setEmissiveColor:(const KSGColor&)color;

@end
