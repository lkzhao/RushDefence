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
        // Create the shader from external file for better debugging
        if let shaderPath = Bundle.main.path(forResource: "GridShader", ofType: "fsh"),
           let shaderSource = try? String(contentsOfFile: shaderPath, encoding: .utf8) {
            gridShader = SKShader(source: shaderSource)
        } else {
            // Fallback to embedded shader source if file loading fails
            gridShader = SKShader(source: GridShaderNode.fallbackShaderSource)
            print("Warning: Could not load GridShader.fsh, using fallback shader")
        }
        
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
        // Convert position to normalized coordinates for SpriteKit shader system
        // SpriteKit uses (0,0) at bottom-left, (1,1) at top-right for texture coordinates
        let normalizedX = Float((position.x + size.width * 0.5) / size.width)
        let normalizedY = Float((position.y + size.height * 0.5) / size.height)
        
        // Clamp values to prevent shader artifacts at edges
        let clampedX = max(0.0, min(1.0, normalizedX))
        let clampedY = max(0.0, min(1.0, normalizedY))
        
        // Update the shader uniform
        if let uniform = gridShader.uniforms.first(where: { $0.name == "u_mouse_position" }) {
            uniform.vectorFloat2Value = vector_float2(clampedX, clampedY)
        }
    }
    
    /// Sets the visibility of the grid effect
    func setGridVisible(_ visible: Bool) {
        self.alpha = visible ? 1.0 : 0.0
    }
    
    // MARK: - Fallback Shader Source
    
    private static let fallbackShaderSource = """
    void main() {
        // Simplified fallback shader for when GridShader.fsh cannot be loaded
        vec2 coord = v_tex_coord;
        float gridRadius = u_grid_radius;
        float gridSize = u_grid_size;
        vec2 mousePos = u_mouse_position;
        vec2 resolution = u_resolution;
        
        vec2 pixelCoord = coord * resolution;
        vec2 mousePixel = mousePos * resolution;
        float distanceFromMouse = length(pixelCoord - mousePixel);
        
        if (distanceFromMouse > gridRadius) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
            return;
        }
        
        vec2 gridCoord = pixelCoord / gridSize;
        vec2 gridFract = fract(gridCoord);
        float lineThickness = 0.05;
        
        float verticalLine = step(gridFract.x, lineThickness) + step(1.0 - lineThickness, gridFract.x);
        float horizontalLine = step(gridFract.y, lineThickness) + step(1.0 - lineThickness, gridFract.y);
        float gridLine = clamp(verticalLine + horizontalLine, 0.0, 1.0);
        
        float fadeOut = 1.0 - smoothstep(0.0, gridRadius, distanceFromMouse);
        float alpha = gridLine * fadeOut * 0.6;
        
        gl_FragColor = vec4(1.0, 1.0, 1.0, alpha);
    }
    """
}