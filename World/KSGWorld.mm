//
//  KSGWorld.m
//  World
//
//  Created by Keith Staines on 14/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGWorld.h"
#import "KSVVehicle.h"
#import "KSPPhysicsBody.h"
#import "KSEEnvironments.h"

@implementation KSGWorld
@synthesize binaryVolumeHeirarchy;

// globals
const NSString* axes = @"World Axes";
const NSUInteger expectedMaxObjectCount = 1024;
const NSUInteger maxContacts = expectedMaxObjectCount;

// global objects
KSGCamera*    camera;
NSArray*      lights;

-(void)setArrayObjectsToNSNull:(NSMutableArray*)array
{
    for (NSUInteger i = 0; i < array.count; i++) 
    {
        [array replaceObjectAtIndex:i withObject:[NSNull null]];
    }
}

////////////////////////////////////////////////////////////////////////////////
// init
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        isLoaded        = NO;
                       
        transformPack   = [[KSGTransformPack     alloc] init];
        shaderManager   = [[KSGShaderManager     alloc] init];
        materialManager = [[KSGMaterialManager   alloc] init];
        textureManager  = [[KSGTextureManager    alloc] init];
        
        lights          = [NSMutableArray arrayWithCapacity:MAX_LIGHTS];
        forceGeneratorRegistry = [[KSPForceGeneratorRegistry alloc] init];
        gameObjects = [NSMutableDictionary dictionaryWithCapacity:expectedMaxObjectCount];
        potentialContacts = [NSMutableDictionary dictionaryWithCapacity:maxContacts];
        
    }

    return self;
}

////////////////////////////////////////////////////////////////////////////////
// loadWorld (one loader to load them all) Loads all geometry, shaders, and
// game objects
-(void)loadWorld
{    
    NSLog(@"Creating lights");
    
    // Create the static lights
    [self loadPhysicalEnvironment];
    NSLog(@"Physical environment OK");
    
    NSLog(@"Loading shaders");
    [self loadShaders];
    NSLog(@"Shaders OK");
    
    NSLog(@"Loading camera");
    [self loadCamera];
    NSLog(@"Camera OK");
    
    NSLog(@"Loading Geometry");
    [self loadGeometry];
    NSLog(@"Geometry OK");
    
    NSLog(@"Binding geometry to GP");
    [self sendToGL];
    NSLog(@"Geometry binding OK");
    
    NSLog(@"World load OK");
    
    isLoaded = YES;
}

