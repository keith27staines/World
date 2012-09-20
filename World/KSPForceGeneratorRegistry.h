//
//  KSPForceGeneratorRegistry.h
//  World
//
//  Created by Keith Staines on 06/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSPForceGeneratorBase;

@interface KSPForceGeneratorRegistry : NSObject
{
    NSMutableDictionary * forceGeneratorDictionary;
}

// tells each of the registered force generators to apply their forces
// to the bodies registered with them
-(void)applyForceGeneratorsOverInterval:(double)dt;

// register a force generator
-(void)registerGenerator:(KSPForceGeneratorBase*)generator;

// unregister a force generator
-(void)unregisterGenerator:(KSPForceGeneratorBase*)generator;


@end

