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

import 'hash_value.dart';

/// An interface for fast hash functions.
abstract class FastHash extends Converter<List<int>, HashValue> {
  const FastHash();

  @override
  HashValue convert(List<int> input) {
    var innerSink = HashValueSink();
    var outerSink = startChunkedConversion(innerSink);
    outerSink.add(input);
    outerSink.close();
    return innerSink.value;
  }

  @override
  ByteConversionSink startChunkedConversion(Sink<HashValue> sink);
}

/// A base class for implementations of hash algorithms.
abstract class FastHashSink<T> implements ByteConversionSinkBase {
  final Sink<HashValue> _sink;
  bool _isClosed;

  FastHashSink(this._sink)
      : _isClosed = false,
        super();

  void iterateBytes(Iterable<int> input, int length);

  HashValue finalize();

  @override
  void add(List<int> input) {
    assert(!_isClosed, "FastHashSink.add() called after close().");
    iterateBytes(input, input.length);
  }

  @override
  void addSlice(List<int> chunk, int start, int end, bool isLast) {
    iterateBytes(chunk.getRange(start, end), end - start);
    if (isLast) {
      close();
    }
  }

  @override
  void close() {
    if (_isClosed) return;
    _isClosed = true;
    _sink.add(finalize());
    _sink.close();
  }
}