////////////////////////////////////////////////////////////////////////////////
// load physical environment (terrain, sun, gravity generators etc)
-(void)loadPhysicalEnvironment
{
    // setup sun and ambient light
    KSGLight* sunAndSky = [KSGLight lightAsSunAndSky];
    [lights addObject:sunAndSky];
    
    // setup water
    water = [[KSPWater alloc] init];
    
    // setup uniform gravity
    gravity = [[KSPFGUniformGravity alloc] init];
    //[forceGeneratorRegistry registerGenerator:gravity];
    
    // setup uniform air resistance
    airResistance = [KSPFGUniformDrag makeStillAirResistance];
    //[forceGeneratorRegistry registerGenerator:airResistance];
    
    // setup water resistance
    waterResistance = [KSPFGUniformDrag makeStillWaterResistance];
    //[forceGeneratorRegistry registerGenerator:waterResistance];
    
    // create the array that will hold the primitive planes representing
    // the walls, ceiling and ground
    staticPlanes = [NSMutableArray arrayWithCapacity:1024];
    
    // create the planes representing the walls and ceiling, etc
    double width = 7.0;
    double height = 4.0;
    
    // setup ground
    ground = [KSCPrimitivePlane alloc];
    ground = [ground initWithParentBody:nil 
                         pointinPlanePC:KSMVector4(0, -height, 0, 1) 
                               normalPC:KSMVector3(0, 1, 0)];

    [staticPlanes addObject:ground];
    
    // setup ceiling
    ceiling = [KSCPrimitivePlane alloc];
    ceiling = [ceiling initWithParentBody:nil 
                           pointinPlanePC:KSMVector4(0, height, 0, 1)
                                 normalPC:KSMVector3(0, -1, 0)];
    [staticPlanes addObject:ceiling];

    // setup front wall (at +Z)
    frontWall = [KSCPrimitivePlane alloc];
    frontWall = [frontWall initWithParentBody:nil 
                               pointinPlanePC:KSMVector4(0, 0, width, 1)
                                     normalPC:KSMVector3(0, 0, -1)];
    [staticPlanes addObject:frontWall];

    // setup back wall (at -Z)
    backWall = [KSCPrimitivePlane alloc];
    backWall = [backWall initWithParentBody:nil 
                             pointinPlanePC:KSMVector4(0, 0, -width, 1)
                                   normalPC:KSMVector3(0, 0, 1)];
    [staticPlanes addObject:backWall];

    // setup left wall (at +X)
    leftWall = [KSCPrimitivePlane alloc];
    leftWall = [leftWall initWithParentBody:nil 
                             pointinPlanePC:KSMVector4(width, 0, 0, 1)
                                   normalPC:KSMVector3(-1, 0, 0)];
    [staticPlanes addObject:leftWall];

    // setup right wall (at -X)
    rightWall = [KSCPrimitivePlane alloc];
    rightWall = [rightWall initWithParentBody:nil 
                               pointinPlanePC:KSMVector4(-width, 0, 0, 1)
                                     normalPC:KSMVector3(1, 0, 0)];
    [staticPlanes addObject:rightWall];

}

////////////////////////////////////////////////////////////////////////////////
// loads game objects 
-(void)loadCamera
{
    ////////////////////////////////////////////////////////////////////////////
    // setup camera (which is itself a game object and can be subject
    // to physics)
    ////////////////////////////////////////////////////////////////////////////    
    
    KSMVector3 origin = KSMVector3();
    
    // define the position of the camera in world space
    KSMVector3 cameraPosition = 1.0 * KSMVector3(0.0, 0.0, 24.0);
    
    KSMVector3 cameraLookDirection = KSMVector3(0.0, 0.0, -1.0);
    
    // tell the camera which way is up
    KSMVector3 cameraUp = KSMVector3(0.0, 1.0, 0.0).unitVector();
    
    camera = [KSGCamera perspectiveCameraAtPosition:cameraPosition
                                           LookingIn:cameraLookDirection 
                                         UpDirection:cameraUp 
                                               Width:640 
                                              Height:480 
                                           nearPlane:0.1 
                                            farPlane:1000.0 
                                          zoomFactor:5.0];
    KSPPhysicsBody * body = [camera physicsBody];
    body.canSleep = NO;
    
    KSMVector4 camera4 = KSMVector4(cameraPosition.x, 
                                    cameraPosition.y, 
                                    cameraPosition.z, 1.0);
    
    KSCBoundingVolume * bounds = 
                             [KSCBoundingVolume boundingVolumeWithCentre:camera4 
                                                                  radius:1.0];
    
    // give the camera a bounding volume and a bvh node
    [camera setBoundingVolume:bounds];
    [camera setBoundingNode:[KSCBVHNode nodeWithParentNode:nil 
                                                      body:camera 
                                            boundingVolume:bounds]];
    
    [gameObjects setObject:camera forKey:@"camera"];       
}

