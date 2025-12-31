# Winnie Design System
**Inspired by Tiimo's Apple Design Award-Winning Aesthetic**

Complete visual specification for AI-assisted development

---

## Design Philosophy

Winnie adopts Tiimo's sophisticated visual language to make financial planning feel calm, approachable, and delightful. The design transforms potentially stressful money conversations into collaborative, positive experiences for couples.

### Core Principles

- **Generous Breathing Room**: Abundant white space creates calm and clarity
- **Elegant Simplicity**: Serif headlines paired with clean sans-serif body text
- **Warmth Through Art**: Minimalist line art illustrations add personality without clutter
- **Calm Color Palette**: Soft purples, warm creams, and gentle pastels
- **Thoughtful Interactions**: Smooth animations with spring-based physics

---

## Color System

### Updated Winnie Color Palette

Your new color palette provides a warm, approachable feel that reduces financial anxiety while maintaining professionalism.

**Core Colors:**

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Ink** | `#131718` | Primary text (light mode), background (dark mode) |
| **Ink Elevated** | `#1E2224` | Elevated surfaces in dark mode (cards, panels) |
| **Snow** | `#FFFCFF` | Background (light mode), primary text (dark mode) |
| **Peach Glow** | `#F9B58B` | Accent color, highlights, warm CTAs, primary button (dark mode) |
| **Amethyst Smoke** | `#A393BF` | Primary purple accent, interactive elements, progress indicators |
| **Blackberry Cream** | `#5B325D` | Primary button background (light mode) |
| **Parchment** | `#F2EFE9` | Legacy accent color for special surfaces |

### Light Mode (Primary Theme)

| Element | Hex Code | Usage |
|---------|----------|-------|
| **Background** | `#FFFCFF` (Snow) | Main app background |
| **Primary Text** | `#131718` (Ink) | Headlines, important text |
| **Secondary Text** | `#131718` (Ink) at 80% opacity | Body text, descriptions |
| **Tertiary Text** | `#131718` (Ink) at 50% opacity | Helper text, captions |
| **Primary Button BG** | `#5B325D` (Blackberry Cream) | Primary action buttons |
| **Primary Button Text** | `#FFFCFF` (Snow) | Text on dark buttons |
| **Secondary Button BG** | `#F9B58B` (Peach Glow) | Secondary actions, warm CTAs |
| **Accent Orange** | `#F9B58B` (Peach Glow) | Highlights, hover states, attention |
| **Accent Purple** | `#A393BF` (Amethyst Smoke) | Interactive elements, links, progress |
| **Card Background** | `#FFFCFF` (Snow) | Goal cards, elevated surfaces |
| **Card Accent - Purple** | `#A393BF` at 20% opacity | Subtle card backgrounds |
| **Card Accent - Peach** | `#F9B58B` at 20% opacity | Warm card backgrounds |
| **Borders** | `#131718` (Ink) at 20% opacity | Button outlines, input borders, dividers |

### Dark Mode (Secondary Theme)

| Element | Hex Code | Usage |
|---------|----------|-------|
| **Background** | `#131718` (Ink) | Main app background |
| **Primary Text** | `#FFFCFF` (Snow) | Headlines, important text |
| **Secondary Text** | `#FFFCFF` (Snow) at 80% opacity | Body text, descriptions, labels |
| **Tertiary Text** | `#FFFCFF` (Snow) at 50% opacity | Helper text, timestamps, captions |
| **Primary Button BG** | `#F9B58B` (Peach Glow) | Primary action buttons (Continue, Save, etc.) |
| **Primary Button Text** | `#131718` (Ink) | Text on peach buttons |
| **Secondary Button BG** | `#A393BF` (Amethyst Smoke) | Secondary actions, alternate CTAs |
| **Accent Purple** | `#A393BF` (Amethyst Smoke) | Progress indicators, selected states, highlights |
| **Card Background** | `#1E2224` (Ink Elevated) | Cards, panels, elevated surfaces |
| **Borders / Dividers** | `#FFFCFF` (Snow) at 15% opacity | Border strokes, divider lines |

