//
//  KSMNormalDistributionFunction.h
//  RandomNumbers
//
//  Created by Keith Staines on 06/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMDistributionFunctionAbstractBase.h"

@interface KSMNormalDistributionFunction : KSMDistributionFunctionAbstractBase

// initialises with mean zero, standard deviation = 1, and a default
// random number generator
-(id)init;

// designated constructor
-(id)initWithMeanValue:(double)mean 
     standardDeviation:(double)sigma
       randomGenerator:(KSMRandomNumberGenerator *)rgen;

@end
