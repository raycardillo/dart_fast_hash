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

import 'package:fast_hash/src/stats_list.dart';
import 'package:test/test.dart';

void main() {
  group('Test common helpers', () {
    setUp(() {
      // Additional setup can go here.
    });

    test('stdDev - all', () {
      List<double> testSample = [100, 200, 200, 100];
      expect(testSample.stdDev(), equals(50));
    });

    test('stdDev - range', () {
      List<double> testSample = [100, 200, 300, 100];
      expect(testSample.stdDev(2, 4), equals(100));
    });

    test('mean - all', () {
      List<double> testSample = [100, 200, 200, 200, 100];
      expect(testSample.mean(), equals(160));
    });

    test('mean - range', () {
      List<double> testSample = [100, 200, 200, 200, 100];
      expect(testSample.mean(3, 5), equals(150));
    });

    test('filterOutliers @1.0', () {
      List<double> testSample = [
        1,
        1,
        1,
        1,
        1,
        400,
        300,
        100,
        200,
        2,
        2,
        2,
        2,
        2
      ];
      List<double> expectedValue = [
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        2.0,
        2.0,
        2.0,
        2.0,
        2.0,
        100.0
      ];
      testSample.filterHighOutliers(1.0);
      expect(testSample, equals(expectedValue));
    });

    test('filterOutliers @2.0', () {
      List<double> testSample = [
        1,
        1,
        1,
        1,
        1,
        325,
        300,
        100,
        200,
        2,
        2,
        2,
        2,
        2
      ];
      List<double> expectedValue = [
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        2.0,
        2.0,
        2.0,
        2.0,
        2.0,
        100.0,
        200.0
      ];
      testSample.filterHighOutliers(2.0);
      expect(testSample, equals(expectedValue));
    });

    test('filterOutliers @3.0', () {
      List<double> testSample = [
        1,
        1,
        1,
        1,
        1,
        1000,
        300,
        100,
        200,
        2,
        2,
        2,
        2,
        2
      ];
      List<double> expectedValue = [
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        2.0,
        2.0,
        2.0,
        2.0,
        2.0,
        100.0,
        200.0,
        300.0
      ];
      testSample.filterHighOutliers(3.0);
      expect(testSample, equals(expectedValue));
    });

    test('filter then mean on same list', () {
      List<double> testSample = [
        1,
        1,
        1,
        1,
        1,
        1,
        400,
        300,
        100,
        200,
        1,
        2,
        2,
        2,
        2,
        2
      ];
      List<double> expectedValue = [
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        2.0,
        2.0,
        2.0,
        2.0,
        2.0,
        100.0
      ];
      expect(testSample.mean(), equals(63.5625));
      testSample.filterHighOutliers(1.0);
      expect(testSample, equals(expectedValue));
      expect(testSample.mean(), equals(9.0));
    });
  });
}
