//
//  KSVVehicle.h
//  World
//
//  Created by Keith Staines on 13/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KSGGameObject;
@class KSPForceGeneratorRegistry;
@class KSPWater;

@interface KSVVehicle : NSObject

+(void)equipAsBoat:(KSGGameObject*)gameObject 
           inWater:(KSPWater*)water 
     buoyancyRatio:(double)buoyancy
    registerForceGeneratorsWith:(KSPForceGeneratorRegistry *)registry;


@end
