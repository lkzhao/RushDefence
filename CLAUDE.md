# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RushDefense is a tower defense iOS game built with SpriteKit and GameplayKit using Swift. The project follows an Entity-Component-System (ECS) architecture with a shared codebase that could potentially support multiple platforms.

## Build Commands

- **Build**: Open `RushDefense.xcodeproj` in Xcode and build normally (⌘+B)
- **Run**: Use Xcode's run command (⌘+R) to launch the iOS simulator
- **Debug**: Xcode's built-in debugger; the game shows FPS and node count by default

## Architecture

### Core Framework
- `EntityScene`: Custom SKScene that manages NodeEntity updates with delta time
- `NodeEntity`: Base entity class extending GKEntity with SKNode integration
- `EntityType`: Bitmask-based typing system for entity categorization

### Entity System
All game entities inherit from `NodeEntity` and use component composition:
- **Altar**: Player's defensive structure
- **Portal**: Enemy spawn point with spawning logic
- **Worker**: Player-controlled unit that follows touch/click input
- **Enemy**: AI-controlled opponents with pathfinding
- **Projectile**: Attack projectiles fired between entities

### Component Architecture
Components provide modular functionality:
- **MoveComponent**: Position, velocity, and target-based movement
- **HealthComponent**: Health management with damage/healing
- **AttackComponent**: Combat system with cooldowns and targeting
- **SpriteComponent**: Visual representation and animations
- **ProjectileComponent**: Projectile physics and collision
- **TrailComponent**: Visual trail effects
- **SteeringBehavior**: AI movement behaviors (seek, avoid, wander)

### Input Handling
- **iOS**: Touch-based movement where Worker follows finger location
- **macOS**: Mouse-based movement (partially commented out)

### Visual System
- Uses SpriteKit with texture atlases in `Assets.xcassets`
- Animation sequences for character states (walk, death, idle)
- Map system with tilesets for background terrain

## Dependencies

- **BaseToolbox**: External Swift package for utility functions
- **SpriteKit**: Apple's 2D game framework
- **GameplayKit**: AI and gameplay systems
- **UIKit**: iOS interface framework

## Development Notes

- The project exports `@_exported import BaseToolbox` making BaseToolbox utilities globally available
- Game scene size is fixed at 640x360 points
- Touch handling is continuous (both touchesEnded and touchesMoved)
- Pathfinding code exists but is currently commented out
- Entity collision uses simple radius-based detection