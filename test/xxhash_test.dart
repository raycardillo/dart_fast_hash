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

import 'dart:async';
import 'dart:convert';

import 'package:fast_hash/src/common.dart';
import 'package:fast_hash/src/fast_hash.dart';
import 'package:fast_hash/src/hash_value.dart';
import 'package:fast_hash/src/xxhash.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

final Matcher throwsAssertionError = throwsA(isA<AssertionError>());

const int p32 = 0x9E3779B1;
const int p64 = 0x9E3779B185EBCA8D;

final FastHash xxHash64wSeed = XxHash64(Int64(p32));

// NOTE: The following are helpful as a cross reference for testing.
// - https://asecuritysite.com/encryption/xxhash
// - `brew install xxhash`

// See the sanity checks from the main xxHash repository:
// https://github.com/Cyan4973/xxHash/blob/684812267dcaf99d8571c00bd5a215eca0c4daaa/cli/xsum_sanity_check.c
List<int> getTestBuffer(int length) {
  Int64 byteGen = Int64(p32);
  var buffer = List<int>.generate(length, (index) {
    int value = byteGen.shiftRightUnsigned(56).toInt() & mask8;
    byteGen *= p64;
    return value;
  });
  return buffer;
}

void main() {
  final testBuffer = getTestBuffer(2400);

  group('xxHash64 tests', () {
    group('with a chunked converter', () {
      test('add may not be called after close', () {
        var sink =
            xxHash64.startChunkedConversion(StreamController<HashValue>().sink);
        sink.close();
        expect(() => sink.add([0]), throwsAssertionError);
      });

      test('close may be called multiple times', () {
        var sink =
            xxHash64.startChunkedConversion(StreamController<HashValue>().sink);
        sink.close();
        sink.close();
        sink.close();
        sink.close();
      });

      test('close closes the underlying sink', () {
        var inner = ChunkedConversionSink<HashValue>.withCallback(
            expectAsync1((accumulated) {
          expect(accumulated.length, equals(1));
          expect(accumulated.first.toString(), equals("EF46DB3751D8E999"));
        }));

        var outer = xxHash64.startChunkedConversion(inner);
        outer.close();
      });
    });

    group('simple input checks', () {
      test('empty input - no seed', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0xEF46DB3751D8E999));
        final actualHash = xxHash64.convert(utf8.encode(""));
        expect(actualHash, equals(expectedHash));
      });
      test('empty input - with seed', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0xAC75FDA2929B17EF));
        final actualHash = xxHash64wSeed.convert(utf8.encode(""));
        expect(actualHash, equals(expectedHash));
      });
      test('verify small input - no seed', () {
        const stringData = "hello world.";
        final expectedHash = OneLaneHashValue<Int64>(Int64(0x0F9BF27A87B7661A));
        final actualHash = xxHash64.convert(utf8.encode(stringData));
        expect(actualHash, equals(expectedHash));
      });
      test('verify small input - with seed', () {
        const stringData = "hello world.";
        final expectedHash = OneLaneHashValue<Int64>(Int64(0x56FC739BE21740FB));
        final actualHash = xxHash64wSeed.convert(utf8.encode(stringData));
        expect(actualHash, equals(expectedHash));
      });
      test('verify medium input - no seed', () {
        const stringData = "The quick brown fox jumps over the lazy dog";
        final expectedHash = OneLaneHashValue<Int64>(Int64(0x0B242D361FDA71BC));
        final actualHash = xxHash64.convert(utf8.encode(stringData));
        expect(actualHash, equals(expectedHash));
      });
      test('verify medium input - with seed', () {
        const stringData = "The quick brown fox jumps over the lazy dog";
        final expectedHash = OneLaneHashValue<Int64>(Int64(0xB31B9019EC176B0C));
        final actualHash = xxHash64wSeed.convert(utf8.encode(stringData));
        expect(actualHash, equals(expectedHash));
      });
      test('verify large input - no seed', () {
        const stringData =
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer vitae est quis libero feugiat convallis. Integer pharetra luctus sapien, non accumsan lorem placerat non. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Praesent ac aliquam dui, a euismod justo. Donec viverra nec felis quis ultricies. Nunc volutpat justo ut aliquet tincidunt. Maecenas ligula neque, placerat sit amet commodo et, semper ac erat. Morbi ultricies odio turpis, in sagittis justo efficitur quis. Vestibulum ultrices, nulla nec dapibus viverra, sapien tortor porttitor eros, in sollicitudin arcu turpis sed libero. Aliquam semper finibus tellus et sollicitudin. Phasellus non dolor in augue consectetur consectetur in rutrum eros. Etiam eu augue tristique eros dictum placerat. Vivamus cursus risus libero, et feugiat sem interdum quis. Aliquam erat volutpat. Nulla tristique, mi semper cursus elementum, risus augue mollis ipsum, scelerisque mattis quam libero id nulla. Etiam in justo et metus lacinia ut.";
        final expectedHash = OneLaneHashValue<Int64>(Int64(0xB2135665F2659CC9));
        final actualHash = xxHash64.convert(utf8.encode(stringData));
        expect(actualHash, equals(expectedHash));
      });
      test('verify large input - with seed', () {
        const stringData =
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer vitae est quis libero feugiat convallis. Integer pharetra luctus sapien, non accumsan lorem placerat non. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Praesent ac aliquam dui, a euismod justo. Donec viverra nec felis quis ultricies. Nunc volutpat justo ut aliquet tincidunt. Maecenas ligula neque, placerat sit amet commodo et, semper ac erat. Morbi ultricies odio turpis, in sagittis justo efficitur quis. Vestibulum ultrices, nulla nec dapibus viverra, sapien tortor porttitor eros, in sollicitudin arcu turpis sed libero. Aliquam semper finibus tellus et sollicitudin. Phasellus non dolor in augue consectetur consectetur in rutrum eros. Etiam eu augue tristique eros dictum placerat. Vivamus cursus risus libero, et feugiat sem interdum quis. Aliquam erat volutpat. Nulla tristique, mi semper cursus elementum, risus augue mollis ipsum, scelerisque mattis quam libero id nulla. Etiam in justo et metus lacinia ut.";
        final expectedHash = OneLaneHashValue<Int64>(Int64(0x0B467C24AF412320));
        final actualHash = xxHash64wSeed.convert(utf8.encode(stringData));
        expect(actualHash, equals(expectedHash));
      });
    });

    group('verify sanity checks', () {
      // Uncomment to see byte values
      test('sanity check: len=0, seed=0', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0xEF46DB3751D8E999));
        final actualHash = xxHash64.convert(List<int>.empty());
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=0, seed=p32', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0xAC75FDA2929B17EF));
        final actualHash = xxHash64wSeed.convert(List<int>.empty());
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=1, seed=0', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0xE934A84ADB052768));
        final actualHash = xxHash64.convert(testBuffer.sublist(0, 1));
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=1, seed=p32', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0x5014607643A9B4C3));
        final actualHash = xxHash64wSeed.convert(testBuffer.sublist(0, 1));
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=4, seed=0', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0x9136A0DCA57457EE));
        final actualHash = xxHash64.convert(testBuffer.sublist(0, 4));
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=8, seed=0', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0xCDBCF538E71D1348));
        final actualHash = xxHash64.convert(testBuffer.sublist(0, 8));
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=9, seed=0', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0x554B1AE991EDA6B6));
        final actualHash = xxHash64.convert(testBuffer.sublist(0, 9));
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=12, seed=0', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0x0723BF50086EAD9A));
        final actualHash = xxHash64.convert(testBuffer.sublist(0, 12));
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=14, seed=0', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0x8282DCC4994E35C8));
        final actualHash = xxHash64.convert(testBuffer.sublist(0, 14));
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=14, seed=p32', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0xC3BD6BF63DEB6DF0));
        final actualHash = xxHash64wSeed.convert(testBuffer.sublist(0, 14));
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=222, seed=0', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0xB641AE8CB691C174));
        final actualHash = xxHash64.convert(testBuffer.sublist(0, 222));
        expect(actualHash, equals(expectedHash));
      });
      test('sanity check: len=222, seed=p32', () {
        final expectedHash = OneLaneHashValue<Int64>(Int64(0x20CB8AB7AE10C14A));
        final actualHash = xxHash64wSeed.convert(testBuffer.sublist(0, 222));
        expect(actualHash, equals(expectedHash));
      });
    });
  });
}