////////////////////////////////////////////////////////////////////////////////
// createGameObject 
-(KSGGameObject*)createGameObjectWithName:(NSString *)name 
                           withSubBatches:(NSArray *)subBatches
{
    // used to change position for each new object so that they are not on
    // top of each other
    static int i = 0;
        
    double angle               = degTorad( 0.0 ); 
    KSMVector3 initPosv        = KSMVector3(0.0, 4.0 * i, 0.0);
    KSMVector3 initRotv        = KSMVector3(1.0, 1.0, 1.0);     
    KSMVector3 angularVelocity = KSMVector3(0.0, 0.0, 0.0);
    KSMMatrix3Rot initRotm3 = KSMMatrix3Rot::createRotationAboutDirection(angle,
                                                                      initRotv);
        
    KSMMatrix4 initPosm4 = KSMMatrix4(); 
    initPosm4.setPosition(initPosv);

    KSMMatrix4 initRotm4 = KSMMatrix4();    
    initRotm4.setOrientation(initRotm3);
    
    // concatenate position and rotation
    KSMMatrix4 modelWorld;
    modelWorld = initPosm4 * initRotm4;    
    
    // create the object with the position, orientation and spin, and assign
    // the sub-batches
    KSGGameObject* gameObject; 
    gameObject = [KSGGameObject gameObjectWithName:name 
                                              mass:0.1 
                                   momentOfInertia:KSMMatrix3() 
                               initialModelToWorld:modelWorld
                                    linearVelocity:KSMVector3() 
                                   angularVelocity:angularVelocity 
                                           batches:subBatches];
    if (!binaryVolumeHeirarchy) 
    {
        binaryVolumeHeirarchy = [KSCBVHNode 
                                  nodeWithParentNode:nil 
                                                body:gameObject 
                                      boundingVolume:gameObject.boundingVolume];
    }
    else
    {
        [binaryVolumeHeirarchy insertBody:gameObject 
                               withVolume:gameObject.boundingVolume];
    }
    i +=2;
    return gameObject;
    
}

/*
 Preparation for the start of frame includes clearing lists of potential contacts,
 reseting force accumulators, etc.
 */
-(void)startFrame
{
    // prepare potential contact list for new set of contacts 
    [potentialContacts removeAllObjects];  
    
    // clear force accumulators in physics objects
    for (NSString * key in gameObjects) 
    {
        KSGGameObject * gameObject = [gameObjects objectForKey:key];
        [[gameObject physicsBody] resetForceAccumulators];
    }
}

-(void)endFrame
{

}

/*
 Move the game objects according to physics and user inputs. 
 */
-(void)updateGameObjects:(NSTimeInterval)dt
{
    [forceGeneratorRegistry applyForceGeneratorsOverInterval:dt];
    
    for (NSString * key in gameObjects) 
    {        
        KSGGameObject * gameObject = [gameObjects objectForKey:key];
        [gameObject update:dt];
    } 
}

-(void)diagnosticsReportGameObjectNodes
{
    // diagnostics! delete when finished
    for (NSString * aKey in gameObjects) 
    {
        KSGGameObject * aGameObject = [gameObjects objectForKey:aKey];
        
        // insert the game object again
        if (aGameObject != camera) 
        {
            // obtain the node that owns the game object
            KSCBVHNode * aNode = [aGameObject boundingNode];
            NSLog(@"Node now = %@", aNode);
        }
    }   
}

/*
 The binary volume hierarchy must be reconfigured because the game objects
 might have moved. Each game object in turn is removed and reinserted, 
 thereby finding its new home in the reconfigured tree
 */
-(void)reconfigureBinaryVolumeHierarchy
{
    for (NSString * key in gameObjects) 
    {
        KSGGameObject * gameObject = [gameObjects objectForKey:key];
        
        // insert the game object again
        if (gameObject != camera) 
        {
            // if the game oject's physics body is asleep, we don't need to move
            // it.
            KSPPhysicsBody * body = [gameObject physicsBody];
            if ( ![body isAwake] ) 
            {
                // the body hasn't moved so we don't need to reconfigure its
                // position in the BVH
                continue;
            }
            
            // obtain the node that owns the game object
            KSCBVHNode * node = [gameObject boundingNode];
            
            if (node == binaryVolumeHeirarchy) 
            {
                /*
                 As this node is the only node, and its position and
                 volume continue to be represented by the same game object,
                 there is nothing to do here because there are no parent
                 nodes that might need to reconfigure to allow for the 
                 movement of this one.
                 */
                continue;
            }
            else
            {
                /*
                 This node is not the only node in the heirarchy
                 so we must remove it and re-insert its object 
                 (which might require the modification of all
                 volumes of all nodes above its eventual insertion node.
                 */
                [node remove];            
                [binaryVolumeHeirarchy insertBody:gameObject 
                                       withVolume:[gameObject boundingVolume]];

            }
        }
    } 
}

