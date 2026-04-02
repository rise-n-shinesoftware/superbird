# Superbird Game Assets

This folder contains the visual assets for the Superbird game. To make the game objects more realistic, replace these placeholder files with actual PNG images.

## Required Images:

### Bird Sprites
- `bird.png` - Main bird sprite (32x32 or 64x64 pixels)
- `bird_flap.png` - Bird with wings up (optional animation frame)

### Obstacle Sprites
- `pipe_top.png` - Top pipe obstacle (72x[variable] pixels)
- `pipe_bottom.png` - Bottom pipe obstacle (72x[variable] pixels)

### Power Pickup Sprites
- `power_red.png` - Red burst power pickup (28x28 pixels)
- `power_blue.png` - Blue slowmo power pickup (28x28 pixels)
- `power_green.png` - Green shield power pickup (28x28 pixels)
- `power_yellow.png` - Yellow multiplier power pickup (28x28 pixels)
- `power_purple.png` - Purple blink power pickup (28x28 pixels)
- `power_black.png` - Black phase power pickup (28x28 pixels)

## Creating Realistic/3D-Looking Sprites:

### Design Tips:
1. **Isometric Perspective**: Create sprites with a 3/4 view for depth
2. **Lighting & Shadows**: Add drop shadows and highlights for 3D effect
3. **Textures**: Use subtle textures for realistic materials
4. **Details**: Add small details like feathers, metal textures, glowing effects
5. **Color Depth**: Use gradients and multiple shades for volume

### Bird Sprite Ideas:
- Feathered body with wing details
- Beak and eye highlights
- Subtle shadow underneath
- Wing flap animation frames

### Pipe Obstacle Ideas:
- Metallic or concrete texture
- Rivets, bolts, or pipe connections
- Rust or weathering effects
- Top and bottom caps with different designs

### Power Pickup Ideas:
- Glowing orbs with particle effects
- Suit-colored energy crystals
- Floating animations
- Light rays or auras

### Tools for Creating Sprites:
- **Aseprite** - Pixel art editor
- **Photoshop/GIMP** - General image editing
- **Blender** - 3D modeling for sprite creation
- **Texture Packer** - Sprite sheet creation

## Technical Notes:
- All sprites should have transparent backgrounds (PNG format)
- Sizes are recommendations - adjust component sizes in code if needed
- Sprites are loaded using Flame's Sprite.load() method
- Collision detection uses RectangleHitbox around sprite bounds

Replace the placeholder text files with actual PNG images to see your realistic sprites in the game!
