#!/bin/bash

# Create base directories
mkdir -p lib/models
mkdir -p lib/providers
mkdir -p lib/screens

# Create files
touch lib/main.dart
touch lib/models/models.dart
touch lib/models/mood_entry.dart
touch lib/providers/mood_provider.dart
touch lib/providers/theme_provider.dart
touch lib/screens/home_screen.dart
touch lib/screens/log_screen.dart
touch lib/screens/history_screen.dart
touch lib/screens/analytics_screen.dart
touch README.md

# Add optional assets folder
mkdir -p assets/images

# Print success message
echo "✅ Folder structure for DailyPulse (Hive + Provider) has been created!"
echo "Now paste the provided code snippets into the corresponding files."
