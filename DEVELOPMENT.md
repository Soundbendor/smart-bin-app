# Development and Debugging Details

With the development of this application, there are a few things to consider.

## Crashes During Development

Due to how the internal SQLite database was set up, when making breaking changes to the database, old data may cause problems. To fix this, try deleting the app or the app's data in the emulator or device before re-running the app.

In addition, the codebase currently relies on a relatively new version of Flutter (3.22+). If running into build problems, this may be the cause. To resolve this issue, upgrade Flutter to the latest version. You may also need to update Android Studio.

## `debug()`

The `debug()` function is a custom function that prints out debug information to the console. It is used to print out information about the state of the application, such as the current user, the current user's data, and the current user's settings. It wraps the `print()` function allowing it to be used in development, but not doing anything in production.

## Architecture

The project structure looks like so:

- `lib/` contains all the Dart code for the application
  - `database/` contains the models and code for interacting with the SQLite database
  - `pages/` contains logical sections of the app
    - `main/` contains the home and help pages
    - `detection/` contains the detection listing, annotation, and detail pages
    - `setup/` contains the setup pages
  - `util/` contains utility functions and classes
    - `providers/` contains the providers for the app, which are a kind of global state
  - `widgets/` contains widgets for the app. These may be reusable components, or complex components that may be used in a single place.

## App Icon and Splash Screen

The `flutter_native_splash` and `flutter_launcher_icons` packages are used to generate the app icon and splash screen. However, there are some custom changes in the `android` directories that should be noted. These changes are there to ensure that the app icon and splash screen are displayed correctly and should not be overridden accidentally.

## `.env` Files

For development purposes, it can be helpful to have an `.env` files when testing features related to the API. To do so, place an `.env` file at `assets/data/.env`. The required fields are `API_KEY`, which is the key for accessing the API and `DEVICE_ID`, which is the identifier for a Smart Compost Bin.

## Developing API Features and Main Section

Often, to test the API features or main section, the `main.dart` file will need to be temporarily modified to skip the set up process. We have done this by changing this line:

```dart
// From this:
initialLocation: widget.skipSetup ? '/main' : '/set-up',

// To this:
initialLocation: !widget.skipSetup ? '/main' : '/set-up',
```

After reaching the desired screen, this should be reverted to avoid hassle later.

## Documentation

We try to document the codebase as much as possible. This includes documenting functions, classes, and variables. Also, when importing packages, we sort them based on whether they are Flutter, Dart, third-party, or local packages. This makes it easier to see what packages are being used in the codebase.

## Automated Documentation

We upload the Dart documentation to GitHub pages using `dart doc` automatically when changes are pushed to `dev`. However, this requires a token to be set up in the repository secrets. If it expires, someone will need to create a new token.

## Repository Rules

Currently, the repository is set up to require a Pull Request with at least two approvals before merging. Pull Requests also have tests run on them, but are not currently required to pass before merging.

## Next Steps

There are a few TODOs in the codebase that should be addressed. These include:

- Adding proper migrations to the database
- Adding more tests to the codebase
- Adjusting the `imageId` for detections to be more unique
- Fixing various bugs in the codebase (see Issues for more details)
