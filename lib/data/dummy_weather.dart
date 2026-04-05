import '../models/weather_info.dart';

class DummyWeather {
  DummyWeather._();

  static const WeatherInfo current = WeatherInfo(
    condition: 'Partly Cloudy',
    tempCelsius: 31,
    humidity: 78,
    riskLevel: 'high',
    riskMessage: 'High humidity today — risk of fungus',
    icon: '⛅',
  );
}
