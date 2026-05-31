//shader code that will be aplied to every obstacles
#pragma header

uniform float outlineSize;
uniform vec3 outlineColor;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec2 size = openfl_TextureSize;
    vec4 color = flixel_texture2D(bitmap, uv);

    // if this pixel is empty (transparent), check its nearest pixel to see if we need an outline
    if (color.a < 0.1) {
        float w = outlineSize / size.x;
        float h = outlineSize / size.y;
        
        float alpha = 0.0;
        
        // check pixels that arent existed from left to right and up to down
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x + w, uv.y)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x - w, uv.y)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x, uv.y + h)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x, uv.y - h)).a);
        
        // check pixels that arent existed from diagonally to make the outline smoother 
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x + w, uv.y + h)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x - w, uv.y - h)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x + w, uv.y - h)).a);
        alpha = max(alpha, flixel_texture2D(bitmap, vec2(uv.x - w, uv.y + h)).a);

        //if the pixel is visible paint it white
        if (alpha > 0.0) {
            color = vec4(outlineColor * alpha, alpha); 
        }
    }

    gl_FragColor = color;
    //its obiviously a variable DUH
}