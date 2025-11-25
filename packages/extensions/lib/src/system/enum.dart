// Mixin to create Enum for bitflags uses.
mixin EnumFlags on Enum {
  int get value => 1 << index;
  int operator |(EnumFlags other) => value | other.value;
  int operator &(EnumFlags other) => value & other.value;
  int operator ^(EnumFlags other) => value ^ other.value;
}

// Extension `int` to verify that value contains the enum flag.
extension EnumFlagsExtension on int {
  bool hasFlag(EnumFlags flag) => this & flag.value == flag.value;
}
