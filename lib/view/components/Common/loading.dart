import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String? message;

  const Loading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Config().init(context);
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: _calculateWidth(message),
          constraints: BoxConstraints(
            maxWidth: Config.screenWidth! * 0.7,
            minHeight: 130,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Config.surfaceDark.withOpacity(0.95)
                : Config.surfaceLight.withOpacity(0.98),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated progress indicator with pulse effect
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation(
                    isDark ? Config.accentColor : Config.primaryColor,
                  ),
                ),
              ),

              if (message != null) ...[
                const SizedBox(height: 20),
                _buildMessageText(context, message!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _calculateWidth(String? message) {
    if (message == null) return 130;

    // Calculate width based on message length
    final baseWidth = 130.0;
    final messageLength = message.length;

    if (messageLength <= 15) return baseWidth;
    if (messageLength <= 30) return baseWidth + 40;
    return baseWidth + 80;
  }

  Widget _buildMessageText(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Config.screenWidth! * 0.5,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? Config.textLight : Config.textDark.withOpacity(0.8),
          fontWeight: FontWeight.w600,
          fontSize: _calculateFontSize(message),
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  double _calculateFontSize(String message) {
    final length = message.length;
    if (length <= 20) return 14;
    if (length <= 40) return 13;
    return 12;
  }
}

// Optional: Enhanced loading with different styles
class LoadingStyle {
  static const basic = 0;
  static const withBackground = 1;
  static const minimal = 2;
}

class EnhancedLoading extends StatelessWidget {
  final String? message;
  final int style;
  final double size;

  const EnhancedLoading({
    super.key,
    this.message,
    this.style = LoadingStyle.basic,
    this.size = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case LoadingStyle.minimal:
        return _buildMinimalLoading(context);
      case LoadingStyle.withBackground:
        return _buildWithBackground(context);
      default:
        return Loading(message: message);
    }
  }

  Widget _buildMinimalLoading(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3.0 * size,
            valueColor: AlwaysStoppedAnimation(
              isDark ? Config.accentColor : Config.primaryColor,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Config.textLight : Config.textDark,
                fontSize: 12 * size,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWithBackground(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          width: 100 * size,
          height: 100 * size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(16 * size),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3.0 * size,
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              if (message != null) ...[
                SizedBox(height: 8 * size),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10 * size,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
