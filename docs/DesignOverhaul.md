# Winnie Design Overhaul

Complete visual refresh mirroring **Wispr Flow** aesthetic: rhythm, presence, and clarity.

---

## New Color Palette

| Color | Hex | Role |
|-------|-----|------|
| **Sweet Salmon** | `#FFA099` | Primary accent (buttons) |
| **Pine Teal** | `#034F46` | Secondary accent (cards, large areas) |
| **Golden Orange** | `#F0A202` | Tertiary accent (highlights, icons) |
| **Carbon Black** | `#1A1A1A` | Text (replaces Ink) |
| **Ivory** | `#FFFFEB` | Background (replaces Snow) |

---

## Design Principles (from Wispr Flow)

- **Rhythm, presence, clarity** - emotionally resonant, not flat minimalism
- **Generous spacing** - soft corners, gentle curves, breathing room
- **Warm neutrals** - Ivory base with soft contrast (not clinical grays)
- **Thick bordered buttons** - prominent CTAs with strong definition
- **Subtle accents** - Sweet Salmon/Pine Teal evoke calm vitality

---

## Typography Update

| Purpose | Current | New |
|---------|---------|-----|
| Headlines/Display | Playfair Display | **EB Garamond** (serif) |
| Body/UI | Lato | **Figtree** (sans-serif) |

> [!NOTE]
> Both fonts are Google Fonts with excellent iOS/SwiftUI support.

---

## Proposed Changes

### Core Design System

#### WinnieColors.swift

**Replace core colors:**
```diff
- static let ink = Color(red: 19/255, green: 23/255, blue: 24/255)
+ static let carbonBlack = Color(hex: "1A1A1A")

- static let snow = Color(red: 255/255, green: 252/255, blue: 255/255)
+ static let ivory = Color(hex: "FFFFEB")
```

**Add new accents:**
```swift
static let sweetSalmon = Color(hex: "FFA099")  // Primary buttons
static let pineTeal = Color(hex: "034F46")     // Cards
static let goldenOrange = Color(hex: "F0A202") // Tertiary
```

**Update theme functions for new palette.**

---

#### WinnieButton.swift

**New button style:**
- **Primary**: Sweet Salmon fill + 3px Carbon Black border
- **Secondary**: Transparent + 3px Carbon Black border
- All buttons get thick black borders (per reference image)

---

#### WinnieTypography.swift

**Update font families:**
- Headlines: Playfair Display → **EB Garamond**
- Body: Lato → **Figtree**

---

### Documentation

- Update `ColorPalette.md`
- Update `DesignSystem.md`

---

## Key Decisions

> [!IMPORTANT]
> **Card Backgrounds**: Pine Teal (`#034F46`) will be used for cards in both light/dark modes. Text on cards will be Ivory for contrast.

> [!WARNING]
> **Breaking Visual Change**: This replaces the entire purple/cream color scheme with a warm coral/teal palette. Typography changes from Playfair/Lato to EB Garamond/Figtree.

---

## Verification Plan

### Build
```bash
xcodebuild -project Winnie.xcodeproj -scheme Winnie -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

### Manual Review
1. Run app in Simulator - verify all screens render correctly
2. Check button appearance (thick borders, Sweet Salmon fills)
3. Verify Pine Teal card backgrounds with Ivory text
4. Test both light and dark modes
5. Review typography with new fonts

---

*Design Overhaul Plan - January 2026*
