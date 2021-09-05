/*
 * fast_hash dart library
 * Copyright (c) 2021 Raymond Cardillo (of Cardillo's Creations)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';

/// A bitmask that limits an integer to 8 bits.
const mask8 = 0xFF;

/// A bitmask that limits an integer to 32 bits.
const mask32 = 0xFFFFFFFF;

/// A bitmask that limits an integer to 64 bits.
const mask64 = 0xFFFFFFFFFFFFFFFF;

/// Print bytes as a comma separated string of hexadecimal values.
/// Can sometimes be helpful for debugging.
printBytes(List<int> bytes, int start, [int? end]) {
  print(bytes
      .sublist(start, end)
      .map((e) => "0x" + e.toRadixString(16))
      .reduce((value, element) => value + ", " + element));
}

/// Bitwise rotates [val] to the left by [shift],
/// obeying 32-bit overflow semantics.
@internal
@pragma('vm:prefer-inline')
Int32 rotl32(Int32 val, int shift) {
  int modShift = shift & 31;
  return ((val << modShift) & mask32) |
      ((val.shiftRightUnsigned(32 - modShift)) & mask32);
}

/// Bitwise rotates [val] to the left by [shift],
/// obeying 64-bit overflow semantics.
@internal
@pragma('vm:prefer-inline')
Int64 rotl64(Int64 val, int shift) {
  int modShift = shift & 63;
  return ((val << modShift) & mask64) |
      ((val.shiftRightUnsigned(64 - modShift)) & mask64);
}

@internal
@pragma('vm:prefer-inline')
Int32 int32FromBytes(Iterable<int> bytes) {
  int value = 0;
  int shift = 0;
  for (int byte in bytes.take(4)) {
    value |= (byte & mask8) << shift;
    shift += 8;
  }
  return Int32(value);
}

@internal
@pragma('vm:prefer-inline')
Int64 int64FromBytes(Iterable<int> bytes, [int num = 8]) {
  int value = 0;
  int shift = 0;
  for (int byte in bytes.take(num)) {
    value |= (byte & mask8) << shift;
    shift += 8;
  }
  return Int64(value);
}
