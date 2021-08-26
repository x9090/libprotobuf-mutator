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

#ifndef EXAMPLES_FUZZER_TEST_H_
#define EXAMPLES_FUZZER_TEST_H_

#include <dirent.h>
#include <memory>
#include <string>
#include <stdio.h>
#include <stdlib.h>

#include "port/gtest.h"

using testing::Test;

class FuzzerTest : public testing::Test {
 protected:
  void SetUp() override {
    std::string dir_template;
#if defined(_WIN32) || defined(_WIN64)
    std::string tmpdir = std::string(getenv("TMP"));
    dir_template = tmpdir + "\\libfuzzer_mutator_test_XXXXXX";
    auto dir = _mktemp((char*)dir_template.c_str());
    printf("_mktemp: %s\n", dir);
    _mkdir(dir);
#else
    dir_template = "/tmp/libfuzzer_mutator_test_XXXXXX";
    auto dir = mkdtemp(dir_template.c_str());
#endif
    ASSERT_TRUE(dir);
#if defined(_WIN32) || defined(_WIN64)
    dir_ = std::string(dir) + "\\";
#else
    dir_ = std::string(dir) + "/";
#endif
    EXPECT_EQ(0, CountFilesInDir());
  }

  void TearDown() override {
#if defined(_WIN32) || defined(_WIN64)
    EXPECT_EQ(0, std::system((std::string("rmdir /Q /S ") + dir_).c_str()));
#else
    EXPECT_EQ(0, std::system((std::string("rm -rf ") + dir_).c_str()));
#endif
  }

  int RunFuzzer(const std::string& name, int max_len, int runs) {
#if defined(_WIN32) || defined(_WIN64)
    _putenv("ASAN_OPTIONS=detect_leaks=0");
    std::string cmd = ".\\" + name;
#else
    std::string cmd = "ASAN_OPTIONS=detect_leaks=0 ./" + name;
#endif
    cmd += " -detect_leaks=0";
    cmd += " -len_control=0";
    cmd += " -max_len=" + std::to_string(max_len);
    cmd += " -runs=" + std::to_string(runs);
    cmd += " -artifact_prefix=" + dir_;
    cmd += " " + dir_;
    fprintf(stderr, "%s \n", cmd.c_str());
    return std::system(cmd.c_str());
  }

  size_t CountFilesInDir() const {
    size_t res = 0;
    std::unique_ptr<DIR, decltype(&closedir)> dir(opendir(dir_.c_str()),
                                                  &closedir);
    if (!dir) return 0;
    while (readdir(dir.get())) {
      ++res;
    }
    if (res <= 2) return 0;
    res -= 2;  // . and ..
    return res;
  }

  std::string dir_;
};

#endif  // EXAMPLES_FUZZER_TEST_H_
