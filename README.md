# Discourse Watch Category Button

Theme component that enables staff users to create a “Watch this category” button. Clicking it sets the **current user’s** category notification level to Watching. It uses the Discourse API via the current logged-in user’s session - behind the scenes the operation is the same as going to the category page and clicking the 'Watching' bell.

## Why is this needed?

Although I have over a decade of experience managing Discourses for communities, I still find that many users are not aware of the category notification settings. This component makes it easy for staff to add a button in posts (e.g., welcome posts, announcements) to encourage users to watch important categories. I hope this will help improve user engagement and ensure that important updates are not missed.

## How it works

### Put a 'Watch Category *X*' button in a post

Staff users can use this markup inside a post to create a button:

```
<span data-watch-category="3">Watch the category with categoryId 3</span>
```

On posting, the theme component transforms that span into a button.
If the user clicks on the button, the user's notification level for categoryId 3 will be set to Watching.
To find out the category ID, go to that category and look at the URL. For example, in `https://discourse.example.com/c/support/5`, the category ID is `5`.

To target the **current post’s category**, use:

```
<span data-watch-category="current">Watch this category</span>
```

- `data-watch-category` value = categoryId to watch (or `current` watches the post’s category)
- `<span>` inner text => button label (defaults to “Watch this category” if empty)

### Who can create buttons

Only posts **authored by users in the allowlist** are transformed into buttons. By default, only `staff` is allowed. All users can see and click the rendered buttons.

### What happens on click

- POST `/category/{id}/notifications` with `notification_level=3`
- Button text updates to “Watching ✓”
- Sometimes a page refresh is needed to start seeing the new notification level in the 'bell' Watching icon.

## Security and privacy considerations

- These buttons can only be created by #staff users (at the moment)
- Requires an explicit user click to change notification settings.
- No API keys are used; it relies on the logged-in session.

## Roadmap ideas

- Make the groups who can create buttons configurable via theme settings.
- Make the button style configurable via theme settings.
- Make the Notification Level configurable (e.g., Tracking, Watching, Muted).

## Contributing

I'm happy to accept contributions! Please open issues or pull requests on the GitHub repository.

Ideally let's improve _this_ component rather than forking it to change the ALLOWED_GROUPS or other hard-coded values!