### Winnie Financial Data Colors

Additional colors specific to Winnie for representing financial states and goal types:

#### State Colors
| Purpose | Hex Code | Usage |
|---------|----------|-------|
| **Success / On Track** | `#98D8AA` (Success Mint) | Progress bars, on-track indicators, positive states |
| **Warning / Attention** | `#F5C894` (Warning Peach) | Alerts, allocation warnings, attention needed |

#### Accent Colors
| Name | Hex Code | Usage |
|------|----------|-------|
| **Soft Sage** | `#A8C5B5` | Stability and growth |
| **Warm Coral** | `#E8A898` | Safety and protection |
| **Warm Slate** | `#7492A6` | Neutral blue-gray |
| **Sandy Dune** | `#D4C4A8` | Vacation and travel |

#### Goal Type Colors
| Goal Type | Hex Code | Color Name |
|-----------|----------|------------|
| **House** | `#A8C5B5` | Soft Sage |
| **Retirement** | `#F9B58B` | Peach Glow |
| **Vacation** | `#D4C4A8` | Sandy Dune |
| **Emergency Fund** | `#E8A898` | Warm Coral |
| **Baby & Family** | `#A393BF` | Amethyst Smoke |
| **Custom Goal** | `#7492A6` | Warm Slate |

---

## Typography System

Your typography choices create an elegant yet highly readable system:

- **Playfair Display**: Classic serif that adds warmth and sophistication to headlines
- **Lato**: Modern, friendly sans-serif with excellent readability across all sizes

### Font Families

| Purpose | Font Choice | Why |
|---------|------------|-----|
| **Display / Headlines** | Playfair Display (serif) | Creates editorial elegance, warmth, and sophistication. Highly legible serif with distinctive character. |
| **UI / Body Text** | Lato (sans-serif) | Clean, friendly, and highly readable. Humanist sans-serif with warmth. Excellent x-height for small sizes. Web-safe with great Google Fonts support. |
| **Financial Data** | Lato with `font-variant-numeric: tabular-nums` | Monospaced numbers ensure currency values align vertically in tables and lists. |

**Font Loading:**
```css
/* Google Fonts import */
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;700;900&display=swap');
```

**Font Weights Available:**
- Playfair Display: 400 (Regular), 500 (Medium), 600 (Semibold), 700 (Bold)
- Lato: 300 (Light), 400 (Regular), 700 (Bold), 900 (Black)

### Type Scale & Hierarchy

Generous type sizing with ample line spacing for improved readability and calm aesthetic.

| Style | Size | Weight | Line Height | Font | Usage |
|-------|------|--------|-------------|------|-------|
| **Display XL** | 52pt | Regular (400) | 1.2 | Playfair Display | Welcome screens, major onboarding moments |
| **Display L** | 44pt | Regular (400) | 1.2 | Playfair Display | Subscription paywall, important screens |
| **Display M** | 36pt | Medium (500) | 1.3 | Playfair Display | Screen titles, page headers |
| **Headline L** | 28pt | Semibold (600) | 1.3 | Playfair Display | Section headers within screens |
| **Headline M** | 22pt | Semibold (600) | 1.4 | Playfair Display | Card titles, goal names, subsection headers |
| **Body L** | 18pt | Regular (400) | 1.5 | Lato | Primary body text, longer descriptions, paragraphs |
| **Body M** | 16pt | Regular (400) | 1.5 | Lato | Button text, form labels, secondary descriptions |
| **Body S** | 14pt | Regular (400) | 1.4 | Lato | Helper text, timestamps, legal text, footnotes |
| **Caption** | 12pt | Regular (400) | 1.4 | Lato | Very small helper text, footnotes |
| **Financial XL** | 40pt | Bold (700) | 1.2 | Lato | Hero financial amounts (disposable income display) |
| **Financial L** | 32pt | Bold (700) | 1.2 | Lato | Large amounts, goal targets, timeline projections |
| **Financial M** | 24pt | Bold (700) | 1.3 | Lato | Card amounts, allocation values, smaller financial data |

