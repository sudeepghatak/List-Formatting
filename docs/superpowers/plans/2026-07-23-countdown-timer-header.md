# Countdown Timer Header — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a SharePoint form header formatter that displays a color-coded urgency banner showing the item title and days remaining until a due date.

**Architecture:** Single JSON formatter applied to the Header Format slot in SharePoint's Configure Layout panel. All conditional logic (color, icon, label, day count) is driven by a single date arithmetic expression on the `DueDate` column. No footer variant.

**Tech Stack:** SharePoint Online form formatting JSON, Fluent UI icons, `@now` token, `floor()` / `toString()` expression functions.

## Global Constraints

- No `$schema` field — form header formatters in this repo omit it (see `blank-header.json`, `status-header.json`)
- Background colors use inline hex strings — NOT Fluent CSS class names (class-based conditionals in `background-color` are unreliable across SPO tenants)
- No gradients — silently kill rendering in SPO form formatters
- No number+string concat without `toString()` — causes silent render failure
- Only use icon names confirmed in Fluent UI v1: `Timer`, `Clock`, `Warning`, `ErrorBadge`
- `[$DueDate.displayValue]` for locale-formatted date display (not `.value`)
- Author: Sudeep Ghatak — github.com/sudeepghatak

---

### Task 1: Scaffold folder and write assets/sample.json

**Files:**
- Create: `form-samples/countdown-timer-header/assets/sample.json`
- Create: `form-samples/countdown-timer-header/assets/` (directory)

**Interfaces:**
- Produces: `assets/sample.json` consumed by Task 3 (README thumbnails reference it) and Task 4 (samples.json entry)

- [ ] **Step 1: Create the folder structure**

```powershell
New-Item -ItemType Directory -Force "form-samples\countdown-timer-header\assets"
```

Expected output: directory created, no error.

- [ ] **Step 2: Write assets/sample.json**

Create `form-samples/countdown-timer-header/assets/sample.json` with this exact content:

```json
[
  {
    "name": "pnp-list-formatting-countdown-timer-header",
    "reponame": "countdown-timer-header",
    "source": "pnp",
    "title": "Countdown Timer Header",
    "shortDescription": "A form header formatter that displays days remaining until a due date with color-coded urgency: green (calm, >7 days), amber (warning, 4-7 days), red (urgent, 1-3 days), and crimson (overdue).",
    "url": "https://github.com/pnp/List-Formatting/tree/master/form-samples/countdown-timer-header",
    "longDescription": [
      "A form header formatter that displays days remaining until a due date with color-coded urgency: green (calm, >7 days), amber (warning, 4-7 days), red (urgent, 1-3 days), and crimson (overdue).",
      "The header shows the item title on the left and a countdown badge on the right with the day count, urgency label (DAYS LEFT / DUE TODAY / OVERDUE), and formatted due date.",
      "All conditional logic is driven by date arithmetic on the DueDate column using the @now token."
    ],
    "creationDateTime": "2026-07-23T00:00:00.000Z",
    "updateDateTime": "2026-07-23T00:00:00.000Z",
    "products": [
      "SharePoint",
      "Microsoft Lists"
    ],
    "metadata": [
      {
        "key": "LIST-SAMPLE-TYPE",
        "value": "Form"
      },
      {
        "key": "SHAREPOINT-COMPATIBILITY",
        "value": "SharePoint Online"
      },
      {
        "key": "SAMPLE-CATEGORIES",
        "value": "Date, Urgency, Countdown"
      },
      {
        "key": "LIST-COLUMN-TYPE",
        "value": "Date and Time"
      },
      {
        "key": "FORMATTING-TOKENS",
        "value": "@now"
      },
      {
        "key": "FORMATTING-OPERATORS",
        "value": "floor, toString, if"
      },
      {
        "key": "FORMATTING-ACTIONS",
        "value": ""
      },
      {
        "key": "FORMATTING-FEATURES",
        "value": ""
      },
      {
        "key": "CLASSES",
        "value": ""
      }
    ],
    "thumbnails": [
      {
        "type": "image",
        "order": 100,
        "url": "https://raw.githubusercontent.com/pnp/List-Formatting/master/form-samples/countdown-timer-header/assets/screenshot.png",
        "alt": "screenshot"
      }
    ],
    "authors": [
      {
        "gitHubAccount": "sudeepghatak",
        "pictureUrl": "https://github.com/sudeepghatak.png",
        "name": "Sudeep Ghatak"
      }
    ],
    "references": [
      {
        "name": "Configure the list form",
        "description": "You can configure the list form in a list or library with a custom header, footer and the form body with one or more sections with fields in each of those sections.",
        "url": "https://docs.microsoft.com/sharepoint/dev/declarative-customization/list-form-configuration"
      },
      {
        "name": "Use formatting to customize SharePoint — Date functions",
        "description": "Documentation on @now, floor(), and date arithmetic in SharePoint formatting expressions.",
        "url": "https://docs.microsoft.com/sharepoint/dev/declarative-customization/formatting-syntax-reference"
      }
    ]
  }
]
```

