# Discourse First-Time Experience Theme Component

A Discourse theme component that displays a welcome modal to new members, helping them get oriented and engaged with your community.

## Overview

This theme component creates a smart onboarding experience by showing a customizable modal dialog to first-time users. The modal displays cards with information, links, or actions to help new members get started in your community.

## Features

- **Smart Display Logic**: Shows modal only to appropriate users based on join date and configuration
- **Grace Period Support**: Allows existing members a grace period before showing the modal
- **Customizable Cards**: Display multiple information cards with images, titles, descriptions, and action buttons
- **Flexible Layout**: Choose between grid or list layout for cards
- **External & Internal Links**: Support for both internal Discourse routes and external URLs
- **Persistent State**: Remembers when users have seen the modal to avoid showing it repeatedly
- **Responsive Design**: Works across desktop and mobile devices

## How It Works

### Display Logic

The modal uses intelligent logic to determine when to show:

1. **New Members**: Users who joined after the configured `feature_enabled_date` see the modal immediately
2. **Grace Period**: Existing members get a grace period (default 3 months) where the modal is silently marked as seen
3. **After Grace Period**: Long-time members who haven't seen the modal will see it once the grace period expires
4. **One-Time Display**: Uses localStorage to ensure each user only sees the modal once

### Technical Implementation

- **Component**: `first-time-modal.gjs` - The main modal component with display logic
- **Initializer**: `theme-initializer.gjs` - Renders the modal in the appropriate outlet
- **Settings**: Configurable through Discourse admin panel
- **Localization**: Supports internationalization through locale files

## Configuration

### Settings

Configure the component through your Discourse admin panel:

#### `feature_enabled_date`
- **Type**: String (YYYY-MM-DD format)
- **Default**: "2026-01-01" 
- **Description**: The date when this feature was enabled. Users who joined after this date will see the modal.

#### `grace_period_months`
- **Type**: Integer
- **Default**: 3
- **Description**: Number of months to give existing members before showing them the modal.

#### `card_layout`
- **Type**: Enum (grid/list)
- **Default**: "grid"
- **Description**: Layout style for the information cards in the modal.

#### `card_content`
- **Type**: Objects array
- **Description**: Array of cards to display in the modal. Each card can contain:
  - `id`: Unique identifier
  - `imgUrl`: Upload/URL for card image
  - `title`: Card title text
  - `subtitle`: Card description text
  - `btnLabel`: Button text
  - `action`: URL or Discourse route for the button action

### Example Card Configuration

```yaml
card_content:
  - id: "welcome"
    imgUrl: "/uploads/welcome.png"
    title: "Welcome to Our Community"
    subtitle: "Learn about our community guidelines and values"
    btnLabel: "Read Guidelines"
    action: "/guidelines"
  - id: "introduce"
    imgUrl: "/uploads/introduce.png"
    title: "Introduce Yourself"
    subtitle: "Tell us about yourself in our introductions category"
    btnLabel: "Introduce Yourself"
    action: "/c/introductions"
```

## Localization

The component supports internationalization. Default strings are in English:

- `first_time_member.modal_title`: "Join the conversation"
- `first_time_member.modal_close_btn`: "Done"

Add translations to your locale files as needed.

## Installation

1. Go to your Discourse Admin Panel
2. Navigate to Appearance → Themes
3. Click "Install" and select "From a git repository"
4. Enter the repository URL
5. Install as a Theme Component
6. Add the component to your active theme
7. Configure the settings through the theme settings panel

## Browser Compatibility

- Uses modern JavaScript features (async/await, localStorage)
- Compatible with all modern browsers
- Graceful degradation for older browsers

## File Structure

```
├── about.json                    # Theme metadata
├── settings.yaml                 # Configuration schema
├── locales/
│   └── en.yml                   # English translations
├── javascripts/
│   └── discourse/
│       ├── components/
│       │   └── first-time-modal.gjs    # Main modal component
│       └── api-initializers/
│           └── theme-initializer.gjs   # Component initializer
└── common/
    └── common.scss              # Styling (if needed)
```

## Contributing

When contributing to this theme component:

1. Test with different user scenarios (new users, existing users, grace period)
2. Ensure accessibility compliance
3. Test across different screen sizes
4. Verify locale string functionality

## License

This theme component is released under the standard Discourse theme component license.