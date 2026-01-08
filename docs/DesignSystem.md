# Winnie Design System
**Wispr Flow-Inspired: Rhythm, Presence, Clarity**

Complete visual specification for AI-assisted development

---

## Design Philosophy

Winnie adopts the Wispr Flow aesthetic—warm, rhythmic, and present. The design transforms potentially stressful money conversations into collaborative, positive experiences for couples.

### Core Principles

- **Rhythm**: Consistent spacing and visual cadence create flow
- **Presence**: Bold colors and thick borders command attention
- **Clarity**: High contrast and clear hierarchy guide the eye
- **Warmth**: Coral and teal tones feel approachable, not clinical

---

## Color System

### Core Palette

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Porcelain** | `#FFFFFB` | Background (light mode) |
| **Ivory** | `#FFFFEB` | Primary text (dark mode), card text |
| **Carbon Black** | `#1A1A1A` | Primary text (light mode), background (dark mode) |
| **Sweet Salmon** | `#FFA099` | Primary accent, buttons, interactive elements |
| **Pine Teal** | `#034F46` | Card backgrounds (both modes), secondary accent |
| **Golden Orange** | `#F0A202` | Tertiary accent, highlights, icons |

### Light Mode

| Element | Color | Notes |
|---------|-------|-------|
| **Background** | Porcelain (`#FFFFFB`) | Main app background |
| **Primary Text** | Carbon Black (`#1A1A1A`) | Headlines, important text |
| **Secondary Text** | Carbon Black at 80% | Body text, descriptions |
| **Tertiary Text** | Carbon Black at 50% | Helper text, captions |
| **Primary Button** | Sweet Salmon + 3px Carbon Black border | Main actions |
| **Primary Button Text** | Carbon Black | |
| **Secondary Button** | Transparent + 3px Carbon Black border | Secondary actions |
| **Card Background** | Pine Teal (`#034F46`) | Strong brand presence |
| **Card Text** | Ivory (`#FFFFEB`) | Always ivory on teal |

### Dark Mode

| Element | Color | Notes |
|---------|-------|-------|
| **Background** | Carbon Black (`#1A1A1A`) | Main app background |
| **Primary Text** | Ivory (`#FFFFEB`) | Headlines, important text |
| **Secondary Text** | Ivory at 80% | Body text, descriptions |
| **Tertiary Text** | Ivory at 50% | Helper text, captions |
| **Primary Button** | Sweet Salmon + 3px Ivory border | Main actions |
| **Primary Button Text** | Carbon Black | |
| **Secondary Button** | Transparent + 3px Ivory border | Secondary actions |
| **Card Background** | Pine Teal (`#034F46`) | Same as light mode |
| **Card Text** | Ivory (`#FFFFEB`) | Always ivory on teal |

### Goal Preset Palette

Users can select a color for each goal from this warm palette:

| Name | Hex Code | Description |
|------|----------|-------------|
| **Coral** | `#FFA099` | Default - Sweet Salmon (warm coral) |
| **Teal** | `#034F46` | Pine Teal (deep forest) |
| **Gold** | `#F0A202` | Golden Orange (bright accent) |
| **Sage** | `#7A9E7E` | Warm muted green |
| **Clay** | `#C4907A` | Terracotta (earthy warm) |
| **Sand** | `#D4C4A8` | Warm beige |
| **Slate** | `#6B8B9B` | Cool blue-gray |
| **Storm** | `#5A5A6B` | Deep neutral gray |

**Usage Notes:**
- New goals default to Coral (`#FFA099`)
- Goal colors appear as left accent borders on cards
- Progress bars use the goal's selected color
- Dark colors (Teal, Storm) use Ivory checkmarks in pickers

### Semantic Colors

| Status | Hex | Usage |
|--------|-----|-------|
| Error | `#DC3545` | Validation errors, error states |
| Success | `#28A745` | On-track goals, success feedback |
| Warning | `#F5A623` | Behind schedule, caution states |

---

## Typography System

### Font Families

| Purpose | Font | Fallback |
|---------|------|----------|
| **Headlines** | EB Garamond (serif) | Playfair Display, Georgia |
| **Body/UI** | Figtree (sans-serif) | Lato, SF Pro |
| **Financial Data** | Figtree with tabular-nums | |

*Note: Until custom fonts are added, the app uses Playfair Display and Lato.*

### Type Scale

| Style | Size | Weight | Font | Usage |
|-------|------|--------|------|-------|
| **Display XL** | 52pt | Regular | Serif | Welcome screens |
| **Display L** | 44pt | Regular | Serif | Major headers |
| **Display M** | 36pt | Medium | Serif | Screen titles |
| **Headline L** | 28pt | Semibold | Serif | Section headers |
| **Headline M** | 22pt | Semibold | Serif | Card titles, goal names |
| **Body L** | 18pt | Regular | Sans | Primary body text |
| **Body M** | 16pt | Regular | Sans | Buttons, form labels |
| **Body S** | 14pt | Regular | Sans | Helper text |
| **Caption** | 12pt | Regular | Sans | Small text, footnotes |
| **Financial XL** | 40pt | Bold | Sans | Hero amounts |
| **Financial L** | 32pt | Bold | Sans | Large amounts |
| **Financial M** | 24pt | Bold | Sans | Card amounts |

