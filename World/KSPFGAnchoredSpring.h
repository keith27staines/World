//
//  KSPFGAnchoredSpring.h
//  World
//
//  Created by Keith Staines on 06/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSPFGSpring.h"

@interface KSPFGAnchoredSpring : KSPFGSpring
{
    KSPPhysicsBody * __weak physicsBody;
    KSMVector4 bodyAttachPointMC;
    KSMVector3 worldAnchorPointWC;
}
@property (weak)   KSPPhysicsBody * physicsBody;
@property (assign) KSMVector4     & bodyAttachPointMC;
@property (assign) KSMVector3     & worldAnchorPointWC;

-(id)initWithNaturalLength:(double)length 
            springConstant:(double)spring 
           dampingConstant:(double)damping
                  isBungee:(BOOL)bungee
               physicsBody:(KSPPhysicsBody*)body 
         bodyAttachPointMC:(KSMVector4&)attachPointMC 
        worldAnchorPointWC:(KSMVector3&)anchorWC;



@end
