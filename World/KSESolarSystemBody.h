//
//  KSESolarSystemBody.h
//  World
//
//  Created by Keith Staines on 04/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"

@interface KSESolarSystemBody : NSObject
{
    NSString * _name;
    NSString * _type;
    NSString * _nameOfParent;
    NSString * _texture0Name;
    double _mass;
    double _radius;
    KSMMatrix3 _momentOfInertia;
    KSMVector3 _relativePosition;
    KSMVector3 _relativeVelocity;
    KSMVector3 _angularVelocity;
}

-(id)initWithName:(NSString*)name 
             type:(NSString*)type 
     nameOfParent:(NSString*)nameOfParent 
             mass:(double)mass 
           radius:(double)radius
 relativePosition:(const KSMVector3&)positionRelativeToParent
 relativeVelocity:(const KSMVector3&)velocityRelativeToParent
  angularVelocity:(const KSMVector3&)angularVelocity;

@property (copy) NSString * name;
@property (copy) NSString * type;
@property (copy) NSString * nameOfParent;
@property (copy) NSString * texture0name;
@property double radius;
@property double mass;
@property (assign) const KSMMatrix3& momentOfInertia;
@property (assign) const KSMVector3& relativePosition;
@property (assign) const KSMVector3& relativeVelocity;
@property (assign) const KSMVector3& angularVelocity;
@end
