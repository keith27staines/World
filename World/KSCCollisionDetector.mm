//
//  KSCCollisionDetector.mm
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCCollisionDetector.h"
#import "KSMMaths.h"
#import "KSCPrimitive.h"
#import "KSCPrimitiveSphere.h"
#import "KSCPrimitivePlane.h"
#import "KSCPrimitiveBox.h"
#import "KSCContact.h"
#import "KSPPhysicsBody.h"

@implementation KSCCollisionDetector

@synthesize maxCollisions;
@synthesize contacts;

-(id)initWithMaxCollisions:(NSUInteger)maximum
{
    self = [super init];
    maxCollisions = maximum;
    contacts = [NSMutableArray arrayWithCapacity:maximum];
    return self;
}

-(id)init
{
    return [self initWithMaxCollisions:100];
}

-(NSUInteger)spaceLeft
{
    return maxCollisions - contacts.count - 1;
}

-(NSUInteger)sphere:(KSCPrimitiveSphere*)sphereA 
         withSphere:(KSCPrimitiveSphere*)sphereB
{
    if (contacts.count == maxCollisions - 1) return 0;
    

    double radiusA = sphereA.radius;
    double radiusB = sphereB.radius;
    KSMVector4 posA = sphereA.positionWC;
    KSMVector4 posB = sphereB.positionWC;
    
    KSMVector3 midLineAB = (posB - posA).vector3();
    double distanceAB = midLineAB.length();
    
    if ( distanceAB > (radiusA + radiusB) ) 
    {
        // spheres are too far apart for there to be a collision, so we just
        // return immediately
        return [self spaceLeft];
    }

    // There is interpenetration of the two spheres so construct a contact
    // object to represent it and add to the list of contacts
    KSCContact * contact = [[KSCContact alloc] init];
    [contacts addObject:contact];

    // assign the physics objects involved in the contact
    [contact setBodyA:sphereA.physicsBody];
    [contact setBodyB:sphereB.physicsBody];
    
    // assign the contact normal (points from B to A)
    [contact setContactNormalWC:(-1 * midLineAB.unitVector() )];
    
    // assign the point of contact (very nebulous and arbitrary concept, so
    // pretty much any point between A and B will do. We choose the half
    // way point).

    KSMVector4 contactPoint = posA + 0.5 * midLineAB.vector4Direction();
    [contact setContactPointWC:contactPoint];
    
    // set the depth (+ve depth signifies amount of interpenetration). Unlike
    // the point of contact, the depth of contact has an exact definition - 
    // the amount that the objects must be moved apart along the line joining
    // A to B such that they are no longer interpenetrating.
    [contact setDepth:radiusA + radiusB - distanceAB];
    
    // return the amount of space we have left for other contacts
    return [self spaceLeft];
}


-(NSUInteger)sphere:(KSCPrimitiveSphere*)sphere 
      withHalfPlane:(KSCPrimitivePlane*)plane
{
    if (contacts.count == maxCollisions - 1) return 0;
    
    double     sphereRadius     = sphere.radius;
    KSMVector3 spherePosWC      = sphere.positionWC.vector3();
    KSMVector3 planeNormalWC    = plane.normalWC;
    KSMVector3 planePosWC       = plane.positionWC.vector3();
    KSMVector3 rPlaneToSphereWC = spherePosWC - planePosWC; 

    // calculate perpendicular distance from plane to centre of sphere, which
    // will be positive if the sphere is "above" the plane (ie, in the
    // direction of the plane normal), and negative if below.
    double distancePlaneToSphere = rPlaneToSphereWC * planeNormalWC;
    
    // calculate depth of penetration, which will be positive if there is
    // penetrationa and negative otherwise.
    double penetrationDepth = sphereRadius - distancePlaneToSphere;
    
    if (penetrationDepth < 0) 
    {
        // no contact!
        return [self spaceLeft];
    }
    KSMVector3 contactPositionWC = spherePosWC - sphereRadius * planeNormalWC;
    KSCContact * contact = [[KSCContact alloc] init];
    [contact setBodyA:sphere.physicsBody];
    [contact setBodyB:plane.physicsBody];
    [contact setContactNormalWC:plane.normalWC]; // points from plane to sphere
    [contact setDepth:penetrationDepth];
    [contact setContactPointWC:contactPositionWC.vector4Position()];
    
    [contacts addObject:contact];
    
    return [self spaceLeft];
    
}

