# PDF Equipment Checklist Readability Guide

## What You'll See in the PDF

When you export a character to PDF, **Section VI: EQUIPMENT / LOADOUT CHECKLIST** will appear as follows:

---

### Visual Layout Example

```
┌─────────────────────────────────────────────────────────────┐
│ VI. EQUIPMENT / LOADOUT CHECKLIST                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ ┌───────────┐                                               │
│ │ HEAD/EYES │                                               │
│ └───────────┘                                               │
│ ☑ Night Vision Goggles    ☐ Helmet    ☐ Goggles           │
│                                                              │
│ ┌──────────┐                                                │
│ │ CLOTHING │                                                │
│ └──────────┘                                                │
│ ☐ Combat uniform    ☐ Combat jacket    ☐ Boots            │
│ ☐ Gloves    ☐ Cold weather gear                            │
│                                                              │
│ ┌──────────┐                                                │
│ │ GRENADES │                                                │
│ └──────────┘                                                │
│ ☑ Frag grenade    ☑ Smoke grenade    ☑ Flashbang grenade  │
│ ☐ Gas grenade    ☐ Concussion grenade                      │
│                                                              │
│ ┌───────┐                                                   │
│ │ COMMS │                                                   │
│ └───────┘                                                   │
│ ☑ Inter Squad Radio    ☐ GPS    ☐ Compass                 │
│ ☑ Red star cluster signal flare    ☐ Flashlight           │
│                                                              │
│ ┌─────────┐                                                 │
│ │ WEAPONS │  ← YOUR SELECTED WEAPONS APPEAR HERE            │
│ └─────────┘                                                 │
│ ☑ L85A2 Rifle              (loadout weapon)                │
│ ☑ KBAR                      (loadout weapon)                │
│ ☑ Browning HP Pistol       (custom weapon)                 │
│ ☑ L115A3 Sniper Rifle      (custom weapon)                 │
│                                                              │
│ ┌───────┐                                                   │
│ │ TOOLS │                                                   │
│ └───────┘                                                   │
│ ☑ Hand held mine detector    ☐ Multi-tool                  │
│ ☐ Binoculars    ☐ Combat knife                             │
│                                                              │
│ ┌─────────┐                                                 │
│ │ DAYPACK │                                                 │
│ └─────────┘                                                 │
│ ☑ Unit 1 Medical Kit    ☐ Day patrol pack                  │
│ ☐ Water canteen    ☐ MRE                                    │
│                                                              │
│ ┌──────────────┐                                            │
│ │ LOAD BEARING │                                            │
│ └──────────────┘                                            │
│ ☐ Load bearing vest    ☐ Magazine pouches                  │
│ ☐ Utility pouch                                             │
│                                                              │
│ ┌───────────┐  ┌────────────────┐                          │
│ │ADDITIONAL │  │ HEALTH/MEDICAL │                          │
│ ├───────────┤  ├────────────────┤                          │
│ │☐ ________ │  │☐ _____________ │                          │
│ └───────────┘  └────────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Readability Features

### ✓ Clear Visual Hierarchy
- **10pt bold** section header: "VI. EQUIPMENT / LOADOUT CHECKLIST"
- **8pt bold** category labels with grey background
- **7pt** item text

### ✓ Checkbox Indicators
- **☑** = Item is selected/owned
- **☐** = Item is available but not selected

### ✓ Smart Categorization
Your selections automatically appear in the right category:

| Your Selection | Appears In |
|---------------|------------|
| Night Vision Goggles | HEAD/EYES |
| Frag grenade | GRENADES |
| Smoke grenade | GRENADES |
| Flashbang grenade | GRENADES |
| Inter Squad Radio | COMMS |
| Hand held mine detector | TOOLS |
| Unit 1 Medical Kit | DAYPACK |
| L85A2 Rifle | WEAPONS |
| Browning HP Pistol | WEAPONS |

---

## What Changed (Technical)

### Before Fix ❌
```
WEAPONS
  ☐ Rifle
  ☐ Pistol
  ☐ Knife
```
*Generic placeholders - your actual weapons didn't appear*

### After Fix ✅
```
WEAPONS
  ☑ L85A2 Rifle              ← Your loadout weapon
  ☑ KBAR                      ← Your loadout weapon
  ☑ Browning HP Pistol       ← Your custom weapon
  ☑ L115A3 Sniper Rifle      ← Your custom weapon
