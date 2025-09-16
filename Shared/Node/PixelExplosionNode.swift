//
//  PixelExplosionNode.swift
//  RushDefense iOS
//
//  Creates a pixel explosion effect where each pixel moves away from center
//  and then accelerates downward like a firework
//

import SpriteKit

class PixelExplosionNode: SKSpriteNode {
    private var explosionShader: SKShader
    private var startTime: CFTimeInterval = 0
    private let explosionDuration: Float = 3.0
    private let initialVelocity: Float = 200.0
    private let gravity: Float = 400.0
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        // Create the shader with fragment shader code
        explosionShader = SKShader(source: PixelExplosionNode.fragmentShaderSource)
        
        super.init(texture: texture, color: color, size: size)
        
        // Apply the shader
        self.shader = explosionShader
        
        // Set initial shader uniforms
        explosionShader.uniforms = [
            SKUniform(name: "u_time", float: 0.0),
            SKUniform(name: "u_duration", float: explosionDuration),
            SKUniform(name: "u_initial_velocity", float: initialVelocity),
            SKUniform(name: "u_gravity", float: gravity),
            SKUniform(name: "u_resolution", vectorFloat2: vector_float2(Float(size.width), Float(size.height)))
        ]
        
        self.zPosition = 50
        self.blendMode = .alpha
    }
    
    convenience init(texture: SKTexture) {
        let size = texture.size()
        self.init(texture: texture, color: .clear, size: size)
    }
    
    convenience init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        texture.filteringMode = .nearest
        self.init(texture: texture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Starts the explosion animation
    func explode() {
        startTime = CACurrentMediaTime()
        
        // Create an action to update the shader time uniform
        let updateAction = SKAction.customAction(withDuration: TimeInterval(explosionDuration)) { [weak self] node, elapsedTime in
            guard let self = self else { return }
            
            let currentTime = Float(elapsedTime)
            if let uniform = self.explosionShader.uniforms.first(where: { $0.name == "u_time" }) {
                uniform.floatValue = currentTime
            }
        }
        
        // Remove the node after animation completes
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([updateAction, removeAction])
        
        run(sequence)
    }
    
    /// Adjusts the explosion parameters
    func setExplosionParameters(duration: Float = 3.0, velocity: Float = 200.0, gravity: Float = 400.0) {
        if let uniform = explosionShader.uniforms.first(where: { $0.name == "u_duration" }) {
            uniform.floatValue = duration
        }
        if let uniform = explosionShader.uniforms.first(where: { $0.name == "u_initial_velocity" }) {
            uniform.floatValue = velocity
        }
        if let uniform = explosionShader.uniforms.first(where: { $0.name == "u_gravity" }) {
            uniform.floatValue = gravity
        }
    }
    
    // MARK: - Shader Source
    
    private static let fragmentShaderSource = """
    void main() {
        // Get current fragment position and texture coordinate
        vec2 coord = v_tex_coord;
        vec4 originalColor = texture2D(u_texture, coord);
        
        // Early exit if pixel is transparent
        if (originalColor.a < 0.01) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
            return;
        }
        
        // Get uniforms
        float time = u_time;
        float duration = u_duration;
        float initialVelocity = u_initial_velocity;
        float gravity = u_gravity;
        vec2 resolution = u_resolution;
        
        // Calculate center of texture
        vec2 center = vec2(0.5, 0.5);
        
        // Calculate direction from center to current pixel
        vec2 direction = coord - center;
        float distance = length(direction);
        
        // Normalize direction (handle center pixel case)
        if (distance > 0.0) {
            direction = direction / distance;
        } else {
            direction = vec2(0.0, 1.0); // Default upward direction for center pixel
        }
        
        // Add some randomness based on pixel position
        float seed = dot(coord, vec2(12.9898, 78.233));
        float random = fract(sin(seed) * 43758.5453);
        
        // Vary initial velocity slightly for each pixel
        float pixelVelocity = initialVelocity * (0.8 + 0.4 * random);
        
        // Add some random angular spread
        float angleVariation = (random - 0.5) * 0.5; // ±0.25 radians
        float cosA = cos(angleVariation);
        float sinA = sin(angleVariation);
        vec2 rotatedDirection = vec2(
            direction.x * cosA - direction.y * sinA,
            direction.x * sinA + direction.y * cosA
        );
        
        // Physics calculation: position = initial + velocity*t + 0.5*acceleration*t²
        vec2 velocity = rotatedDirection * pixelVelocity;
        vec2 acceleration = vec2(0.0, -gravity); // Gravity pulls down
        
        // Calculate displacement over time
        vec2 displacement = velocity * time + 0.5 * acceleration * time * time;
        
        // Scale displacement based on resolution to maintain consistent speed
        displacement = displacement / resolution;
        
        // Calculate new position
        vec2 newCoord = coord + displacement;
        
        // Fade out over time
        float alpha = 1.0 - (time / duration);
        alpha = max(0.0, alpha);
        
        // Add some sparkle effect - fade becomes more dramatic towards the end
        float sparkle = 1.0 - smoothstep(0.7, 1.0, time / duration);
        alpha *= sparkle;
        
        // Check if new position is within bounds
        if (newCoord.x < 0.0 || newCoord.x > 1.0 || newCoord.y < 0.0 || newCoord.y > 1.0) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
            return;
        }
        
        // Output the color with modified alpha
        gl_FragColor = vec4(originalColor.rgb, originalColor.a * alpha);
    }
    """
}