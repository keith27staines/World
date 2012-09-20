//
//  KSGGameObject.mm
//  World
//
//  Created by Keith Staines on 11/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGGameObject.h"
#import "KSGVertexBatch.h"
#import "KSGLight.h"
#import "KSGTransformPack.h"
#import "KSCBVHNode.h"
#import "KSGVertex.h"
#import "KSCBoundingVolume.h"
#import "KSCPrimitiveSphere.h"
#import "KSGUID.h"
#import "KSPPhysicsBody.h"
#import "KSPWater.h"

@implementation KSGGameObject

@synthesize uid;
@synthesize name;
@synthesize batches;

@synthesize boundingVolume;
@synthesize physicsBody;


-(void)setBoundingNode:(KSCBVHNode *)aBoundingNode
{
    boundingNode = aBoundingNode;
}

-(KSCBVHNode*)boundingNode
{
    return boundingNode;
}

-(const KSMMatrix4&)modelWorld
{
    return [physicsBody modelWorld];
}

-(void)setModelWorld:(const KSMMatrix4 &)modelWorld
{
    [physicsBody setModelWorld:modelWorld];
}

-(NSArray*)batches
{
    return batches;
}

-(void)setBatches:(NSArray *)batchesArray
{
    if (batches == batchesArray) 
    {
        // nothing to do
        return;
    }
    batches = batchesArray;
    
    // calculate bounding volume for this object and its sub bounding volume
    // hierarchy

    int sub = 0;
    for (KSGVertexBatch* aBatch in batches) 
    {
        NSLog(@"Radius = %f, centre.x = %f", [[aBatch boundingVolume] radius],[[aBatch boundingVolume] centre].x);
        
        // add the bounding volume for this model to the sub-hierarchy
        if (!internalVolumeHierarchy) 
        {
            internalVolumeHierarchy = [KSCBVHNode nodeWithParentNode:nil 
                                                                body:aBatch 
                                                      boundingVolume:aBatch.boundingVolume];
        }
        else
        {
            [internalVolumeHierarchy insertBody:aBatch 
                                     withVolume:aBatch.boundingVolume];
        }
        
        // take this opportunity to give each subbatch a reasonable name
        // which might help in debugging
        NSString* subName;
        subName = [NSString stringWithFormat:@"%@_sub%02d", name, sub++];
        [aBatch setName:subName];
        
    }
    
    // supply a suitable default centre and radius for objects with no batches
    // (e.g pure non-visual objects like cameras,etc)
    KSMVector4 theCentreMC = KSMVector4();
    KSMVector4 theCentreWC = KSMVector4();
    double      theRadius = 1.0;
    
    // override these defaults if the object has a bounding volume hierarchy
    if (internalVolumeHierarchy) 
    {
        theCentreMC = internalVolumeHierarchy.boundingVolume.centre;
        theCentreWC = [self modelWorld] * theCentreMC;
        theRadius = internalVolumeHierarchy.boundingVolume.radius;
    }
    
    // create the bounding volume and retain it
    KSCBoundingVolume * volume;
    volume = [KSCBoundingVolume boundingVolumeWithCentre:theCentreWC 
                                                  radius:theRadius];

    [self setBoundingVolume:volume];
    
    // construct a primitive sphere as the default fine collision geometry
    KSCPrimitiveSphere * primitiveSphere = [KSCPrimitiveSphere alloc];
    primitiveSphere = [primitiveSphere initWithParentBody:self.physicsBody 
                                               positionPC:theCentreMC 
                                                   radius:theRadius];
    
    // add the sphere as the single member of the primitive assembly
    // of the physics body
    [physicsBody setPrimitiveAssembly:[NSArray arrayWithObject:primitiveSphere]];
}

// update internal data for next frame (do physics, etc)
-(void)update:(NSTimeInterval)dt
{
    [physicsBody integrateOverInterval:dt];
    KSMMatrix4 updatedTransform = [physicsBody modelWorld];
    [boundingVolume setCentre:updatedTransform.extractPositionVector4()];
}

+(id)gameObjectWithName:(NSString*)aName
                                  mass:(double)m
                       momentOfInertia:(const KSMMatrix3 &) mI
                   initialModelToWorld:(const KSMMatrix4 &)modelToWord
                        linearVelocity:(const KSMVector3 &)linVel 
                       angularVelocity:(const KSMVector3 &)angVel 
                                 batches:(NSArray *)batches
{
    // call the designated constructor to create a new instance
    KSGGameObject* gameObject = [[self class] alloc];
    gameObject = [gameObject initWithName:aName mass:m 
                          momentOfInertia:mI 
                      initialModelToWorld:modelToWord 
                           linearVelocity:linVel 
                          angularVelocity:angVel 
                                  batches:batches];    
    
    // return the object fully prepared and auto-released
    return gameObject;
    
}