**CSS Implementation Examples:**

```css
/* Display XL */
.display-xl {
  font-family: 'Playfair Display', serif;
  font-size: 52px;
  font-weight: 400;
  line-height: 1.2;
}

/* Body M */
.body-m {
  font-family: 'Lato', sans-serif;
  font-size: 16px;
  font-weight: 400;
  line-height: 1.5;
}

/* Financial XL with tabular nums */
.financial-xl {
  font-family: 'Lato', sans-serif;
  font-size: 40px;
  font-weight: 700;
  line-height: 1.2;
  font-variant-numeric: tabular-nums;
}
```

---

## UI Components

**From Tiimo:** Components emphasize generous touch targets, clear visual hierarchy, and delightful interactions.

### Buttons

#### Primary Button

- **Shape**: Pill-shaped with full rounded corners (`border-radius: 28-32px`)
- **Light mode background**: Blackberry Cream (`#5B325D`)
- **Light mode text**: Snow (`#FFFCFF`)
- **Dark mode background**: Peach Glow (`#F9B58B`)
- **Dark mode text**: Ink (`#131718`)
- **Padding**: Vertical 18px, Horizontal 48px (very generous)
- **Typography**: 16pt, Bold (700), Lato
- **Minimum width**: 280px or full-width on mobile
- **Height**: 56px minimum touch target
- **Shadow (light mode)**: Subtle `0px 2px 8px rgba(91, 50, 93, 0.15)`
- **Shadow (dark mode)**: `0px 2px 12px rgba(249, 181, 139, 0.25)`

#### Secondary Button (outlined)

- **Background**: Transparent
- **Border**: 2px solid, Amethyst Smoke (`#A393BF`) in light mode, Peach Glow (`#F9B58B`) in dark mode
- **Text color**: Matches border color
- **All other specs**: Same as primary

#### Tertiary Button (text only)

- **Background**: Transparent
- **No border**
- **Text color**: Amethyst Smoke (`#A393BF`)
- **Underline on hover**
- **Padding**: Vertical 12px, Horizontal 24px

#### Button States & Animations

- **Press**: Scale to 0.97 with spring animation (mass: 1, stiffness: 400, damping: 20)
- **Hover**: Slight brightness increase (+10%)
- **Disabled**: 40% opacity, no interaction
- **Loading**: Show spinner, disable interaction, maintain size

### Cards

#### Goal Cards

- **Light mode background**: Snow (`#FFFCFF`) with subtle colored accent border
- **Dark mode background**: Ink (`#131718`) with subtle border
- **Border radius**: 20px (generous rounding)
- **Padding**: 24px all sides
- **Minimum height**: 140px
- **Shadow (light mode)**: `0px 2px 12px rgba(19, 23, 24, 0.08)`
- **Border (dark mode)**: `1px solid rgba(255, 252, 255, 0.1)`
- **Accent borders** (left side, 4px width):
  - House goal: `#F9B58B` (Peach Glow)
  - Retirement goal: `#A393BF` (Amethyst Smoke)
  - Vacation goal: `#F9B58B` (Peach Glow)
  - Emergency fund: `#5B325D` (Blackberry Cream)
- **Spacing**: 16px between cards in grid

#### Colored Accent Cards (for variety)

For special emphasis cards, use subtle background tints:
- **Peach tint**: `#F9B58B` at 15% opacity on white background
- **Purple tint**: `#A393BF` at 15% opacity on white background
- **Dark tint**: `#5B325D` at 10% opacity on parchment background

### Input Fields

- **Border radius**: 16px
- **Border**: 1.5px solid
  - Light mode: `#131718` (Ink) at 30% opacity
  - Dark mode: `#FFFCFF` (Snow) at 30% opacity
- **Background**:
  - Light mode: `#FFFCFF` (Snow)
  - Dark mode: `#131718` (Ink)
