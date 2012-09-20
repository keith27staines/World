//
//  KSGCamera.h
//  World
//
//  Created by Keith Staines on 19/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSMMaths.h"
#import "KSGGameObject.h"

@interface KSGCamera : KSGGameObject
{
    double nearDistance;
    double farDistance;
    double zoom;
    class KSMVector3 lookDirection;
    class KSMVector3 upDirection;
    class KSMMatrix4 worldToCamera;
    class KSMMatrix4 projectionMatrix;
    class KSMMatrix4 worldCameraProjection;
}

@property double nearDistance;
@property double farDistance;
@property double fieldOfViewRadians;
@property double zoom;
@property double width;
@property double height;
@property (readonly, assign) KSMMatrix4* projection;
@property (readonly, assign) KSMMatrix4* worldToCamera;
@property (readonly, assign) KSMMatrix4* worldCameraProjection;

+(KSGCamera*) perspectiveCameraAtPosition:(KSMVector3)rpos
                                LookingIn:(KSMVector3)lookDir 
                              UpDirection:(KSMVector3)upDir
                                    Width:(double)w 
                                   Height:(double)h 
                                nearPlane:(double)near 
                                 farPlane:(double)far  
                               zoomFactor:(double)z;

-(void)update:(double)dt;
-(void)reshapeViewportWithWidth:(double)width Height:(double)height;
-(void)setupProjectionMatrix;
-(void)recalcWorldCameraProjection;
-(void)moveForward:(double)amount;
-(void)moveBack:(double)amount;
-(void)moveLeft:(double)amount;
-(void)moveRight:(double)amount;
-(void)moveUp:(double)amount;
-(void)moveDown:(double)amount;

-(void)rotateLeft:(double)amountRadians;
-(void)rotateRight:(double)amountRadians;
-(void)rotateUp:(double)amountRadians;
-(void)rotateDown:(double)amountRadians;
-(void)rollLeft:(double)amountRadians;
-(void)rollRight:(double)amountRadians;
-(void)zoomBy:(double)amount;


@end
