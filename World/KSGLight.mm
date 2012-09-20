//
//  KSGLight.mm
//  World
//
//  Created by Keith Staines on 20/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGLight.h"

@implementation KSGLight

@synthesize specularExponent;
@synthesize specularCutoffAngle;
@synthesize isOn;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        ambientColor        = [KSGColorFactory makeColor:@"Black"];
        diffuseColor        = [KSGColorFactory makeColor:@"Black"];
        specularColor       = [KSGColorFactory makeColor:@"Black"];
        attenuationFactors  = KSMVector3();
        positionVector      = KSMVector4();
        lookDirection       = KSMVector3();
        isOn                = YES;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// lightAsSunAndSky
// returns an autoreleased instance of a directional light with strong diffuse
// and specular elements
+(id)lightAsSunAndSky
{
    
    KSGLight * sun = [[[self class] alloc] init] ;
    if (sun != nil) {
        KSGColor white = [KSGColorFactory makeColor:@"White"];
        
        KSGColor ambient  = [KSGColorFactory brightenColor:white byFactor:0.4];
        KSGColor diffuse  = [KSGColorFactory brightenColor:white byFactor:1.0];
        KSGColor specular = [KSGColorFactory brightenColor:white byFactor:0.8];
        
        KSMVector4 sunDirection     = KSMVector4(1.0, 1.0, 1.0, 0.0);
        KSMVector3 attenuation      = KSMVector3(1.0, 1.0, 1.0);
        
        [sun setAttenuationFactors:attenuation];
        [sun setAmbientColor:ambient];
        [sun setDiffuseColor:diffuse];
        [sun setSpecularColor:specular];
        [sun setPositionVector:sunDirection];
        [sun setSpecularCutoffAngle:PI/20.0];
        [sun setSpecularExponent:1.0];
    }
    
    return sun;
}

-(KSGColor)    ambientColor                       {return ambientColor;}
-(KSGColor)    diffuseColor                       {return diffuseColor;}
-(KSGColor)    specularColor                      {return specularColor;}
-(KSMVector3&) attenuationFactors                 {return attenuationFactors;}
-(KSMVector4&) positionVector                     {return positionVector;}
-(KSMVector3&) lookDirection:(KSMVector3&)lookDir {return lookDirection;}

-(void) setAmbientColor: (KSGColor&) color {ambientColor  = color; }
-(void) setDiffuseColor: (KSGColor&) color {diffuseColor  = color; }
-(void) setSpecularColor:(KSGColor&) color {specularColor = color; }

-(void) setAttenuationFactors:(KSMVector3&)attenuation 
{attenuationFactors = attenuation; }

-(void) setPositionVector:(KSMVector4&)position 
{positionVector = position;}

-(void) setLookDirection:(KSMVector3&)direction 
{lookDirection = direction;}


@end

