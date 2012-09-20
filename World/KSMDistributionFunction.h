//
//  KSMDistributionFunction.h
//  RandomNumbers
//
//  Created by Keith Staines on 06/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMDistributionFunctionAbstractBase.h"

@interface KSMDistributionFunction : KSMDistributionFunctionAbstractBase
{
    
}

// designated constructor
-(id)initWithMimimumX:(double)xMin 
             maximumX:(double)xMax 
      densityFunction:(probabilityDensityFunction)f
      randomGenerator:(KSMRandomNumberGenerator*)rgen;

@end
