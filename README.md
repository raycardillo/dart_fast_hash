# Dart Fast Hash

[![Pub package](https://img.shields.io/pub/v/dart_fast_hash)](https://pub.dev/packages/dart_fast_hash)
[![Dartdoc reference](https://img.shields.io/badge/dartdoc-reference-blue)](https://pub.dev/documentation/dart_fast_hash/latest/)
[![style: lints](https://img.shields.io/badge/style-lints-4BC0F5.svg)](https://pub.dev/packages/lints)
[![Project license](https://img.shields.io/badge/license-Apache%202.0-informational)](https://www.apache.org/licenses/LICENSE-2.0)

A collection of fast non-cryptographic hashing algorithms for dart.

## Algorithms Implemented
- **xxHash** - A very fast hashing algorithm with high quality.
- ...


### _Work In Progress_

_This project is a work in progress that is being developed because I need these algorithms for another project._
_I'll spend time implementing more algorithms depending on demand, need, or community interest._


### Sponsor Me

Please consider [sponsoring me](https://github.com/sponsors/raycardillo) if you are using this library, need help, or if you want to discuss specific algorithms or need a specific algorithm implemented.

<br/>


----------

### _Related References_

- **Wikipedia** has a great overview that includes key concepts, a list of well known algorithms, and more. However,
in practice, most of us just want a fast algorithm with negligible risk of collision against our input data set and
with our key space. In that regard, selecting the right hashing algorithm for a specific purpose is often not only
about speed, but also about the overall intent of use. Each algorithm may have pros/cons depending on the input data
and how the hash is going to be used (e.g., small input, large input, uniformity of input/output, collision tolerance).
  - https://en.wikipedia.org/wiki/Hash_function
  - https://en.wikipedia.org/wiki/List_of_hash_functions

- **SMHasher** is a C/C++ benchmarking test suite with an interesting fork history.
The most actively maintained version (at time of writing) is the fork by Reini Urban. It includes performance and
quality data for the most well known algorithms as well as summary recommendations based on those results. Just be
aware that those results are probably the most optimal implementations available (because everything is in C/C++).
  - https://github.com/rurban/smhasher
  - https://github.com/apache/commons-codec

- **xxHash (C library)** has some of the fastest and highest quality hash algorithms known at time of writing.
However, your mileage may vary widely with implementations written in other languages due to language limitations
or quality of implementation (or advanced tricks used to help take advantage of hardware ops). In any case the
project itself has some very useful information and performance results as well.
  - http://www.xxhash.com/
  - https://github.com/Cyan4973/xxHash
  - [xxHash - Performance Comparison](https://github.com/Cyan4973/xxHash/wiki/Performance-comparison)
  - [xxHash - Collision Ratio Comparison](https://github.com/Cyan4973/xxHash/wiki/Collision-ratio-comparison)

- **Guava Hashing** (from the Guava Java library) also has a lot of great information and practical advice.
  - https://github.com/google/guava/wiki/HashingExplained
  - https://guava.dev/releases/snapshot/api/docs/com/google/common/hash/Hashing.html

- **Zero Allocation Hashing** is a Java library from the OpenHFT project. It's a useful reference to see an example of
a library that was designed to use lean object allocation that is also platform-endianness-agnostic.
  - https://github.com/OpenHFT/Zero-Allocation-Hashing
  - https://javadoc.io/doc/net.openhft/zero-allocation-hashing/latest/index.html
