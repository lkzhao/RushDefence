//
//  GridShaderNode.swift
//  RushDefense iOS
//
//  Creates a grid overlay effect in a 100px circle around mouse position with fade-out
//

import SpriteKit

class GridShaderNode: SKSpriteNode {
    private var gridShader: SKShader
    private let gridRadius: Float = 100.0
    private let gridSize: Float = 32.0 // Size of each grid cell in pixels
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        // Create the shader with fragment shader code
        gridShader = SKShader(source: GridShaderNode.fragmentShaderSource)
        
        super.init(texture: texture, color: color, size: size)
        
        // Configure the sprite node
        self.color = .clear
        self.colorBlendFactor = 1.0
        
        // Apply the shader
        self.shader = gridShader
        
        // Set initial shader uniforms
        gridShader.uniforms = [
            SKUniform(name: "u_grid_radius", float: gridRadius),
            SKUniform(name: "u_grid_size", float: gridSize),
            SKUniform(name: "u_mouse_position", vectorFloat2: vector_float2(0, 0)),
            SKUniform(name: "u_resolution", vectorFloat2: vector_float2(Float(size.width), Float(size.height)))
        ]
        
        // Set z-position to render above terrain but below entities
        self.zPosition = 0.5
        self.blendMode = .alpha
    }
    
    convenience init(mapSize: CGSize) {
        self.init(texture: nil, color: .clear, size: mapSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates the mouse position for the grid effect
    /// - Parameter position: Mouse position in local coordinates relative to this node
    func updateMousePosition(_ position: CGPoint) {
        // Convert position to normalized coordinates (0,0 at bottom-left, 1,1 at top-right)
        let normalizedX = Float(position.x / size.width + 0.5)
        let normalizedY = Float(position.y / size.height + 0.5)
        
        // Update the shader uniform
        if let uniform = gridShader.uniforms.first(where: { $0.name == "u_mouse_position" }) {
            uniform.vectorFloat2Value = vector_float2(normalizedX, normalizedY)
        }
    }
    
    /// Sets the visibility of the grid effect
    func setGridVisible(_ visible: Bool) {
        self.alpha = visible ? 1.0 : 0.0
    }
    
    // MARK: - Shader Source
    
    private static let fragmentShaderSource = """
    void main() {
        // Get current fragment position in normalized coordinates (0-1)
        vec2 coord = v_tex_coord;
        
        // Get uniforms
        float gridRadius = u_grid_radius;
        float gridSize = u_grid_size;
        vec2 mousePos = u_mouse_position;
        vec2 resolution = u_resolution;
        
        // Convert normalized coordinates to pixel coordinates
        vec2 pixelCoord = coord * resolution;
        vec2 mousePixel = mousePos * resolution;
        
        // Calculate distance from mouse position
        float distanceFromMouse = length(pixelCoord - mousePixel);
        
        // Early exit if outside radius
        if (distanceFromMouse > gridRadius) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
            return;
        }
        
        // Calculate grid lines
        vec2 gridCoord = pixelCoord / gridSize;
        vec2 gridFract = fract(gridCoord);
        
        // Create grid lines with some thickness
        float lineThickness = 0.05;
        float gridLine = 0.0;
        
        // Vertical lines
        if (gridFract.x < lineThickness || gridFract.x > (1.0 - lineThickness)) {
            gridLine = 1.0;
        }
        
        // Horizontal lines
        if (gridFract.y < lineThickness || gridFract.y > (1.0 - lineThickness)) {
            gridLine = 1.0;
        }
        
        // Calculate fade-out based on distance from mouse
        float fadeOut = 1.0 - (distanceFromMouse / gridRadius);
        fadeOut = smoothstep(0.0, 1.0, fadeOut);
        
        // Apply circular fade-out
        float alpha = gridLine * fadeOut * 0.6; // 0.6 for semi-transparency
        
        // Grid color (white with transparency)
        vec3 gridColor = vec3(1.0, 1.0, 1.0);
        
        gl_FragColor = vec4(gridColor, alpha);
    }
    """
}