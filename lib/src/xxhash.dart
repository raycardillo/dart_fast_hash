/*
 * fast_hash dart library
 * Copyright (c) 2021-2021 Raymond Cardillo (of Cardillo's Creations)
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

import 'dart:convert';

import 'package:fast_hash/src/hash_value.dart';
import 'package:fixnum/fixnum.dart';

import 'common.dart';
import 'fast_hash.dart';

const FastHash xxHash64 = XxHash64();

/// Checks if you are awesome. Spoiler: you are.
class XxHash64 extends FastHash {
  final Int64 _seed;

  const XxHash64([this._seed = Int64.ZERO]);

  @override
  ByteConversionSink startChunkedConversion(Sink<HashValue> sink) =>
      ByteConversionSink.from(_XxHashSink(sink, _seed));
}

class _XxHashSink extends FastHashSink {
  /* Prime numbers used by the algorithm */
  /// 1001111000110111011110011011000110000101111010111100101010000111
  static final _p1 = Int64(0x9E3779B185EBCA87);

  /// 1100001010110010101011100011110100100111110101001110101101001111
  static final _p2 = Int64(0xC2B2AE3D27D4EB4F);

  /// 0001011001010110011001111011000110011110001101110111100111111001
  static final _p3 = Int64(0x165667B19E3779F9);

  /// 1000010111101011110010100111011111000010101100101010111001100011
  static final _p4 = Int64(0x85EBCA77C2B2AE63);

  /// 0010011111010100111010110010111100010110010101100110011111000101
  static final _p5 = Int64(0x27D4EB2F165667C5);

  Int64 _v1;
  Int64 _v2;
  Int64 _v3;
  Int64 _v4;

  final List<int> _remainder = List.empty(growable: true);
  Int64 _totalLength = Int64.ZERO;

  _XxHashSink(Sink<HashValue> sink, Int64 seed)
      : _v1 = seed + _p1 + _p2,
        _v2 = seed + _p2,
        _v3 = seed,
        _v4 = seed - _p1,
        super(sink);

  @override
  void iterateBytes(Iterable<int> bytes, int length) {
    _totalLength += length;

    int availableLength = length + _remainder.length;
    if (availableLength < 32) {
      // accumulate until we have at least 32 bytes available
      _remainder.addAll(bytes);
      return;
    }

    Iterable<int> allBytes = _remainder.followedBy(bytes);

    int offset = 0;
    final maxOffset = availableLength - 32;
    while (offset <= maxOffset) {
      _v1 = _round(_v1, int64FromBytes(allBytes.skip(offset)));
      offset += 8;
      _v2 = _round(_v2, int64FromBytes(allBytes.skip(offset)));
      offset += 8;
      _v3 = _round(_v3, int64FromBytes(allBytes.skip(offset)));
      offset += 8;
      _v4 = _round(_v4, int64FromBytes(allBytes.skip(offset)));
      offset += 8;
    }

    _remainder.clear();
    _remainder.addAll(allBytes.skip(offset));
  }

  @pragma('vm:prefer-inline')
  Int64 _round(Int64 acc, Int64 value) {
    acc += value * _p2;
    acc = rotl64(acc, 31);
    acc *= _p1;
    return acc;
  }

  @pragma('vm:prefer-inline')
  Int64 _mergeRound(Int64 acc, Int64 value) {
    acc ^= _round(Int64.ZERO, value);
    acc = acc * _p1 + _p4;
    return acc;
  }

  @pragma('vm:prefer-inline')
  Int64 _avalanche(Int64 h64) {
    h64 ^= h64.shiftRightUnsigned(33);
    h64 *= _p2;
    h64 ^= h64.shiftRightUnsigned(29);
    h64 *= _p3;
    h64 ^= h64.shiftRightUnsigned(32);
    return h64;
  }

  @override
  HashValue finalize() {
    Int64 h64 = Int64.ZERO;

    /////
    // XXH64_digest

    if (_totalLength >= 32) {
      h64 = rotl64(_v1, 1) + rotl64(_v2, 7) + rotl64(_v3, 12) + rotl64(_v4, 18);
      h64 = _mergeRound(h64, _v1);
      h64 = _mergeRound(h64, _v2);
      h64 = _mergeRound(h64, _v3);
      h64 = _mergeRound(h64, _v4);
    } else {
      h64 = _v3 + _p5;
    }

    h64 += _totalLength;

    /////
    // XXH64_finalize

    int offset = 0;
    int remaining = _remainder.length & 31;
    while (remaining >= 8) {
      h64 ^= _round(Int64.ZERO, int64FromBytes(_remainder.skip(offset)));
      h64 = _p1 * rotl64(h64, 27) + _p4;
      offset += 8;
      remaining -= 8;
    }
    if (remaining >= 4) {
      h64 ^= _p1 * int64FromBytes(_remainder.skip(offset), 4);
      h64 = _p2 * rotl64(h64, 23) + _p3;
      offset += 4;
      remaining -= 4;
    }
    for (int byte in _remainder.skip(offset)) {
      h64 ^= _p5 * byte;
      h64 = _p1 * rotl64(h64, 11);
    }

    return OneLaneHashValue<Int64>(_avalanche(h64));
  }
}
