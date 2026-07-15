# Gym Coach

Offline workout tracker built with Flutter for Android. Dark-mode first, Material You inspired UI for your personal coach program.

## Features

- **Coach program from JSON** — replace `assets/data/workout_program.json` without touching UI
- **Workout sessions** — set logging, previous weight, drop set / fail badges, expandable cards
- **Rest timer** — 60 / 90 / 120s with sound + vibration
- **Progress** — body measurements + strength history charts (`fl_chart`)
- **Calendar & statistics** — streaks, volume, favorites
- **Settings** — theme (dark / light / system), AMOLED black, units, backup / restore
- **100% offline** — Hive + SharedPreferences, no Firebase / backend

## Architecture

Clean Architecture, feature-first folders:

```
lib/
  core/          # theme, router, widgets, services, utils
  data/          # models, datasources, repositories
  features/      # splash, home, workout, summary, progress, calendar, statistics, settings
  providers/     # Riverpod
```

State: **Riverpod** · Routing: **GoRouter** · DB: **Hive** · Prefs: **SharedPreferences**

## Run

```bash
flutter pub get
flutter run
```

Build release APK:

```bash
flutter build apk --release
```

## Customize the workout program

Edit `assets/data/workout_program.json`. The app loads it dynamically on launch.

## Backup

Settings → Backup / Export creates a JSON file you can share. Import restores logs, measurements, strength history, and settings.