/*
 Potential contacts are identified by checking for collisions of their
 bounding volumes. However, not all combinations of game objects are checked.
 The bounding volume hierarchy is used to downselect other objects a
 particular game object might be colliding with to those that are within the
 same node in the BVH. The potential contacts are written to the 
 potentialContacts dictionary, ready for further inspection. 
 
 Return value:
 The return value is the number of potential contacts discovered.
 */
-(NSUInteger)identifyPotentialContacts
{
    NSUInteger contactCount = 0;
    
    for (NSString * key in gameObjects) 
    {
        // if we have used up all alowable spaces then just break out.
        if (contactCount == maxContacts) break;
        
        KSGGameObject * gameObject = [gameObjects objectForKey:key];
        
        // If the object has infinite mass, it cannot be the active
        // participant in the collision, so skip to the next object.
        if (gameObject.physicsBody.mass == DBL_MAX) continue;
        
        // add potential contacts for this game object to the list of all 
        // potential contacts
        contactCount += [binaryVolumeHeirarchy 
                         addPotentialContactsWith:[gameObject boundingNode]
                         to:potentialContacts 
                         startIndex:contactCount 
                         maxIndex:maxContacts - 1];  
    }  
    
    return contactCount;
}

/*
 Checks each of the potentialContacts in the potentiaContacts dictionary to
 see if they really are colliding, using their more detailed collision geometry.
 
 Return value:
 The collisionDetector used to perform the test. The collision detector holds an
 array of the definite contacts it has discovered.
 */
-(KSCCollisionDetector*)identifyDefiniteContacts
{
    // create the collision detector that will detect and accumulate collisions
    KSCCollisionDetector * collisionDetector = [[KSCCollisionDetector alloc]
                                                initWithMaxCollisions:1024];
    
    // get the definitive list of actual contacts between game objects
    for (NSString * key in potentialContacts) 
    {
        KSCPotentialContact * potential = [potentialContacts objectForKey:key];
        KSGGameObject * objectA = (KSGGameObject*)potential.bodyA;
        KSGGameObject * objectB = (KSGGameObject*)potential.bodyB;
        
        [collisionDetector examinePhysicsBody:objectA.physicsBody 
                           againstPhysicsBody:objectB.physicsBody];
    }
    
    // check for contacts between game objects and scenery
    for (NSString * key  in gameObjects) 
    {
        KSGGameObject * gameObject = [gameObjects objectForKey:key];
        for (KSCPrimitivePlane * plane in staticPlanes) 
        {   
            if (gameObject != camera) 
            {
                [collisionDetector examinePhysicsBody:gameObject.physicsBody 
                                     againstPrimitive:plane];
            }
        }
        
    }
    return collisionDetector;
}

////////////////////////////////////////////////////////////////////////////////
// updateWorld
-(void)updateWorld:(NSTimeInterval)dt
{       
    
    // setup for the start of this time step
    [self startFrame];

    // update positions and orientations of game objects (apply physics
    // and user inputs).
    [self updateGameObjects:dt];
    
    // reconfigure the binary volume hierarchy to allow for game object movements
    [self reconfigureBinaryVolumeHierarchy];

    // identify a list of potential contacts
    [self identifyPotentialContacts];
    
    // identify the definite contacts
    KSCCollisionDetector * collisionDetector = [self identifyDefiniteContacts];
    
    // resolve contacts
    [collisionDetector resolveContactsOverInterval:dt];
    
    // draw now that all cameras and objects are in correct positions
    [self drawToOpenGL];
    
    // end of frame tidy up.
    [self endFrame];

}


