// 
// fragment shader: ShaderFlat
//
#version 150


in       vec4 v4VaryingColor;        
out      vec4 v4FragmentColor;

void main(void)
{
    v4FragmentColor = v4VaryingColor;
}
