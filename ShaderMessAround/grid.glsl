#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

const float div_x = 50.0;
const float div_y = 50.0;

void main()
{
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    int nx = int(floor(st.x * div_x));
    int ny = int(floor(st.y * div_y));

	float dx = (float(nx)/div_x + .5 / div_x - st.x) * div_x * 2.0;
    float dy = (float(ny)/div_y + .5 / div_y - st.y) * div_y * 2.0;

    gl_FragColor = vec4(1.0, 1.0, 1.0, 0.9 * (1.0 - max(dy * dy, dx * dx)) + 0.1 * sin(st.x / div_x + u_time / div_x));
}
