# Priority Asset Creation Guide - 1980s Military Acrylic Style

## Visual Theme: 1980s Military Field Manual Illustrations
**Reference Style**: Acrylic paintings from US Army field manuals (1980-1990)
- Bold outlines, flat lighting
- Muted military colors (OD Green, Desert Tan, Black)
- Canvas texture visible
- Slight grain/noise for photocopied manual aesthetic

---

## Priority Asset #1: Figure Base
**File**: `assets/paper_doll/base/figure_base.png`

### Specifications
- **Dimensions**: 512x512px
- **Output**: PNG with alpha transparency
- **Canvas Position**: Centered, figure height ~450px
- **Pose**: Standing at attention, arms slightly out from body

### Color Palette
- Skin tone (neutral): `#D4A574`
- Shadow areas: `#B88D5F`
- Highlights: `#E8C09A`

### Creation Steps
1. **Sketch outline**: Simple human figure silhouette, military stance
2. **Apply Find Edges filter** (50% opacity, Multiply blend)
3. **Add S-curve contrast**: Boost midtones +50%, blacks +30%
4. **Canvas texture overlay** (30% opacity)
5. **Color grading**: +5 warmth, -15 saturation
6. **Export**: PNG 512x512px with transparency

### Layer Details
- Head: 64px diameter circle
- Torso: 180px height, 120px width rectangle
- Arms: 160px length, 40px width
- Legs: 200px length, 50px width
- Keep proportions blocky/simplified for military manual style

---

## Priority Asset #2: Kevlar Helmet (Standard)
**File**: `assets/paper_doll/head/helmets/kevlar_standard.png`

### Specifications
- **Dimensions**: 512x512px
- **Output**: PNG with alpha transparency
- **Position**: Top 100px of canvas, centered
- **Size**: 140px wide x 100px tall

### Color Palette
- Base color (OD Green): `#4A5D3E`
- Shadow: `#353F2D`
- Highlight edge: `#5C7049`
- Chin strap: `#2B2B2B`

### Creation Steps
1. **Source image**: Find photo of PASGT helmet (1980s style)
2. **Desaturate** to grayscale first
3. **Find Edges filter** (60% opacity, black outlines)
4. **Colorize**: Apply OD Green base `#4A5D3E`
5. **S-curve contrast**: +60% midtone boost
6. **Canvas texture**: 40% opacity overlay
7. **Paint Daubs filter**: Brush size 4, sharpness 6
8. **Add chin strap**: Black line at bottom
9. **Export**: PNG 512x512px

### Key Features
- Prominent bold outline around helmet edge
- Visible canvas texture for vintage feel
- Flat lighting (no complex gradients)
- Slightly asymmetric for hand-drawn effect

---

## Priority Asset #3: Load Bearing Vest
**File**: `assets/paper_doll/torso/vests/load_bearing_vest.png`

### Specifications
- **Dimensions**: 512x512px
- **Output**: PNG with alpha transparency
- **Position**: Center, torso area (Y: 120-320px)
- **Size**: 180px wide x 200px tall

### Color Palette
- Vest body (Tan): `#B8956A`
- Webbing (OD Green): `#4A5D3E`
- Pouches/pockets (Dark Tan): `#9A7A50`
- Buckles/metal: `#6B6B6B`

### Creation Steps
1. **Source image**: ALICE vest or MOLLE vest photo
2. **Find Edges filter** (50% opacity)
3. **Base color fill**: Tan `#B8956A`
4. **Add webbing straps**: OD Green rectangles
5. **Pouch rectangles**: 6-8 pouches in grid pattern
6. **S-curve contrast**: +55% midtones
7. **Canvas texture**: 35% opacity
8. **Noise filter**: Add grain (2-3%, monochrome)
9. **Paint Daubs**: Brush 3, sharpness 7
10. **Export**: PNG 512x512px

### Key Features
- Clear rectangular pouch outlines
- Visible shoulder straps
- Bold black outlines on all edges
- Symmetrical front view

---

## Priority Asset #4: M4 Carbine
**File**: `assets/paper_doll/weapons/rifles/m4_carbine.png`

### Specifications
- **Dimensions**: 512x512px
- **Output**: PNG with alpha transparency
- **Position**: Diagonal across torso (top-right to bottom-left)
- **Size**: 380px length x 80px height

### Color Palette
- Rifle body (Black): `#2B2B2B`
- Metal parts (Gray): `#6B6B6B`
- Handguard (Tan/Black): `#9A7A50` or `#2B2B2B`
- Highlights: `#8B8B8B`

