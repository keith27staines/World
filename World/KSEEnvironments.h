//
//  KSEEnvironments.h
//  Worldl
//
//  Created by Keith Staines on 03/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSGModelLoader;
@class KSCBVHNode;
@class KSGModelLoader;

@interface KSEEnvironments : NSObject
{
    
}
@property (weak) NSString            * resourcePath;
@property (weak) KSGModelLoader      * modelLoader;
@property (weak) NSMutableDictionary * gameObjects;
@property (weak) KSCBVHNode          * binaryVolumeHeirarchy;

-(id)initWithResourcePath:(NSString*)resourcePath 
              modelLoader:(KSGModelLoader*)modelLoader
              gameObjects:(NSMutableDictionary *)gameObjects
    binaryVolumeHeirarchy:(KSCBVHNode*)binaryVolumeHeirarchy;

-(void)createSolarSystem;

@end
