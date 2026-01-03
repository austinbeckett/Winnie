# Winnie Color Palette

A comprehensive guide to all colors used in the Winnie application, organized by category.

> [!NOTE]
> This color system follows a "Light Mode First" design approach. Colors are defined in [`WinnieColors.swift`](file:///Users/austinbeckett/Documents/coding_projects/Winnie/Winnie/Core/Design/WinnieColors.swift).

---

## Core Colors

These are the foundational colors used for backgrounds and text across the app.

| Color Name | Hex | RGB | Usage |
|------------|-----|-----|-------|
| **Ink** | `#131718` | `rgb(19, 23, 24)` | Primary text (light mode), Background (dark mode) |
| **Ink Elevated** | `#1E2224` | `rgb(30, 34, 36)` | Card/panel backgrounds in dark mode |
| **Snow** | `#FFFCFF` | `rgb(255, 252, 255)` | Background (light mode), Primary text (dark mode) |
| **Snow Elevated** | `#F7F4F7` | `rgb(247, 244, 247)` | Card/panel backgrounds in light mode |
| **Parchment** | `#F2EFE9` | `rgb(242, 239, 233)` | Warm neutral background (light mode) |

---

## Accent Colors

Primary brand and interactive element colors.

| Color Name | Hex | RGB | Type | Usage |
|------------|-----|-----|------|-------|
| **Amethyst Smoke** | `#A393BF` | `rgb(163, 147, 191)` | Primary Accent | Interactive elements, progress indicators, primary button background (dark mode) |
| **Blackberry Cream** | `#5B325D` | `rgb(91, 50, 93)` | Secondary Accent | Primary button background (light mode), CTAs, highlights |

---

## Goal Preset Colors

User-selectable colors for personalizing goals. Defined in the `GoalPresetColor` enum.

| Color Name | Hex | RGB | Usage |
|------------|-----|-----|-------|
| **Amethyst** | `#A393BF` | `rgb(163, 147, 191)` | Default goal color |
| **Blackberry** | `#5B325D` | `rgb(91, 50, 93)` | Goal color option |
| **Rose** | `#D4A5A5` | `rgb(212, 165, 165)` | Goal color option |
| **Sage** | `#B5C4B1` | `rgb(181, 196, 177)` | Goal color option |
| **Slate** | `#8BA3B3` | `rgb(139, 163, 179)` | Goal color option |
| **Sand** | `#D4C4A8` | `rgb(212, 196, 168)` | Goal color option |
| **Terracotta** | `#C4907A` | `rgb(196, 144, 122)` | Goal color option |
| **Storm** | `#8B8B9B` | `rgb(139, 139, 155)` | Goal color option |

---

## Semantic Colors

Status and feedback colors with consistent appearance in both modes.

| Color Name | Hex | RGB | Type | Usage |
|------------|-----|-----|------|-------|
| **Error** | `#DC3545` | `rgb(220, 53, 69)` | Error/Danger | Validation errors, destructive actions |
| **Success** | `#28A745` | `rgb(40, 167, 69)` | Success | On-track status, confirmations |
| **Warning** | `#F5A623` | `rgb(245, 166, 35)` | Warning | Behind-schedule status, caution alerts |

---

## Text Colors (Theme-Aware)

Text colors that adapt based on light/dark mode.

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| **Primary Text** | Ink (`#131718`) | Snow (`#FFFCFF`) | Headlines, important text |
| **Secondary Text** | Ink @ 80% opacity | Snow @ 80% opacity | Body text, descriptions |
| **Tertiary Text** | Ink @ 50% opacity | Snow @ 50% opacity | Helper text, captions |
| **Contrast Text** | Snow (`#FFFCFF`) | Snow (`#FFFCFF`) | Text on colored backgrounds |

---

## UI Element Colors (Theme-Aware)

Decorative and functional UI colors.

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| **Border** | Ink @ 20% | Snow @ 15% | Dividers, general borders |
| **Input Border** | Ink @ 30% | Snow @ 30% | Text field borders |
| **Track Background** | Ink @ 20% | Snow @ 20% | Slider/progress track background |
| **Progress Background** | Ink @ 15% | Snow @ 15% | Progress bar track |

---

## Button Colors (Theme-Aware)

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| **Primary Button BG** | Blackberry Cream (`#5B325D`) | Amethyst Smoke (`#A393BF`) | Main CTA buttons |
| **Primary Button Text** | Snow (`#FFFCFF`) | Ink (`#131718`) | Text on primary buttons |
| **Secondary Button BG** | Amethyst Smoke (`#A393BF`) | Blackberry Cream (`#5B325D`) | Secondary action buttons |
| **Secondary Button Border** | Amethyst Smoke (`#A393BF`) | Blackberry Cream (`#5B325D`) | Outlined button style |

---

## Shadow Colors (Theme-Aware)

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| **Shadow** | Black @ 8% | Black @ 30% | General elevation shadows |
| **Card Shadow** | Ink @ 8% | Clear (none) | Card elevation |
| **Button Shadow** | Ink @ 15% | Amethyst Smoke @ 25% | Button elevation |

---

## Additional Colors

Other colors found in specific components.

| Hex | RGB | Location | Usage |
|-----|-----|----------|-------|
| `#4A4A5A` | `rgb(74, 74, 90)` | `UserInitialsAvatar.swift` | Avatar background (dark mode) |
| `#E8E4E8` | `rgb(232, 228, 232)` | `UserInitialsAvatar.swift` | Avatar background (light mode) |

---

## Legacy Colors

Maintained for backward compatibility.

| Color Name | Hex | RGB | Usage |
|------------|-----|-----|-------|
| **Carbon Black** | `#252627` | `rgb(37, 38, 39)` | Legacy deep black |
| **White** | `#FFFFFF` | `rgb(255, 255, 255)` | Pure white (system) |
