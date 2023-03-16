cmake_minimum_required(VERSION 3.7)

project(file)

function(cat IN_FILE OUT_FILE)
  file(READ ${IN_FILE} CONTENTS)
  file(APPEND ${OUT_FILE} "${CONTENTS}")
endfunction()

option(BUILD_SHARED_LIB "build as shared library" ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
find_package(pcre2 REQUIRED)

set(FILE_VERSION 5.44)

set(WIN_COMPAT_SOURCES 
  file/src/asctime_r.c
  file/src/asprintf.c
  file/src/ctime_r.c
  file/src/dprintf.c
  file/src/getline.c
  file/src/gmtime_r.c
  file/src/localtime_r.c
  file/src/pread.c
  file/src/strcasestr.c
  file/src/strlcat.c
  file/src/strlcpy.c
  file/src/vasprintf.c
  file/src/fmtcheck.c
  win-headers/magic.def
)

set(LIBMAGIC_SOURCE_FILES
  ${WIN_COMPAT_SOURCES}
  file/src/apprentice.c
  file/src/apptype.c
  file/src/ascmagic.c
  file/src/buffer.c
  file/src/cdf.c
  file/src/cdf_time.c
  file/src/compress.c
  file/src/der.c
  file/src/encoding.c
  file/src/fsmagic.c
  file/src/funcs.c
  file/src/is_json.c
  file/src/is_tar.c
  ${CMAKE_CURRENT_BINARY_DIR}/magic.c
  file/src/print.c
  file/src/readcdf.c
  ${CMAKE_CURRENT_BINARY_DIR}/readelf.c
  file/src/softmagic.c
  file/src/is_csv.c
)

# replace the version in the magic.h.in and write it to magic.h
FILE(READ file/src/magic.h.in MAGIC_H_CONTENT)
STRING(REPLACE "." "" FILE_VERSION_WITHOUT_DOT "${FILE_VERSION}")
STRING(REPLACE "X.YY" ${FILE_VERSION_WITHOUT_DOT} MAGIC_H_CONTENT_NEW "${MAGIC_H_CONTENT}")
FILE(WRITE file/src/magic.h "${MAGIC_H_CONTENT_NEW}")


FILE(READ file/src/readelf.c READELF_C_CONTENT)
STRING(CONCAT READELF_C_CONTENT_NEW "#include <dirent.h>\n" "${READELF_C_CONTENT}")
FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/readelf.c "${READELF_C_CONTENT_NEW}")

FILE(READ file/src/magic.c MAGIC_C_CONTENT)
STRING(CONCAT MAGIC_C_CONTENT_NEW "#include <dirent.h>\n" "${MAGIC_C_CONTENT}")
FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/magic.c "${MAGIC_C_CONTENT_NEW}")

FILE(READ file/src/file.h FILE_H_CONTENT)
STRING(CONCAT FILE_H_CONTENT_NEW "#ifdef WIN32\n#include <unistd.h>\n#include <dirent.h>\n#undef S_IFLNK\n#undef S_IFSOCK\n#endif\n" "${FILE_H_CONTENT}")
FILE(WRITE file/src/file.h "${FILE_H_CONTENT_NEW}")

# patch test.c and include <getopt.h>
FILE(READ file/tests/test.c TEST_C_CONTENT)
STRING(CONCAT TEST_C_CONTENT_NEW "#include <getopt.h>\n" "${TEST_C_CONTENT}")
FILE(WRITE file/tests/test.c "${TEST_C_CONTENT_NEW}")


add_definitions(-DHAVE_CONFIG_H -DVERSION="${FILE_VERSION}" -DWIN32_LEAN_AND_MEAN -DWIN32 -DPCRE2_STATIC )
if(BUILD_SHARED_LIB)
  add_library(libmagic SHARED ${LIBMAGIC_SOURCE_FILES})
else()
  add_definitions(-DBUILD_AS_WINDOWS_STATIC_LIBARAY)
  add_library(libmagic STATIC ${LIBMAGIC_SOURCE_FILES})
endif()
include_directories (${CMAKE_CURRENT_SOURCE_DIR}/win-headers ${PCRE2_INCLUDE_DIRS} file/src dirent/include getopt)
target_link_libraries(libmagic PRIVATE ${PCRE2_LIBRARIES} ${PCRE2_POSIX_LIBRARIES} shlwapi)


# copy /pcre2posix.h to regex.h so it can be used as posix regex libary
configure_file(${PCRE2_INCLUDE_DIRS}/pcre2posix.h ${PCRE2_INCLUDE_DIRS}/regex.h COPYONLY)

add_executable(file file/src/file.c)
add_executable(file_test file/tests/test.c)
target_link_libraries(file_test PRIVATE libmagic shlwapi)
target_link_libraries(file PRIVATE libmagic shlwapi)


# this tests all because of time-zone or crlf errors
set(DISABLED_TESTS 
  gedcom
  fit-map-data
  regex-eol
  # it seems like the detection of multiple files is not working
  # to be tested after pcre update
  multiple
  )

enable_testing()
file(GLOB TESTFILES "file/tests/*.testfile")
foreach(TEST_FILE ${TESTFILES})
  # extract testname from path and generate command
  string(REGEX MATCH  "(.*)\.testfile" TESTPATH ${TEST_FILE})
  set(TESTPATH ${CMAKE_MATCH_1})
  string(REGEX MATCH  "([a-zA-Z0-9_]|-|\\.)+$" TESTNAME ${TESTPATH})
  if(NOT ${TESTNAME} IN_LIST DISABLED_TESTS)
      add_test(NAME ${TESTNAME} COMMAND ${CMAKE_CURRENT_BINARY_DIR}/file_test ${TEST_FILE} ${TESTPATH}.result)
  endif()
endforeach()


# Following is the compilation of the magic file
set(MAGIC_FRAGMENT_DIR file/magic/Magdir)
file(GLOB MAGIC_FRAGMENTS ${MAGIC_FRAGMENT_DIR}/*)

# Prepare a temporary file to "cat" to:
file(WRITE magic.in "")

# Call the "cat" function for each input file
foreach(MAGIC_FRAGMENT ${MAGIC_FRAGMENTS})
  cat(${MAGIC_FRAGMENT} magic.in)
endforeach()

# Copy the temporary file to the final location
configure_file(magic.in magic COPYONLY)


add_custom_command(OUTPUT magic.mgc
  COMMAND file -C -m magic
  DEPENDS file
  COMMENT "Compiling magic file"
)

add_custom_target(magic_mgc ALL DEPENDS magic.mgc)


install(TARGETS file DESTINATION bin)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/magic.mgc DESTINATION bin)
install(FILES file/src/magic.h DESTINATION include)
install(TARGETS libmagic
  EXPORT libmagic-target
  RUNTIME DESTINATION lib
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  INCLUDES DESTINATION include
  )
install(EXPORT libmagic-target
  FILE libmagic-targets.cmake
  DESTINATION lib/cmake/libmagic
  )
file(WRITE
  ${CMAKE_BINARY_DIR}/libmagic-config.cmake
  "include(\${CMAKE_CURRENT_LIST_DIR}/libmagic-targets.cmake)\n")
install(FILES
  ${CMAKE_BINARY_DIR}/libmagic-config.cmake
  DESTINATION lib/cmake/libmagic)