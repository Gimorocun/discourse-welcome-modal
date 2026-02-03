# Discourse Welcome Modal

A Discourse theme component that displays a customizable welcome modal to help onboard new users and guide them through their first-time experience.

## Overview

This component automatically displays a welcome modal to users based on configurable criteria, helping communities create a better onboarding experience for both new and existing members.

## Features

- **Smart Targeting**: Displays the modal to different user groups based on registration date and feature activation
- **Grace Period**: Configurable grace period for existing users when the feature is first enabled
- **Customizable Cards**: Display custom content cards in either grid or list layout
- **Persistent State**: Remembers when users have seen the modal to avoid repeated displays
- **Responsive Design**: Works across desktop and mobile devices

## How It Works

The modal displays based on three scenarios:

1. **New Users**: Shows to all users who registered after the feature was enabled
2. **Grace Period**: Silently marks existing users as "seen" during a configurable grace period
3. **Legacy Users**: Shows to existing users after the grace period has expired

## Configuration

### Settings

- `feature_enabled_date`: Date when the modal feature was activated (YYYY-MM-DD format)
- `grace_period_months`: Number of months to give existing users before showing the modal
- `card_layout`: Display cards in "grid" or "list" format
- `card_content`: Configure custom cards with content and actions

### Customization

The modal title and button text can be customized.

## Installation

1. Add this theme component to your Discourse instance
2. Configure the settings in your admin panel
3. Customize the card content and layout as needed

**Author**: Noah Lovell  
**Version**: 0.0.1  