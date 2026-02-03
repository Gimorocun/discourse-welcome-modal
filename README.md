# Discourse First Time Experience

A Discourse theme component that provides a welcoming onboarding modal for new users, guiding them to engage with the community.

## Overview

This theme component displays a friendly modal dialog to new users when they first visit your Discourse forum. The modal highlights key ways to participate in the community and encourages immediate engagement through clear calls-to-action.

## Features

- **Automatic Display**: Shows a welcome modal to users on their first visit
- **Smart Targeting**: Only appears for users who joined after the launch date (configurable)
- **Persistent Dismissal**: Remembers when users have seen the modal (via localStorage)
- **Grace Period**: Configurable time window for showing the modal to new users
- **Three Engagement Paths**:
  - **Ask the Community**: Directs users to ask questions
  - **Share Your Expertise**: Encourages showcasing work
  - **Help Others**: Points to unanswered questions
- **Responsive Design**: Adapts to mobile and desktop viewports
- **Debug Tools**: Built-in query parameters for testing

## Installation

1. Navigate to your Discourse Admin panel
2. Go to **Admin** → **Customize** → **Themes**
3. Click **Install** → **From a git repository**
4. Enter the repository URL: `https://github.com/noahLovell/discourse-first-time-experience`
5. Click **Install**
6. Enable the theme component on your active theme

## Configuration

### Launch Date & Grace Period

Edit [`walkthrough-state.js`](javascripts/discourse/lib/walkthrough-state.js) to customize:

```javascript
const LAUNCH_DATE = new Date("2026-02-01");
const GRACE_PERIOD_MONTHS = 6;
```

- **LAUNCH_DATE**: Users created before this date won't see the modal
- **GRACE_PERIOD_MONTHS**: How long after LAUNCH_DATE to continue showing the modal to new users

### Forum Sections

Customize the three sections in [`first-time-modal.gjs`](javascripts/discourse/connectors/above-main-container/first-time-modal.gjs):

```javascript
get forumSections() {
  return [
    {
      id: "ask-the-community",
      imgUrl: "https://example.com/image.png",
      title: "Your Title",
      subtitle: "Your description",
      btnLabel: "Button text",
      action: "/path/to/action"
    },
    // ... more sections
  ];
}
```

## Testing & Debugging

The component includes built-in debugging tools via URL parameters:

| Parameter | Effect |
|-----------|--------|
| `?simulate_new_user=true` | Forces the modal to show (ignores localStorage) |
| `?simulate_existing_user=true` | Forces the modal to hide |
| `?clear_walkthrough=true` | Clears the localStorage flag |

**Example**: `https://yourforum.com/?simulate_new_user=true`

## File Structure

```
discourse-first-time-experience/
├── about.json                      # Theme metadata
├── common/
│   └── common.scss                 # Styling for the modal
├── javascripts/
│   └── discourse/
│       ├── api-initializers/
│       │   └── theme-initializer.gjs    # Initializes the walkthrough
│       ├── connectors/
│       │   └── above-main-container/
│       │       └── first-time-modal.gjs # Modal component
│       └── lib/
│           └── walkthrough-state.js     # State management & logic
```

## How It Works

1. **Initialization**: The theme initializer checks if the current user should see the walkthrough
2. **Eligibility Check**: Users are eligible if they:
   - Are logged in
   - Created their account after `LAUNCH_DATE`
   - Created their account within the grace period
   - Haven't seen the walkthrough before (localStorage check)
3. **Display**: If eligible, the modal appears 500ms after page load
4. **Interaction**: Users can click a section button or close the modal
5. **Persistence**: Once dismissed or clicked, the `seen` flag is stored in localStorage

## Browser Support

- Requires modern browsers with localStorage support
- Fully responsive for mobile and desktop
- Tested on latest versions of Chrome, Firefox, Safari, and Edge

## Development

### Local Setup

1. Clone the repository
2. Make your changes to the appropriate files
3. Test using the debug parameters
4. Submit a pull request

### Key Components

- **WalkthroughState**: Reactive state management using Glimmer tracking
- **FirstTimeModal**: Main modal component using Discourse's DModal
- **Theme Initializer**: API initializer that triggers the modal display

## Customization Tips

### Change Modal Appearance

Edit [`common.scss`](common/common.scss) to customize colors, spacing, and layout.

### Modify Timing

Adjust the delay in [`theme-initializer.gjs`](javascripts/discourse/api-initializers/theme-initializer.gjs):

```javascript
setTimeout(() => {
  walkthroughState.isVisible = true;
}, 500); // Change delay here (milliseconds)
```

### Add More Sections

Add additional objects to the `forumSections` array in the modal component. Each section requires:
- `id`: Unique identifier
- `imgUrl`: Image URL for the section
- `title`: Section heading
- `subtitle`: Descriptive text
- `btnLabel`: Button text
- `action`: URL or route to navigate to

## License

[Add your license here]

## Credits

Developed for Discourse forums to improve new user onboarding and community engagement.

## Support

For issues, questions, or contributions:
- **Issues**: [GitHub Issues](https://github.com/noahLovell/discourse-first-time-experience/issues)
- **Discussions**: [Discourse Meta](https://meta.discourse.org/)

## Version

Current version: 0.0.1

## Requirements

- Discourse version: 1.8.0+
- Theme component (not a standalone theme)