- **Padding**: 18px horizontal, 16px vertical
- **Height**: 56px minimum
- **Typography**: 16pt Lato Regular
- **Focus state**: Border changes to full opacity Amethyst Smoke (`#A393BF`), 2px width
- **Label**: Above input, 14pt Lato Bold, 8px margin below
- **Placeholder**: 60% opacity of text color
- **Error state**: Border color Peach Glow (`#F9B58B`), error text below in Peach Glow

### Sliders (Allocation Controls)

- **Track height**: 6px
- **Track background**:
  - Light mode: `#131718` (Ink) at 20% opacity
  - Dark mode: `#FFFCFF` (Snow) at 20% opacity
- **Track fill**: Amethyst Smoke (`#A393BF`)
- **Thumb**: 28px circle, Snow (`#FFFCFF`) with `0px 2px 8px rgba(19, 23, 24, 0.3)` shadow
- **Value display**: Large financial text (32pt Lato Bold) above slider
- **Animation**: Smooth 200ms ease-out on value changes
- **Active state**: Thumb scales to 32px

### Progress Indicators

#### Progress Bar (linear)

- **Height**: 8px
- **Border radius**: 4px (fully rounded)
- **Background**:
  - Light mode: `#131718` (Ink) at 15% opacity
  - Dark mode: `#FFFCFF` (Snow) at 15% opacity
- **Fill**: Peach Glow (`#F9B58B`) for on-track, Amethyst Smoke (`#A393BF`) for in-progress
- **Animation**: Smooth width transition 400ms ease-out

#### Circular Progress

- **Stroke width**: 6px
- **Size**: 48px typical
- **Track color**: Same as progress bar background
- **Progress color**: Amethyst Smoke (`#A393BF`)
- **Center text**: Percentage in 18pt Lato Bold

---

## Spacing & Layout System

**Critical observation from Tiimo:** Extremely generous spacing creates calm and clarity. Don't be afraid of white space!

### Spacing Scale (8pt grid)

| Token | Value | Usage |
|-------|-------|-------|
| **XXS** | 4px | Icon padding, minimal internal component spacing |
| **XS** | 8px | Tight spacing between related elements (label to input) |
| **S** | 12px | Text line spacing, small component gaps |
| **M** | 16px | Standard spacing between list items, card content internal spacing |
| **L** | 24px | Card padding, spacing between sections within a screen |
| **XL** | 32px | Between major content sections, large component spacing |
| **XXL** | 48px | Screen top padding, bottom safe area padding, major sections |
| **XXXL** | 64px | Onboarding screen spacing, large hero sections |

### Layout Guidelines

- **Screen margins**: 24px horizontal on mobile, 32px on tablet
- **Safe area**: Always respect iOS safe area insets (top notch, bottom home indicator)
- **Content max width**: 680px for optimal readability on larger screens
- **Grid**: 2 column on mobile for cards, 3-4 on tablet

---

## Illustration Style

**Observed from Tiimo:** Minimalist line art with organic, flowing shapes. Characters are abstract but expressive. The blob mascot adds personality.

### Illustration Characteristics

- **Line weight**: Consistent 2-3px stroke throughout
- **Style**: Simple line art, no gradients or complex fills
- **Colors**: Use brand cream and purple, occasional pastel accents
- **Forms**: Mix of geometric shapes and organic flowing curves
- **Characters**: Abstract human forms, minimal facial features
- **Usage**: Onboarding screens, empty states, celebration moments

### Winnie-Specific Illustration Concepts

- **Couple collaboration**: Two abstract figures working together with financial symbols
- **Goal visualization**: House, vacation destinations in line art style
- **Growth metaphor**: Upward trending lines, organic growth imagery
- **Celebration**: Confetti, achievement badges in line art
- **Mascot: The Otters**:
  - **Metaphor**: Otters hold hands while sleeping so they don't drift apart—the perfect symbol for "Money decisions, made together."
  - **Visual Style**: Minimalist, fluid line art. Focus on the connection (holding hands/paws).
  - **Usage**:
    - *Syncing/Loading*: Otters floating downstream reaching for each other.
    - *Success*: High-fiving or hugging.
    - *Onboarding*: One otter pulling the other up onto a riverbank (symbolizing support).

