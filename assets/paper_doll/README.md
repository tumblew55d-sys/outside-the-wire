# Paper Doll Asset Pipeline Guide

## Overview
This directory contains layered image assets for the character paper doll visualization system in Screen F (Appearance).

## 1980s Acrylic Art Style - Filter Processing Workflow

### Recommended: Option B - Filter Macro Approach

**Step 1: Source Image Acquisition**
- Start with high-quality photo-realistic military gear images
- Examples: tactical vests, helmets, rucksacks, weapons
- Resolution: 1024x1024px minimum for detail preservation

**Step 2: Filter Processing (Photoshop/GIMP)**
Create a reusable filter macro with these layers:

1. **Bold Edges**
   - Apply: Filter → Stylize → Find Edges
   - Blend mode: Multiply (50% opacity)
   - Creates strong outlines

2. **Gritty Contrast**
   - Curves adjustment: S-curve to boost midtones
   - Increase contrast: +40-60%
   - Slight desaturation: -10 to -20%

3. **Canvas Texture Overlay**
   - Add canvas texture from texture library
   - Blend mode: Overlay (30-40% opacity)
   - Scale to match image resolution

4. **Color Grading**
   - Slight warm tint (+5 yellow/red)
   - Reduce blues slightly for vintage feel
   - Add vignette (subtle, 10% opacity)

5. **Paint Stroke Effect** (Optional)
   - Filter → Artistic → Paint Daubs
   - Brush size: 3-5
   - Sharpness: 5-7

**Step 3: Export Settings**
- Format: PNG with transparency
- Color profile: sRGB
- Bit depth: 32-bit (RGBA)
- Resolution: 512x512px final (downsample after filtering)

## Directory Structure

```
paper_doll/
├── base/
│   ├── figure_base.png          # Base human figure silhouette
│   ├── figure_variants/          # Different builds (slim, muscular, etc.)
│   
├── head/
│   ├── helmets/
│   │   ├── kevlar_standard.png
│   │   ├── helmet_nvg_mount.png
│   ├── faces/                    # Optional face variants
│   
├── torso/
│   ├── vests/
│   │   ├── load_bearing_vest.png
│   │   ├── plate_carrier.png
│   ├── jackets/
│   │   ├── combat_jacket.png
│   
├── hands/
│   ├── gloves_tactical.png
│   
├── back/
│   ├── rucksack_standard.png
│   ├── day_pack.png
│   ├── backpack_radio.png
│   
├── equipment/
│   ├── nvg_mounted.png
│   ├── radio_antenna.png
│   ├── thor_jammer.png
│   
├── weapons/
│   ├── rifles/
│   │   ├── m4_carbine.png       # 50+ weapon variants
│   │   ├── m16a4.png
│   │   ├── m249_saw.png
│   ├── pistols/
│   │   ├── m9_holstered.png
│   │   ├── glock17_holstered.png
│   ├── heavy/
│   │   ├── m240_mg.png
│   │   ├── law_launcher.png
│   
└── README.md                     # This file
```

## Asset Naming Convention
- Use snake_case for all filenames
- Format: `{category}_{variant}_{optional_detail}.png`
- Examples:
  - `kevlar_standard.png`
  - `m4_carbine_suppressed.png`
  - `plate_carrier_desert.png`

## Z-Index Layering Order (Back to Front)
1. Base figure
2. Rucksack/backpack
3. Torso/vest
4. Weapons (slung on back)
5. Helmet
6. Face equipment (NVG)
7. Weapons (handheld/front)

## Color Palette (Military Gear)
- OD Green: #4A5D3E
- Tan/Desert: #B8956A
- Black: #2B2B2B
- Gray: #6B6B6B
- Camo variants as needed

## Implementation Notes
- All assets should have transparent backgrounds
- Maintain consistent lighting angle (45° from top-left)
- Shadow layer can be added programmatically
- Each asset should be self-contained (no dependencies)

## Priority Assets to Create First
1. Base figure (1 asset)
2. Kevlar helmet (1 asset)
3. Standard vest (1 asset)
4. M4 Carbine (1 asset)
5. Rucksack (1 asset)

These 5 assets will demonstrate the full system with basic equipment visualization.

## Filter Macro Template (Photoshop Action)
Save this as "Military_Gear_1980s_Style.atn":
1. Duplicate layer
2. Find Edges → Multiply 50%
3. Curves: S-curve preset
4. Hue/Saturation: -15 saturation
5. Canvas texture overlay (30%)
6. Vignette (subtle)
7. Flatten and export PNG

## Testing
- Test each asset in the Flutter app before batch processing
- Verify transparency is preserved
- Check z-index ordering with multiple layers
- Validate at different screen sizes

---
Last updated: December 2, 2025