-(id)init
{
    return [self initWithName:@"UNNAMED" 
                         mass:1.0 
              momentOfInertia:KSMMatrix3() 
          initialModelToWorld:KSMMatrix4() 
               linearVelocity:KSMVector3() 
              angularVelocity:KSMVector3() 
                      batches:[NSMutableArray arrayWithCapacity:1024]];
    
}

////////////////////////////////////////////////////////////////////////////////
// initWithName
// Designated constructor
-(id)initWithName:(NSString*)aName 
                                   mass:(double)m 
                        momentOfInertia:(const KSMMatrix3&)mI                    
                    initialModelToWorld:(const KSMMatrix4 &)modelToWord
                         linearVelocity:(const KSMVector3 &)linVel 
                        angularVelocity:(const KSMVector3 &)angVel 
                                batches:(NSArray *)batchesArray
{
    self = [super init];
    if (self) 
    {
        [self setName:aName];
        uid                 = [[KSGUID alloc] init];
        physicsBody         = [[KSPPhysicsBody alloc] init];
        [physicsBody setMass:m];
        [physicsBody setMI:mI];
        [physicsBody setModelWorld:modelToWord];
        [physicsBody setLinearVelocity:linVel];
        [physicsBody setAngularVelocity:angVel];
        
        [self setBatches:batchesArray];
        if ([batchesArray count] > 0) 
        {
            KSGBatch* b     = [batchesArray objectAtIndex:0];
            progId          = b.openGLProgramId;
            
        }
    }
    
    return self;
}

-(NSArray*) importantLights:(NSArray*)allLights maxLights:(NSUInteger)max
{
    // create storage for important lights
    NSMutableArray* important = [NSMutableArray arrayWithCapacity:
                                  [allLights count]];
    
    // down-select to lights that are on
    for (KSGLight* light in allLights) 
    {
        if ([light isOn]) 
        {
            // TODO sort by brightness, etc
            [important addObject:light];
            if (max == important.count) break;
        }
    }
    
    return important;
}

////////////////////////////////////////////////////////////////////////////////
// drawUsingTransformPack
-(void)drawUsingTransformPack:(KSGTransformPack *)transformPack 
                       lights:(NSArray *)allLights
{ 
    // Get the lights that are important for this object sorted by brightness
    NSArray* importantLights = [self importantLights:allLights maxLights:1];
    
    // these are the names of the uniform data
    GLint    v4lPositionVC;
    GLint    v4lAmbientColor;
    GLint    v4lDiffuseColor;
    GLint    v4lSpecularColor;
    GLint    v3lAttenuations;
    GLint    lSpecularExponent;
    GLint    lConeAngle;
    GLint    numLights;
    
    // check to see that there is such a shader, otherwise 
    // we just return
    if ( 0 == progId ) return;
    glUseProgram(progId);
    
    v4lPositionVC           = glGetUniformLocation(progId, "v4lPositionVC");
    v4lAmbientColor         = glGetUniformLocation(progId, "v4lAmbientColor");
    v4lDiffuseColor         = glGetUniformLocation(progId, "v4lDiffuseColor");
    v4lSpecularColor        = glGetUniformLocation(progId, "v4lSpecularColor");
    v3lAttenuations         = glGetUniformLocation(progId, "v3lAttenuations");
    lSpecularExponent       = glGetUniformLocation(progId, "lExponent");
    lConeAngle              = glGetUniformLocation(progId, "lConeAngle");
    numLights               = glGetUniformLocation(progId, "numLights");
    
    // set the uniform data for this light
    glUniform1i(numLights, (GLint)importantLights.count);
    KSMMatrix4 worldToView = [transformPack worldToView];
    for (KSGLight* light in importantLights) 
    {
        
        // colors, etc are straightforward...
        glUniform4fv(v4lAmbientColor, 1, light.ambientColor.f);
        glUniform4fv(v4lDiffuseColor, 1, light.diffuseColor.f);
        glUniform4fv(v4lSpecularColor,1, light.specularColor.f);
        glUniform1f(lSpecularExponent,light.specularExponent);
        glUniform1f(lConeAngle,       light.specularCutoffAngle);

        // set the position (which is required in view coordinates so we
        // have to transform from world coordinates), and convert from
        // doubles to floats.
        KSMVector4 lightPosWC = [light positionVector];
        KSMVector4 positionVC = worldToView * lightPosWC;
        float * position4f = floatsFromDoubles(positionVC.d, 4);
        glUniform4fv(v4lPositionVC,   1, position4f);
        delete[] position4f;
        
        // the attentuation factors also need to be converted from double to float
        float * attentuation3f = floatsFromDoubles(light.attenuationFactors.d, 3);
        glUniform3fv(v3lAttenuations, 1, attentuation3f);
        delete[] attentuation3f;
    }
    
    // draw the associated mesh
    [transformPack setModelToWorld:[self modelWorld]];
    for (KSGBatch* batch in batches) 
    {
        [batch drawUsingTransformPack:transformPack];
    }
}

@end
