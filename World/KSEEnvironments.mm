//
//  KSEEnvironments.mm
//  World
//
//  Created by Keith Staines on 03/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSEEnvironments.h"
#import "KSGModelLoader.h"
#import "KSCBVHNode.h"

@implementation KSEEnvironments

@synthesize resourcePath          = _resourcePath;
@synthesize gameObjects           = _gameObjects;
@synthesize binaryVolumeHeirarchy = _binaryVolumeHeirarchy;
@synthesize modelLoader           = _modelLoader;

-(id)init
{
    NSAssert(NO, @"Do not use this constructor");
    return nil;
}

-(id)initWithResourcePath:(NSString*)resourcePath 
              modelLoader:(KSGModelLoader*)modelLoader
              gameObjects:(NSMutableDictionary *)gameObjects
    binaryVolumeHeirarchy:(KSCBVHNode*)binaryVolumeHeirarchy
{
    self = [super init];
    self.resourcePath          = resourcePath;
    self.modelLoader           = modelLoader;
    self.gameObjects           = gameObjects;
    self.binaryVolumeHeirarchy = binaryVolumeHeirarchy;
    return self;
}

-(void)createSolarSystem
{
//    // read the mesh data from file (there might be many sub models)
//    float scaleFactor = 1.0;
//    NSArray* subBatches = [loader loadModelFromFile:fileName 
//                                             ofType:extension 
//                                       applyScaling:scaleFactor];
//    
//    // create the game object that will hold these sub-batches and add the 
//    // game object to the game object collection.
//    
//    KSGGameObject* gameObject;
//    gameObject = [self createGameObjectWithName:fileName 
//                                 withSubBatches:subBatches];
//    
//    [gameObjects setObject:gameObject forKey:fileName];   
}
@end
