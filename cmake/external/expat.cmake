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

set(EXPAT_TARGET external.expat)
set(EXPAT_BUILD_TARGET external.expat-build)
set(EXPAT_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/${EXPAT_TARGET})
set(EXPAT_BUILD_DIR ${EXPAT_INSTALL_DIR}/src/${EXPAT_BUILD_TARGET})
set(EXPAT_SRC_DIR ${EXPAT_INSTALL_DIR}/src/${EXPAT_TARGET}/expat)

set(EXPAT_INCLUDE_DIRS ${EXPAT_INSTALL_DIR}/include/)
include_directories(${EXPAT_INCLUDE_DIRS})

list(APPEND EXPAT_LIBRARIES expat)

foreach(lib IN LISTS EXPAT_LIBRARIES)
  if (MSVC)
    if (CMAKE_BUILD_TYPE MATCHES Debug)
      set(LIB_PATH ${EXPAT_INSTALL_DIR}/lib/lib${lib}d.lib)
    else()
      set(LIB_PATH ${EXPAT_INSTALL_DIR}/lib/lib${lib}.lib)
    endif()
  else()
    set(LIB_PATH ${EXPAT_INSTALL_DIR}/lib/lib${lib}.a)
  endif()
  
  list(APPEND EXPAT_BUILD_BYPRODUCTS ${LIB_PATH})

  add_library(${lib} STATIC IMPORTED)
  set_property(TARGET ${lib} PROPERTY IMPORTED_LOCATION ${LIB_PATH})
  add_dependencies(${lib} ${EXPAT_TARGET})

endforeach(lib)


include (ExternalProject)
if (MSVC)
set(EXPAT_SHARED_LIBS OFF)
if (${EXPAT_SHARED_LIBS})
	set(EXPAT_INSTALL_CMD ${CMAKE_COMMAND} -E copy ${SRC_EXPAT_DLL} ${DST_EXPAT_DLL})
	set(SRC_EXPAT_DLL ${EXPAT_BUILD_DIR}/libexpat.dll)
	set(DST_EXPAT_DLL ${CMAKE_CURRENT_BINARY_DIR}/libexpat.dll)
else()
	set(EXPAT_INSTALL_CMD "")
	set(EXPAT_EXTRA_LINK_FLAGS "-llibexpat.lib" )
endif()
add_definitions(-D_CRT_SECURE_NO_WARNINGS)
ExternalProject_Add(${EXPAT_TARGET}
    PREFIX ${EXPAT_TARGET}
    GIT_REPOSITORY https://github.com/libexpat/libexpat
    GIT_TAG master
    UPDATE_COMMAND ""
	CMAKE_ARGS ${CMAKE_ARGS} 
			   -DCMAKE_TOOLCHAIN_FILE=F:/dev/vcpkg/scripts/buildsystems/vcpkg.cmake

    CONFIGURE_COMMAND ${CMAKE_COMMAND} ${EXPAT_SRC_DIR}
        -G${CMAKE_GENERATOR}
		-DCMAKE_C_FLAGS_RELEASE=${DCMAKE_C_FLAGS_RELEASE}
		-DCMAKE_CXX_FLAGS_RELEASE=${CMAKE_CXX_FLAGS_RELEASE}
		-DCMAKE_C_FLAGS_RELEASE_INIT=${CMAKE_C_FLAGS_RELEASE_INIT}
		-DCMAKE_CXX_FLAGS_RELEASE_INIT=${CMAKE_CXX_FLAGS_RELEASE_INIT}
		-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} 
		-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
        -DCMAKE_INSTALL_PREFIX=${EXPAT_INSTALL_DIR}
        -DCMAKE_INSTALL_LIBDIR=lib
		-DEXPAT_BUILD_TOOLS=OFF # equivalent --without-xmlwf
		-DEXPAT_SHARED_LIBS=${EXPAT_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
		-DMSVC=ON
		"-DCMAKE_C_FLAGS=${EXPAT_CFLAGS} -w -DXML_POOR_ENTROPY -lclang_rt.fuzzer-i386.lib -lclang_rt.asan_dynamic-i386.lib"
        "-DCMAKE_CXX_FLAGS=${EXPAT_CXXFLAGS} -w  -DXML_POOR_ENTROPY -lclang_rt.asan_dll_thunk-i386.lib"
	INSTALL_COMMAND ${EXPAT_INSTALL_CMD}
    BUILD_BYPRODUCTS ${EXPAT_BUILD_BYPRODUCTS}
)
else()
ExternalProject_Add(${EXPAT_TARGET}
    PREFIX ${EXPAT_TARGET}
    GIT_REPOSITORY https://github.com/libexpat/libexpat
    GIT_TAG master
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND cd ${EXPAT_SRC_DIR} && ./buildconf.sh  && ./configure
                                                    --prefix=${EXPAT_INSTALL_DIR}
                                                    --without-xmlwf
                                                    CC=${CMAKE_C_COMPILER}
                                                    CXX=${CMAKE_CXX_COMPILER}
                                                    "CFLAGS=${EXPAT_CFLAGS} -w -DXML_POOR_ENTROPY"
                                                    "CXXFLAGS=${EXPAT_CXXFLAGS} -w -DXML_POOR_ENTROPY"
    BUILD_COMMAND cd ${EXPAT_SRC_DIR} &&  make -j ${CPU_COUNT}
    INSTALL_COMMAND cd ${EXPAT_SRC_DIR} &&  make install
    BUILD_BYPRODUCTS ${EXPAT_BUILD_BYPRODUCTS}
)
endif()
