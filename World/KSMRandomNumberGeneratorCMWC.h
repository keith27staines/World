//
//  KSMRandomNumberGeneratorCMWC.h
//  RandomNumbers
//
//  Created by Keith Staines on 07/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSMRandomNumberGenerator.h"

/*
 This pseudo random number generator is an implementation of the "Complementary
 Multiply With Carry" algorithm. Its characteristics are excellent quality 
 (arguably of cryptographic standard), at the cost of carrying significant state
 (in excess of 4K per instance). Therefore, this generator is suited for use in 
 a singleton pattern although is not implemented as such.
 */
@interface KSMRandomNumberGeneratorCMWC : KSMRandomNumberGenerator
{
    uint32_t q[4096];
    uint32_t c;
    uint32_t i;
}

@end
