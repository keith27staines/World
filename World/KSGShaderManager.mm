//
//  KSGShaderManager.mm
//  World
//
//  Created by Keith Staines on 07/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGShaderManager.h"
#import "KSGIndexedAttributes.h"


@implementation KSGShaderManager

+(NSString*)shaderName:(KSG_SHADERS)shader
{
    switch (shader) 
    {
        case KSG_ShaderXY:
            return @"ShaderXY";
            
        case KSG_ShaderGouraud:
            return @"ShaderGouraud";
            
        case KSG_ShaderPerspective:
            return @"ShaderPerspective";
            
        case KSG_ShaderPhong:
            return @"ShaderPhong";
            
        default:
            return @"ShaderGouraud";
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        sourcCodeStrings = [NSMutableDictionary dictionaryWithCapacity:1024];
        programIDs = [NSMutableDictionary dictionaryWithCapacity:1024];
        
        // Add the 2D projection shader (z coord ignored)
        [programIDs setObject:[NSNumber numberWithInt:-1] 
                       forKey:@"ShaderXY"];
        
        // Add the Gouraud shader (also the default)
        [programIDs setObject:[NSNumber numberWithInt:-1] 
                       forKey:@"ShaderGouraud"];

        // Add the Phong shader 
        [programIDs setObject:[NSNumber numberWithInt:-1] 
                       forKey:@"ShaderPhong"];
        
        // Add the flat shader (uses vertex colors)
        [programIDs setObject:[NSNumber numberWithInt:-1] 
                       forKey:@"ShaderFlat"];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// loadShaders
// loads all shaders into GPU
-(void)loadShaders
{
    // create the attribute list    
    KSGIndexedAttributes* attributes = [[KSGIndexedAttributes alloc] init];
    [attributes setToFullDefaults];
    NSMutableDictionary* updatedProgramIDs = [NSMutableDictionary dictionaryWithCapacity:[programIDs count]];
                                             
    int loadResult;
    for (NSString* shaderKey in programIDs) 
    {
        loadResult = [self loadVertShader:shaderKey 
                               FragShader:shaderKey 
                               Attributes:attributes];
        NSNumber* updatedProgID = [NSNumber numberWithInt:loadResult];
        [updatedProgramIDs setObject:updatedProgID forKey:shaderKey];
        
        // Did the shader load correctly?
        NSAssert1(loadResult > 0, @"Failed to load shader: %@", shaderKey);
        
    }

    programIDs = updatedProgramIDs;
}

////////////////////////////////////////////////////////////////////////////////
// programID: 
// Returns the name by which the GL knows the specified shader
-(GLint)programID:(KSG_SHADERS)shader
{
    NSString* key = [KSGShaderManager shaderName:shader];
    return (GLint)[[programIDs objectForKey:key] integerValue];
}

////////////////////////////////////////////////////////////////////////////////
// loadVertShader: FragShader: Attributes:
// Load the specified vertex shader and fragment shader into the GPU with the
// specified attributes.
-(GLuint)loadVertShader:(NSString*)vertShaderName 
             FragShader:(NSString*)fragShaderName
             Attributes:(KSGIndexedAttributes*)attributes
{

    // define a value to hold result returned from GPU from 
    // success/failure queries
    GLint testVal = 0;          // holds the success or failure of the op
    char infoLog[1024];         // holds the reason for failure

    // get the source code for the vertex shader
    NSString* srcVertex = [self shaderSourcecode:vertShaderName 
                                             ofType:KSGL_SHADER_TYPE_VERTEX] ;
    
    // do we have it?
    if ( nil == srcVertex )
    {
        // failed to get the source code for the vertex shader
        NSLog(@"failed to obtain vertex shader source: %@", vertShaderName );
        return 0;
    }
    
    NSLog(@"Source code for vertex shader\n%@ \n",srcVertex);
    
    // convert the vertex source code to c style null terminated char array 
    const char* sv = [srcVertex cStringUsingEncoding:NSUTF8StringEncoding];
    
    // ok, we have source code for the vertex shader
    GLuint hVertShader = glCreateShader(GL_VERTEX_SHADER);
    
    // send the vertex source to the vertex shader so that it can be compiled
    glShaderSource(hVertShader, 1, &sv, NULL);

    // comile the vertex shader
    glCompileShader(hVertShader);
    
    // Check the vertex shader for errors
    glGetShaderiv(hVertShader, GL_COMPILE_STATUS, &testVal);
    if (GL_FALSE == testVal) 
    {
        // failed to create the vertex shader
        char infoLog[1024];         // holds the reason for failure

        glGetShaderInfoLog(hVertShader, 1024, NULL, infoLog);
        [self logInfoSummary:@"Failed to compile the vertex shader." 
                errorDetails:infoLog];
        
        glDeleteShader(hVertShader);
        return 0;
    }
    testVal = 0;
    
    ////////////////////////////////////////////////////////////////////////////
    // Now repeat above steps for the fragment shader
    
    // get the source code for the fragment shader
    NSString* srcFragment = [self shaderSourcecode:fragShaderName 
                                               ofType:KSGL_SHADER_TYPE_FRAGMENT] ;
    
    // do we have it?
    if ( nil == srcFragment )
    {
        // failed to get source code for fragent shader
        NSLog(@"Failed to obtain fragment shader source: %@", vertShaderName );
        return 0;
    }          

    // ok, we have the source code, but we need it in a c style string
    // convert the fragment source to c style null terminated char array
    const char* sf = [srcFragment cStringUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"Source code for fragment shader\n%@ \n",srcFragment);

    // create the fragment shader
    GLuint hFragShader = glCreateShader(GL_FRAGMENT_SHADER);
    
    // send the fragment source to the fragment shader
    glShaderSource(hFragShader, 1, &sf, NULL);
 
    // compile the fragment shader
    glCompileShader(hFragShader);
    
    // check fragment shader for compile errors
    glGetShaderiv(hFragShader, GL_COMPILE_STATUS, &testVal);
    if (GL_FALSE == testVal) 
    {
        // failed to compile the fragment shader
        glGetShaderInfoLog(hVertShader, 1024, NULL, infoLog);
        [self logInfoSummary:@"Failed to compile the fragment shader." 
                errorDetails:infoLog];
        
        glDeleteShader(hVertShader);
        glDeleteShader(hFragShader);
        return 0;
    }
    
    // ok, we have compiled shaders, now we need to create a program and
    // link the shaders to it
    
    // create the program 
    GLuint hProgram = glCreateProgram();
    
    // attach the shaders
    glAttachShader(hProgram, hVertShader);
    glAttachShader(hProgram, hFragShader);
    
    // bind the attribute names (as defined in the shader programs)
    // to ids. We will use these ids to pass data from the client into
    // the shader program
    for (KSGIndexedAttribute *ia in attributes.indexedAttributes) 
    {
        // get the attribute name as it is known in the shader program
        // (assuming that the shader program conforms to our naming
        // convention)
        const char* cstr = [ia.attribute UTF8String];
        
        // get the index we intend to use to refer to the attribute
        int index = ia.indexForAttrbute;
        
        // bind the index and the string together (actually, just queues
        // this up as work to be done by the linker).
        glBindAttribLocation(hProgram, index, cstr);
    }
    
    // link the program
    glLinkProgram(hProgram);
                  
    // now that we've linked the program, we can delete the shaders
    glDeleteShader(hVertShader);
    glDeleteShader(hFragShader);
    
    // test that the link worked
    glGetProgramiv(hProgram, GL_LINK_STATUS, &testVal);
    if( false == testVal)
    {
        glGetProgramInfoLog(hProgram, 1024, NULL, infoLog);
        [self logInfoSummary:@"Failed to link the program." 
                errorDetails:infoLog];
        return 0;
    }
    
    // return the handle to our fully compiled and linked program
    return hProgram;
}

-(void) logInfoSummary:(NSString*)summary 
          errorDetails:(char*)details
{
    NSLog(@"ERROR summary: %@ \n DETAILS: \n %@", 
          summary,
          [NSString stringWithCString:details encoding:NSUTF8StringEncoding]);    
}

////////////////////////////////////////////////////////////////////////////////
// shaderSourcecode
// Loads and caches the shader source code and returns a pointer to it.
// Note that this method does NOT send the sourcecode to the GPU, so it remains
// only in client-side memory
-(NSString*)shaderSourcecode:(NSString *)shaderName 
                         ofType:(KSGL_SHADER_TYPE)enumType
{
    NSString* ext = nil;
    switch (enumType) 
    {
        case KSGL_SHADER_TYPE_VERTEX:
            ext = @"vp";
            break;

        case KSGL_SHADER_TYPE_FRAGMENT:
            ext = @"fp";
            break;
            
        default:
            NSLog(@"Unknown shader type");
            return nil;
            break;
    }

    // construct the fullname including extension as we will use this
    // as the source code's key in the source code dictionay
    NSString * fullname;
    fullname = [shaderName stringByAppendingString:@"."];
    fullname = [fullname stringByAppendingString:ext];    
    
    // if we've loaded it before, just locate it and return it
    NSString *src = nil;
    src = [sourcCodeStrings objectForKey:fullname];

    // if we found it in the dictionary, return it
    if (src) return src;
    
    // didn't already exist so we read from file and add it
    
    // construct the URL where the file is located
    NSURL* url = [[NSBundle mainBundle] URLForResource:shaderName 
                                         withExtension:ext];
    
    // set up an error object in case there is an error during read
    NSError* error = nil;
    
    // try to read the contents of the file
    src = [NSString stringWithContentsOfURL:url 
                                   encoding:NSASCIIStringEncoding 
                                      error:&error];
    // did the file read work?
    if( src )
    {        
        // yep, we've got our source code in memory
        // so add it to the dictionary for future reference
        // and return it for immediate use
        [sourcCodeStrings setObject:src forKey:fullname];
        return src;
    }
    
    // error reading file
    NSLog(@"Error = %@", error);

    return nil;
}


@end
