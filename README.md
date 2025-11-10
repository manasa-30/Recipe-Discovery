Recipe Discovery App

A modern Flutter application to browse, search, and favorite delicious recipes.
This app uses Provider for state management, HTTP API calls to fetch data, and supports light/dark themes for better user experience.

🚀 Features

✅ Fetch real-time recipes from DummyJSON API

✅ Search recipes by name or category
✅ Add and remove recipes from favorites
✅ View detailed recipe information including:

Ingredients

Step-by-step instructions

Preparation and cooking time
✅ Toggle Dark/Light mode in settings
✅ Smooth UI built with Flutter Material components

Tech Stack
Component	Description
Framework	Flutter
State Management	Provider
API	DummyJSON REST API
HTTP Client	http package
Language	Dart

APP Structure:

lib/
│
├── main.dart
│
├── models/
│   └── recipe.dart
│
├── providers/
│   ├── recipe_provider.dart
│   └── theme_provider.dart
│
├── screens/
│   ├── main_screen.dart
│   ├── recipe_list_screen.dart
│   ├── recipe_detail_screen.dart
│   ├── favorites_screen.dart
│   └── settings_screen.dart
│
└── widgets/
    └── recipe_card.dart


🌐 API Reference

Recipes are fetched from the public DummyJSON API:
🔗 https://dummyjson.com/recipes

Key Functionalities:

Feature	Description
Home Page	Displays recipe list fetched from API
Search Bar	Filters recipes dynamically
Favorites Page	Stores user’s favorite recipes locally
Details Page	Shows ingredients and step-by-step cooking process
Settings Page	Enables theme switching


