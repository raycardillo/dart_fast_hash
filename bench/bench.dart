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

import 'package:fast_hash/fast_hash.dart';

import 'do_nothing_hash.dart';
import 'speed_test.dart';

void main(List<String> arguments) {
  var speedTest = SpeedTest();
  var hash = XxHash64();
  speedTest.runTinySpeedTest(hash, 100, DateTime.now().microsecond);
  var dnh = DoNothingHash();
  speedTest.runTinySpeedTest(dnh, 100, DateTime.now().microsecond);
}