- [ ] **Step 3: Verify JSON is valid**

Open `form-samples/countdown-timer-header/assets/sample.json` in VS Code and confirm no red squiggles, or run:

```powershell
Get-Content "form-samples\countdown-timer-header\assets\sample.json" | ConvertFrom-Json | Out-Null; Write-Output "Valid JSON"
```

Expected output: `Valid JSON`

- [ ] **Step 4: Commit**

```powershell
git add form-samples/countdown-timer-header/assets/sample.json
git commit -m "Add countdown-timer-header scaffold and sample.json"
```

---

### Task 2: Write countdown-timer-header.json

**Files:**
- Create: `form-samples/countdown-timer-header/countdown-timer-header.json`

**Interfaces:**
- Consumes: nothing from prior tasks
- Produces: the formatter applied in SharePoint Header Format slot; README (Task 3) references this file name

**Key expression** (used repeatedly — evaluate once mentally before reading the JSON):
```
floor(([$DueDate] - @now) / 86400000)
```
This yields: positive integer = days remaining, 0 = due today, negative = overdue.

**Color tier logic** (all four expressions use this same chain):
- `> 7` → `#1e7e34` (dark green) / `Timer`
- `> 3` → `#b8860b` (dark amber) / `Clock`
- `> 0` → `#c0392b` (deep red) / `Warning`
- `≤ 0` → `#6d0000` (dark crimson) / `ErrorBadge`

- [ ] **Step 1: Create countdown-timer-header.json**

Create `form-samples/countdown-timer-header/countdown-timer-header.json` with this exact content:

```json
{
  "elmType": "div",
  "style": {
    "display": "flex",
    "justify-content": "space-between",
    "align-items": "center",
    "border-radius": "8px",
    "padding": "16px 20px",
    "background-color": "=if(floor(([$DueDate] - @now) / 86400000) > 7, '#1e7e34', if(floor(([$DueDate] - @now) / 86400000) > 3, '#b8860b', if(floor(([$DueDate] - @now) / 86400000) > 0, '#c0392b', '#6d0000')))",
    "color": "#ffffff",
    "min-height": "80px"
  },
  "children": [
    {
      "elmType": "div",
      "txtContent": "[$Title]",
      "style": {
        "flex": "1",
        "font-size": "24px",
        "font-weight": "600",
        "margin-right": "16px",
        "line-height": "1.2",
        "color": "#ffffff"
      }
    },
    {
      "elmType": "div",
      "style": {
        "display": "flex",
        "flex-direction": "column",
        "align-items": "center",
        "background-color": "rgba(0,0,0,0.2)",
        "border-radius": "6px",
        "padding": "8px 16px",
        "min-width": "110px",
        "text-align": "center"
      },
      "children": [
        {
          "elmType": "div",
          "style": {
            "display": "flex",
            "align-items": "center",
            "justify-content": "center"
          },
          "children": [
            {
              "elmType": "div",
              "attributes": {
                "iconName": "=if(floor(([$DueDate] - @now) / 86400000) > 7, 'Timer', if(floor(([$DueDate] - @now) / 86400000) > 3, 'Clock', if(floor(([$DueDate] - @now) / 86400000) > 0, 'Warning', 'ErrorBadge')))"
              },
              "style": {
                "font-size": "20px",
                "margin-right": "6px",
                "color": "#ffffff"
              }
            },
            {
              "elmType": "div",
              "txtContent": "=if(floor(([$DueDate] - @now) / 86400000) >= 0, toString(floor(([$DueDate] - @now) / 86400000)), toString(floor(([$DueDate] - @now) / 86400000) * -1))",
              "style": {
                "font-size": "48px",
                "font-weight": "700",
                "line-height": "1",
                "color": "#ffffff"
              }
            }
          ]
        },
        {
          "elmType": "div",
          "txtContent": "=if(floor(([$DueDate] - @now) / 86400000) > 0, 'DAYS LEFT', if(floor(([$DueDate] - @now) / 86400000) == 0, 'DUE TODAY', 'OVERDUE'))",
          "style": {
            "font-size": "11px",
            "font-weight": "700",
            "letter-spacing": "1px",
            "color": "#ffffff",
            "margin-top": "4px"
          }
        },
        {
          "elmType": "div",
          "txtContent": "[$DueDate.displayValue]",
          "style": {
            "font-size": "10px",
            "color": "rgba(255,255,255,0.85)",
            "margin-top": "4px"
          }
        }
      ]
    }
  ]
}
```

- [ ] **Step 2: Verify JSON is valid**

```powershell
Get-Content "form-samples\countdown-timer-header\countdown-timer-header.json" | ConvertFrom-Json | Out-Null; Write-Output "Valid JSON"
```

Expected output: `Valid JSON`

- [ ] **Step 3: Check expression consistency**

Manually verify all four nested `if()` chains in the JSON use identical structure:
- `background-color`: `> 7 → > 3 → > 0 → else` ✓
- `iconName`: `> 7 → > 3 → > 0 → else` ✓
- Day count display uses `>= 0` for the positive branch (covers the DUE TODAY case correctly) ✓
- Label: `> 0 → == 0 → else` ✓

- [ ] **Step 4: Commit**

```powershell
git add form-samples/countdown-timer-header/countdown-timer-header.json
git commit -m "Add countdown-timer-header formatter JSON"
```

---

### Task 3: Write README.md

**Files:**
- Create: `form-samples/countdown-timer-header/README.md`

**Interfaces:**
- Consumes: file name `countdown-timer-header.json` from Task 2, author info from Global Constraints
- Produces: documentation displayed on GitHub and the PnP samples gallery

- [ ] **Step 1: Create README.md**

Create `form-samples/countdown-timer-header/README.md` with this exact content:

```markdown
# Countdown Timer Header

## Summary

This SharePoint JSON form header formatter transforms the form header into a color-coded urgency banner. It shows the item title on the left and a countdown badge on the right — displaying days remaining until a due date, a status label (DAYS LEFT / DUE TODAY / OVERDUE), and the formatted due date.

The banner background shifts through four urgency tiers based on days remaining:
- **Green** (`#1e7e34`) — more than 7 days remaining
- **Amber** (`#b8860b`) — 4 to 7 days remaining
- **Red** (`#c0392b`) — 1 to 3 days remaining
- **Crimson** (`#6d0000`) — overdue (0 or fewer days)

It's designed for task lists, project trackers, action item registers, or any list where due-date urgency should be immediately visible when opening a form.

![screenshot of the sample](./assets/screenshot.png)

## Form requirements

This formatter is applied to the **Header Format** slot in SharePoint's **Configure Layout** panel.