////////////////////////////////////////////////////////////////////////////////
// load shaders
-(void)loadShaders
{
    // load the shader manager and tell it to load the shaders
    [shaderManager loadShaders];    
}

////////////////////////////////////////////////////////////////////////////////
// load batch representing world axes
-(KSGVertexBatch*)loadBatchWorldAxes
{
    // create the batch we are going to populate and return
    KSGVertexBatch *batch = [KSGVertexBatch vertexBatch];
    [batch setName:@"World Axes"];
    
    // create the  vertices
    double length = 1000.0;
    int nLines = 1000;
    double x;
    KSGVertex *vertStart, *vertStop;
    for (int i = -nLines; i <= nLines; i++)
    {
        x = length * (double)i / (double)nLines;
        
        vertStart = [KSGVertex vertexAtPosX:-1.0 * length 
                                       PosY:0.0f 
                                       PosZ:x 
                                WithNormalX:0.0f 
                                    NormalY:0.0f 
                                    NormalZ:0.0f 
                                AndColorRed:1.0f 
                                 ColorGreen:0.0f 
                                  ColorBlue:0.0f];
        
        vertStop = [KSGVertex vertexAtPosX:1.0 * length 
                                      PosY:0.0f 
                                      PosZ:x 
                               WithNormalX:0.0f 
                                   NormalY:0.0f 
                                   NormalZ:0.0f 
                               AndColorRed:1.0f 
                                ColorGreen:0.0f 
                                 ColorBlue:0.0f];
        
        [batch addVertex:vertStart];
        [batch addVertex:vertStop];
        
        vertStart = [KSGVertex vertexAtPosX:x 
                                       PosY:0.0f 
                                       PosZ:-1.0f * length 
                                WithNormalX:0.0f 
                                    NormalY:0.0f 
                                    NormalZ:0.0f 
                                AndColorRed:0.0f 
                                 ColorGreen:0.0f 
                                  ColorBlue:1.0f];
        
        vertStop = [KSGVertex vertexAtPosX:x 
                                      PosY:0.0f 
                                      PosZ:1.0f * length
                               WithNormalX:0.0f 
                                   NormalY:0.0f 
                                   NormalZ:0.0f 
                               AndColorRed:0.0f 
                                ColorGreen:0.0f 
                                 ColorBlue:1.0f];
        
        [batch addVertex:vertStart];
        [batch addVertex:vertStop];
        
    }
    
    
    vertStart = [KSGVertex vertexAtPosX:0.0f 
                                   PosY:0.0f 
                                   PosZ:0.0f 
                            WithNormalX:0.0f 
                                NormalY:0.0f 
                                NormalZ:0.0f 
                            AndColorRed:0.0f 
                             ColorGreen:1.0f 
                              ColorBlue:0.0f];
        
    vertStop = [KSGVertex vertexAtPosX:0.0f 
                                  PosY:1.0f * length 
                                  PosZ:0.0f 
                           WithNormalX:0.0f 
                               NormalY:0.0f 
                               NormalZ:0.0f 
                           AndColorRed:0.0f 
                            ColorGreen:1.0f 
                             ColorBlue:0.0f];

    [batch addVertex:vertStart];
    [batch addVertex:vertStop];
    [batch close];
    
    // assign the shader for this object
    GLint progId = [shaderManager programID:KSG_ShaderPerspective];
    [batch setOpenGLProgramId:progId];
    
    // return the already autoreleased batch
    return batch;
}

