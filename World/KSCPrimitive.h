//
//  KSCPrimitive.h
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"

@class KSPPhysicsBody;

@interface KSCPrimitive : NSObject
{
    // The plane is defined relative to a parent body. The
    // parent body is either this physics body, or, if nil,
    // the "world".
    KSPPhysicsBody * __weak _physicsBody;
    
    // The origin of this primitive relative to the parent
    KSMVector4 _positionPC;
}

// designated constructor. 
-(id)initWithParentBody:(KSPPhysicsBody*)body 
             positionPC:(const KSMVector4&)positionPC;

@property (weak)           KSPPhysicsBody * physicsBody;
@property (readonly) const KSMMatrix4 primitiveToWorld;
@property (assign)         double linearSize; 

// returns the origin of this primitive in world coordinates
-(KSMVector4)positionWC;

@end
