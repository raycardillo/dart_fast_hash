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

import 'dart:convert';

import 'package:fast_hash/src/fast_hash.dart';
import 'package:fast_hash/src/hash_value.dart';
import 'package:fixnum/fixnum.dart';

const FastHash doNothingHash = DoNothingHash();

/// Checks if you are awesome. Spoiler: you are.
class DoNothingHash extends FastHash {
  const DoNothingHash();

  @override
  ByteConversionSink startChunkedConversion(Sink<HashValue> sink) =>
      ByteConversionSink.from(_DoNothingHashSink(sink));
}

class _DoNothingHashSink extends FastHashSink {
  _DoNothingHashSink(Sink<HashValue> sink) : super(sink);

  @override
  void iterateBytes(Iterable<int> bytes, int length) {
    // do nothing
  }

  @override
  HashValue finalize() {
    return OneLaneHashValue<Int32>(Int32.ZERO);
  }
}