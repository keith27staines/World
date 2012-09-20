//
//  KSPFGUniformDrag.h
//  World
//
//  Created by Keith Staines on 29/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSPFGUniformGravity.h"

@interface KSPFGUniformDrag : KSPFGUniformGravity
{
    double _linearDragCoefficient;
    double _quadraticDragCoefficient;
}

@property (assign) double linearDragCoefficient;
@property (assign) double quadraticDragCoefficient;

+(id)makeStillWaterResistance;
+(id)makeStillAirResistance;
-(void)scaleFactorsBy:(double)factor;

@end
