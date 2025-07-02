vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    number div_x = love_ScreenSize.x / 2.75;
    number div_y = love_ScreenSize.y / 2.75;

    vec2 st = screen_coords.xy / love_ScreenSize.xy;

    int nx = int(floor(st.x * div_x));
    int ny = int(floor(st.y * div_y));

	float dx = (float(nx)/div_x + .5 / div_x - st.x) * div_x * 2.0;
    float dy = (float(ny)/div_y + .5 / div_y - st.y) * div_y * 2.0;

    vec4 overlayColour = vec4(1.0, 1.0, 1.0, 0.9 * (1.0 - max(dy * dy, dx * dx)));
    // vec4 overlayColour = vec4(st.x, 0, 0, 1);

    vec4 pixel = Texel(texture, texture_coords); // This is the current pixel color
    return overlayColour * pixel * color;
}
