//
//  KSGLight.h
//  World
//
//  Created by Keith Staines on 20/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"
#import "KSGColor.h"

@interface KSGLight : NSObject
{
    @protected
    KSGColor   ambientColor;
    KSGColor   diffuseColor;
    KSGColor   specularColor;
    KSMVector3 attenuationFactors;
    KSMVector4 positionVector;
    KSMVector3 lookDirection;

    double specularExponent;
    double specularCutoffAngle;
}

@property (assign) double specularExponent;
@property (assign) double specularCutoffAngle;
@property (assign) BOOL  isOn;

-(KSGColor)    ambientColor;
-(KSGColor)    diffuseColor;
-(KSGColor)    specularColor;
-(KSMVector3&) attenuationFactors;
-(KSMVector4&) positionVector;
-(KSMVector3&) lookDirection:(KSMVector3&)lookDir;

-(void) setAmbientColor:(KSGColor&)color;
-(void) setDiffuseColor:(KSGColor&)color;
-(void) setSpecularColor:(KSGColor&)color;
-(void) setAttenuationFactors:(KSMVector3&)attenuations;
-(void) setPositionVector:(KSMVector4&)position;
-(void) setLookDirection:(KSMVector3&)direction;

+(id)lightAsSunAndSky;

@end