**Tool recommendation:** Use Figma or hire an illustrator who can match Tiimo's aesthetic. For AI generation, use prompts like: *"minimalist line art, 2px stroke, organic flowing shapes, abstract human figures, cream and purple colors"*

---

## Visual Effects & Atmosphere

### Background Treatments

#### Light Mode (primary)

- **Background**: Snow (`#FFFCFF`)
- **Cards**: Snow (`#FFFCFF`) cards with subtle shadow for depth
- **Shadows**: Subtle shadows on cards and buttons for depth
  - Cards: `0px 2px 12px rgba(19, 23, 24, 0.08)`
  - Buttons: `0px 2px 8px rgba(19, 23, 24, 0.15)`

#### Dark Mode

- **Background**: Ink (`#131718`)
- **Cards**: Ink (`#131718`) with subtle borders for definition
- **Glow effect**: Soft radial gradient (Amethyst Smoke `#A393BF` at 30% opacity) behind key illustrations

### Animations & Transitions

**Observed from Tiimo:** Smooth, organic animations with spring physics. Never abrupt.

- **Page transitions**: 350ms ease-out, slight vertical slide (20px)
- **Button interactions**: Scale to 0.97 with spring (stiffness: 400, damping: 20)
- **Card appearance**: Fade in + scale from 0.95 to 1.0, 300ms ease-out
- **Number changes**: Counting animation over 600ms for financial amounts
- **Loading states**: Gentle pulse (scale 0.98-1.0) or shimmer effect
- **Success moments**: Confetti animation, scale bounce, haptic feedback
- **Slider interaction**: Real-time updates with 200ms debounce

---

## Key Screen Layouts

### 1. Welcome Screen

- Background: Snow (`#FFFCFF`)
- Top 1/3: Winnie logo + tagline
- Middle: Line art illustration (couple + financial symbols)
- Display text (52pt serif): "Plan your future together" in Ink (`#131718`)
- Body text (18pt): "Answer money questions as a team" in Ink at 80% opacity
- Bottom: Blackberry Cream "Get Started" button with Snow text, 24px from safe area bottom

### 2. Dashboard

- Background: Snow (`#FFFCFF`)
- Top bar: User name (left) in Ink (`#131718`), settings icon (right), 24px horizontal margins
- Hero section: "Disposable Income" label in Ink at 80% + $X,XXX/month in large financial text (40pt) Ink
- Section header (28pt serif): "Your Goals" in Ink
- Grid: 2 columns, 16px gap, Snow cards with pastel accent borders
- Each card shows: Icon, Goal name (22pt), Current/Target (24pt financial), Timeline
- FAB: '+' button bottom right, Amethyst Smoke background, 56px diameter

### 3. Allocation Modeling

- Background: Snow (`#FFFCFF`)
- Header: "Adjust Your Allocation" (36pt serif) in Ink (`#131718`)
- Top indicator: "Remaining: $XXX" in Ink at 80% with Amethyst Smoke progress bar
- For each goal:
  - Snow card with pastel accent border (left side, 4px)
  - Goal name + icon in Ink
  - Large $ amount (32pt) in Ink
  - Slider control with Amethyst Smoke fill
  - Timeline: "2.8 years" with calendar icon in Ink at 80%
- Bottom: Blackberry Cream "Save as Scenario" button

### 4. Paywall / Subscription

- Background: Snow (`#FFFCFF`)
- Display headline (44pt serif): "Unlock unlimited scenarios" in Ink (`#131718`)
- Feature list with Amethyst Smoke checkmarks
- Pricing cards: Side by side, Snow backgrounds with subtle shadows
  - Monthly: $8.99/mo (outlined in Amethyst Smoke)
  - Annual: $89.99/yr (highlighted, Peach Glow pill "MOST POPULAR")
