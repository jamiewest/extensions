abstract class SystemClock {
  Duration get utcNow => DateTime.now().timeZoneOffset;
}
