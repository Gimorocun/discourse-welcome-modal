# Spec: Watch Category Button (Discourse Theme Component)

## Goal
Provide a simple, embeddable “Watch this category” button inside posts that, when clicked by a logged-in user, sets their own notification level for a category to **Watching**.

## Post Markup (sanitizer‑safe)
Use a single data attribute that survives cooking/sanitization:

```
<span data-watch-category="3">Watch this category</span>
```

- Attribute name is the marker.
- Attribute value is the category ID.

## Theme Component (initializer)
Implement as a Discourse theme component initializer:

Path:
- javascripts/discourse/api-initializers/theme-initializer.gjs

Behavior:
- Find elements with `[data-watch-category]` inside cooked posts.
- Replace each with a `<button>`.
- On click, POST to the category notifications endpoint and set to Watching.

Endpoint:
- **POST** `/category/{categoryId}/notifications`
- Data: `notification_level=3`

## UX
- Button text defaults to the node text, else “Watch this category”.
- On click: disable, show “Updating…”, then “Watching ✓” on success.
- On error: restore original text and show the Discourse AJAX error.

## Requirements / Constraints
- Must be an explicit user action (click) — no silent changes.
- Use the logged-in user’s session (no API keys client-side).
- Avoid relying on `class=` in post HTML (often stripped).

## Security / Abuse Notes
- No drive‑by or third‑party forced changes; only the user’s click triggers the change.
- Social‑engineering risk exists (misleading button text).
- Optional mitigations: allowlist category IDs, staff-only render, or add a confirmation dialog.

## Troubleshooting Notes
- If background JS fails (e.g., 429 rate limits), decorators may not run. Disable chat/presence if needed during testing.
- Ensure the initializer lives in the theme’s api-initializers directory (not a header/body field).
