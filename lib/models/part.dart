class Part {
  String serial;
  String module;
  String email;
  String flightHours;
  String remainingCycles;

  Part({
    required this.serial,
    required this.module,
    required this.email,
    required this.flightHours,
    required this.remainingCycles,
  });

  Map<String, dynamic> toMap() {
    return {
      "serial": serial,
      "module": module,
      "email": email,
      "flightHours": flightHours,
      "remainingCycles": remainingCycles,
    };
  }
}