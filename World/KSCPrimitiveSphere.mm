//
//  KSCPrimitiveSphere.m
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCPrimitiveSphere.h"

@implementation KSCPrimitiveSphere


// override designated constructor of super
-(id)initWithParentBody:(KSPPhysicsBody *)body 
             positionPC:(const KSMVector4 &)positionPC
{
    return [self initWithParentBody:body 
                         positionPC:positionPC 
                             radius:1.0];   
}

// new designated constructor
-(id)initWithParentBody:(KSPPhysicsBody *)body 
             positionPC:(const KSMVector4 &)positionPC 
                 radius:(double)radius
{
    self = [super initWithParentBody:body positionPC:positionPC];
    self.radius = radius;
    return self;    
}

-(double)radius
{
    return _radius;
}

-(void)setRadius:(double)radius
{
    _radius = radius;
    self.linearSize = radius;
}
@end
