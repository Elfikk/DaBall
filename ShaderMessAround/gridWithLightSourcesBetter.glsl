#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

const float div_x = 15.0;
const float div_y = 15.0;

const float x_src = 0.668;
const float y_src = 0.827;

const float x_src2 = 0.264;
const float y_src2 = 0.455;

vec3 colourMultiplier(float x, float y)
{
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    float r_sq = (st.x - x) * (st.x - x) + (st.y - y) * (st.y - y);

    float i = 0.02;

    float sf = i / r_sq;
    if (r_sq  < .1)
    {
        float sf = i;
    }

    return vec3(1.0 - sf, 1.0, 1.0 - sf);
}

float intensityAddition(float x, float y)
{
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    float r_sq = (st.x - x) * (st.x - x) + (st.y - y) * (st.y - y);

    float i = 0.001;

    float sf = i / r_sq;
    if (r_sq  < .1)
    {
        float sf = i;
    }
    return sf;
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    int nx = int(floor(st.x * div_x));
    int ny = int(floor(st.y * div_y));

	float dx = (float(nx)/div_x + .5 / div_x - st.x) * div_x * 2.0;
    float dy = (float(ny)/div_y + .5 / div_y - st.y) * div_y * 2.0;

    float intensity = 0.3 - 0.6 * (1.0 - max(dy * dy, dx * dx)) + intensityAddition(x_src, y_src) + intensityAddition(x_src2, y_src2);
    vec3 colour = vec3(1.0, 1.0, 1.0) * colourMultiplier(x_src, y_src) * colourMultiplier(x_src2, y_src2);

	gl_FragColor = vec4(colour, intensity);
}
