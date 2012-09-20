//
//  KSMRandomNumberGenerator.h
//  RandomNumbers
//
//  Created by Keith Staines on 06/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 This base-class implementation wraps the standard C rand() function. The rand()
 function is known for its speed and light weight (it carries almost no state), 
 but the quality of the random numbers it generates is poor. This base class is 
 therefore appropriate for situations requiring high speed results with low
 memory footprint, but which do not require random number sequences with long 
 periodicity, or which must anything other than the crudest statistical tests of
 randomness.
 Higher quality random number generators are implemented in subclasses, at the
 cost of speed and amount of state carried.
 */
@interface KSMRandomNumberGenerator : NSObject
{
    NSUInteger _max;
}

// defaults to a reproducible sequence (seeded with 1)
-(id)init;

// use a positive seed (e.g, 1,2,3, 9743, etc, to generate a reproducible
// sequence of random numbers. Specify a negative value to use a system-generated
// unguessable seed.
-(id)initWithSeed:(NSInteger)seedValue;

// returns the largest random integer this generator can produce
-(NSUInteger)largestRandomInteger;

// returns a randome number greater than or equal to lowest and less than or
// equal to highest, assuming that:
// highest > lowest, 
// lowest >=0, 
// highest <= largestRandomeInteger
-(NSUInteger)nextRandomIntegerFrom:(NSUInteger)lowest 
                                to:(NSUInteger)highest; 

// returns a random double between the lowest and highest limits (exclusive)
-(double)nextRandomDoubleFrom:(double)lowest to:(double)highest;

// returns the next random integer from the generator (will be between zero
// and largestRandomInteger).
-(NSUInteger)nextRandom;

@end
