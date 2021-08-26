# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set(LIBXML2_TARGET external.libxml2)
set(LIBXML2_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/${LIBXML2_TARGET})
set(LIBXML2_SRC_DIR ${LIBXML2_INSTALL_DIR}/src/${LIBXML2_TARGET})

set(LIBXML2_INCLUDE_DIRS ${LIBXML2_INSTALL_DIR}/include/libxml2)
include_directories(${LIBXML2_INCLUDE_DIRS})

list(APPEND LIBXML2_LIBRARIES xml2)

foreach(lib IN LISTS LIBXML2_LIBRARIES)
  if (MSVC)
    if (CMAKE_BUILD_TYPE MATCHES Debug)
      set(LIB_PATH ${LIBXML2_INSTALL_DIR}/lib/${lib}d.lib)
    else()
      set(LIB_PATH ${LIBXML2_INSTALL_DIR}/lib/${lib}.lib)
    endif()
  else()
    set(LIB_PATH ${LIBXML2_INSTALL_DIR}/lib/lib${lib}.a)
  endif()
  list(APPEND LIBXML2_BUILD_BYPRODUCTS ${LIB_PATH})

  add_library(${lib} STATIC IMPORTED)
  set_property(TARGET ${lib} PROPERTY IMPORTED_LOCATION ${LIB_PATH})
  add_dependencies(${lib} ${LIBXML2_TARGET})
endforeach(lib)

include (ExternalProject)
if (MSVC)
ExternalProject_Add(${LIBXML2_TARGET}
    PREFIX ${LIBXML2_TARGET}
    GIT_REPOSITORY GIT_REPOSITORY https://gitlab.gnome.org/GNOME/libxml2
    GIT_TAG master
    UPDATE_COMMAND ""
    CMAKE_CACHE_ARGS -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
                     -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    CMAKE_ARGS ${CMAKE_ARGS}
               -DCMAKE_INSTALL_PREFIX=${LIBXML2_INSTALL_DIR}
               -DCMAKE_INSTALL_LIBDIR=lib
			   -DLIBXML2_WITH_PYTHON=OFF
			   -DCMAKE_TOOLCHAIN_FILE=F:/dev/vcpkg/scripts/buildsystems/vcpkg.cmake
			   "-DCMAKE_C_FLAGS=${LIBXML2_CFLAGS} -lclang_rt.fuzzer-i386.lib -lclang_rt.asan_dynamic-i386.lib"
			   "-DCMAKE_CXX_FLAGS=${LIBXML2_CXXFLAGS} -lclang_rt.asan_dll_thunk-i386.lib"
    BUILD_BYPRODUCTS ${LIBXML2_BUILD_BYPRODUCTS}
)
else ()
ExternalProject_Add(${LIBXML2_TARGET}
    PREFIX ${LIBXML2_TARGET}
    GIT_REPOSITORY GIT_REPOSITORY https://gitlab.gnome.org/GNOME/libxml2
    GIT_TAG master
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${LIBXML2_SRC_DIR}/autogen.sh --without-python
                                                    --prefix=${LIBXML2_INSTALL_DIR}
                                                    CC=${CMAKE_C_COMPILER}
                                                    CXX=${CMAKE_CXX_COMPILER}
                                                    CFLAGS=${LIBXML2_CFLAGS}
                                                    CXXFLAGS=${LIBXML2_CXXFLAGS}
    BUILD_COMMAND make -j ${CPU_COUNT} all
    INSTALL_COMMAND make install
    BUILD_BYPRODUCTS ${LIBXML2_BUILD_BYPRODUCTS}
)
endif()
