//
//  KSGWorld.h
//  World
//
//  Created by Keith Staines on 14/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
#import "KSPPhysics.h"
#import "KSGGraphics.h"
#import "KSCPrimitivePlane.h"


// forward declarations
@class KSCBVHNode;

// interface
@interface KSGWorld : NSObject
{
 @private 
    const NSUInteger              MAX_LIGHTS;
    BOOL                          isLoaded;
    NSMutableDictionary          * gameObjects;
    KSGShaderManager             * shaderManager;
    KSGMaterialManager           * materialManager;
    KSGTextureManager            * textureManager;
    KSGTransformPack             * transformPack;
    NSMutableArray               * lights;
    NSMutableDictionary          * potentialContacts;
    KSCBVHNode                   * binaryVolumeHeirarchy;
    KSPForceGeneratorRegistry    * forceGeneratorRegistry;
    KSPFGUniformGravity          * gravity;
    KSPFGUniformDrag             * airResistance;
    KSPFGUniformDrag             * waterResistance;
    
    KSPWater                     * water;
    KSCPrimitivePlane            * ground;
    KSCPrimitivePlane            * ceiling;
    KSCPrimitivePlane            * frontWall;
    KSCPrimitivePlane            * backWall;
    KSCPrimitivePlane            * leftWall;
    KSCPrimitivePlane            * rightWall;
    NSMutableArray               * staticPlanes;
}

@property (strong) KSCBVHNode * binaryVolumeHeirarchy;

////////////////////////////////////////////////////////////////////////////////
// one loader to load them all
-(void)loadWorld;

////////////////////////////////////////////////////////////////////////////////
// load physical environment (terrain, sun, gravity generators etc)
-(void)loadPhysicalEnvironment;

////////////////////////////////////////////////////////////////////////////////
// load shaders
-(void)loadShaders;

////////////////////////////////////////////////////////////////////////////////
// gets geometry from store and puts into batches
-(void)loadGeometry;

////////////////////////////////////////////////////////////////////////////////
// createGameObject
-(KSGGameObject*)createGameObjectWithName:(NSString*)name 
                           withSubBatches:(NSArray*)subBatches;

////////////////////////////////////////////////////////////////////////////////
// loadCamera
-(void)loadCamera;

////////////////////////////////////////////////////////////////////////////////
// send geometry to OpenGL
-(void)sendToGL;

////////////////////////////////////////////////////////////////////////////////
// updateWorld
-(void)updateWorld:(NSTimeInterval)dt;

////////////////////////////////////////////////////////////////////////////////
// drawToOpenGL
-(void)drawToOpenGL;

////////////////////////////////////////////////////////////////////////////////
// load batch representing world axes
-(KSGVertexBatch*)loadBatchWorldAxes;

////////////////////////////////////////////////////////////////////////////////
// modify the camera projection as the window on the world has changed shape
-(void)reshapeToWidth:(double)width Height:(double)height;

// deal with user pressing a key
-(void)keyDown:(NSEvent*) event;
@end