- CTA: "Start 14 days free trial" Blackberry Cream button with Snow text
- Footer: "No commitment. Cancel anytime." (14pt) in Ink at 50% opacity

---

## Implementation Guide for AI Development

### Example Prompts

#### For the Dashboard:

```
Create the Winnie dashboard screen in SwiftUI. Use light mode with Snow (#FFFCFF) background. Display "Disposable Income" in 18pt Lato regular in Ink at 80% opacity, then show the amount $4,200/month in 40pt Lato Bold Ink (#131718) with tabular figures. Below that, add "Your Goals" in 36pt Playfair Display Ink. Create a 2-column grid with 16px gaps showing goal cards. Each card has Snow background with colored left accent border (4px), 20px border radius, 24px padding, subtle shadow, and shows the goal name in 22pt Lato Semibold, current vs target in 24pt Lato Medium, and timeline below. Use generous spacing throughout: 48px top margin, 32px between sections.
```

#### For a Button Component:

```
Create a reusable Button component in SwiftUI that matches Winnie's design. Make it pill-shaped with 28px border radius, 18px vertical padding, 48px horizontal padding, minimum 56px height. For light mode: Blackberry Cream background (#5B325D) with Snow text (#FFFCFF). For dark mode: Peach Glow background (#F9B58B) with Ink text (#131718). Use 16pt Lato Bold for button text. Add a press animation that scales to 0.97 with spring physics (stiffness: 400, damping: 20). Include loading and disabled states.
```

### Code Structure Tips

- **Design tokens**: Use central files like `WinnieColors.swift`, `WinnieSpacing.swift`, `WinnieTypography.swift` for all design tokens
- **Light/dark mode**: Use SwiftUI's `@Environment(\.colorScheme)` to switch themes
- **Reusable components**: Build WinnieButton, WinnieCard, WinnieInput, WinnieSlider as separate View components
- **Typography**: Create View modifiers for each style (`.winnieDisplayXL()`, `.winnieHeadlineL()`, `.winnieBodyM()`, etc.)
- **Animations**: Use SwiftUI's built-in `.animation()` modifier with spring physics for smooth 60fps animations

### Design Consistency Checklist

Before considering a screen complete, verify:

- ☐ All buttons are pill-shaped with correct colors (Blackberry Cream bg in light mode, Peach Glow in dark)
- ☐ Button text uses Snow (#FFFCFF) in light mode, Ink (#131718) in dark mode
- ☐ Headlines use Playfair Display serif font
- ☐ Financial amounts use Lato Bold with tabular figures
- ☐ Spacing follows 8pt grid (multiples of 4, 8, 16, 24, 32, 48)
- ☐ Cards have 20px radius, 24px padding, Snow background with subtle shadow (light mode)
- ☐ Light mode uses Snow (#FFFCFF) background, Dark mode uses Ink (#131718)
- ☐ Primary text uses Ink (light) / Snow (dark), Secondary at 80%, Tertiary at 50%
- ☐ All touch targets are minimum 44x44pt (iOS guideline)
- ☐ Animations use spring physics for organic feel
- ☐ Safe areas respected (top notch, bottom home indicator)
- ☐ Illustrations match line art style (2-3px strokes, organic shapes)

---

## Conclusion

This design system captures Tiimo's Apple Design Award-winning aesthetic and adapts it for Winnie's financial planning context. The key is generous spacing, elegant typography, calm colors, and thoughtful interactions. Every pixel should feel intentional.

### Remember the Core Principles:

- **Let content breathe** - white space is your friend
- **Typography creates hierarchy** - serif for warmth, sans-serif for clarity
- **Colors evoke emotion** - calm purples and creams reduce financial anxiety
- **Animations feel organic** - spring physics, never linear
- **Illustrations add personality** - minimalist line art creates approachability

When in doubt, look to Tiimo's screens for inspiration. Your goal is to make financial planning feel as calm and delightful as daily task management.

---

*Design System Version 1.0 - December 2025*
