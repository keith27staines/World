#version 150
// 
// fragment shader ShaderIdentity
//

in  vec4 v4VaryingColor;         // smoothly varying color from vertex shader
out vec4 vFragmentColor;

void main(void)
{
    // all the work has been done in the vertex shader, so we just pass on
    // the smoothly varying color that the vertx shader found for us.

    vFragmentColor = v4VaryingColor;

}
