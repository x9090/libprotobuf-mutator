// Copyright 2017 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "examples/fuzzer_test.h"
#include "port/gtest.h"

#ifndef WSTOPSIG
#define WSTOPSIG(status)   (((status) & 0xff00) >> 8)
#endif

namespace {

const int kDefaultLibFuzzerError = 77;

class LibFuzzerExampleTest : public FuzzerTest {};

int GetError(int exit_code) { return WSTOPSIG(exit_code); }

TEST_F(LibFuzzerExampleTest, Text) {
#if defined(_WIN32) || defined(_WIN64)
  EXPECT_EQ(kDefaultLibFuzzerError,
            RunFuzzer("libfuzzer_example", 1000, 10000000));
#else
  EXPECT_EQ(kDefaultLibFuzzerError,
            GetError(RunFuzzer("libfuzzer_example", 1000, 10000000)));
#endif
}

TEST_F(LibFuzzerExampleTest, Binary) {
#if defined(_WIN32) || defined(_WIN64)
  EXPECT_EQ(kDefaultLibFuzzerError,
            RunFuzzer("libfuzzer_bin_example", 1000, 10000000));
#else
    EXPECT_EQ(kDefaultLibFuzzerError,
            GetError(RunFuzzer("libfuzzer_bin_example", 1000, 10000000)));
#endif
}

}  // namespace
