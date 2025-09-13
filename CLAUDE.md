# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RushDefense is a tower defense iOS game built with SpriteKit using Swift. The project follows an Entity-Component-System (ECS) architecture.

#### Build Project
```bash
# Build for iOS Simulator (iPhone 16)
xcodebuild -scheme "RushDefense iOS" -configuration Debug -destination "platform=iOS Simulator,name=iPhone 16" build
```

#### Test Commands
```bash
xcodebuild test -scheme "RushDefense iOS" -destination "platform=iOS Simulator,name=iPhone 16"
```