////////////////////////////////////////////////////////////////////////////////
// includeModel
// A set of switches to select or exclude models for loading
-(BOOL)includeModel:(NSString*) name
{
      BOOL ans = NO;
    if ([name isEqualToString:@"PlanetSun"])                          ans = YES;
    if ([name isEqualToString:@"PlanetMercury"])                      ans = YES;
    if ([name isEqualToString:@"PlanetVenus"])                        ans = YES;
    if ([name isEqualToString:@"PlanetEarth"])                        ans = YES;
    if ([name isEqualToString:@"PlanetMars"])                         ans = YES;
    if ([name isEqualToString:@"PlanetJupiter"])                      ans = YES;
    if ([name isEqualToString:@"PlanetSaturn"])                       ans = YES;
    if ([name isEqualToString:@"PlanetUranus"])                       ans = YES;
    if ([name isEqualToString:@"PlanetNeptune"])                      ans = YES;

    
    
//    if ([name isEqualToString:@"Sphere"])                           ans = YES;
//    if ([name isEqualToString:@"Cone"])                             ans = YES;
//    if ([name isEqualToString:@"Cylinder"])                         ans = YES;
//    if ([name isEqualToString:@"Polyhedra"])                        ans = YES;
//    if ([name isEqualToString:@"Relief"])                           ans = YES;
//    if ([name isEqualToString:@"Stair"])                            ans = YES;
//    if ([name isEqualToString:@"Tube"])                             ans = YES;
//    if ([name isEqualToString:@"Torus"])                            ans = YES;
//    if ([name isEqualToString:@"Cube"])                             ans = YES;
//    
//    if ([name isEqualToString:@"CubeMarble"])                       ans = YES;
//    
//    if ([name isEqualToString:@"CubeMarbleTexture"])                ans = YES;
//
//    if ([name isEqualToString:@"Women 3 N190210"])                  ans = YES;
//    
//    if ([name isEqualToString:@"Bridge N090409"])                   ans = YES;
//    
//    if ([name isEqualToString:@"Figurine N270211"])                 ans = YES;
//    
//    if ([name isEqualToString:@"FigurineGoddess"])                  ans = YES;
//    
//    if ([name isEqualToString:@"Globe N170611"])                    ans = YES;
//    
//    if ([name isEqualToString:@"HighlyDetailedIonicColumn"])        ans = YES;
//    
//    if ([name isEqualToString:@"HighyDetailedCorinthianColumn"])    ans = YES;
//    
//    if ([name isEqualToString:@"jungle_foot_bridge^"])              ans = !YES;
//    
//    if ([name isEqualToString:@"Sculpture N240611"])                ans = YES;
//    
//    if ([name isEqualToString:@"Sculpture Shiva"])                  ans = YES;
//    
//    if ([name isEqualToString:@"Ship N100511"])                     ans = YES;
//    
//    if ([name isEqualToString:@"Skeleton"])                         ans = YES;
//    
//    if ([name isEqualToString:@"Skull N070211"])                    ans = YES;
//    
//    if ([name isEqualToString:@"Wellingtons N270309"])              ans = YES;
//    
//    if ([name isEqualToString:@"Telescope celestron omni xlt102 N170111"]) ans = !YES;
//    
    return ans;
}

