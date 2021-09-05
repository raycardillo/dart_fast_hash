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

// Inspired by SMHasher: https://github.com/rurban/smhasher

import 'package:fast_hash/src/fast_hash.dart';
import 'package:fast_hash/src/stats_list.dart';

import 'random_bytes.dart';

// Note that timing values are viewed as a series of random variables that get
// contaminated with occasional outliers due to cache misses, thread
// preemption, etc. To filter out the outliers, any values more more than
// [_outlierScale] standard deviations from the mean are discarded.
const _outlierScale = 3.0;

class SpeedTest {
  final _stopwatch = Stopwatch();

  int _timeHash(FastHash hash, List<int> bytes) {
    _stopwatch.start();
    hash.convert(bytes);
    _stopwatch.stop();
    return _stopwatch.elapsedMicroseconds;
  }

  double runSpeedTest(
      FastHash hash, final int seed, final int trials, final int blockSize) {
    var rand = RandomBytes(seed);
    var byteList = rand.randByteList(blockSize);

    var times = List<int>.filled(trials, 0);
    for (int trialNum = 0; trialNum < trials; trialNum++) {
      times[trialNum] = _timeHash(hash, byteList);
    }

    times.filterHighOutliers(_outlierScale);
    return times.mean();
  }

  double runTinySpeedTest(FastHash hash, int keySize, int seed) {
    const int trials = 99999;

    print(
        "Small key speed test - ${keySize.toString().padLeft(4)}-byte keys - ");

    double cycles = runSpeedTest(hash, seed, trials, keySize);

    print("${cycles.toStringAsFixed(2).padLeft(11)} cycles/hash");

    return cycles;
  }
}
