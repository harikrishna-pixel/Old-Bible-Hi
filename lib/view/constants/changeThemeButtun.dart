import 'package:biblebookapp/core/notifiers/download.notifier.dart';
import 'package:biblebookapp/view/constants/theme_provider.dart';
import 'package:biblebookapp/view/widget/home_content_edit_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeThemeButtonWidget extends StatelessWidget {
  const ChangeThemeButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    debugPrint("sz current width - $screenWidth ");
    SavePreference pre = SavePreference();
    if (themeProvider.isDarkMode) {
      return InkWell(
          onTap: () async {
            // Check subscription before allowing theme change
            final downloadProvider =
                Provider.of<DownloadProvider>(context, listen: false);
            final subscriptionPlan =
                await downloadProvider.getSubscriptionPlan();
            final hasSubscriptionPlan = subscriptionPlan != null &&
                subscriptionPlan.isNotEmpty &&
                ['platinum', 'gold', 'silver']
                    .contains(subscriptionPlan.toLowerCase());
            // Also check if ads are disabled, which indicates premium access
            final adsDisabled = !downloadProvider.adEnabled;
            final isSubscribed = hasSubscriptionPlan || adsDisabled;

            if (!isSubscribed) {
              // Show premium popup for unsubscribed users
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const PremiumAccessDialog(),
              );
              return;
            }

            // User is subscribed, proceed with theme change
            final provider = Provider.of<ThemeProvider>(context, listen: false);
            provider.toggleTheme(false);
            pre.setTheme("light");
          },
          child: Image.asset(
            "assets/dark_modes/Dark mode.png",
            height: screenWidth > 450 ? 30 : 20,
            width: screenWidth > 450 ? 34 : 24,
          ));
    } else {
      return InkWell(
          onTap: () async {
            // Check subscription before allowing theme change
            final downloadProvider =
                Provider.of<DownloadProvider>(context, listen: false);
            final subscriptionPlan =
                await downloadProvider.getSubscriptionPlan();
            final hasSubscriptionPlan = subscriptionPlan != null &&
                subscriptionPlan.isNotEmpty &&
                ['platinum', 'gold', 'silver']
                    .contains(subscriptionPlan.toLowerCase());
            // Also check if ads are disabled, which indicates premium access
            final adsDisabled = !downloadProvider.adEnabled;
            final isSubscribed = hasSubscriptionPlan || adsDisabled;

            if (!isSubscribed) {
              // Show premium popup for unsubscribed users
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const PremiumAccessDialog(),
              );
              return;
            }

            // User is subscribed, proceed with theme change
            final provider = Provider.of<ThemeProvider>(context, listen: false);
            provider.toggleTheme(true);
            pre.setTheme("dark");
          },
          child: Image.asset("assets/light_modes/Light mode.png",
              height: screenWidth > 450 ? 30 : 20,
              width: screenWidth > 450 ? 34 : 24));
    }
    // return Switch.adaptive(
    //   value: themeProvider.isDarkMode,
    //   onChanged: (value) {
    //     final provider = Provider.of<ThemeProvider>(context, listen: false);
    //     provider.toggleTheme(value);
    //   },
    //);
  }
}