-(NSUInteger)examinePrimitive:(KSCPrimitive*)a 
             againstPrimitive:(KSCPrimitive*)b
{
    KSCPrimitive * c; // used to swap a and b if necessary
    
    // make sure that if one of the two primitives is a sphere, then
    // the first object, a, is a sphere (b might be too). 
    if ( [b isKindOfClass:[KSCPrimitiveSphere class]] ) 
    {
        c = a;
        a = b;
        b = c;
        c = nil;
    }
    
    // sphere and something 
    if ([a isKindOfClass:[KSCPrimitiveSphere class]]) 
    {
        // sphere - sphere
        if ( [b isKindOfClass:[KSCPrimitiveSphere class]] ) 
        {
            [self sphere:(KSCPrimitiveSphere*)a 
              withSphere:(KSCPrimitiveSphere*)b];
            return [self spaceLeft];
        }
        
        // sphere - box
        if ( [b isKindOfClass:[KSCPrimitiveBox class]] ) 
        {
            [self sphere:(KSCPrimitiveSphere*)a 
                 withBox:(KSCPrimitiveBox*)b];
            return [self spaceLeft];
        }
        
        // sphere - plane
        if ( [b isKindOfClass:[KSCPrimitivePlane class]] ) 
        {
            [self sphere:(KSCPrimitiveSphere*)a 
           withHalfPlane:(KSCPrimitivePlane*)b];
            return [self spaceLeft];
        }
        
        // sphere with something we can't handle
        NSAssert(YES, @"Can't handle this type of primitive collision");
    }
    
    // make sure that if one of the objects is a box, it is a
    if ( [b isKindOfClass:[KSCPrimitiveBox class]] ) 
    {
        c = a;
        a = b;
        b = c;
        c = nil;
    }
    
    // box and something
    if ([a isKindOfClass:[KSCPrimitiveBox class]]) 
    {
        // box - box
        if ( [b isKindOfClass:[KSCPrimitiveBox class]] ) 
        {
            [self box:(KSCPrimitiveBox*)a 
              withBox:(KSCPrimitiveBox*)b];
            return [self spaceLeft];
        }
        
        // box - halfplane
        if ( [b isKindOfClass:[KSCPrimitivePlane class]] ) 
        {
            [self box:(KSCPrimitiveBox*)a 
        withHalfPlane:(KSCPrimitivePlane*)b];
            return [self spaceLeft];
        }
        
        // box with something we can't handle
        NSAssert(YES, @"Can't handle this type of primitive collision");
    }
    
    // two objects we can't handle at all yet
    NSAssert(YES, @"Can't handle this type of primitive collision");
    
    return [self spaceLeft];
    
}


-(NSUInteger)examinePhysicsBody:(KSPPhysicsBody *)aPhysicsBody 
              againstPrimitive:(KSCPrimitive *)aPrimitive
{
    for (KSCPrimitive * primitiveA in aPhysicsBody.primitiveAssembly) 
    {
        [self examinePrimitive:primitiveA againstPrimitive:aPrimitive];        
    }    
    
    // return number of spaces left
    return [self spaceLeft];
}

-(NSUInteger)examinePhysicsBody:(KSPPhysicsBody *)bodyA
             againstPhysicsBody:(KSPPhysicsBody *)bodyB
{
    for (KSCPrimitive * primitiveA in bodyA.primitiveAssembly) 
    {
        for (KSCPrimitive * primitiveB in bodyB.primitiveAssembly) 
        {
            [self examinePrimitive:primitiveA againstPrimitive:primitiveB];
        }
    }
    
    // return number of spaces left
    return [self spaceLeft];
}

-(NSUInteger)sphere:(KSCPrimitiveSphere*)sphere 
            withBox:(KSCPrimitiveBox*)box
{
    if (contacts.count == maxCollisions - 1) return 0;

    return [self spaceLeft];
}

-(NSUInteger)box:(KSCPrimitiveBox*)box 
   withHalfPlane:(KSCPrimitivePlane*)plane
{
    if (contacts.count == maxCollisions - 1) return 0;

    return [self spaceLeft];
}

-(NSUInteger)box:(KSCPrimitiveBox*)boxA 
         withBox:(KSCPrimitiveBox*)boxB
{
    if (contacts.count == maxCollisions - 1) return 0;
    
    return [self spaceLeft];    
}

// PRIVATE worker function
-(void)removeAll
{
    [contacts removeAllObjects];
}

-(KSCContact *)findDeepestContact
{
    double deepest = MAX_ALLOWED_PENETRATION;
    KSCContact * worstContact = nil;
    for (KSCContact * contact in contacts) 
    {
        if (contact.depth > deepest) 
        {
            worstContact = contact;
            deepest = worstContact.depth;
        }
    }
    return worstContact;
}

