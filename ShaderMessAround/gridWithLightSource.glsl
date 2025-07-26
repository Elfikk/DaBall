#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

const float div_x = 25.0;
const float div_y = 25.0;

const float x_src = 0.9;
const float y_src = 0.955;

const float x_src2 = 0.152;
const float y_src2 = 0.671;

vec4 multiplier(float x, float y)
{
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    float r_sq = (st.x - x) * (st.x - x) + (st.y - y) * (st.y - y);

    float sf = max(0.00, 1.0 / (r_sq + 1.));

    return vec4(1.0 - sf * sf * sf, 1.0, 1. - sf * sf * sf, sf);
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    int nx = int(floor(st.x * div_x));
    int ny = int(floor(st.y * div_y));

	float dx = (float(nx)/div_x + .5 / div_x - st.x) * div_x * 2.0;
    float dy = (float(ny)/div_y + .5 / div_y - st.y) * div_y * 2.0;

	gl_FragColor = vec4(1.0, 1.0, 1.0, 1. - (1.0 - max(dy * dy, dx * dx))) * multiplier(x_src, y_src) * multiplier(x_src2, y_src2);
}