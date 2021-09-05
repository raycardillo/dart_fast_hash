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

import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';

/// A hash value as computed by a concrete [FastHash] implementation.
abstract class HashValue {
  /// Returns the total number of bits represented in the hash value.
  /// Note that this is not the same as [IntX.bitLength].
  int get numBits;

  /// Returns a string representing the value of this integer in uppercase
  /// hexadecimal notation; for example: '0x1234ABCD'.
  @override
  String toString();

  /// Helper to convert from IntX to hex string in a consistent way by passing
  /// [IntX.toBytes()]
  @pragma('vm:prefer-inline')
  static String _toHexEncode(List<int> bytes) {
    const hexDigits = '0123456789ABCDEF';
    var length = bytes.length;
    var charCodes = Uint8List(length * 2);
    for (var i = length - 1, j = 0; i >= 0; i--) {
      var byte = bytes[i];
      charCodes[j++] = hexDigits.codeUnitAt((byte >> 4) & 0xF);
      charCodes[j++] = hexDigits.codeUnitAt(byte & 0xF);
    }
    return String.fromCharCodes(charCodes);
  }

  // TODO: Consider adding more common helpers if needed.
  // TODO: Consider adding Endian logic for helpers to convert multiple lanes.
}

/// One lane hash value stored in [x].
class OneLaneHashValue<T extends IntX> extends HashValue {
  /// One lane hash value: `x`.
  final T x;

  OneLaneHashValue(this.x);

  @override
  int get numBits => (x is Int64) ? 64 : 32;

  @override
  bool operator ==(Object other) {
    if (other is OneLaneHashValue) {
      return x == other.x;
    }
    return false;
  }

  @override
  int get hashCode => x.hashCode;

  @override
  String toString() => HashValue._toHexEncode(x.toBytes());
}

/// Two lane hash value stored in [x] and [y].
class TwoLaneHashValue<T extends IntX> extends HashValue {
  /// Fist lane of hash value: `x`.
  final T x;

  /// Second lane of hash value: `y`.
  final T y;

  TwoLaneHashValue(this.x, this.y);

  @override
  int get numBits => (x is Int64) ? 128 : 64;

  @override
  bool operator ==(Object other) {
    if (other is TwoLaneHashValue) {
      return x == other.x && y == other.y;
    }
    return false;
  }

  @override
  int get hashCode {
    return x.hashCode ^ (y.hashCode >> 7);
  }

  @override
  String toString() =>
      HashValue._toHexEncode(x.toBytes()) + HashValue._toHexEncode(y.toBytes());
}

/// A sink used to get a [HashValue] out of [FastHash.startChunkedConversion].
class HashValueSink extends Sink<HashValue> {
  // TODO: review value optional - maybe late initialization is better?
  HashValue? _value;

  /// The value added to the sink.
  ///
  /// A value must have been added using [add] before reading the [value].
  HashValue get value => _value!;

  /// Adds [value] to the sink.
  ///
  /// Unlike most sinks, this may only be called once.
  @override
  void add(HashValue value) {
    if (_value != null) {
      throw StateError('add may only be called once.');
    } else {
      _value = value;
    }
  }

  @override
  void close() {
    if (_value == null) {
      throw StateError('add must be called once.');
    }
  }
}
