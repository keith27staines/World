#version 150
// 
// fragment shader: ADS Gouraud shader
//

////////////////////////////////////////////////////////////////////////////////
// Vector postfix defs
// VC  = view coordinate (aka eye coordinate)
// WC  = world coordinate
// MC  = model coordinate
// PC  = projection coordinates 
////////////////////////////////////////////////////////////////////////////////

in  vec4 v4VaryingColor;         // smoothly varying color from vertex shader
out vec4 v4FragmentColor;

void main(void)
{
    // all the work has been done in the vertex shader, so we just pass on
    // the smoothly varying color that the vertx shader found for us.

    v4FragmentColor = v4VaryingColor;

}