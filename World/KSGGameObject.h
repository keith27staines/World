//
//  KSGGameObject.h
//  World
//
//  Created by Keith Staines on 11/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "KSMMaths.h"
#import "KSCBody.h"

@class KSGTransformPack;
@class KSGBatch;
@class KSCBVHNode;
@class KSCBoundingVolume;
@class KSGUID;
@class KSPPhysicsBody;
@class KSPWater;

@interface KSGGameObject : NSObject <KSCBody>
{
 @public 

 @protected
    KSGUID   * uid;
    NSString * name;
    NSArray  * batches;
    
    KSPPhysicsBody * physicsBody;

    // bounding volume
    KSCBVHNode * internalVolumeHierarchy;
    KSCBVHNode * boundingNode;
    KSCBoundingVolume * boundingVolume;
    
    // shader used to draw
    GLint      progId;
    
}

@property (copy)     NSString               * name;
@property (strong, readonly) KSGUID         * uid; 
@property (strong)   NSArray                * batches;
@property (strong)   KSCBVHNode             * boundingNode;
@property (strong)   KSCBoundingVolume      * boundingVolume;
@property (strong)   KSPPhysicsBody         * physicsBody;
@property (assign)   const KSMMatrix4       & modelWorld;

////////////////////////////////////////////////////////////////////////////////
// designated constructor
-(id)  initWithName:(NSString*)aName mass:(double)m 
    momentOfInertia:(const KSMMatrix3&)mi                    
initialModelToWorld:(const KSMMatrix4 &)modelToWord
     linearVelocity:(const KSMVector3 &)linVel 
    angularVelocity:(const KSMVector3 &)angVel 
            batches:(NSArray *)batches;

// helper factory method to construct a new game object
+(id)gameObjectWithName:(const NSString*)kName
                   mass:(double)m
        momentOfInertia:(const KSMMatrix3 &)mI
    initialModelToWorld:(const KSMMatrix4 &)modelToWord
         linearVelocity:(const KSMVector3 &)linVel 
        angularVelocity:(const KSMVector3 &)angVel 
                batches:(const NSArray*)batches;

// draws the model using the transforms in the pack
-(void)drawUsingTransformPack:(KSGTransformPack*)transformPack
                       lights:(NSArray*)allLights;


// update internal data for next frame (do physics, etc)
-(void)update:(double)dt;

@end
