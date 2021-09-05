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

class RandomBytes {
  Int32 _x;
  Int32 _y;
  Int32 _z;
  Int32 _w;

  RandomBytes([int seed = 0])
      : _x = Int32(seed ^ 0x498b3bc5),
        _y = Int32((seed >> 32) ^ 0x5a05089a),
        _z = Int32.ZERO,
        _w = Int32.ZERO {
    for (int i = 0; i < 10; i++) {
      _mix();
    }
  }

  void _mix() {
    Int32 t = _x ^ (_x << 11);
    _x = _y;
    _y = _z;
    _z = _w;
    _w = _w ^ (_w >> 19) ^ t ^ (t >> 8);
  }

  Int32 rand32() {
    _mix();
    return _x;
  }

  Int64 rand64() {
    _mix();
    return Int64.fromInts(_x.toInt(), _y.toInt());
  }

  Int32x4 rand128() {
    _mix();
    return Int32x4(_x.toInt(), _y.toInt(), _z.toInt(), _w.toInt());
  }

  ByteData randByteData(int length) {
    var byteData = ByteData(length);
    int i = 0;
    while (i < length) {
      byteData.setUint32(i, rand32().toInt());
      i += 4;
    }
    return byteData;
  }

  List<int> randByteList(int length) {
    var byteList = List<int>.empty(growable: true);
    int i = 0;
    while (i < length) {
      byteList.addAll(rand32().toBytes());
      i += 4;
    }
    return byteList;
  }
}
