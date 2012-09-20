//
//  KSPFGConnectingSpring.h
//  World
//
//  Created by Keith Staines on 07/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSPFGSpring.h"

@interface KSPFGConnectingSpring : KSPFGSpring
{
    KSPPhysicsBody * __weak physicsBody1;
    KSPPhysicsBody * __weak physicsBody2;
    KSMVector4 body1AttachPointMC;
    KSMVector4 body2AttachPointMC;
}

@property (weak)  KSPPhysicsBody * physicsBody1;
@property (weak)  KSPPhysicsBody * physicsBody2;
@property (assign)KSMVector4     & body1AttachPointMC;
@property (assign)KSMVector4     & body2AttachPointMC;

// designated constructor
-(id)initWithNaturalLength:(double)length 
            springConstant:(double)spring 
           dampingConstant:(double)damping
                  isBungee:(BOOL)bungee
              physicsBody1:(KSPPhysicsBody*)body1 
        body1AttachPointMC:(KSMVector4&)attachPoint1MC 
              physicsBody2:(KSPPhysicsBody*)body2 
        body2AttachPointMC:(KSMVector4&)attachPoint2MC;



@end
