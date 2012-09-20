//
//  KSMEnhancedRandomNumberGenerator.h
//  World
//
//  Created by Keith Staines on 07/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSMRandomNumberGenerator.h"

/*
 Implementation based on the C language's random() function. This is a fast
 random numbe generator of reasonable quality. The quality is determined by the 
 size of the state array, which should be set to any of: 8, 32, 64, 128, or 256 
 bytes; other amounts will be rounded down to the nearest known amount. Using 
 less than 8 bytes will cause an error. The larger the amount of state, the 
 better the quality will be, but at the cost of a larger memory footprint.
 With a size of 256 characters, this approaches but does not meet cryptographic
 standards. With 8 characters, the randomness (as measured by the periodicity)
 is poor, but useful in some applications where a fast and very lightweight
 generator is the main requirement.
 */
@interface KSMEnhancedRandomNumberGenerator : KSMRandomNumberGenerator
{
    char * _state;
}

// initialises this instance with a seed value and the size of the state array.
// Use positive seeds for reproducible sequences of random numbers and any
// negative number for a system generated unguessable seed. The stateSize should
// be specified to be one of 8, 32, 64, 128 or 256 bytes.
-(id)initWithSeed:(NSInteger)seedValue stateSize:(uint)size;

@end
