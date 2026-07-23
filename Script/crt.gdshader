shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;

    float r = texture(SCREEN_TEXTURE, uv + vec2(0.0015, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv - vec2(0.0015, 0.0)).b;
    
    float scanline = sin(uv.y * 400.0) * 0.04;
    COLOR = vec4(r - scanline, g - scanline, b - scanline, 1.0);
}
