#version 150
// 
// fragment shader: ADS Phong shader
//

////////////////////////////////////////////////////////////////////////////////
// Vector postfix defs
// VC  = view coordinate (aka eye coordinate)
// WC  = world coordinate
// MC  = model coordinate
// PC  = projection coordinates 
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Vector postfix defs
// VC  = view coordinate (aka eye coordinate)
// WC  = world coordinate
// MC  = model coordinate
// PC  = projection coordinates 
////////////////////////////////////////////////////////////////////////////////

const int MAX_LIGHTS          =  1;

const int FOG_MODE_NONE  	  =  0;
const int FOG_MODE_LINEAR  	  =  1;
const int FOG_MODE_EXP        =  2;
const int FOG_MODE_EXP2       =  3;

// memory-saving constants
const float F_ZERO = 0.0;
const float F_ONE  = 1.0;
const float F_TWO  = 2.0;
const int   I_ZERO = 0;
const int   I_ONE  = 1;
const float PI     = 3.141592654;

struct light
{
    vec4 v4positionVC;              // position of light (in eye coordinates)
    vec4 v4ambientColor;            // ambient color emitted by light
    vec4 v4diffuseColor;            // diffuse color emitted by light
    vec4 v4specularColor;           // specular color emitted by light
    vec3 v3attenuations;            // holds constant, linear and quadratic factors
    float exponent;                 // intensity falls off with angle
    float coneAngle;                // limiting angle
};

struct material
{
    vec4    v4ambientColor;
    vec4    v4diffuseColor;
    vec4    v4specularColor;
    vec4    v4emissiveColor;
    float   exponent;
};

// lighting and material
uniform sampler2D colorMap;

uniform vec4    v4lPositionVC;
uniform vec4    v4lAmbientColor;
uniform vec4    v4lDiffuseColor;
uniform vec4    v4lSpecularColor;
uniform vec3    v3lAttenuations;
uniform float   lExponent;
uniform float   lConeAngle;

uniform vec4    v4mAmbientColor;
uniform vec4    v4mDiffuseColor;
uniform vec4    v4mSpecularColor;
uniform vec4    v4mEmissiveColor;
uniform float   mExponent;

uniform int     numLights;
material        aMaterial;
light           lights[MAX_LIGHTS];

// inputs from vertex shader  
in vec3     v3NormalVC;    // normal direction in eye coords
in vec3     v3vertexToLightVC[MAX_LIGHTS];
in vec3     v3VertexToEyeVC;
in vec2     v2varyingTex0;

out vec4 v4FragmentColor;

