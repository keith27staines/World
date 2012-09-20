//
//  KSGShaderManager.h
//  World
//
//  Created by Keith Staines on 07/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <OpenGL/gl3.h>

enum KSGL_SHADER_TYPE 
{
    KSGL_SHADER_TYPE_VERTEX = 0,
    KSGL_SHADER_TYPE_FRAGMENT 
};

enum KSG_SHADERS 
{
    KSG_ShaderXY = 0,
    KSG_ShaderPerspective,
    KSG_ShaderGouraud,
    KSG_ShaderPhong
};

@class KSGIndexedAttributes;


@interface KSGShaderManager : NSObject
{
    @private 
    NSMutableDictionary* sourcCodeStrings;
    NSMutableDictionary* programIDs;
}

+(NSString*)shaderName:(KSG_SHADERS)shader;

////////////////////////////////////////////////////////////////////////////////
// loadShaders
// loads all shaders into GPU
-(void)loadShaders;

////////////////////////////////////////////////////////////////////////////////
// loadVertShader: FragShader: Attributes:
// Load the specified vertex shader and fragment shader into the GPU with the
// specified attributes.
-(GLuint)loadVertShader:(NSString*)vertShaderName 
             FragShader:(NSString*)fragShaderName
             Attributes:(KSGIndexedAttributes*)attributes;

////////////////////////////////////////////////////////////////////////////////
// programID: 
// Returns the name by which the GL knows the specified shader
-(GLint)programID:(KSG_SHADERS)shader;


////////////////////////////////////////////////////////////////////////////////
// getShaderSourcecode: ofType
// Returns a pointer to the specified shader
-(NSString*)shaderSourcecode:(NSString*) shaderName
                         ofType:(KSGL_SHADER_TYPE) enumType;

-(void) logInfoSummary:(NSString*)summary 
          errorDetails: (char*) details;

@end
