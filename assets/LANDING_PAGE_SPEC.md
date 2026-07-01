# Landing Page Hero Image Specification

## Image: "Patrol" Title Screen
**File**: `assets/landing_hero.png`

### Dimensions
- **Size**: 1920x1080px (16:9 aspect ratio)
- **Output**: PNG with optional transparency
- **Mobile crop**: Center-weighted for 9:16 portrait

### Visual Composition

#### Layout
```
┌─────────────────────────────────────────┐
│                                         │
│         [Silhouetted Patrol Scene]      │
│                                         │
│                                         │
│              ╔═══════════╗              │
│              ║  PATROL   ║              │
│              ╚═══════════╝              │
│                                         │
│       Character Generation System       │
│                                         │
│         [Start Mission Button]          │
│                                         │
└─────────────────────────────────────────┘
```

#### Elements

**Background Layer**:
- Desert/mountain landscape silhouette
- Sunset/dawn gradient (orange-tan sky)
- Color: `#D4A574` (tan) to `#4A5D3E` (OD green)

**Middle Layer** (Silhouettes):
- 4-5 soldiers in tactical gear
- Patrol formation (staggered line)
- Backlit silhouettes (black `#1A1A1A`)
- Weapons visible (rifles on shoulders)
- Positioned lower-third of frame

**Title Treatment**:
- Text: "PATROL"
- Font: Bold military stencil style (Impact/Stencil)
- Size: 180px height
- Color: `#2B2B2B` (black) with tan outline `#B8956A`
- Drop shadow: 4px offset, 50% opacity
- Position: Center, slightly above middle

**Subtitle**:
- Text: "Character Generation System"
- Font: Sans-serif, uppercase
- Size: 36px
- Color: `#4A5D3E` (OD green)
- Position: Below title, centered

**Border/Frame** (Optional):
- Military field manual style border
- Corners: Simple right angles
- Width: 8px
- Color: `#2B2B2B`
- Inset: 20px from edges

### Color Palette
```
Sky/Background:     #D4A574 → #B8956A (gradient)
Ground/Shadow:      #4A5D3E
Silhouettes:        #1A1A1A
Title Text:         #2B2B2B
Title Outline:      #B8956A
Subtitle:           #4A5D3E
Accent:             #353F2D
```

### Style Treatment (1980s Acrylic)

1. **Find Edges**: Apply to entire composition (30% opacity)
2. **Canvas Texture**: 25% opacity overlay
3. **Color Grading**: +10 warmth, -20 saturation
4. **Grain**: 2% noise for photocopied manual aesthetic
5. **Vignette**: Subtle darkening at edges (15% opacity)

### Creation Steps

#### Option A: Digital Illustration
1. Create gradient background (tan to green)
2. Add mountain/terrain silhouette at bottom
3. Add 4-5 soldier silhouettes in patrol formation
4. Add title text with stencil font
5. Apply canvas texture overlay
6. Add grain/noise filter
7. Apply find edges effect (low opacity)
8. Export PNG 1920x1080

#### Option B: Photo Composite
1. Find military patrol photo (desert/mountain setting)
2. Convert to high-contrast silhouette
3. Add gradient sky background
4. Overlay canvas texture
5. Add title text treatment
6. Apply vintage filters
7. Export PNG 1920x1080

### Asset Variations

**Full Resolution** (Desktop):
- `assets/landing_hero.png` - 1920x1080px

**Mobile** (Portrait):
- `assets/landing_hero_mobile.png` - 1080x1920px
- Vertical composition, soldiers at bottom

**Icon/Logo** (Optional):
- `assets/patrol_logo.png` - 512x512px
- Just title treatment on transparent background

---

## Implementation in Auth Screen

### Layout
```dart
Stack(
  children: [
    // Hero image background
    Positioned.fill(
      child: Image.asset(
        'assets/landing_hero.png',
        fit: BoxFit.cover,
      ),
    ),
    
    // Dark overlay for readability
    Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
      ),
    ),
    
    // Auth form in center
    Center(
      child: Card(
        margin: EdgeInsets.all(24),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: AuthForm(), // Email/password fields
        ),
      ),
    ),
  ],
)
```

### Responsive Design
- Desktop: Full hero image background
- Tablet: Cropped hero, focus on title
- Mobile: Mobile variant (portrait), smaller card

---

## Quick Placeholder (For Development)

If creating full hero image takes time, use this simple placeholder:

**Solid Color Background**:
- Color: `#4A5D3E` (OD Green)
- Add title text: "PATROL" in white
- Add subtitle: "Character Generation" in tan
- Canvas texture overlay (30%)

**SVG Text Treatment** (Inline):
```xml
<svg viewBox="0 0 400 200">
  <text x="50%" y="45%" text-anchor="middle" 
        font-family="Impact" font-size="72" 
        fill="#2B2B2B" stroke="#B8956A" stroke-width="2">
    PATROL
  </text>
  <text x="50%" y="65%" text-anchor="middle" 
        font-family="Arial" font-size="18" 
        fill="#F7F3EE">
    CHARACTER GENERATION SYSTEM
  </text>
</svg>
```

---

## Testing Checklist

- [ ] Hero image loads correctly on auth screen
- [ ] Text remains readable over image
- [ ] Responsive on mobile (portrait orientation)
- [ ] Canvas texture visible
- [ ] Colors match military palette
- [ ] Title clearly legible
- [ ] File size under 500KB (optimize if needed)
- [ ] Loads quickly (under 1 second)

---

Last Updated: December 2, 2025
