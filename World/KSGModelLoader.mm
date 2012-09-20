//
//  KSGModelLoader.mm
//  World
//
//  Created by Keith Staines on 07/10/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//
#import "KSMMaths.h"
#import "KSGModelLoader.h"
#import "KSGMaterial.h"
#import "KSGVertex.h"
#import "KSGIndexedTriangleBatch.h"
#import "KSGVertexBatch.h"
#import "KSGShaderManager.h"
#import "KSGMaterialManager.h"
#import "KSGTextureManager.h"
#import "KSGMaterial.h"
#import "KSGTexture.h"
#import "KSCBVHNode.h"


@implementation KSGModelLoader

// The model data, which is arranged in a heirarchy of chunks with these ids:
const unsigned short MAIN_CHUNK                 = 0x4d4d;
const unsigned short EDITOR_CHUNK               = 0x3d3d;
const unsigned short OBJECT_BLOCK_CHUNK         = 0x4000;
const unsigned short TRIANGLE_MESH_CHUNK        = 0x4100;
const unsigned short VERTICES_CHUNK             = 0x4110;
const unsigned short FACES_CHUNK                = 0x4120;
const unsigned short FACES_MATERIAL_CHUNK       = 0x4130;
const unsigned short MAPPING_LIST_CHUNK         = 0x4140;
const unsigned short SMOOTHING_CHUNK            = 0x4150;
const unsigned short CAMERA_CHUNK               = 0x4600;
const unsigned short LIGHTS_CHUNK               = 0x4700;

// texture related chunks
const unsigned short MATERIALS_CHUNK            = 0xAFFF;
const unsigned short MAT_NAME_CHUNK             = 0xA000;
const unsigned short MAT_AMBIENT_COLOR_CHUNK    = 0xA010;
const unsigned short MAT_DIFFUSE_COLOR_CHUNK    = 0xA020;
const unsigned short MAT_SPECULAR_COLOR_CHUNK   = 0xA030;
const unsigned short MAT_SELF_ILLUM_CHUNK       = 0xA084;

const unsigned short MAT_SHINYNESS_CHUNK        = 0xA040;
const unsigned short MAT_SHINY_STRENGTH_CHUNK   = 0xA041;
const unsigned short MAT_TRANSPARENCY_CHUNK     = 0xA050;
const unsigned short MAT_SHADER_TYPE_CHUNK      = 0xA100;

const unsigned short TEX_TEXTURE1_CHUNK         = 0xA200;
const unsigned short TEX_TEXTURE2_CHUNK         = 0xA33A;
const unsigned short TEX_TEXTURE1_MASK_CHUNK    = 0xA33E;
const unsigned short TEX_TEXTURE2_MASK_CHUNK    = 0xA340;
const unsigned short TEX_OPACITY_CHUNK          = 0xA210;
const unsigned short TEX_BUMP_CHUNK             = 0xA230;
const unsigned short TEX_SPECULAR_CHUNK         = 0xA204;
const unsigned short TEX_SHINY_CHUNK            = 0xA33C;
const unsigned short TEX_EMISSIVE_CHUNK         = 0xA33D;
const unsigned short TEX_REFLECTION_CHUNK       = 0xA220;
const unsigned short TEX_FILENAME_CHUNK         = 0xA300;
const unsigned short TEX_MAP_OPTIONS_CHUNK      = 0xA351;
const unsigned short TEX_U_SCALE_CHUNK          = 0xA354;
const unsigned short TEX_V_SCALE_CHUNK          = 0xA356;
const unsigned short TEX_U_OFFSET_CHUNK         = 0xA358;
const unsigned short TEX_V_OFFSET_CHUNK         = 0xA35A;
const unsigned short TEX_MAP_ROTATION_CHUNK     = 0xA35C;


// material color chunks
const unsigned short MAT_RGB1                   = 0x0011;
const unsigned short MAT_RGB2                   = 0x0012;

// Amount of
const unsigned short AMOUNT_OF                  = 0x0030;


NSString* binRep;


////////////////////////////////////////////////////////////////////////////////
// override designated constructor of super class
- (id)init
{    
    KSGShaderManager   * smgr = [[KSGShaderManager   alloc] init];
    KSGMaterialManager * mmgr = [[KSGMaterialManager alloc] init];
    KSGTextureManager  * tmgr = [[KSGTextureManager  alloc] init];
    
    return [self initWithShaderManager:smgr 
                   withMaterialManager:mmgr 
                    withTextureManager:tmgr];
}