```
*Your actual selections with checkmarks*

---

## Font & Spacing

### Section Header
```css
Font: Helvetica-Bold
Size: 10pt
Letter-spacing: 0.5
Weight: Bold
```

### Category Headers
```css
Font: Helvetica-Bold
Size: 8pt
Background: Grey (#E0E0E0)
Padding: 4px horizontal, 2px vertical
Weight: Bold
```

### Item Text
```css
Font: Helvetica
Size: 7pt
Color: Black
Spacing: 8px between items, 3px between rows
```

### Checkboxes
```css
Size: 8px × 8px
Border: 1px solid black
Checked: Black fill with white checkmark
Unchecked: Empty white box
```

---

## Complete Example Output

**Character:** Test Soldier Wilson (UK Army Rifleman)

**Selected:**
- Loadout: L85A2 Rifle, KBAR
- Custom: Browning HP Pistol, L115A3 Sniper Rifle  
- Equipment: Night Vision Goggles, 3× grenades, Radio, Medical Kit, Mine Detector

**PDF Section VI Renders As:**

```
VI. EQUIPMENT / LOADOUT CHECKLIST

HEAD/EYES
  ☑ Night Vision Goggles  ☐ Helmet  ☐ Kevlar helmet  ☐ Goggles  ☐ Sunglasses

CLOTHING
  ☐ Combat uniform  ☐ Combat jacket  ☐ Boots  ☐ Gloves  ☐ Cold weather gear

GRENADES
  ☑ Frag grenade  ☑ Smoke grenade  ☐ CS grenade  ☑ Flashbang grenade  
  ☐ Stun grenade  ☐ Gas grenade  ☐ Concussion grenade  ☐ Thermite grenade

COMMS
  ☐ Radio  ☐ GPS  ☐ Compass  ☐ Flashlight  ☐ Signal flares  
  ☐ Red star cluster signal flare  ☐ Illumination signal flare  
  ☐ Green start cluster signal flare  ☑ Inter Squad Radio  
  ☐ Backpack Radio  ☐ Hand held walkie talkie

WEAPONS
  ☑ L85A2 Rifle
  ☑ KBAR
  ☑ Browning HP Pistol
  ☑ L115A3 Sniper Rifle

TOOLS
  ☐ Combat knife  ☐ Multi-tool  ☐ Wire cutters  ☐ Binoculars  
  ☐ Entrenching tool  ☑ Hand held mine detector  ☐ EOD demo kit  
  ☐ EOD robot and computer  ☐ Breacher Kit  ☐ JTAC computer and radio  
  ☐ Civil Affairs Kit  ☐ Signal Collection Kit  ☐ Spy Kit  ☐ Canine Kit

DAYPACK
  ☐ Day patrol pack  ☐ Personal medical kit  ☐ Water canteen  
  ☐ MRE  ☐ Poncho  ☑ Unit 1 Medical Kit

LOAD BEARING
  ☐ Load bearing vest  ☐ Magazine pouches  ☐ First aid pouch  
  ☐ Grenade pouch  ☐ Utility pouch

┌───────────┐  ┌────────────────┐
│ADDITIONAL │  │ HEALTH/MEDICAL │
│☐_________ │  │☐______________ │
└───────────┘  └────────────────┘
```

---

## Verification Checklist

Use this checklist to verify your PDF is correct:

- [ ] Section VI appears on the character sheet
- [ ] All 8 equipment categories are visible
- [ ] Your selected weapons appear in WEAPONS section with ☑
- [ ] Your selected equipment appears in appropriate categories with ☑
- [ ] Unselected items show as ☐
- [ ] Text is readable (7-10pt fonts)
- [ ] Checkboxes are clear and distinguishable
- [ ] Layout is clean with proper spacing
- [ ] No missing items from your selections

---

## Known Limitations

### Font Warnings (Safe to Ignore)
You may see these console warnings:
```
Helvetica-Bold has no Unicode support
Unable to find a font to draw "—" (U+2014)
```
**Impact:** None - all standard equipment text displays correctly

### Default Items
Some base inventory items are always shown (even if not explicitly selected):
- Combat uniform
- Helmet  
- Day patrol pack
- Load bearing vest

These are standard issue and appear as ☐ unless you explicitly select them.

---

## Troubleshooting

### "My weapons don't appear"
**Check:**
1. Did you click the weapon chips to select them? (They should turn amber/blue)
2. Did you click "Next: Review" to save?
3. Wait for "✓ Inventory & equipment saved" confirmation

### "Equipment missing from categories"
**Check:**
1. Are the FilterChips highlighted when selected?
2. Did you save before generating PDF?
3. Check the category - equipment auto-categorizes by type

### "PDF is blank/incomplete"
**Solution:**
1. Go back to Inventory screen
2. Re-select your equipment
3. Click "Save Character" on Final Review
4. Then export PDF

---

## PDF Print Quality

- **Screen (72 DPI):** All text clearly readable
- **Print (300 DPI):** Professional quality, suitable for game use
- **Font Size:** 7pt minimum = ~2.5mm height (easily readable)
- **Checkbox Size:** 8×8 px = ~2.8mm squares (easy to mark with pen)

---

**Questions?** The equipment checklist should now show all your selections with checkmarks. If anything looks wrong, please report the specific missing item and category.
