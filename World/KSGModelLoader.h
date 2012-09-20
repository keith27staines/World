//
//  KSGModelLoader.h
//  World
//
//  Created by Keith Staines on 07/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSGColor.h"

@class KSGIndexedTriangleBatch;
@class KSGShaderManager;
@class KSGMaterialManager;
@class KSGTextureManager;

const int MAX_ASCIIZ_CHARS = 1024;  // maximum number of characters to read

@interface KSGModelLoader : NSObject
{
    @private
    NSRange r;
    NSData* byteData;
    NSUInteger length;
    KSGShaderManager   * shaderManager;
    KSGMaterialManager * materialManager;
    KSGTextureManager  * textureManager;
    
}

////////////////////////////////////////////////////////////////////////////////
// helper to construct an autoreleased KSGModelLoader
+(id)loaderWithShaderManager:(KSGShaderManager   *) theShaderManager 
         withMaterialManager:(KSGMaterialManager *) theMaterialManager
          withTextureManager:(KSGTextureManager  *) theTextureManager;

-(id)initWithShaderManager:(KSGShaderManager     *) theShaderManager 
       withMaterialManager:(KSGMaterialManager   *) theMaterialManager           
        withTextureManager:(KSGTextureManager    *) theTextureManager;

////////////////////////////////////////////////////////////////////////////////
-(NSArray*)loadModelFromFile:(NSString*)fileName 
                      ofType:(NSString*)modelType 
                applyScaling:(float)scale;

////////////////////////////////////////////////////////////////////////////////
// private methods
-(NSData*)readModelData:(NSString*)modelName 
                 ofType:(NSString*)modelType;

-(void)skipChunk:(NSUInteger)chunkLength;

-(void)getBytes:(void*)dataElement sizeOfElement:(NSUInteger)thisSize;

// common in many chunks, "Amount of" data is held in a specialised sub chunk.
// This function reads it and moves the pointer on by the appropriate amount
-(unsigned short)readAmount;

// strings are null delimited c strings which we convert to NSStrings
-(NSString*)readAsciiz;

// colors are read into 4 component vectors
-(void)getActualColor:(KSGColor*)actual 
      getDisplayColor:(KSGColor*)display
      withChunkLength:(unsigned int)numBytes;

-(KSGColor)readColorActual;
-(KSGColor)readColorDisplay;

@end