////////////////////////////////////////////////////////////////////////////////
// Construct with a shader manager. This is the designated constructor
-(id)initWithShaderManager:(KSGShaderManager    *) theShaderManager 
       withMaterialManager:(KSGMaterialManager  *) theMaterialManager
        withTextureManager:(KSGTextureManager   *) theTextureManager
{
    self = [super init];
    if (self) {
        // Initialization code here.
        shaderManager   = theShaderManager;
        materialManager = theMaterialManager;
        textureManager  = theTextureManager;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// helper to construct an autoreleased KSGModelLoader
+(id)loaderWithShaderManager:(KSGShaderManager   *) theShaderManager 
         withMaterialManager:(KSGMaterialManager *) theMaterialManager
         withTextureManager:(KSGTextureManager   *) theTextureManager
{
    id ldr = [[[self class] alloc] initWithShaderManager:theShaderManager 
                                     withMaterialManager:theMaterialManager 
                                      withTextureManager:theTextureManager];
    return ldr;
}

-(NSString*)binaryRepresentation:(int)toChange
{
    int inNumber;
    NSString *binaryRep = @"";
    int temp;
    
    inNumber=toChange;
    
    for (int b=0; b<=7; b++) 
    {
        temp = inNumber%2;
        inNumber = (inNumber-temp)/2;
        binaryRep = [binaryRep stringByAppendingFormat:@"%i", temp];
    }
    
    return binaryRep;
}

////////////////////////////////////////////////////////////////////////////////
// loads the geometry from the file into a batch ojbect
-(NSArray*)loadModelFromFile:(NSString*)fileName 
                      ofType:(NSString*)modelType 
                applyScaling:(float)scale
{    
    
    // we will process all model data in memory rather than from file
    
    // set up the data structure to hold the model data while we parse it
    byteData = [self readModelData:fileName ofType:modelType];
    
    // This range will be used to read sequencies of bytes
    r = NSMakeRange(0, 0);
    
    // we need to make sure we don't attempt to read bytes beyond the data
    length = [byteData length];
    
    // each chunk will hold the following "header" info...
    unsigned short chunk_id = 0;        // tells us the id of the chunk
    unsigned int chunk_length = 0;      // tells us the length of the chunk
    unsigned short qty = 0;             // tells us how many data items to read
    
    // The array to hold all the models we will be returning
    NSMutableArray* subBatches = [NSMutableArray arrayWithCapacity:10];
    
    // to hold a vertex before adding to batch
    KSGVertex* vertex;
    
    // The current batch being built
    KSGIndexedTriangleBatch* batch             = nil;
    KSGMaterial*             material          = nil;
    KSGTexture *             texture           = nil;
    NSString   *             modelNameInEditor = nil;
    
    double largestSize2 = 0.0;   
    KSG_TextureType currentTextureType; 
    
try 
{
    // loop through the file, processing it chunk by chunk
    while (r.location < length) 
    {
        // read the chunk header
        [self getBytes:&chunk_id sizeOfElement:sizeof(chunk_id)];
        
        // read the length of the chunk
        [self getBytes:&chunk_length sizeOfElement:sizeof(chunk_length)];
        
        // temporary variables we will need as we process the switch
        int i = 0;
        
        // 3ds vertex position info in floats
        float x = 0.0f, y = 0.0f, z = 0.0f;          
        
        // 3ds indices are in unsigned shorts
        unsigned short a = 0, b = 0, c = 0; 

        switch (chunk_id)
        {
            case MAIN_CHUNK:
                // The mother of all chunks, but just a container for more
                // interesting stuff, with the Editor chunk right beneath it
                break;
                
            case EDITOR_CHUNK:
                // Drill into this one because its subchunks contain info
                // on geometry, material, lights, etc
                break;
                
            case OBJECT_BLOCK_CHUNK:
                // Holds the name of the object as provided in the 3d editor
                {                    
                    modelNameInEditor = [self readAsciiz];
                }
                break;
                
            case TRIANGLE_MESH_CHUNK:
                // We are very interested in the triangle mesh, but there is
                // nothing in this chunk itself - it is just another container
                // between us and the stuff we are drilling down to
                break;
                
            case VERTICES_CHUNK:
            {
                // Vertex data stored here. First question is, how much?
                [self getBytes:&qty sizeOfElement:sizeof(qty)];
                
                // create vertices array to hold them
                batch = (KSGIndexedTriangleBatch*)[KSGIndexedTriangleBatch 
                                                   vertexBatchWithCapacity:qty];
                [batch setName:modelNameInEditor];
                [batch setMaterial:nil];
                [subBatches addObject:batch];
                for (i=0; i < qty; i++)
                {
                    // read the three elements of data for this vertex
                    [self getBytes:&x sizeOfElement:sizeof(x)];
                    [self getBytes:&y sizeOfElement:sizeof(y)];
                    [self getBytes:&z sizeOfElement:sizeof(z)];
                    
                    // keep track of largest distance from origin
                    KSMVector3 radial = KSMVector3(x,y,z);
                    if (radial.length2() > largestSize2) 
                    {
                        largestSize2 = radial.length2();
                    }
                    // create the vertex
                    vertex = [KSGVertex vertexAtX:x Y:y Z:z];
                    
                    // set the vertex color (TODO: really just white?)
                    vertex.red   = 1.0f;
                    vertex.green = 1.0f;
                    vertex.blue  = 1.0f;
                    
                    // store the vertex in the batch
                    [batch addVertex:vertex];
                }
            }
            break;
                
            case FACES_CHUNK:
            {
                // Triangle data stored here (indices into the vertex list).
                // First task is to determine how many polygons (triangles)
                [self getBytes:&qty sizeOfElement:sizeof(qty)];
                
                // now read the polygon data (indices into the vertex batch)
                // each triangle consists of three vertices, so there are three
                // indices to be read for each triangle, plus some other data
                // of no interest to us
                for (i=0; i<qty; i++)
                {
                    // each of the three elements is the index of a vertex, 
                    // and three vertices make up one face (which is a triangle)
                    
                    [self getBytes:&a sizeOfElement:sizeof(a)];
                    [self getBytes:&b sizeOfElement:sizeof(b)];
                    [self getBytes:&c sizeOfElement:sizeof(c)];

                    // copy these indices into the batch
                    [batch AddIndex:a];
                    [batch AddIndex:b];
                    [batch AddIndex:c];
                    
                    // there are also some face flags which are important because
                    // they tell us whether the normal needs to be reversed
                    unsigned short face_flags = 0;      
                    [self getBytes:&face_flags sizeOfElement:sizeof(face_flags)];
                    
                    // Test faceFlags to decide whether normal must be reversed,
                    // which we will arrange for by swapping the order.
         
                    if ( face_flags == 7  )
                    {
                          //NSLog(@"7");
                    }
                    else
                    {
                          //NSLog(@"!7");
                    } 

                }
                break;
            }
            case FACES_MATERIAL_CHUNK:
            {                
                // get the name of the material
                NSString* materialName = [self readAsciiz];
                if (!materialName) {
                    materialName = @"default";
                }
                
                // now we read off the faces that this material applies to
                qty = 0;
                [self getBytes:&qty sizeOfElement:sizeof(qty)];
                if (qty)
                {
                    // get hold of the material with the corresponding name
                    KSGMaterial* mat = [materialManager resourceWithName:materialName];

                    if (![batch material])
                    {
                        NSLog(@"Assigning material '%@' to batch '%@'",[material name],[batch name]);
                        [batch setMaterial:mat];
                    }
                    else
                    {
                        if (mat != [batch material])
                        {
                            NSLog( @"WARNING: there is more than one material defined for batch %@. Material %@ is different from the assigned material, %@, which will be used.",[batch name], [mat name], [[batch material] name]);
                            mat = nil;
                        }
                    }                    
                }
                for (i=0; i<qty; i++)
                {
                    [self getBytes:&a sizeOfElement:sizeof(a)];                    
                }
                break;
            }
                
            case SMOOTHING_CHUNK:
            {
                // Texture mapping data stored here.
                unsigned int smoothings;
                // now read the mapping data
                for (i=0; i < [batch triangleCount] / 3; i++)
                {
                    [self getBytes:&a sizeOfElement:sizeof(smoothings)];
                    binRep = [self binaryRepresentation:a];
                    [batch AddSmoothingGroups:smoothings];
                }
                break;
            }
            
            case MAPPING_LIST_CHUNK:
            {
                // Texture mapping data stored here.
                [self getBytes:&qty sizeOfElement:sizeof(qty)];
                
                // now read the mapping data
                for (i=0; i<qty; i++)
                {
                    // get the vertex object at index i
                    KSGVertex* vertex = [[batch vertices] objectAtIndex:i];
                    
                    // get the mapping data
                    [self getBytes:&x sizeOfElement:sizeof(x)];
                    [self getBytes:&y sizeOfElement:sizeof(y)];
                    
                    // insert the mapping data into the vertex
                    vertex.textureX = x;
                    vertex.textureY = -y;
                    vertex.textureZ = 0.0f;
                }
                break;
            }
                
            case MATERIALS_CHUNK:
            {
                // container for material info subchunks so we drill into this
                break;
            }
            
            case MAT_NAME_CHUNK:
            {
                if (material) 
                {
                    material.isOpen = NO;
                    material = nil;
                }
                material = [materialManager resourceWithName:[self readAsciiz]];
                break;
            }
            
            case MAT_AMBIENT_COLOR_CHUNK:
            {
                if (!material || !material.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }
                KSGColor actual; 
                KSGColor display;
                [self getActualColor:&actual 
                     getDisplayColor:&display 
                     withChunkLength:chunk_length];
                [material setAmbientColor:actual];
                break;
            }
            case MAT_DIFFUSE_COLOR_CHUNK:
            {
                if (!material || !material.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                KSGColor actual; 
                KSGColor display;
                [self getActualColor:&actual 
                     getDisplayColor:&display 
                     withChunkLength:chunk_length];
                [material setDiffuseColor:actual];
                break;
            }
            case MAT_SPECULAR_COLOR_CHUNK:
            {
                if (!material || !material.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                KSGColor actual; 
                KSGColor display;
                [self getActualColor:&actual 
                     getDisplayColor:&display 
                     withChunkLength:chunk_length];
                [material setSpecularColor:actual];
                break;
            }
            case MAT_SELF_ILLUM_CHUNK:
            {
                if (!material || !material.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                KSGColor actual; 
                KSGColor display;
                [self getActualColor:&actual 
                     getDisplayColor:&display 
                     withChunkLength:chunk_length];
                [material setEmissiveColor:actual];
                break;
            }
            case MAT_TRANSPARENCY_CHUNK:
            {
                if (!material || !material.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                [material setOpacity:[self readAmount]];
                break;
            }
            case MAT_SHADER_TYPE_CHUNK:
            {
                if (!material || !material.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                unsigned short shaderType;
                [self getBytes:&shaderType sizeOfElement:sizeof(shaderType)];
                break;
            }
                
            case MAT_SHINYNESS_CHUNK:
            {
                if (!material || !material.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                [material setSpecularExponent:[self readAmount]];
                break;
            }
                
            case MAT_SHINY_STRENGTH_CHUNK:
            {
                if (!material || !material.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                // not really sure what this means so skip anyway
                [self skipChunk:chunk_length];               
                break;
            }
                
            case TEX_BUMP_CHUNK:
            {
                currentTextureType = KSG_Texture_Bump;
                [self skipChunk:chunk_length];
                break;
            }
            
            case TEX_OPACITY_CHUNK:
            {
                [self skipChunk:chunk_length];
                break;
            }
                
            case TEX_REFLECTION_CHUNK:
            {
                currentTextureType = KSG_Texture_Reflection;
                // can't handle reflections yet
                [self skipChunk:chunk_length];
                break;
            }
            
            case TEX_EMISSIVE_CHUNK:
            {
                KSGColor actual; 
                KSGColor display;
                [self getActualColor:&actual 
                     getDisplayColor:&display 
                     withChunkLength:chunk_length];
                break;
            }
                
            case TEX_SHINY_CHUNK:
            {
                [self skipChunk:chunk_length];
                break;
            }
                
            case TEX_SPECULAR_CHUNK:
            {
                [self skipChunk:chunk_length];
                break;
            }
            case TEX_TEXTURE1_CHUNK:
            {
                currentTextureType = KSG_Texture_1;
                break;
            }
            
            case TEX_TEXTURE2_CHUNK:
            {
                currentTextureType = KSG_Texture_2;
                break;  
            }
            
            case TEX_TEXTURE1_MASK_CHUNK:
            {
                [self skipChunk:chunk_length];
                break;
            }
                
            case TEX_TEXTURE2_MASK_CHUNK:
            {
                [self skipChunk:chunk_length];
                break;  
            }     
            
            case TEX_FILENAME_CHUNK:
            {
                if (texture) 
                {
                    [texture setIsOpen:NO];
                    texture = nil;
                }
                texture = [textureManager resourceWithName:[self readAsciiz]];
                [material setTexture:texture ofType:currentTextureType];
                break;
            }
                
            case TEX_MAP_OPTIONS_CHUNK:
            {
                if (!texture || !texture.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }
                unsigned short int mapOptions;
                [self getBytes:&mapOptions sizeOfElement:sizeof(mapOptions)];
                break;
            }
                
            case TEX_U_SCALE_CHUNK:
            {
                if (!texture || !texture.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                double uScale;
                [self getBytes:&uScale sizeOfElement:sizeof(uScale)];
                [texture setUScale:uScale];
                break;
            }
                
            case TEX_V_SCALE_CHUNK:
            {
                if (!texture || !texture.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                double vScale;
                [self getBytes:&vScale sizeOfElement:sizeof(vScale)];
                [texture setVScale:vScale];
                break;
            }

            case TEX_U_OFFSET_CHUNK:
            {
                if (!texture || !texture.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                double uOffset;
                [self getBytes:&uOffset sizeOfElement:sizeof(uOffset)];
                [texture setUOffset:uOffset];
                break;
            }

            case TEX_V_OFFSET_CHUNK:
            {
                if (!texture || !texture.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                double vOffset;
                [self getBytes:&vOffset sizeOfElement:sizeof(vOffset)];
                [texture setVOffset:vOffset];
                break;
            }
                
            case TEX_MAP_ROTATION_CHUNK:
            {
                if (!texture || !texture.isOpen) 
                {
                    [self skipChunk:chunk_length];
                    break;
                }

                double angle;
                [self getBytes:&angle sizeOfElement:sizeof(angle)];
                [texture setRotAngle:angle];
                break;
            }
                
            default:
                // we aren't interested in any other chunks we might come
                // across so we skip over them
                [self skipChunk:chunk_length];
                break;

        }
        
    }
    
    // ensure that the final texture is flagged as closed
    if (texture) 
    {
        [texture setIsOpen:NO];
    }
    
    // close assign ashader and close the batches
    GLint progId = [shaderManager programID:KSG_ShaderPhong];
    scale = sqrt(scale / largestSize2);
    
    for (KSGIndexedTriangleBatch* aBatch in subBatches) 
    {        
        // Assigning this scale ensures that all batches are well sized
        // so that they are visible but ultimately we want to apply scales from 
        // a config file so that they are proportionaly sized
        aBatch.scale = scale;
        
        // assign the material for this batch
        material = [aBatch material];
        if ( material == nil ) 
        {
            // set the material for this batch to the default material
            material = [materialManager defaultResource];
            [aBatch setMaterial:material];
        }
        
        // assign the texture for this batch
        texture = [material texture1];
        if (texture == nil) 
        {
            texture = [textureManager defaultResource];
            [material setTexture1:texture];
        }
        
        // assign the shader program that will be used to draw this batch
        [aBatch setOpenGLProgramId:progId];
                
        // TODO: scale should be applied to the transform rather than by scaling
        // vertex vectors individually        
        for (KSGVertex* vertex in aBatch.vertices)
        {
            vertex.x *= scale;
            vertex.y *= scale;
            vertex.z *= scale;
        }
        
        // This batch now contains all the vertices it ever will, so close it
        [aBatch close];     
        
    }

    return subBatches;

} catch (NSException* exception) 
{
    NSLog(@"EXCEPTION: %@", exception);
}
    return subBatches;
}

-(unsigned short)readAmount
{ 
    unsigned short chunkID;
    [self getBytes:&chunkID sizeOfElement:sizeof(chunkID)];
    if( chunkID != AMOUNT_OF )
    {
        // "amount of" chunks are expected to have the AMOUNT_OF id
        NSLog(@"UNEXPECTED chunk id in fn readAmount!!!");
    }
    
    unsigned int chunkLength;
    [self getBytes:&chunkLength sizeOfElement:sizeof(chunkLength)];

    // six bytes because length includes id and length of the length field,
    // then two more for a total of 8 because we are expecting two bytes of
    // data.
    if ( chunkLength != 6+2 )
    {
        // this should really throw an exception because things are 
        // obviously going way wrong, but I'll just log it for now
        NSLog(@"HUGELY unexpected chunk length in fn readAmount!!!");
    }

    // we really are expecting two bytes worth of data here...
    short value;
    [self getBytes:&value sizeOfElement:sizeof(value)];
    return value;

}

////////////////////////////////////////////////////////////////////////////////
// read characters until '\0' encountered and return the string
-(NSString*)readAsciiz
{
    char chars[MAX_ASCIIZ_CHARS + 1];
    int i = 0;
    do
    {
        [self getBytes:&chars[i] sizeOfElement:sizeof(chars[0])];
        i++;
    } while (chars[i-1] != '\0' && i < MAX_ASCIIZ_CHARS);
    
    // ensure correct termination
    chars[i] = '\0'; 

    // create an NSString from the char array and return it
    return [NSString stringWithUTF8String:chars];
} 

-(KSGColor)readColorWithExpectedChunkID:(unsigned short)chunkID
{
    unsigned short readChunkID;
    [self getBytes:&readChunkID sizeOfElement:sizeof(readChunkID)];
    NSAssert(chunkID == readChunkID, 
             @"UNEXPECTED chunk id in fn readColorWithExpectedChunkID.");
    
    unsigned int chunkLength;
    [self getBytes:&chunkLength sizeOfElement:sizeof(chunkLength)];
    
    // six bytes because length includes id and length of the length field,
    // then three more for a total of 9 because we are expecting three bytes of
    // color data, rgb.
    NSAssert(chunkLength == 6 + 3, 
             @"UNEXPECTED chunk length in fn readColorWithExpectedChunkID.");

    unsigned char red,green,blue;
    [self getBytes:&red   sizeOfElement:sizeof( red  )];
    [self getBytes:&green sizeOfElement:sizeof( green)];
    [self getBytes:&blue  sizeOfElement:sizeof( blue )];
    float cscale = 1.0f / 255.0f;
    
    return [KSGColorFactory makeColorWithRed:red * cscale 
                                       green:green * cscale 
                                        blue:blue * cscale 
                                       alpha:1.0];
}

-(KSGColor)readColorActual
{
    // read the color at chunk id MAT_RGB1 (this is the actual chunk
    // with no gamma correction).
    return [self readColorWithExpectedChunkID:MAT_RGB1];
}

-(KSGColor)readColorDisplay
{
    // read the color at chunk id MAT_RGB2 (this color includes gamma correction)
    return [self readColorWithExpectedChunkID:MAT_RGB2];
}


-(void)getActualColor:(KSGColor*)actual 
       getDisplayColor:(KSGColor*)display
       withChunkLength:(unsigned int)numBytes
{   
    
    switch (numBytes) {
        case 15:
            // only one color held in file, so copy it to the other
            *actual = [self readColorActual];
            *display = *actual;
            break;
        case 24:
            // both colors held in file so we can safely read the second on too
            *actual = [self readColorActual];
            *display = [self readColorDisplay];
            break;
            
        default:
            NSAssert(YES, @"Unexpected length for color chunk.");
    }
}

////////////////////////////////////////////////////////////////////////////////
// skip chunk. NB, this method assumes that we have just read the chunk id
// and the chunk length
-(void)skipChunk:(NSUInteger)chunkLength
{
    // note that the chunk id and chunk length are both
    // unsigned shorts (three bytes each).
    r.location += chunkLength - 6;    
}


////////////////////////////////////////////////////////////////////////////////
// read off the required number of bytes into the specified data element
-(void)getBytes:(void*)dataElement sizeOfElement:(NSUInteger)thisSize
{
    // how many bytes do we need to read to fill this data element?
    r.length = thisSize;
    
    // sanity check - we mustn't read beyond the end of the data
    NSAssert(r.location + r.length <= length, 
             @"Attempting to read beyond end of model data");

    // fill the data element
    [byteData getBytes:dataElement range:r];
    
    // move the read position forward to the end of this data element
    // ready for the next one
    r.location += r.length;    
}

////////////////////////////////////////////////////////////////////////////////
// reads the file containing the model into an NSData object
-(NSData*)readModelData:(NSString*)modelName ofType:(NSString*)modelType
{
    // the model is a resource in the application bundle
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* modelFilename = [bundle pathForResource:modelName 
                                               ofType:modelType];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:modelFilename];
    
    NSAssert1(fileExists,@"resource file %@ does not exist", modelFilename);
             
    // read the date from the model
    NSData* bytes = [NSData dataWithContentsOfFile:modelFilename];
    
    // return the date object
    return bytes;
}


@end