### Creation Steps
1. **Source image**: M4 carbine profile view (left side)
2. **Rotate**: 30° diagonal angle
3. **Find Edges filter** (70% opacity for weapon detail)
4. **Colorize**: Black base with gray metal accents
5. **S-curve contrast**: +70% for sharp edges
6. **Canvas texture**: 25% opacity (lighter for metal)
7. **Sharpen filter**: Unsharp mask, amount 80%
8. **Paint Daubs**: Brush 2, sharpness 8 (minimal, keep detail)
9. **Add bold outline**: 2px black stroke around entire weapon
10. **Export**: PNG 512x512px

### Key Features
- Clearly visible barrel, stock, magazine, handguard
- Bold black outline for separation from body
- Sling visible (OD Green strap)
- Simplified trigger/grip area

---

## Priority Asset #5: Rucksack (Standard ALICE)
**File**: `assets/paper_doll/back/rucksack_standard.png`

### Specifications
- **Dimensions**: 512x512px
- **Output**: PNG with alpha transparency
- **Position**: Behind torso (Y: 100-380px), slightly wider than shoulders
- **Size**: 200px wide x 280px tall

### Color Palette
- Main body (OD Green): `#4A5D3E`
- Frame (Black): `#2B2B2B`
- Straps (OD Green): `#3C4D32`
- Buckles: `#6B6B6B`

### Creation Steps
1. **Source image**: ALICE pack (large) rear view
2. **Find Edges filter** (55% opacity)
3. **Base fill**: OD Green `#4A5D3E`
4. **Add frame outline**: Black vertical bars on sides
5. **Strap details**: Shoulder straps visible at top
6. **Pouch details**: 2-3 external pouches (darker green)
7. **S-curve contrast**: +50% midtones
8. **Canvas texture**: 40% opacity (heavy for cloth feel)
9. **Noise filter**: 3% grain
10. **Paint Daubs**: Brush 4, sharpness 6
11. **Slight blur on edges**: 1px Gaussian for depth
12. **Export**: PNG 512x512px

### Key Features
- Rectangular shape with rounded top
- Visible external frame bars (black)
- Shoulder straps extending upward
- Bold outline for separation from body
- Slightly behind body in z-index

---

## General Export Settings (All Assets)

### Photoshop Export
1. File → Export → Export As...
2. Format: PNG
3. Transparency: Checked
4. Convert to sRGB: Checked
5. Dimensions: 512x512px
6. Resample: Bicubic Sharper

### GIMP Export
1. File → Export As
2. Select PNG image
3. Compression level: 9
4. Save background color: Unchecked
5. Save gamma: Unchecked
6. Interlacing: None

---

## Photoshop Action Script (Batch Processing)

```
1. Open source image
2. Resize canvas to 1024x1024 (for detail)
3. Run "Find Edges" filter (Filter → Stylize → Find Edges)
4. Duplicate layer, set to Multiply 50%
5. Merge visible
6. Adjust Curves: Create S-curve (shadows down, highlights up)
7. Hue/Saturation: -15 saturation, 0 hue, 0 lightness
8. Apply canvas texture overlay (30-40% opacity)
9. Filter → Artistic → Paint Daubs (brush 3-4, sharpness 6-7)
10. Add 2% noise (Filter → Noise → Add Noise, monochrome)
11. Resize to 512x512 (Bicubic Sharper)
12. Save as PNG with transparency
```

---

## Quality Checklist

Before finalizing each asset:
- [ ] Bold black outlines visible on all major edges
- [ ] Canvas texture visible but not overwhelming
- [ ] Colors match military palette (OD Green, Tan, Black, Gray)
- [ ] Transparency working (no white background)
- [ ] Asset centered properly in 512x512 canvas
- [ ] File size under 200KB
- [ ] Slight grain/noise visible for vintage effect
- [ ] No complex gradients (flat lighting style)
- [ ] Matches 1980s field manual illustration aesthetic

---

## Testing Process

1. Create asset following guide
2. Place in correct directory (base/, head/helmets/, etc.)
3. Update `pubspec.yaml` with asset path
4. Run `flutter pub get`
5. Test in Screen F (Appearance) paper doll viewer
6. Verify z-index layering order
7. Check scaling at different window sizes
8. Adjust if needed and re-export

---

## Quick Reference: Military Color Codes

```
OD Green:    #4A5D3E (Primary equipment)
Desert Tan:  #B8956A (Vests, pouches)
Black:       #2B2B2B (Weapons, frames)
Gray:        #6B6B6B (Metal, buckles)
Dark Green:  #353F2D (Shadows)
Light Tan:   #E8C09A (Highlights)
```

---

## Next 45 Assets Priority Order

After priority 5 complete, create in this order:
1. Additional helmets (3 variants)
2. Plate carrier vest
3. M16A4, M249 SAW rifles
4. M9 pistol (holstered)
5. NVG goggles
6. Day pack
7. Radio with antenna
8. Additional weapons (20+ variants)
9. Face variants (optional)
10. Equipment items (15+ items)

---

Last Updated: December 2, 2025