// PRIVATE worker function
-(void)updatePenetrationsDueToContact:(KSCContact*)contact 
                         overInterval:(double)dt
{
    for (KSCContact * otherContact in contacts) 
    {
        // the depth adjustment has already been made for |contact| as part
        // of the body position adjustment code
        if (contact == otherContact)continue;
        
        // adjust the |otherContact|'s depth because (one or both) of its bodies
        // have had their position adjusted as a result of resolving |contact|
        
        if ( contact.bodyA == otherContact.bodyA ) 
        {
            otherContact.depth -= otherContact.contactNormalWC *
            (contact.translationA + 
                             contact.rotationA % otherContact.bodyAToContactWC);
        }
        else if ( contact.bodyA == otherContact.bodyB ) 
        {
            otherContact.depth += otherContact.contactNormalWC *
            (contact.translationA + 
             contact.rotationA % otherContact.bodyBToContactWC);
        }
        
        if ( !contact.bodyB ) continue;
        
        if ( contact.bodyB == otherContact.bodyA ) 
        {
            otherContact.depth -= otherContact.contactNormalWC *
            (contact.translationB + 
             contact.rotationB % otherContact.bodyAToContactWC);
        }
        else if ( contact.bodyB == otherContact.bodyB ) 
        {
            otherContact.depth = otherContact.contactNormalWC *
            (contact.translationB + 
             contact.rotationB % otherContact.bodyBToContactWC);
        }
    }
}

// PRIVATE worker function
-(void)prepareContactsOverInterval:(double)dt
{
    for (KSCContact * contact in contacts) 
    {
        [contact calculateInternals:dt];
    }
}

// PRIVATE worker function
-(void)resolvePenetration:(KSCContact*)contact 
         overInterval:(double)dt
{
    if (contact.depth < MAX_ALLOWED_PENETRATION) return;
        
    // wake up the bodies involved in the contact
    [contact matchAwakeState];
    
    // attempt to resolve it
    [contact adjustBodyPositions:dt];
    
    // We have shifted some bodies which might affect the penetration depth
    // of other contacts
    [self updatePenetrationsDueToContact:contact overInterval:dt];

}

// PRIVATE worker function
-(void)resolveClosingVelocity:(KSCContact*)contact overInterval:(double)dt
{
    if (contact.closingSpeed > MAX_ALLOWED_SPEED) 
    {
        [contact matchAwakeState];
        [contact adjustBodyVelocities:dt];
    }
}

-(KSCContact*)findFastestContact
{
    KSCContact * fastestContact = nil;
    double fastestSpeed = MAX_ALLOWED_SPEED;
    for (KSCContact * contact in contacts) 
    {
        if (contact.closingSpeed > fastestSpeed) 
        {
            fastestContact = contact;
            fastestSpeed = fastestContact.closingSpeed;
        }
    }
    return fastestContact;    
}

/* 
 Attempt to resolve each of the definite contacts currently stored in the
 collisionDetector. There is no guarantee that the collisions will be
 resolved, or that new ones will not be created in the attempt.
 */
-(void)resolveContactsOverInterval:(double)dt
{
    // If there are no contacts, there are no contacts to resolve
    if ([contacts count] == 0) return;
    
    // tell the contacts to calculate their internal data
    [self prepareContactsOverInterval:dt];
    
    // first run through all contacts to make sure that each one gets
    // some treatment
    for (KSCContact * contact in contacts) 
    {
        [self resolvePenetration:contact overInterval:dt];
        [self resolveClosingVelocity:contact overInterval:dt];
    }

    // now find the most deeply penetrating contact, resolve it, and repeat until
    // all iterations are used up, or all contacts have been resolved
    for (NSUInteger i = 0; i < MAX_RESOLUTION_ITERATIONS; i++) 
    {
        // find the contact with the greatest interpenetration of the bodies
        KSCContact * deepestContact = [self findDeepestContact];
        
        // if we haven't found one, we can stop now
        if (!deepestContact) break; 
        
        // adjust the positions of the bodies involved in the contact
        // so that they are no longer interpenetrating. This potentially affects
        // the penetration depths of all other contacts the bodies are involved
        // in, hence we will need to search for the deepest one again during
        // the next iteration.
        [self resolvePenetration:deepestContact overInterval:dt];
    }
    
    // find the contact with the greatest approach speed, resolve it and repeat.
    for (NSUInteger i = 0; i < MAX_RESOLUTION_ITERATIONS; i++) 
    {
        // find the contact with the fastest closing speed
        KSCContact * fastestContact = [self findFastestContact];
        
        // if we haven't found one we can stop now
        if (!fastestContact) break;
        
        // bounce the bodies off each other, apply friction between them, etc
        [self resolveClosingVelocity:fastestContact overInterval:dt];
    }
}

@end
