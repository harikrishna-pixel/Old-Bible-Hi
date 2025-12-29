import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biblebookapp/view/constants/theme_provider.dart';

class Images {
  static String bgImage(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/night_mode.png'
        : 'assets/lightMode/day_bg.png';
  }

  static String home(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/home.png'
        : 'assets/lightMode/icons/home.png';
  }

  static String reading(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/reading_book.png'
        : 'assets/lightMode/icons/reading_book.png';
  }

  static String daily(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/daily_verse.png'
        : 'assets/lightMode/icons/daily_verse.png';
  }

  static String wallpaper = 'assets/wallpaper.png';
  static String quote = 'assets/quote.png';

  static String myLibrary(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/mylibarary.png'
        : 'assets/lightMode/icons/my_library.png';
  }

  static String setting(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/settings_1.png'
        : 'assets/lightMode/icons/settings.png';
  }

  static String feedback(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/feedback.png'
        : 'assets/lightMode/icons/feedback.png';
  }

  static String share(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/share.png'
        : 'assets/lightMode/icons/share-1.png';
  }

  static String rateUs(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/ratesus.png'
        : 'assets/lightMode/icons/rates_us.png';
  }

  static String aboutUs(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/about.png'
        : 'assets/lightMode/icons/about_us.png';
  }

  static String search(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/search.png'
        : 'assets/lightMode/icons/search.png';
  }

  static String notificationBell(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/icons/bell.png'
        : 'assets/lightMode/icons/bell.png';
  }

  static String appLogo(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/lightMode/icons/logo.png'
        : 'assets/lightMode/icons/logo.png';
  }

  static String adFree(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/adFree.png'
        : 'assets/adFree.png';
  }

  static String bookmarkPlaceHolder(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/Bookmark icons/cloud-fog2-fill.png'
        : 'assets/Bookmark icons/cloud-fog2-fill.png';
  }

  static String highlightsPlaceHolder(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/images/Highlights.png'
        : 'assets/lightMode/images/Highlights.png';
  }

  static String notesPlaceHolder(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/images/notes.png'
        : 'assets/lightMode/images/notes.png';
  }

  static String underlinePlaceHolder(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/images/Underline.png'
        : 'assets/lightMode/images/Underline.png';
  }

  static String imagesPlaceHolder(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/images/image.png'
        : 'assets/lightMode/images/image.png';
  }

  static String searchPlaceHolder(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/nightMode/images/search.png'
        : 'assets/lightMode/images/search.png';
  }

  static String aboutPlaceHolder(BuildContext context) {
    return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
        ? 'assets/lightMode/images/about.png'
        : 'assets/nightMode/images/about.png';
  }
}
