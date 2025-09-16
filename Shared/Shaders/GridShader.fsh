// GridShader.fsh
// Fragment shader for creating a grid overlay effect in a circular area around mouse position
// Compatible with SpriteKit shader system

void main() {
    // Get the current fragment's texture coordinates (0-1 range)
    vec2 coord = v_tex_coord;
    
    // Get shader uniforms - these are passed from GridShaderNode
    float gridRadius = u_grid_radius;
    float gridSize = u_grid_size;
    vec2 mousePos = u_mouse_position;
    vec2 resolution = u_resolution;
    
    // Convert normalized coordinates to pixel space
    // SpriteKit's v_tex_coord goes from (0,0) at bottom-left to (1,1) at top-right
    vec2 pixelCoord = coord * resolution;
    vec2 mousePixel = mousePos * resolution;
    
    // Calculate distance from current pixel to mouse position
    float distanceFromMouse = length(pixelCoord - mousePixel);
    
    // Early exit if pixel is outside the grid radius to improve performance
    if (distanceFromMouse > gridRadius) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }
    
    // Calculate grid coordinates by dividing pixel position by grid cell size
    vec2 gridCoord = pixelCoord / gridSize;
    vec2 gridFract = fract(gridCoord);
    
    // Define line thickness as a fraction of cell size
    float lineThickness = 0.05;
    float gridLine = 0.0;
    
    // Check if we're on a grid line (vertical or horizontal)
    // Use step functions for better performance than conditionals
    float verticalLine = step(gridFract.x, lineThickness) + step(1.0 - lineThickness, gridFract.x);
    float horizontalLine = step(gridFract.y, lineThickness) + step(1.0 - lineThickness, gridFract.y);
    
    // Combine vertical and horizontal lines, clamping to avoid overdraw
    gridLine = clamp(verticalLine + horizontalLine, 0.0, 1.0);
    
    // Calculate smooth fade-out based on distance from mouse
    // Use smoothstep for better visual quality
    float fadeOut = 1.0 - smoothstep(0.0, gridRadius, distanceFromMouse);
    
    // Calculate final alpha value
    float alpha = gridLine * fadeOut * 0.6; // 0.6 for semi-transparency
    
    // Output white grid lines with calculated alpha
    gl_FragColor = vec4(1.0, 1.0, 1.0, alpha);
}