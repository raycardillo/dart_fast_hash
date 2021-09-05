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

import 'dart:math';

/// Extends [num] based [List]s with some statistics utility methods.
extension StatsList<T extends num> on List<T> {
  /// Returns the mean for the values of this list.
  @pragma('vm:prefer-inline')
  double mean([int start = 0, int? end]) {
    end ??= length;

    double sum = 0;
    for (var value in getRange(start, end)) {
      sum += value;
    }

    return sum / (end - start);
  }

  /// Returns the variance for the values of this list.
  @pragma('vm:prefer-inline')
  double variance([int start = 0, int? end]) {
    end ??= length;

    double meanValue = mean(start, end);
    double sumDistSquared = 0;
    for (var value in getRange(start, end)) {
      double dist = value - meanValue;
      sumDistSquared += dist * dist;
    }

    return sumDistSquared / (end - start);
  }

  /// Returns the standard deviation for the values of this list.
  @pragma('vm:prefer-inline')
  double stdDev([int start = 0, int? end]) {
    return sqrt(variance(start, end));
  }

  /// Sorts and then filters the high values from this list that are more than
  /// [scale] standard deviations from the mean.
  void filterHighOutliers(double scale) {
    sort();

    double meanValue = mean();
    double stdDevValue = stdDev();
    double cutoff = meanValue + stdDevValue * scale;

    while (isNotEmpty && last >= cutoff) {
      removeLast();
    }
  }
}