////////////////////////////////////////////////////////////////////////////////
// uses the ADS lighting model to calculate the contribution of this light, and
// adds the contribution color accumulator
vec4 lightingEquation(int lightIndex)
{
    // define the color vector this light contributes, and initially assume that 
    // this light provides no illumination
    vec4     retColor = vec4(F_ZERO, F_ZERO, F_ZERO, F_ZERO);

    // define the intensity of the light to be maximum brightness initially
    // (this will probably get downgraded before we are through)
    float    intensity = F_ONE;

    // get the light that we are going to analyse
    light    aLight = lights[lightIndex];

    // define the position vector from the vertex to the light (later, we will
    // turn this into a pure direction, but initially we also need the vertex
    // to light distance
    vec3     v3vertToLightVC = v3vertexToLightVC[lightIndex];
        
    // are we dealing with a directional light or a spot/point light?
    if ( 0 == aLight.v4positionVC.w )
    {
        // the ambient effect is independent of geometry and distance
        retColor += aLight.v4ambientColor * aMaterial.v4ambientColor;

    }
    else
    {
        // compute intensity factors
        vec3    v3intensityFactors;

        // constant intensity term
        v3intensityFactors.x = intensity;

        // intensity of light arriving at vertex depends on distance squared
        v3intensityFactors.z = dot(v3vertToLightVC, v3vertToLightVC);

        // there is also a linear term in distance
        v3intensityFactors.y = sqrt(v3intensityFactors.z);

        // put everything together
        intensity *= F_ONE / dot(v3intensityFactors, aLight.v3attenuations);
        
        // ambience is affected by distance but not by geometry, so calculate it
        // now.
        retColor += intensity * aLight.v4ambientColor * aMaterial.v4ambientColor;

        // from now on we want the vertex to light vector to be normalised
        v3vertToLightVC = normalize(v3vertToLightVC);

        // are we dealing with a spot 
        float   cosineOfAngle;
        if (aLight.coneAngle < PI)
        {
            // we are dealing with a spot light, so introduce an extra
            // factor to reduce intensity depending on how far from
            // the light's pointing direction we are.

            // Begin by calculating the cosine of the angle between the 
            // spot look direction and the vector from the light to the vertex
            cosineOfAngle = dot(v3vertToLightVC, normalize(aLight.v4positionVC.xyz));

            // are we inside the cone of the spot light?
            if ( cosineOfAngle < cos(aLight.coneAngle) )
            {
                // No, we are outside the cone, so this light contributes zero
                intensity = F_ZERO;
            }
            else
            {
                // we are inside the cone of light coming from the spot
                intensity *= pow(cosineOfAngle, aLight.exponent);
            }
        }
    }
            
    // if the intensity is greater than zero, we need to calculate the
    // none-ambient color this light contributes
    if (intensity > 0)
    {
        // this light provides at least some illumination in addition to ambient
        // so calculate the color. First comes the diffuse term...
        float cosAngleBetweenNormalAndLight = max(F_ZERO, 
                                          dot(normalize(v3NormalVC), 
                                              v3vertToLightVC));
        
        retColor += cosAngleBetweenNormalAndLight * 
                       (aLight.v4diffuseColor * aMaterial.v4diffuseColor);
                       
        // fold in the texture color
        retColor *= texture(colorMap, v2varyingTex0.st );

        // and now the specular term
        vec3 v3reflectionVC = reflect(-v3vertToLightVC, 
                                       normalize(v3NormalVC));
        
        // calculate the cosine of the angle between the perfect reflection 
        // angle and the line of sight
        float cosAlpha = max( F_ZERO, dot(normalize(v3VertexToEyeVC),
                                          normalize(v3reflectionVC) ) );
        
        retColor += pow( cosAlpha, aMaterial.exponent) *
                    (aLight.v4specularColor * aMaterial.v4specularColor);
         
    }

    // and return the color contribution from this light
    return retColor * intensity;
}

////////////////////////////////////////////////////////////////////////////////
// doLighting - applies the lighting equation to each light in turn and sums
// the results. The alpha channel is overwritten by taking the alpha value
// from the material diffuse color
vec4 doLighting(void)
{
    vec4 v4fragColor = aMaterial.v4emissiveColor;

    for( int i = I_ZERO; i < MAX_LIGHTS; i++ )
    {
        if (i >= numLights) break;
        
        v4fragColor += lightingEquation(i);
    }

    v4fragColor.a = aMaterial.v4diffuseColor.a;
    
    return v4fragColor;
}

////////////////////////////////////////////////////////////////////////////////
// main
void main(void)
{
    // Prepare for the lighting calculation. 
    lights[0].v4positionVC          = v4lPositionVC;               
    lights[0].v4ambientColor        = v4lAmbientColor;            
    lights[0].v4diffuseColor        = v4lDiffuseColor;           
    lights[0].v4specularColor       = v4lSpecularColor;           
    lights[0].v3attenuations        = v3lAttenuations;      
    lights[0].exponent              = lExponent;         
    lights[0].coneAngle             = lConeAngle;                
       
    // do the same with the material data
    aMaterial.v4ambientColor        = v4mAmbientColor;
    aMaterial.v4diffuseColor        = v4mDiffuseColor;
    aMaterial.v4specularColor       = v4mSpecularColor;
    aMaterial.v4emissiveColor       = v4mEmissiveColor;
    aMaterial.exponent              = mExponent; 

    // do the lighting calculation
    v4FragmentColor = doLighting();
}