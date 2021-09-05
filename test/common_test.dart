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

import 'package:fast_hash/src/common.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

void main() {
  final Int32 _int32sample = Int32(0xDEADBEEF);
  final Int64 _int64sample = Int64(0xF00D8BADDEADBEEF);

  group('Test common helpers', () {
    setUp(() {
      // Additional setup can go here.
    });

    test('rotl32', () {
      Int32 expectedValue = Int32(0xDBEEFDEA);
      Int32 actualValue = rotl32(_int32sample, 12);
      expect(actualValue, equals(expectedValue));
    });

    test('rotl64', () {
      Int64 expectedValue = Int64(0xBADDEADBEEFF00D8);
      Int64 actualValue = rotl64(_int64sample, 20);
      expect(actualValue, equals(expectedValue));
    });

    test('int32FromBytes', () {
      // test behavior when exact bytes available
      List<int> bytes = List<int>.from(_int32sample.toBytes());
      expect(int32FromBytes(bytes), equals(_int32sample));

      // test behavior when more bytes available
      bytes.addAll([1, 2, 3]);
      expect(int32FromBytes(bytes), equals(_int32sample));
    });

    test('int64FromBytes', () {
      // test behavior when exact bytes available
      List<int> bytes = List<int>.from(_int64sample.toBytes());
      expect(int64FromBytes(bytes), equals(_int64sample));

      // test behavior when more bytes available
      bytes.addAll([1, 2, 3]);
      expect(int64FromBytes(bytes), equals(_int64sample));
    });
  });
}
