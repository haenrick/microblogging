# fl4re — Styleguide

> Retro-Terminal Aesthetic. Monospace. Neon auf Schwarz.

Basiert auf dem [DIVIDE Styleguide](https://github.com/haenrick/divide/blob/saas/docs/styleguide.md), angepasst für fl4re.

---

## Design-Philosophie

fl4re sieht aus wie ein Terminal — kein Zufall. Das Design kommuniziert:
**Präzision, Kontrolle, Klarheit.** Keine Ablenkung, kein Rauschen.

Kernprinzipien:
- **Monospace only** — keine Serifenlosen, keine Mischung
- **Neon auf Schwarz** — hoher Kontrast, minimale Farben
- **Kein Dekor** — keine Schatten unter Cards, keine Gradienten, keine Icons außer funktionale
- **Terminal-Sprache** — `>`, `$`, `//`, `[!]` als visuelle Marker
- **Themes** — 6 Benutzer-wählbare Akzentfarben (green, amber, purple, pink, cyan, white)

---

## Farben

```css
/* Dynamischer Akzent — vom User-Theme abhängig */
--primary:     /* z.B. #00ff88 (green), #ffaa00 (amber), … */
--primary-dim: /* gedämpfte Variante für Hover/Focus */
--primary-glow:/* rgba-Variante für Hintergründe */

/* Feste Hintergründe */
--bg:         #000000   /* Basis — reines Schwarz */
--bg-card:    #080808   /* Cards und Panels */
--bg-input:   #0a0a0a   /* Eingabefelder */

/* Borders */
--border:        #1a1a1a

/* Text */
--text:        #aaa
--text-bright: #f0f0f0

/* Semantisch */
--red:         #ff4444   /* Fehler, Löschaktionen */
```

### Themes (Akzentfarben)

| Theme  | Primary   | Dim       |
|--------|-----------|-----------|
| green  | `#00ff88` | `#00cc6a` |
| amber  | `#ffaa00` | `#cc8800` |
| purple | `#bf5fff` | `#9933cc` |
| pink   | `#ff44aa` | `#cc2288` |
| cyan   | `#00e5ff` | `#00b8cc` |
| white  | `#e0e0e0` | `#aaaaaa` |

---

## Typografie

```css
--mono: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', ui-monospace, monospace;
```

**Ausschließlich Monospace.** Keine Ausnahmen.

### Schriftgrößen

| Verwendung         | Größe  |
|--------------------|--------|
| Basis-Schriftgröße | `14px` |
| Eingabefelder      | `16px` (min. — verhindert iOS-Zoom) |
| Fließtext, Labels  | `13px` |
| Buttons, sekundär  | `12px` |
| Kleine Labels      | `11px` |
| Hints, Datum       | `10px` |

---

## Abstände & Layout

```
Container-Maxbreite: 640px (mobile-first)
Standard-Gap:        12px
Card-Padding:        14–16px
```

### Spacing-Skala
```
4px → 6px → 8px → 10px → 12px → 14px → 16px → 24px → 32px → 48px
```

---

## Komponenten

### Cards / Panels
```css
background:    var(--bg-card)
border:        1px solid var(--border)
border-radius: 4px
padding:       14–16px
```

### Eingabefelder
```css
background:  var(--bg-input)
border:      1px solid var(--border)
font-size:   16px
caret-color: var(--primary)
/* Focus: */
border-color: var(--primary-dim)
box-shadow:   0 0 0 1px var(--primary)
```

### Buttons (primary)
```css
background:     var(--primary)
color:          #000
font-weight:    700
letter-spacing: 2px
padding:        8px 14px
```

### Buttons (ghost)
```css
background:  transparent
border:      1px solid var(--border)
color:       var(--text)
/* Hover: */
border-color: var(--primary)
background:   var(--primary-glow)
color:        var(--primary)
```

---

## Terminal-Sprache

| Symbol | Bedeutung        |
|--------|-----------------|
| `>`    | Navigation       |
| `$`    | Eingabe-Prompt   |
| `//`   | Kommentar        |
| `[!]`  | Warnung          |
| `@`    | Username         |
| `_`    | Blinkender Cursor|

---

## Animationen

| Element        | Transition              |
|----------------|------------------------|
| Buttons / Hover | `0.15s`               |
| Borders / Focus | `0.2s`               |
| Cursor-Blinken  | `1s step-end infinite`|

---

## Do's & Don'ts

| ✅ Do                            | ❌ Don't                        |
|----------------------------------|--------------------------------|
| Monospace für alles              | Sans-Serif verwenden           |
| Theme-Farbe für primäre Aktionen | Mehrere Farben mischen         |
| Borders statt Shadows für Tiefe  | Box-Shadow unter Cards         |
| Terminal-Vokabular               | Marketing-Sprache              |
| Dezente Hover-States             | Starke Animationen             |