---

## UI Components

### Buttons

#### Primary Button (Wispr Flow Style)
- **Shape**: Pill-shaped (`border-radius: 28px`)
- **Height**: 56px minimum
- **Background**: Sweet Salmon (`#FFA099`)
- **Border**: 3px solid (Carbon Black in light, Ivory in dark)
- **Text**: Carbon Black, 16pt Bold
- **Press animation**: Scale to 0.97 with spring

#### Secondary Button
- **Background**: Transparent
- **Border**: 3px solid (Carbon Black in light, Ivory in dark)
- **Text**: Matches border color

#### Text Button
- **Background**: None
- **Border**: None
- **Text**: Sweet Salmon

### Cards

Cards support three background styles via `WinnieCardStyle`:

#### Card Styles

| Style | Light Mode BG | Dark Mode BG | Text Color |
|-------|---------------|--------------|------------|
| `.pineTeal` | Pine Teal | Pine Teal | Ivory |
| `.carbon` | Carbon Black | Carbon Black | Ivory |
| `.ivory` | Ivory | Carbon Black | Adapts |

**Usage:**
```swift
// Pine Teal (default)
WinnieCard {
    Text("Content").cardPrimaryText(for: .pineTeal)
}

// Carbon Black
WinnieCard(style: .carbon) {
    Text("Content").cardPrimaryText(for: .carbon)
}

// Ivory (inverts in dark mode)
WinnieCard(style: .ivory) {
    Text("Content").cardPrimaryText(for: .ivory)
}
```

#### Common Card Properties
- **Border radius**: 20px
- **Padding**: 24px
- **Shadow (light)**: `0 2px 12px rgba(26, 26, 26, 0.08)`
- **Shadow (dark)**: None

#### Goal Cards
- **Base**: Standard card styling (`.pineTeal` by default)
- **Accent border**: 4px left border in goal's selected color
- **Icon background**: Ivory at 20% opacity

### Input Fields

- **Border radius**: 16px
- **Height**: 56px
- **Border**: 1px (unfocused), 2px (focused)
- **Border color**: Carbon Black/Ivory at 30% (unfocused), Sweet Salmon (focused)
- **Background**: Card background color (Pine Teal)

### Progress Bars

- **Height**: 8px
- **Border radius**: 4px
- **Track**:
  - On card: Ivory at 20%
  - On background: Carbon Black/Ivory at 15%
- **Fill**: Goal's selected color

---

## Spacing System (8pt Grid)

| Token | Value | Usage |
|-------|-------|-------|
| **XXS** | 4px | Icon padding |
| **XS** | 8px | Tight spacing |
| **S** | 12px | Small gaps |
| **M** | 16px | Standard spacing |
| **L** | 24px | Card padding, section spacing |
| **XL** | 32px | Major sections |
| **XXL** | 48px | Screen padding |
| **XXXL** | 64px | Hero sections |

### Layout

- **Screen margins**: 24px (mobile)
- **Content max width**: 680px
- **Card spacing**: 16px between cards

---

## Animations

- **Button press**: Scale 0.97, spring (stiffness: 400, damping: 20)
- **Page transitions**: 350ms ease-out
- **Card appearance**: Fade + scale from 0.95, 300ms
- **Number changes**: 600ms counting animation
- **Progress bar**: 400ms ease-out

---

## Implementation

### Design Tokens

All design tokens are defined in:
- `WinnieColors.swift` - All colors including legacy aliases
- `WinnieTypography.swift` - Type scale
- `WinnieSpacing.swift` - Spacing values and component sizes

### Key Components

| Component | File |
|-----------|------|
| Buttons | `WinnieButton.swift` |
| Cards | `WinnieCard.swift` |
| Text Fields | `WinnieTextField.swift` |
| Progress Bars | `WinnieProgressBar.swift` |
| Goal Cards | `GoalCard.swift` |
| Color Picker | `GoalColorPicker.swift` |
| Avatar | `UserInitialsAvatar.swift` |

### Checklist

Before considering a screen complete:

- [ ] Background uses Porcelain (light) / Carbon Black (dark)
- [ ] Cards use appropriate style (`.pineTeal`, `.carbon`, or `.ivory`) with matching text colors
- [ ] Buttons have 3px borders
- [ ] Primary buttons use Sweet Salmon
- [ ] Goal colors use the new warm palette
- [ ] Spacing follows 8pt grid
- [ ] Touch targets are 44pt minimum
- [ ] Both light and dark mode tested

---

*Design System Version 2.0 - January 2026 (Wispr Flow Update)*