### Required SharePoint List Columns

| Type                | Internal Name | Required | Description                                 |
| ------------------- | ------------- | :------: | ------------------------------------------- |
| Single line of text | Title         | Yes      | Item name — displayed on the left of the header |
| Date and Time       | DueDate       | Yes      | Target deadline — drives all countdown logic |

### Expression used

Days remaining is computed as:

```
=floor(([$DueDate] - @now) / 86400000)
```

This yields a positive integer (days left), 0 (due today), or a negative integer (overdue). All conditional styling, icon selection, and label text branch from this single expression.

## Sample

Solution|Author
--------|---------
countdown-timer-header.json | [Sudeep Ghatak](https://github.com/sudeepghatak) ([LinkedIn](https://www.linkedin.com/in/sudeepghatak/))

## Version history

Version|Date|Comments
-------|----|--------
1.0|July 23, 2026|Initial release

## Disclaimer

**THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.**

---

## Additional notes

- **Background color is inline hex** — not Fluent CSS class names. Class-based conditionals in `background-color` style values are unreliable across SharePoint Online tenants.
- **Overdue day count** shows the absolute number of days past due (e.g., `3` not `-3`), paired with the "OVERDUE" label so the meaning is unambiguous.
- **`[$DueDate.displayValue]`** is used (not `[$DueDate]`) to render the locale-formatted date string in the badge subtitle.
- **No gradients** are used — gradient `background` values silently fail to render in SharePoint form formatters.
- The formatter has no footer counterpart — it is a header-only sample.

<img src="https://pnptelemetry.azurewebsites.net/list-formatting/form-samples/countdown-timer-header" />
```

- [ ] **Step 2: Verify the telemetry URL slug matches the folder name**

Confirm the last line reads:
```
form-samples/countdown-timer-header
```
Not `readme-template` or any other value.

- [ ] **Step 3: Commit**

```powershell
git add form-samples/countdown-timer-header/README.md
git commit -m "Add countdown-timer-header README"
```

---

### Task 4: Register entry in samples.json

**Files:**
- Modify: `samples.json` (root of repo)

**Interfaces:**
- Consumes: all metadata from `assets/sample.json` (Task 1) — the root `samples.json` mirrors that structure
- Produces: sample appears in the PnP gallery search index

- [ ] **Step 1: Locate the insertion point in samples.json**

`samples.json` is an array. Find any existing `"form"` sample entry (e.g., `pnp-list-formatting-status-header-footer`) so you can see the correct neighbour. Insert the new entry anywhere in the array — alphabetical order by `"name"` is preferred but not enforced.

- [ ] **Step 2: Add the new entry**

Insert this object into the root `samples.json` array:

```json
{
  "name": "pnp-list-formatting-countdown-timer-header",
  "reponame": "countdown-timer-header",
  "source": "pnp",
  "title": "Countdown Timer Header",
  "shortDescription": "A form header formatter that displays days remaining until a due date with color-coded urgency: green (calm, >7 days), amber (warning, 4-7 days), red (urgent, 1-3 days), and crimson (overdue).",
  "url": "https://github.com/pnp/List-Formatting/tree/master/form-samples/countdown-timer-header",
  "longDescription": [
    "A form header formatter that displays days remaining until a due date with color-coded urgency: green (calm, >7 days), amber (warning, 4-7 days), red (urgent, 1-3 days), and crimson (overdue).",
    "The header shows the item title on the left and a countdown badge on the right with the day count, urgency label (DAYS LEFT / DUE TODAY / OVERDUE), and formatted due date.",
    "All conditional logic is driven by date arithmetic on the DueDate column using the @now token."
  ],
  "creationDateTime": "2026-07-23T00:00:00.000Z",
  "updateDateTime": "2026-07-23T00:00:00.000Z",
  "products": [
    "SharePoint",
    "Microsoft Lists"
  ],
  "metadata": [
    {
      "key": "LIST-SAMPLE-TYPE",
      "value": "Form"
    },
    {
      "key": "SHAREPOINT-COMPATIBILITY",
      "value": "SharePoint Online"
    },
    {
      "key": "SAMPLE-CATEGORIES",
      "value": "Date, Urgency, Countdown"
    },
    {
      "key": "LIST-COLUMN-TYPE",
      "value": "Date and Time"
    },
    {
      "key": "FORMATTING-TOKENS",
      "value": "@now"
    },
    {
      "key": "FORMATTING-OPERATORS",
      "value": "floor, toString, if"
    },
    {
      "key": "FORMATTING-ACTIONS",
      "value": ""
    },
    {
      "key": "FORMATTING-FEATURES",
      "value": ""
    },
    {
      "key": "CLASSES",
      "value": ""
    }
  ],
  "thumbnails": [
    {
      "type": "image",
      "order": 100,
      "url": "https://raw.githubusercontent.com/pnp/List-Formatting/master/form-samples/countdown-timer-header/assets/screenshot.png",
      "alt": "screenshot"
    }
  ],
  "authors": [
    {
      "gitHubAccount": "sudeepghatak",
      "pictureUrl": "https://github.com/sudeepghatak.png",
      "name": "Sudeep Ghatak"
    }
  ],
  "references": [
    {
      "name": "Configure the list form",
      "description": "You can configure the list form in a list or library with a custom header, footer and the form body with one or more sections with fields in each of those sections.",
      "url": "https://docs.microsoft.com/sharepoint/dev/declarative-customization/list-form-configuration"
    },
    {
      "name": "Use formatting to customize SharePoint — Date functions",
      "description": "Documentation on @now, floor(), and date arithmetic in SharePoint formatting expressions.",
      "url": "https://docs.microsoft.com/sharepoint/dev/declarative-customization/formatting-syntax-reference"
    }
  ]
}
```

- [ ] **Step 3: Verify samples.json is still valid**

```powershell
Get-Content "samples.json" | ConvertFrom-Json | Out-Null; Write-Output "Valid JSON"
```

Expected output: `Valid JSON`

- [ ] **Step 4: Commit**

```powershell
git add samples.json
git commit -m "Register countdown-timer-header in samples.json"
```

---

### Task 5: Manual verification checklist

**Files:** None modified — this is a verification-only task.

Before considering the sample complete, open a SharePoint list with `Title` (text) and `DueDate` (Date and Time) columns. Apply `countdown-timer-header.json` as the Header Format in Configure Layout, then open a form for each of the four urgency states and confirm:

- [ ] **Calm (green)** — set DueDate to 10+ days from today. Header background: dark green `#1e7e34`. Icon: `Timer`. Label: `DAYS LEFT`.
- [ ] **Warning (amber)** — set DueDate to 5 days from today. Header background: amber `#b8860b`. Icon: `Clock`. Label: `DAYS LEFT`.
- [ ] **Urgent (red)** — set DueDate to 2 days from today. Header background: deep red `#c0392b`. Icon: `Warning`. Label: `DAYS LEFT`.
- [ ] **Overdue (crimson)** — set DueDate to 3 days before today. Header background: dark crimson `#6d0000`. Icon: `ErrorBadge`. Label: `OVERDUE`. Day count shows positive integer (not negative).
- [ ] **Due today** — set DueDate to today. Label: `DUE TODAY`. Day count: `0`.
- [ ] Title text renders white on all backgrounds.
- [ ] Due date text (`[$DueDate.displayValue]`) appears in locale format beneath the count.

- [ ] **Take a screenshot** of the sample (any urgency tier — overdue or urgent is most visually striking) and save as `form-samples/countdown-timer-header/assets/screenshot.png`.

- [ ] **Final commit**

```powershell
git add form-samples/countdown-timer-header/assets/screenshot.png
git commit -m "Add countdown-timer-header screenshot"
```
