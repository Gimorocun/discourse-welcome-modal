| | | |
| - | - | - |
| :discourse2: | **Summary** | **Watch Category Button** adds a marker span that becomes a “Watch this category” button in posts. |
| :eyeglasses: | **Preview** | _Add screenshot/GIF here_ |
| :hammer_and_wrench: | **Repository** | <https://github.com/pacharanero/discourse-watch-category-button> |
| :open_book: | **New to Discourse Themes?** | [Beginner’s guide to using Discourse Themes](https://meta.discourse.org/t/beginners-guide-to-using-discourse-themes/91966) |

[wrap=theme-install-button repoName="Watch Category Button" repoUrl="https://github.com/pacharanero/discourse-watch-category-button"]
Install this theme component
[/wrap]

[quote]

:discourse2: Use the buttons below to open a support, bug, UX, or feature topic for this theme component.

<kbd>[:question:&nbsp;**Support**](https://meta.discourse.org/new-topic?category_id=6&tags=watch-category-button "Ask for support on configuring and using Watch Category Button")</kbd>
<kbd>[:bug:&nbsp;**Bug**](https://meta.discourse.org/new-topic?category_id=1&tags=watch-category-button "Report a bug for Watch Category Button")</kbd>
<kbd>[:eyes:&nbsp;**UX**](https://meta.discourse.org/new-topic?category_id=9&tags=watch-category-button "Discuss the user experience of Watch Category Button")</kbd>
<kbd>[:bulb:&nbsp;**Feature**](https://meta.discourse.org/new-topic?category_id=2&tags=watch-category-button "Request or discuss new features")</kbd>

[/quote]

> :information_source: This theme component uses the logged‑in user’s session to update category notification levels; no API keys are required.

## Features

- Add a “Watch this category” button inside posts using a sanitizer‑safe span.
- Clicking the button sets the **current user’s** category notification level to **Watching**.
- Only posts authored by allowed groups (default: `staff`) are transformed into buttons.
- Supports targeting a specific category ID or the current post’s category.

## Usage

**Set a specific category**

```
<span data-watch-category="3">Watch this category</span>
```

**Use the current post’s category**

```
<span data-watch-category="current">Watch this category</span>
```

## Settings

This component does not include theme settings yet. To change who can create buttons, edit:

- `ALLOWED_GROUPS` in `javascripts/discourse/api-initializers/theme-initializer.gjs`

## Notes

- Requires an explicit user click (no silent changes).
- The change mirrors the native category notification menu behavior.
- Category page header updates on next visit without a full page refresh.
