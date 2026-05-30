#pragma header

uniform float outlineSize;
uniform vec3 outlineColor;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec2 size = openfl_TextureSize;
    vec4 color = flixel_texture2D(bitmap, uv);

    // If the current pixel is mostly transparent, check its neighbors
    if (color.a < 0.1) {
        float w = outlineSize / size.x;
        float h = outlineSize / size.y;
        
        float alpha = 0.0;
        
        // Check orthogonal neighbors (Up, Down, Left, Right)
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x + w, uv.y)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x - w, uv.y)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x, uv.y + h)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x, uv.y - h)).a);
        
        // Check diagonal neighbors for a smoother, rounded outline
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x + w, uv.y + h)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x - w, uv.y - h)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x + w, uv.y - h)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x - w, uv.y + h)).a);

        // If a neighboring pixel is visible, paint this pixel with the outline color
        if (alpha > 0.0) {
            color = vec4(outlineColor * alpha, alpha); 
        }
    }

    gl_FragColor = color;
}