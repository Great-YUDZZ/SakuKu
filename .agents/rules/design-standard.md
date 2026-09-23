# Global Design Standard: IT-Toolbox Neumorphism Light

This rule establishes the mandatory visual identity and UI/UX design standard for ALL web applications, desktop applications, and user interfaces created for the user. It is directly modeled after the signature **`Neumorphism Light`** aesthetic of **`IT-Toolbox`**.

---

## 1. Core Visual Philosophy
- **Name**: IT-Toolbox Neumorphism Light ("Luminous Frosted Glass over Cool Ambient Ice")
- **Atmosphere**: Ethereal, clean, tactile, luminous, high-contrast, modern engineering workbench.
- **Mood**: Precision, calm, professional, tactile depth with soft dual lighting.
- **NEVER use dark-mode obsidian glass or harsh flat neo-brutalism unless specifically requested.**

---

## 2. Palette & Design Tokens

### Backgrounds & Surfaces
- **Canvas / Base Background**: `#EFF4FA` (Ethereal cool ice / pearl canvas)
- **Sidebar Background**: `#E8EEF7` (Soft frosted cool light sidebar)
- **Card Surface**: `#FFFFFF` (Luminous pure white surface)
- **Card Inset / Input Well**: `#F4F7FB` (Recessed well for inputs, tables, and secondary containers)
- **Hover Surface**: `#DBEAFE` (Soft blue tinted hover)
- **Border Subtle**: `#E2E8F0` or `rgba(203, 213, 225, 0.6)` (1.0px - 1.5px subtle structure)

### Neumorphic Dual Shadows
Every elevated card and button utilizes a dual-light source shadow system:
- **Light Shadow (Top-Left Highlight)**:
  - Color: `#FFFFFF` (100% white)
  - Offset: `(-3px, -3px)` to `(-4px, -4px)`
  - Blur Radius: `8px` - `10px`
- **Dark Shadow (Bottom-Right Ambient Depth)**:
  - Color: `#C2D0E2` (Cool slate-blue shadow)
  - Offset: `(4px, 4px)` to `(6px, 6px)`
  - Blur Radius: `12px` - `16px`

### Inset Shadows (Inputs & Wells)
- Recessed/sunken feel using inner shadow or inset background `#F4F7FB` with a clean `1.5px` border `#CBD5E1`.

### Accent Colors (Vibrant Indicators & Statuses)
- **Cobalt Blue (Primary / Brand / Active)**: `#2563EB` | Tint: `#DBEAFE` | Dark: `#1E40AF`
- **Cyan (Info / Network / Data)**: `#0284C7` | Tint: `#BAE6FD`
- **Emerald Green (Success / Usable / Surplus)**: `#059669` | Tint: `#D1FAE5` | Dark: `#047857`
- **Amber / Tangerine (Warning / Total / Savings)**: `#D97706` / `#EA580C` | Tint: `#FEF3C7`
- **Coral / Red (Danger / Expense / Deficit)**: `#DC2626` | Tint: `#FEE2E2`
- **Violet / Purple (Special / Utilities)**: `#7C3AED` | Tint: `#EDE9FE`

### Typography & Text Hierarchy
- **Text Primary (Headings, Values)**: `#0F172A` (Deep Slate / Pitch Blue-Black)
- **Text Secondary (Labels, Subheadings)**: `#334155` (Slate Gray)
- **Text Muted (Hints, Metadata, Uppercase Tags)**: `#64748B` (Cool Muted Slate)
- **Font Families**: Modern sans-serif (Inter, Plus Jakarta Sans, Roboto, Outfit).

---

## 3. Signature UI Components

### A. StatCard with Left Accent Stripe
Stat cards are the primary data visualization container:
1. **Background**: Pure white `#FFFFFF`.
2. **Left Vertical Stripe**: `3.5px` - `4px` solid color bar on the left edge (Cobalt, Emerald, Amber, or Coral).
3. **Card Border & Shadow**: Subtle border with dual neumorphic shadow (`#FFFFFF` top-left, `#C2D0E2` bottom-right).
4. **Header Label**: Small (`10px` - `11px`), bold, uppercase, tracked (`letter-spacing: 0.5px`), muted color `#64748B` (e.g., `TOTAL SALDO BERSIH`, `RASIO DANA DARURAT`).
5. **Metric Value**: Large (`24px` - `30px`), extra bold, colored matching the left accent stripe.
6. **Footer / Subtitle**: Muted text (`12px`), providing contextual explanation.

### B. Sidebar Navigation
1. **Background**: `#E8EEF7` with subtle right border.
2. **Brand Capsule Header**:
   - Solid Cobalt Blue pill (`#2563EB`) with bold white brand name (e.g. `IT TOOLBOX` or `FINANCE TOOLBOX`).
   - Muted uppercase subtitle (e.g., `ENGINEERING WORKBENCH`).
   - Version pill badge on the right (`v1.x.x`).
3. **Nav Items**:
   - **Active Item**: Pill-shaped container with soft blue tint `#DBEAFE`, subtle blue border, and Cobalt text/icon `#2563EB`.
   - **Inactive Items**: Transparent background with `#334155` text and icon; smooth hover to `#E2E8F0`.
4. **Bottom Status Section**:
   - Theme badge pill: `🎨 Neumorphism Light`.
   - Active screen indicator pill with colored dot: `• Toolbox & Kalkulator` (or `• Dashboard Keuangan`).
   - Tech stack footer: e.g. `Flutter • SQLite • Offline`.

### C. Inputs & Forms
- **Input Background**: Inset well `#F4F7FB`.
- **Border**: `#CBD5E1` (focused: `#2563EB` with `2px` width).
- **Corner Radius**: `10px` - `12px`.
- **Text Color**: Deep Slate `#0F172A`.

### D. Tactile Buttons
- **Resting**: Convex elevated pill or rounded rectangle with dual shadow.
- **Primary Button**: Cobalt Blue `#2563EB` with white text, or pure white with cobalt text and soft shadow.
- **Pressed Effect**: Inset or reduced shadow with subtle `scale(0.98)` translation.

### E. Informational Banners
- Rounded container (`radius: 12px`), background `#F1F5F9` or `#F4F7FB`, subtle left border or neutral outline, clean dark slate text explaining recommendations or tips.

---

## 4. Application Scope
This standard MUST be adhered to whenever building or redesigning any Web application, desktop tool, or UI requested by the user, ensuring a consistent, cohesive, and signature premium experience.
