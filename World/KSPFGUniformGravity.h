//
//  KSPFGUniformGravity.h
//  World
//
//  Created by Keith Staines on 06/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"
#import "KSPFGUniversalBodyForce.h"

@interface KSPFGUniformGravity : KSPFGUniversalBodyForce
{
    // acceleration due to gravity
    double accelerationDueToGravity;
}

@property (assign) double accelerationDueToGravity;

@end
