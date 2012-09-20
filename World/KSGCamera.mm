//
//  KSGCamera.m
//  World
//
//  Created by Keith Staines on 19/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGCamera.h"

@implementation KSGCamera

@synthesize nearDistance;
@synthesize farDistance;
@synthesize width;
@synthesize height;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(KSMMatrix4*)projection
{
    return &projectionMatrix;
}

-(KSMMatrix4*)worldToCamera
{
    return &worldToCamera;
}

-(KSMMatrix4*)worldCameraProjection
{
    return &worldCameraProjection;
}


-(void)update:(NSTimeInterval)dt
{

    // update position and orientation, just as for any other game object
    [super update:dt];
    
    // modelWorld is now correct, but we still have to update 
    // world to camera transformation
    KSMMatrix4 modelWorld = [self modelWorld];
    
    worldToCamera = modelWorld.inverse();
    
    // and we must update the worldCameraProjection matrix too
    [self recalcWorldCameraProjection];
    
}


////////////////////////////////////////////////////////////////////////////////
// rotate the camera to the right about its model-space axis
-(void)rotateRight:(double)amountRadians
{
    [self rotateLeft:-amountRadians];
}

// need to rotate about the y axis in model space.
-(void)rotateLeft:(double)amountRadians
{
    // start with the y axis in world space
    KSMVector3 yAxis = KSMVector3(0.0, 1.0, 0.0);
    
    // rotate about yAxis
    KSMMatrix4 modelWorld = [self modelWorld];
    modelWorld.rotateAboutAxis(amountRadians, yAxis);
    [self setModelWorld:modelWorld];
}

// rotate the camera up with respect to its horizontal ( the x,z plane)
-(void)rotateUp:(double)amountRadians
{
    [self rotateDown:-amountRadians];
}


// rotate the camera down with respect to the horizontal (the x,z plane)
-(void)rotateDown:(double)amountRadians
{
    // start with the x axis in model space
    KSMVector3 xAxis = KSMVector3(1.0, 0.0, 0.0);
    
    // get the current orientation
    KSMMatrix4 modelWorld = [self modelWorld];
    KSMMatrix3 orient = modelWorld.extract3x3();
    
    // Find the direction of the x axis in world space
    orient = orient.inverse();    
    xAxis = orient * xAxis;    
    
    // rotate about xAxis
    modelWorld.rotateAboutAxis(amountRadians, xAxis);
    [self setModelWorld:modelWorld];
}

// roll left
-(void)rollLeft:(double)amountRadians
{
    [self rollRight:-amountRadians];
}

// roll right
-(void)rollRight:(double)amountRadians
{
    // camera points in negative z direction in model space
    KSMVector3 rotAxis = KSMVector3(0.0, 0.0, -1.0);
    
    // convert this axis to world coordinates
    KSMMatrix4 modelWorld = [self modelWorld];
    KSMMatrix3Rot orient = modelWorld.extract3x3();
    rotAxis = orient * rotAxis;
    
    // apply rotation
    modelWorld.rotateAboutAxis(amountRadians, rotAxis);
    [self setModelWorld:modelWorld];
}

// zoom
-(void)zoomBy:(double)amount
{
    zoom = amount * zoom;
}

////////////////////////////////////////////////////////////////////////////////
// move the camera forward along its look direction (-z in its own model space)
// by the specified amount
-(void)moveForward:(double)amount
{
    // The camera "looks" in the -ve z direction in its own model space.
    // We need to get this direction in world space
    
    KSMVector3 zAxis = KSMVector3(0.0, 0.0, -1.0);
    
    KSMMatrix4 modelWorld = [self modelWorld];
    KSMMatrix3 orient = modelWorld.extract3x3();
    
    // transform the z axis to world space
    zAxis = orient * zAxis; 
    
    // translation vector (remembering that for the camera, forwards is backwards)
    KSMVector3 translate = amount * zAxis;
    
    // do the translation
    modelWorld.translate(translate);
    [self setModelWorld:modelWorld];
}


// move the camera to the left (-x in its own model space)
-(void)moveLeft:(double)amount
{
    [self moveRight:-amount];
}

// move the camera to the right (+x in its own model space)
-(void)moveRight:(double)amount
{
    // get the direction of + x in world space
    KSMVector3 xAxis = KSMVector3(1.0, 0.0, 0.0);
    
    // extract the current orientation in world space
    KSMMatrix4 modelWorld = [self modelWorld];
    KSMMatrix3 orient = modelWorld.extract3x3();
    
    // use the current orientation to transform the model x axis to world space
    xAxis = orient * xAxis;
    
    // create the required translation vector
    KSMVector3 translate = amount * xAxis;
    
    // do the translation
    modelWorld.translate(translate);
    [self setModelWorld:modelWorld];
    
}

// move the camera backwards (backwards is +z in the camera's model space)
-(void)moveBack:(double)amount
{
    [self moveForward:-amount];
}

