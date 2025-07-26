#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI 3.14159265359

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

float gridColour(vec2 st, vec2 divs, vec2 widths)
{
	vec2 fracts = fract(st * divs) / divs;
	vec2 relevantWidths = min(fracts, 1.0 - fracts);
    if ((relevantWidths.x < widths.x) || (relevantWidths.y < widths.y))
    {
        return 0.0;
    }
    return 1.0;
}

void main()
{
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    float colour = gridColour(rotate2d(0.25 * PI) * st, vec2(20,20), vec2(0.02,0.02));

    gl_FragColor = vec4(colour, colour, colour, 1);
}
