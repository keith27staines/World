//
//  KSGTexture.mm
//  World
//
//  Created by Keith Staines on 03/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGTexture.h"

@implementation KSGTexture

@synthesize mapID;
@synthesize tile;
@synthesize mirror;
@synthesize uOffset;
@synthesize vOffset;
@synthesize uScale;
@synthesize vScale;
@synthesize rotAngle;

////////////////////////////////////////////////////////////////////////////////
// initWithName
// Override the designated constructor of super
-(id)initWithName:(NSString *)aName
{
    self = [super initWithName:aName];
    if (self)
    {
        // Add KSGTexture specific initialisation here
        
        mapID       = 0;
        tile        = NO;
        mirror      = NO;
        uOffset     = 0.0f;
        vOffset     = 0.0f;
        uScale      = 1.0f;
        vScale      = 1.0f;
        rotAngle    = 0.0f;
    
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// sendToGL
// Copies texture map and its attributes to GL texture object
-(void)sendToGL
{
    [self textureMapFromFile:name];
}

-(GLint)textureMapFromFile:(NSString *)filename
{    
    // Get the bitmap from file
    NSBitmapImageRep*  bmp = [self bitmapFromFile:filename];
    NSInteger bmpSamplesPerPixel = [bmp samplesPerPixel];

    GLint borderWidth     = 0;
    GLenum internalFormat = 0;
    GLenum externalFormat = 0;
    mapID                 = 0;

    // Create the GL texture object
    glGenTextures(1, &mapID);
    glBindTexture(GL_TEXTURE_2D, mapID);    
        
    // determine pixel format
    if ( ![bmp isPlanar] )
    {
        if ( 4 == bmpSamplesPerPixel )
        {
            internalFormat = GL_COMPRESSED_RGBA; // GL_RGBA8;
            externalFormat = GL_RGBA;
        }
        else
        {
            internalFormat = GL_COMPRESSED_RGB; // GL_RGB8;
            externalFormat = GL_BGR;
        }
    }
    else
    {
        // Don't know how to handle non-planar bitmaps
        NSAssert(@"image %@ is in unexpected (planar) format.",filename);
    }
        
    // assign parameter values
    //glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)[bmp pixelsWide]);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 
                 0, 
                 internalFormat, 
                 (GLuint)bmp.pixelsWide, 
                 (GLuint)bmp.pixelsHigh, 
                 borderWidth, 
                 externalFormat, 
                 GL_UNSIGNED_BYTE, 
                 [bmp bitmapData]);
    
    
    // Reporting
    GLint compressedSize;
    GLint isCompressed;
    glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_COMPRESSED, &isCompressed);
    glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_COMPRESSED_IMAGE_SIZE, &compressedSize);
    NSLog(@"Image %@ loaded as texture. \nNative size     = %ld\nCompressed size = %d",
          filename,
          [bmp bytesPerPlane],
          compressedSize);
    
    
    glGenerateMipmap(GL_TEXTURE_2D);
    
    return mapID;
}

-(NSBitmapImageRep*)bitmapFromFile:(NSString*)filename
{
    // Create the img from file
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *fullName = [resourcePath stringByAppendingPathComponent:filename];
    
    NSImage * img = [[NSImage alloc] initWithContentsOfFile:fullName];
    
    NSAssert1(img, @"image could not be loaded from file %@", filename);
    
    // create a bitmap from the image
    NSSize imgSize = [img size];
    NSRect imgRect = NSMakeRect(0.0f, 0.0f, imgSize.width, imgSize.height);
    [img lockFocus];
    NSBitmapImageRep* bmp = [[NSBitmapImageRep alloc] 
                             initWithFocusedViewRect:imgRect];
    [img unlockFocus];
    NSAssert1(bmp, @"failed to create bitmap for %@", filename);
    
    return bmp;
}
@end
