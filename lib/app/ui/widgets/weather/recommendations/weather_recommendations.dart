import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:weatherbet/app/ui/widgets/weather/status/status_data.dart';

class WeatherRecommendations extends StatelessWidget {
  const WeatherRecommendations({
    super.key,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.windspeed,
    required this.uvIndex,
    required this.visibility,
  });

  final double temperature;
  final int weatherCode;
  final int? precipitationProbability;
  final double? windspeed;
  final double? uvIndex;
  final double? visibility;

  Widget _buildRecommendationItem(
      BuildContext context, IconData icon, String text, Color? iconColor) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (iconColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                text,
                style: context.textTheme.bodyLarge?.copyWith(
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRecommendations(BuildContext context) {
    final List<Widget> recommendations = [];
    
    // Базовые рекомендации по температуре
    if (temperature < -15) {
      recommendations.add(_buildRecommendationItem(
        context,
        IconsaxPlusLinear.cloud_snow,
        'extreme_cold_warning'.tr,
        Colors.blue[700]
      ));
    } else if (temperature < 0) {
      recommendations.add(_buildRecommendationItem(
        context,
        IconsaxPlusLinear.cloud_snow,
        'cold_weather_clothes'.tr,
        Colors.blue
      ));
    } else if (temperature < 10) {
      recommendations.add(_buildRecommendationItem(
        context,
        IconsaxPlusLinear.cloud,
        'cool_weather_clothes'.tr,
        Colors.blueGrey
      ));
    } else if (temperature < 20) {
      recommendations.add(_buildRecommendationItem(
        context,
        IconsaxPlusLinear.sun,
        'mild_weather_clothes'.tr,
        Colors.orange
      ));
    } else if (temperature < 30) {
      recommendations.add(_buildRecommendationItem(
        context,
        IconsaxPlusLinear.sun_1,
        'warm_weather_clothes'.tr,
        Colors.orange
      ));
    } else {
      recommendations.add(_buildRecommendationItem(
        context,
        IconsaxPlusLinear.sun_1,
        'hot_weather_warning'.tr,
        Colors.red
      ));
    }

    // Рекомендации по погодным условиям
    switch (weatherCode) {
      case 0: // Ясно
        if (uvIndex != null && uvIndex! > 7) {
          recommendations.add(_buildRecommendationItem(
            context,
            IconsaxPlusLinear.sun_fog,
            'high_uv_warning'.tr,
            Colors.orange
          ));
        }
        break;
      
      case 1: // Переменная облачность
      case 2:
        if (temperature > 20) {
          recommendations.add(_buildRecommendationItem(
            context,
            IconsaxPlusLinear.sun,
            'perfect_outdoor_weather'.tr,
            Colors.green
          ));
        }
        break;

      case 45: // Туман
      case 48:
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.cloud_fog,
          'fog_warning'.tr,
          Colors.grey
        ));
        break;

      case 51: // Морось
      case 53:
      case 55:
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.cloud_drizzle,
          'light_rain_gear'.tr,
          Colors.blueGrey
        ));
        break;

      case 61: // Дождь
      case 63:
      case 65:
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.cloud_plus,
          'rain_protection'.tr,
          Colors.blue
        ));
        break;

      case 71: // Снег
      case 73:
      case 75:
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.cloud_snow,
          'snow_protection'.tr,
          Colors.blue[300]
        ));
        break;

      case 95: // Гроза
      case 96:
      case 99:
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.cloud_lightning,
          'thunderstorm_warning'.tr,
          Colors.purple
        ));
        break;
    }

    // Рекомендации по ветру
    if ((windspeed ?? 0) > 20) {
      recommendations.add(_buildRecommendationItem(
        context,
        IconsaxPlusLinear.wind_2,
        'strong_wind_warning'.tr,
        Colors.red
      ));
    } else if ((windspeed ?? 0) > 10) {
      recommendations.add(_buildRecommendationItem(
        context,
        IconsaxPlusLinear.wind_2,
        'moderate_wind_warning'.tr,
        Colors.orange
      ));
    }

    // Комбинированные рекомендации
    if (temperature > 25 && (uvIndex ?? 0) > 5) {
      recommendations.add(_buildRecommendationItem(
        context,
        IconsaxPlusLinear.sun_fog,
        'heat_protection'.tr,
        Colors.red
      ));
    }

    if (temperature < 5 && (windspeed ?? 0) > 8) {
      recommendations.add(_buildRecommendationItem(
        context,
        IconsaxPlusLinear.wind_2,
        'wind_chill_warning'.tr,
        Colors.blue
      ));
    }

    // Рекомендации для автомобилистов
    void addDriverRecommendations() {
      if ((visibility ?? 0) < 1000) {
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.car,
          'low_visibility_driving'.tr,
          Colors.red
        ));
      }

      switch (weatherCode) {
        case 45: // Туман
        case 48:
          recommendations.add(_buildRecommendationItem(
            context,
            IconsaxPlusLinear.driver,
            'fog_driving'.tr,
            Colors.orange
          ));
          break;

        case 51: // Морось
        case 53:
        case 55:
        case 61: // Дождь
        case 63:
        case 65:
          recommendations.add(_buildRecommendationItem(
            context,
            IconsaxPlusLinear.driver_2,
            'rain_driving'.tr,
            Colors.blue
          ));
          break;

        case 71: // Снег
        case 73:
        case 75:
          recommendations.add(_buildRecommendationItem(
            context,
            IconsaxPlusLinear.car,
            'snow_driving'.tr,
            Colors.blue[300]
          ));
          break;

        case 95: // Гроза
        case 96:
        case 99:
          recommendations.add(_buildRecommendationItem(
            context,
            IconsaxPlusLinear.car,
            'storm_driving'.tr,
            Colors.purple
          ));
          break;
      }

      if (temperature < 3 && temperature > -3) {
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.driver_refresh,
          'ice_driving'.tr,
          Colors.blue
        ));
      }
    }

    // Рекомендации для велосипедистов
    void addCyclingRecommendations() {
      // Общие условия для велосипедистов
      if (temperature > 30) {
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.routing,
          'hot_cycling'.tr,
          Colors.red
        ));
      } else if (temperature < 5) {
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.routing,
          'cold_cycling'.tr,
          Colors.blue
        ));
      }

      // Проверка ветра для велосипедистов
      if ((windspeed ?? 0) > 15) {
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.route_square,
          'wind_cycling'.tr,
          Colors.orange
        ));
      }

      // Проверка осадков
      if (precipitationProbability != null && precipitationProbability! > 30) {
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.routing,
          'rain_cycling'.tr,
          Colors.blue
        ));
      }

      // Идеальные условия для велосипеда
      if (temperature > 15 && temperature < 25 && 
          (windspeed ?? 0) < 10 && 
          (precipitationProbability ?? 0) < 20) {
        recommendations.add(_buildRecommendationItem(
          context,
          IconsaxPlusLinear.routing_2,
          'perfect_cycling'.tr,
          Colors.green
        ));
      }
    }

    // Добавляем рекомендации
    addDriverRecommendations();
    addCyclingRecommendations();

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  IconsaxPlusLinear.message_question,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(8),
                Text(
                  'recommendations'.tr,
                  style: context.textTheme.titleLarge,
                ),
              ],
            ),
            const Gap(12),
            ..._buildRecommendations(context),
          ],
        ),
      ),
    );
  }
}
