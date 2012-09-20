//
//  KSCPrimitiveSphere.h
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCPrimitive.h"
#import "KSMMaths.h"

@interface KSCPrimitiveSphere : KSCPrimitive
{
    double _radius;
}

-(id)initWithParentBody:(KSPPhysicsBody *)body 
             positionPC:(const KSMVector4 &)positionPC 
                 radius:(double)radius;

@property double radius;

@end