// move the camera up (upwards is + y in its own model space)
-(void)moveUp:(double)amount
{
    // get the direction of + y in world space
    KSMVector3 yAxis = KSMVector3(0.0, 1.0, 0.0);
    
    // extract the current orientation in world space
    KSMMatrix4 modelWorld = [self modelWorld];
    KSMMatrix3 orient = modelWorld.extract3x3();
    
    // use the current orientation to transform the model x axis to world space
    yAxis = orient * yAxis;
    
    // create the required translation vector
    KSMVector3 translate = amount * yAxis;
    
    // do the translation
    modelWorld.translate(translate);
    [self setModelWorld:modelWorld];
}

// move the camera down (downwards is -y in its own model space)
-(void)moveDown:(double)amount
{
    [self moveUp:-amount];
}

-(void) setZoom:(double)newZoom
{
    zoom = newZoom;
    [self setupProjectionMatrix];
}

-(void) setFieldOfViewRadians:(double)fieldOfViewRadians
{
    zoom = 1.0 / tan(fieldOfViewRadians/2.0);
}

-(double)zoom
{
    return zoom;
}

-(double)fieldOfViewRadians
{
    return 2.0 * atan2(1.0, zoom);
}

+(id) perspectiveCameraAtPosition:(KSMVector3)rpos 
                                LookingIn:(KSMVector3)lookDir 
                              UpDirection:(KSMVector3)up
                                    Width:(double)w 
                                   Height:(double)h 
                                nearPlane:(double)near 
                                 farPlane:(double)far 
                               zoomFactor:(double)z
{   
    id newCameraInstance = [[[self class] alloc] init];
    KSGCamera* camera = (KSGCamera*)newCameraInstance;
    
    camera->upDirection = up;
    camera->lookDirection = lookDir;

    // The look direction of the camera is along its negative z axis
    // in its own model space, so we want to align the +z axis with 
    // the the reverse of the look direction
    lookDir = -1.0 * lookDir;    
    
    // also ensure that the look direction is normalised
    lookDir.normalise();
    
    // project look direction into xy plane and normalise the projection
    KSMVector3 u = lookDir;
    u.y = 0;
    u.normalise();
    
    // define the axes in model space (which is currently also World space
    // as we have done no translations or rotations yet)
    KSMVector3 xAxis = KSMVector3(1.0, 0.0, 0.0);
    KSMVector3 yAxis = KSMVector3(0.0, 1.0, 0.0);
    KSMVector3 zAxis = KSMVector3(0.0, 0.0, 1.0);
    
    // calculate the angle between u and the z axis
    double phi = acos(zAxis * u);
    if ( u * xAxis < 0 ) phi = -phi;
    KSMMatrix3Rot orient = KSMMatrix3Rot::createRotationAboutDirection(phi, yAxis);

    // calculate the angle of elevation of the look direction
    double theta = acos(lookDir * u);
    if (lookDir * yAxis < 0) theta *= -1;

    // so set the elevation, we need to rotate about the x axis by - theta
    // but the x axis itself needs to be rotated because we have performed
    // a rotation about the y axis
    theta *= -1;
    xAxis = orient * xAxis;
    
    // we now concatenate the rotation about the a axis with the rotation
    // about y (which is already stored in the matrix orient
    orient = KSMMatrix3Rot::createRotationAboutDirection(theta, xAxis) * orient;

    // setup camera position and orientation
    KSMMatrix4 modelWorld = [camera modelWorld];
    modelWorld.setPosition(rpos);
    modelWorld.setOrientation(orient);
    [camera setModelWorld:modelWorld];
    
    // setup camera properties
    camera.width = w;
    camera.height = h;
    camera.nearDistance = near;
    camera.farDistance = far;
    camera.zoom = z;
    
    return newCameraInstance;
}

-(void)setupProjectionMatrix
{
    projectionMatrix.d[ 0] = zoom * height / width;
    projectionMatrix.d[ 1] = 0.0;
    projectionMatrix.d[ 2] = 0.0;
    projectionMatrix.d[ 3] = 0.0;
    projectionMatrix.d[ 4] = 0.0;
    
    projectionMatrix.d[ 5] = zoom;
    projectionMatrix.d[ 6] = 0.0;
    projectionMatrix.d[ 7] = 0.0;
    projectionMatrix.d[ 8] = 0.0;
    projectionMatrix.d[ 9] = 0.0;
    
    projectionMatrix.d[10] = (nearDistance + farDistance) /
                                                   (nearDistance - farDistance);
    projectionMatrix.d[11] = -1.0;
    
    projectionMatrix.d[12] = 0.0;
    projectionMatrix.d[13] = 0.0;

    projectionMatrix.d[14] = 2.0 * nearDistance * farDistance /
                                                   (nearDistance - farDistance);
    
    projectionMatrix.d[15] = 0.0;
    
}

-(void)recalcWorldCameraProjection
{
    projectionMatrix.d[0] = zoom * height /width;
    projectionMatrix.d[5] = zoom;
    worldCameraProjection = projectionMatrix * worldToCamera;    
}

-(void)reshapeViewportWithWidth:(double)w Height:(double)h
{
    height = h;
    width  = w;
    projectionMatrix.d[0] = zoom * h / w; 
}

@end