////////////////////////////////////////////////////////////////////////////////
// gets geometry from store and puts into batches
-(void)loadGeometry
{
    // never want to load geometry more than once
    if (isLoaded) 
    {
        return;
    }
    
    
    // create the loader that will load geometry from 3ds files into
    // vertext batches
    KSGModelLoader* loader = [KSGModelLoader 
                                    loaderWithShaderManager:shaderManager 
                                        withMaterialManager:materialManager 
                                         withTextureManager:textureManager];
    
    // each model is a resource in the application bundle
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    // load the solar system
    KSEEnvironments * environmentLoader;
    environmentLoader = [[KSEEnvironments alloc] 
                         initWithResourcePath:resourcePath
                                  modelLoader:loader
                                  gameObjects:gameObjects 
                        binaryVolumeHeirarchy:binaryVolumeHeirarchy];
    
    [environmentLoader createSolarSystem];
    
    // get an array of all resources
    NSArray *modelFiles = [[NSFileManager defaultManager] 
                            contentsOfDirectoryAtPath:resourcePath error:nil];
    
    // filter down to 3ds models
    NSArray *models3ds = [modelFiles filteredArrayUsingPredicate:
                                 [NSPredicate predicateWithFormat:
                                  @"self ENDSWITH '.3ds' OR self ENDSWITH '.3DS'"]];
    

    // loop through all 3ds files creating a game object for each one (if not 
    // explicitly excluded)
    NSString* fileName;
    NSString* extension;
    KSGGameObject * cube;
    KSGGameObject * torus;
    KSGGameObject * stair;
    KSGGameObject * cylinder;
    KSGGameObject * cone;
    
    for (NSString* fPath in models3ds) 
    {
        NSLog(@"Checking model file : %@", fPath);
        
        // get the extension
        extension = [fPath pathExtension];
        
        // get the filename excluding the path and extension
        fileName = [[fPath lastPathComponent] stringByDeletingPathExtension];
        
        if ( ![self includeModel:fileName] ) 
        {
            NSLog(@"file %@ has been excluded in function 'includeModel'.",fPath);
            continue;            
        }
        
        // read the mesh data from file (there might be many sub models)
        float scaleFactor = 1.0;
        NSArray* subBatches = [loader loadModelFromFile:fileName 
                                                 ofType:extension 
                                           applyScaling:scaleFactor];
        
        // create the game object that will hold these sub-batches and add the 
        // game object to the game object collection.
        
        KSGGameObject* gameObject;
        gameObject = [self createGameObjectWithName:fileName 
                                     withSubBatches:subBatches];
        
        [gameObjects setObject:gameObject forKey:fileName];
        
        // register the game object's physics body with the gravity force
        [gravity registerBody:[gameObject physicsBody]];
        
        // register with air resistance
        [airResistance registerBody:[gameObject physicsBody]];
        
        // register with water resistance
        //[waterResistance registerBody:[gameObject physicsBody]];
        
        // Earth
        if ( [fileName isEqualToString:@"PlanetEarth"]) 
        {
            [gameObject.physicsBody setPosition:KSMVector3(-4, 2, 0)];
            [gameObject.physicsBody setIsAwake:YES];
        }
        // Mars
        if ( [fileName isEqualToString:@"PlanetMars"]) 
        {
            double mass = 10.0;
            double radius = 1.0;
            [gameObject.physicsBody setMass:mass];
            KSMMatrix3 mI = [KSPMomentsOfInertia sphereOfMass:mass radius:radius];
            [gameObject.physicsBody setMI:mI];
            [gameObject.physicsBody setPosition:KSMVector3(-4, 0, 0)];
            [gameObject.physicsBody setLinearVelocity:KSMVector3(1, 0, 0)];
            [gameObject.physicsBody setIsAwake:YES];
            cone = gameObject;
        }
        // Jupiter
        if ( [fileName isEqualToString:@"PlanetJupiter"]) 
        {
            double mass = 10.0;
            double radius = 1.0;
            [gameObject.physicsBody setMass:mass];
            KSMMatrix3 mI = [KSPMomentsOfInertia sphereOfMass:mass radius:radius];
            [gameObject.physicsBody setMI:mI];
            [gameObject.physicsBody setPosition:KSMVector3(4, 0, 0)];
            [gameObject.physicsBody setLinearVelocity:KSMVector3(-1, 0, 0)];
            [gameObject.physicsBody setIsAwake:YES];
        }
        
        // identify the cone
        if ( [fileName isEqualToString:@"Cone"]) 
        {
            cone = gameObject;
            [gravity unregisterBody:cone.physicsBody];
        }
        
        // identify the cube
        if ( [fileName isEqualToString:@"Cube"] ) 
        {
            cube = gameObject;
        }
        
        // identify the stair
        if ( [fileName isEqualToString:@"Stair"] ) 
        {
            stair = gameObject;
        }
        
        // identify the cylinder
        if ( [fileName isEqualToString:@"Cylinder"] ) 
        {
            cylinder = gameObject;
        }
        
        // identify the torus
        if ( [fileName isEqualToString:@"Torus"] ) 
        {
            torus = gameObject;
        }
        
    }
    
    // Add a spring to the apex of the cone
    KSPFGAnchoredSpring * spring;
    KSMVector4 attachPoint = KSMVector4(0, 0, 0, 1);
    KSMVector3 anchorPoint = KSMVector3(0, 4, 0);
    KSPPhysicsBody * physicsBody = cone.physicsBody;
    spring = [[KSPFGAnchoredSpring alloc] initWithNaturalLength:3 
                                                 springConstant:0.5 
                                                dampingConstant:0.0 
                                                       isBungee:YES 
                                                    physicsBody:physicsBody 
                                              bodyAttachPointMC:attachPoint
                                             worldAnchorPointWC:anchorPoint];
    
    //[forceGeneratorRegistry registerGenerator:spring];
    [spring setName:[self className]];
    [spring setNaturalPeriod:1];

    
//    // add floats to the cube
//    [KSVVehicle equipAsBoat:cube inWater:water buoyancyRatio:1.5 
//             registerForceGeneratorsWith:forceGeneratorRegistry];
    

    
}

