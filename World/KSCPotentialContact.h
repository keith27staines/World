//
//  KSCPotentialContact.h
//  World
//
//  Created by Keith Staines on 10/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSCBody.h"



@interface KSCPotentialContact : NSObject
{
    NSObject<KSCBody>* __weak bodyA;
    NSObject<KSCBody>* __weak bodyB;
    NSString* name;
}

@property (weak, readonly)   NSObject<KSCBody>* bodyA;
@property (weak, readonly)   NSObject<KSCBody>* bodyB;
@property (copy)   NSString * name;

////////////////////////////////////////////////////////////////////////////////
// potentialContactWithBody1:body2:
+(id)potentialContactWithBodyA:(NSObject<KSCBody>*)aBodyA 
                         bodyB:(NSObject<KSCBody>*)aBodyB;

// designated constructor
-(id)initWithBodyA:(NSObject<KSCBody>*)aBodyA 
             bodyB:(NSObject<KSCBody>*)aBodyB;

-(NSString*)name;

@end

