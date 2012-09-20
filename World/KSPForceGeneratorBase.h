//
//  KSPForceGeneratorBase.h
//  World
//
//  Created by Keith Staines on 12/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"
#import "KSPPhysicsBody.h"

@interface KSPForceGeneratorBase : NSObject
{
    
}

@property (copy) NSString * name;

-(void)applyForceOverInterval:(double)dt;

@end