////////////////////////////////////////////////////////////////////////////////
// send geometry to OpenGL
-(void)sendToGL
{
    for (NSString* name in gameObjects) 
    {
        KSGGameObject* gameObject = [gameObjects objectForKey:name];
        for (KSGBatch* batch in gameObject.batches) 
        {
            [batch sendToGL];
        }
    }
    
    [textureManager sendToGL];
}


////////////////////////////////////////////////////////////////////////////////
// drawToOpenGL
-(void)drawToOpenGL
{
    // clear context
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClearDepth(1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    glEnable(GL_TEXTURE_2D);
    
    [transformPack setWorldToView:*(camera.worldToCamera)];
    [transformPack setViewToProjection:*(camera.projection)];
    
    // TODO - downselect to potentially visible objects
    for (NSString* key in gameObjects) 
    {
        KSGGameObject* gameObject = [gameObjects objectForKey:key];
        [gameObject drawUsingTransformPack:transformPack 
                                    lights:lights];
    }     
}


////////////////////////////////////////////////////////////////////////////////
// modify the camera projection because the window on the world has changed shape
-(void)reshapeToWidth:(double)width Height:(double)height
{
    [camera reshapeViewportWithWidth:width Height:height];
}


////////////////////////////////////////////////////////////////////////////////
// capture keyboard input and translate into instructions for the world to process
-(void)keyDown:(NSEvent *)event
{        
    double linearDelta = 0.1;
    double angularDelta = PI * 5 / 180.0;

    const char g = 'g';
    const char h = 'h';
    const char z = 'z';
    const char x = 'x';
    
    int key = (int)[[event characters] characterAtIndex:0];
    switch (key) {
            
        case NSUpArrowFunctionKey:
            [camera moveForward:linearDelta];
            break;
            
        case NSDownArrowFunctionKey:
            [camera moveBack:linearDelta];
            break;
            
        case NSLeftArrowFunctionKey:
            [camera moveLeft:linearDelta];
            break;
            
        case NSRightArrowFunctionKey:
            [camera moveRight:linearDelta];
            break;
            
        case NSPageUpFunctionKey:
            [camera moveUp:linearDelta];
            break;
            
        case NSPageDownFunctionKey:
            [camera moveDown:linearDelta];
            break;
            
        case 97:
            // a key => rotate left
            [camera rotateLeft:angularDelta];
            break;
            
        case 100:
            // d key => rotate right
            [camera rotateRight:angularDelta];
            break;
            
        case 119:
            // w key = rotate up
            [camera rotateUp:angularDelta];
            break;
            
        case 115:
            // s key => rotate down
            [camera rotateDown:angularDelta];
            break;
        
        case g:
            // g key => roll left
            [camera rollLeft:angularDelta];
            break;
            
        case h:
            // h key => roll right
            [camera rollRight:angularDelta];
            break;
            
        case z:
            // z key => zoomin
            [camera zoomBy:2.0];
            break;
            
        case x:
            // x key => zoom out
            [camera zoomBy:0.5f];
            break;
            
        default:
            break;
    }
}    

@end
