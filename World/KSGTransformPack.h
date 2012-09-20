//
//  KSGTransformPack.h
//  World
//
//  Created by Keith Staines on 22/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"

@interface KSGTransformPack : NSObject
{
    // Basic transforms
    KSMMatrix4      modelToWorld;
    KSMMatrix4      worldToView;
    KSMMatrix4      viewToProjection;
    
    // Calculated transforms (cached for speed)
    KSMMatrix4      modelToView;
    KSMMatrix4      modelToProjection;
    KSMMatrix3Rot   modelToWorldRot;
    KSMMatrix3Rot   modelToViewRot;
}

////////////////////////////////////////////////////////////////////////////////
// convenience constructor
+(id)transformPackWithModelToWorld:(const KSMMatrix4&)mwMatrix4
                       worldToView:(const KSMMatrix4&)wvMatrix4
                  viewToProjection:(const KSMMatrix4&)vpMatrix4;

////////////////////////////////////////////////////////////////////////////////
// designated constructor
-(id)initWithModelToWorld:(const KSMMatrix4&)mwMatrix4
              worldToView:(const KSMMatrix4&)wvMatrix4
         viewToProjection:(const KSMMatrix4&)vpMatrix4;

////////////////////////////////////////////////////////////////////////////////
-(void)allTransformsToIdentity;

////////////////////////////////////////////////////////////////////////////////
// The set messages all copy the supplied transforms
-(void)setWorldToView:(const KSMMatrix4&)wvMatrix4;
-(void)setViewToProjection:(const KSMMatrix4&)vpMatrix4;
-(void)setModelToWorld:(const KSMMatrix4&)mwMatrix4;

-(void)setModelToWorld:(const KSMMatrix4&)mwMatrix4
           worldToView:(const KSMMatrix4&)wvMatrix4
      viewToProjection:(const KSMMatrix4&)vpMatrix4;

////////////////////////////////////////////////////////////////////////////////
-(KSMMatrix4 &)modelToWorld; 
-(KSMMatrix4 &)worldToView;
-(KSMMatrix4 &)viewToProjection;

-(KSMMatrix4 &)modelToView;
-(KSMMatrix4 &)modelToProjection;
-(KSMMatrix3Rot &)modelToWorldRot;
-(KSMMatrix3Rot &)modelToViewRot;

@end
