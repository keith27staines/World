//
//  KSPForceGeneratorRegistry.mm
//  World
//
//  Created by Keith Staines on 06/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPForceGeneratorRegistry.h"
#import "KSPForceGeneratorBase.h"


@implementation KSPForceGeneratorRegistry

-(id)init
{
    self = [super init];
    forceGeneratorDictionary = [NSMutableDictionary dictionaryWithCapacity:1024];
    return self;
}

-(void)applyForceGeneratorsOverInterval:(double)dt
{
    for (NSString * key in forceGeneratorDictionary) 
    {
        KSPForceGeneratorBase * fg = [forceGeneratorDictionary objectForKey:key];
        [fg applyForceOverInterval:dt];
    }
}

-(void)registerGenerator:(KSPForceGeneratorBase*)generator
{
    [forceGeneratorDictionary setObject:generator forKey:[generator name]];
}

-(void)unregisterGenerator:(KSPForceGeneratorBase*)generator
{
    [forceGeneratorDictionary removeObjectForKey:[generator name]];
}
@end
