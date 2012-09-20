//
//  KSCCollisionDetector.h
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KSCPrimitiveSphere;
@class KSCPrimitivePlane;
@class KSCPrimitiveBox;
@class KSPPhysicsBody;
@class KSCPrimitive;

const NSUInteger MAX_RESOLUTION_ITERATIONS = 20;

// We won't do anything about penetrations that are shallower than this...
const double     MAX_ALLOWED_PENETRATION   = 0.01;

// We won't do anything about contacts moving together more slowly than this...
// (Question - should this be related to the sleep epsilon in the physics system?
const double     MAX_ALLOWED_SPEED = 0;//sqrt( 2.0 * MAX_ALLOWED_PENETRATION * 9.81); 

@interface KSCCollisionDetector : NSObject
{
    NSUInteger maxCollisions;
    NSMutableArray * contacts;
    NSUInteger maxResolutionIterations;
}

@property (readonly)  NSUInteger maxCollisions;
@property (readonly, strong) NSMutableArray * contacts;

-(id)initWithMaxCollisions:(NSUInteger)maximum;

// detects a collision between the two specified spheres, adds the contact
// data to the contactdata list, and returns the number of slots left for other
// contacts
-(NSUInteger)sphere:(KSCPrimitiveSphere*)sphereA 
         withSphere:(KSCPrimitiveSphere*)sphereB;

// detects a collision between the specified sphere and plane, adds the contact
// data to the contactdata list, and returns the number of slots left for other
// contacts
-(NSUInteger)sphere:(KSCPrimitiveSphere*)sphere 
      withHalfPlane:(KSCPrimitivePlane*)plane;

// detects a collision between the specified sphere and box, adds the contact
// data to the contactdata list, and returns the number of slots left for other
// contacts
-(NSUInteger)sphere:(KSCPrimitiveSphere*)sphere 
            withBox:(KSCPrimitiveBox*)box;

// detects a collision between the specified box and half plane, adds the contact
// data to the contactdata list, and returns the number of slots left for other
// contacts
-(NSUInteger)box:(KSCPrimitiveBox*)box 
   withHalfPlane:(KSCPrimitivePlane*)plane;

// detects a collision between the specified boxes, adds the contact
// data to the contactdata list, and returns the number of slots left for other
// contacts
-(NSUInteger)box:(KSCPrimitiveBox*)boxA 
         withBox:(KSCPrimitiveBox*)boxB;

// detect collision between two game objects
-(NSUInteger)examinePhysicsBody:(KSPPhysicsBody*)bodyA 
                       againstPhysicsBody:(KSPPhysicsBody*)bodyB;

-(NSUInteger)examinePrimitive:(KSCPrimitive*)primitiveA 
       againstPrimitive:(KSCPrimitive*)primitiveB;

// detect collisions between a physics body and a primitive
-(NSUInteger)examinePhysicsBody:(KSPPhysicsBody*)aPhysicsBody 
       againstPrimitive:(KSCPrimitive*)aPrimitive;



// returns the maximum number of contacts that may still be added
-(NSUInteger)spaceLeft;

// remove all contacts and ready for next frame
-(void)removeAll;

// attempt to resolve contacts
-(void)resolveContactsOverInterval:(double)dt;

@end
