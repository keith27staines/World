//
//  KSGTransformPack.mm
//  World
//
//  Created by Keith Staines on 22/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGTransformPack.h"

@implementation KSGTransformPack


////////////////////////////////////////////////////////////////////////////////
// transformPackWithModelToWorld
// convenience constructor returns a new, autoreleased instance
+(id)transformPackWithModelToWorld:(const KSMMatrix4&)mwMatrix4
                       worldToView:(const KSMMatrix4&)wvMatrix4
                  viewToProjection:(const KSMMatrix4&)vpMatrix4
{
    KSGTransformPack* tp = [[[self class] alloc] 
                            initWithModelToWorld:mwMatrix4 
                            worldToView:wvMatrix4 
                            viewToProjection:vpMatrix4];
    
    return tp;
    
}

////////////////////////////////////////////////////////////////////////////////
// init
// override designated constructor of super so that it calls the designated
// constructor of this subclass
- (id)init
{
    KSMMatrix4 Identity; 
    self = [self initWithModelToWorld:Identity 
                          worldToView:Identity 
                     viewToProjection:Identity];

    return self;
}

////////////////////////////////////////////////////////////////////////////////
// recalculate
// recalculates all transforms that are dependent on the three basic transforms
-(void)recalculate
{
    // recalculate the dependent matrices
    modelToView         = worldToView * modelToWorld;
    modelToProjection   = viewToProjection * modelToView;
    modelToWorldRot     = modelToWorld.extract3x3();
    modelToViewRot      = modelToView.extract3x3();
}

////////////////////////////////////////////////////////////////////////////////
// init
// designated constructor
-(id)initWithModelToWorld:(const KSMMatrix4&)mwMatrix4
              worldToView:(const KSMMatrix4&)wvMatrix4
         viewToProjection:(const KSMMatrix4&)vpMatrix4
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self allTransformsToIdentity];
    }

    [self setModelToWorld:mwMatrix4 
              worldToView:wvMatrix4 
         viewToProjection:vpMatrix4];
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// allTransformsToIdentity
// sets all transforms (basic and derived) to identity
-(void)allTransformsToIdentity
{
    // Basic transforms
    modelToWorld        = KSMMatrix4();
    worldToView         = KSMMatrix4();
    viewToProjection    = KSMMatrix4();   

    // derived transforms
    modelToView         = KSMMatrix4();
    modelToProjection   = KSMMatrix4();
    modelToWorldRot     = KSMMatrix3Rot();
    modelToViewRot      = KSMMatrix3Rot();
}


////////////////////////////////////////////////////////////////////////////////
// setWorldToView 
// sets the world - to - view transform and recalcutes its dependencies
-(void)setWorldToView:(const KSMMatrix4&)wvMatrix4
{
    worldToView = KSMMatrix4(wvMatrix4);
    [self recalculate];
}

////////////////////////////////////////////////////////////////////////////////
// setViewToProjection 
// sets the view - to - projection transform and recalcutes its dependencies
-(void)setViewToProjection:(const KSMMatrix4&)vpMatrix4
{
    viewToProjection = KSMMatrix4(vpMatrix4);
    [self recalculate];    
}

////////////////////////////////////////////////////////////////////////////////
// setModelToWorld 
// sets the model - to - world transform and recalcutes its dependencies
-(void)setModelToWorld:(const KSMMatrix4&)mwMatrix4
{
    modelToWorld = KSMMatrix4(mwMatrix4);
    [self recalculate];
}

////////////////////////////////////////////////////////////////////////////////
// setModelToWorld 
// sets the model - to - world transform and recalcutes its dependencies
// sets the world - to - view transform and recalcutes its dependencies
// sets the view - to - projection transform and recalcutes its dependencies
-(void)setModelToWorld:(const KSMMatrix4&)mwMatrix4
           worldToView:(const KSMMatrix4&)wvMatrix4
      viewToProjection:(const KSMMatrix4&)vpMatrix4
{
    modelToWorld     = KSMMatrix4(mwMatrix4);  
    worldToView      = KSMMatrix4(wvMatrix4);
    viewToProjection = KSMMatrix4(vpMatrix4);

    [self recalculate];
}

////////////////////////////////////////////////////////////////////////////////
// Getters return references

-(KSMMatrix4 &)modelToWorld
{ return modelToWorld; }

-(KSMMatrix4 &)worldToView
{ return worldToView; }

-(KSMMatrix4 &)viewToProjection
{ return viewToProjection; }

-(KSMMatrix4 &)modelToView
{ return modelToView; }

-(KSMMatrix4 &)modelToProjection
{ return modelToProjection; }

-(KSMMatrix3Rot &)modelToWorldRot
{ return modelToWorldRot; }

-(KSMMatrix3Rot &)modelToViewRot
{ return modelToViewRot; }

@end
