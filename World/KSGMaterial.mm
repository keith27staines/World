//
//  KSGMaterial.m
//  World
//
//  Created by Keith Staines on 20/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGMaterial.h"

@implementation KSGMaterial

////////////////////////////////////////////////////////////////////////////////
// initWithName
// Override designated constructor of super
- (id)initWithName:(NSString *)aName
{
    self = [super initWithName:aName];
        
    if (self) {

        // Add KSGMaterial specific initialisation here
        texture1            = nil;
        texture2            = nil;
        textureBump         = nil;
        textureReflection   = nil;
        textureNormal       = nil;
        
        // Initialization code here.
        KSGColor white = [KSGColorFactory makeColor:@"White"];
        KSGColor black = [KSGColorFactory makeColor:@"Black"];
        ambientColor       = white;
        diffuseColor       = white;
        specularColor      = [KSGColorFactory brightenColor:white byFactor:0.4];
        emissiveColor      = black;
        specularExponent   = 20.0;
    }
    
    return self;
}

@synthesize specularExponent;
@synthesize opacity;

@synthesize texture1;
@synthesize texture2;
@synthesize textureBump;
@synthesize textureReflection;
@synthesize textureNormal;



-(KSGColor) ambientColor  {return ambientColor;}
-(KSGColor) diffuseColor  {return diffuseColor;}
-(KSGColor) specularColor {return specularColor;}
-(KSGColor) emissiveColor {return emissiveColor;}

-(void) setAmbientColor: (const KSGColor&)color {ambientColor  = color;}
-(void) setDiffuseColor: (const KSGColor&)color {diffuseColor  = color;}
-(void) setSpecularColor:(const KSGColor&)color {specularColor = color;}
-(void) setEmissiveColor:(const KSGColor&)color {emissiveColor = color;}

-(void)setTexture:(KSGTexture*)aTexture ofType:(KSG_TextureType)type
{
    switch (type) 
    {
        case KSG_Texture_1:
        {
            [self setTexture1:aTexture];
            break;
        }

        case KSG_Texture_2:
        {
            [self setTexture2:aTexture];
            break;
        }
            
        case KSG_Texture_Bump:
        {
            [self setTextureBump:aTexture];
            break;
        }

        case KSG_Texture_Normal:
        {
            [self setTextureNormal:aTexture];
            break;
        }
        
        case KSG_Texture_Reflection:
        {
            [self setTextureReflection:aTexture];
            break;
        }

        default:
            break;
    }
}

-(KSGTexture*)textureOfType:(KSG_TextureType)type
{
    switch (type) 
    {
    case KSG_Texture_1:
        {
            return texture1;
            break;
        }
        
    case KSG_Texture_2:
        {
            return texture2;
            break;
        }
        
    case KSG_Texture_Bump:
        {
            return textureBump;
            break;
        }
        
    case KSG_Texture_Normal:
        {
            return textureNormal;
            break;
        }
        
    case KSG_Texture_Reflection:
        {
            return textureNormal;
            break;
        }
        
    default:
        break;
    }  
}


@end
