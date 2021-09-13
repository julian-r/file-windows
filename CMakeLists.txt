cmake_minimum_required(VERSION 3.7)

project(file)

function(cat IN_FILE OUT_FILE)
  file(READ ${IN_FILE} CONTENTS)
  file(APPEND ${OUT_FILE} "${CONTENTS}")
endfunction()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
MESSAGE("CMAKE_MODULE_PATH: " ${CMAKE_MODULE_PATH})
find_package(pcre2 REQUIRED)

option(BUILD_SHARED_LIBS "build as shared library" ON)

# set(FILE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/file/src")
set(LIBMAGIC_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/file/src")
set(LIBMAGIC_TEST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/file/tests")
set(WIN_HEADERS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/win-headers")
# set(PCRE2_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/pcre2/src")
set(PCRE2_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/pcre2/install_dir/lib")

set(FILE_VERSION 5.38)

set(WIN_COMPAT_SOURCES 
  ${LIBMAGIC_SOURCE_DIR}/asctime_r.c
  ${LIBMAGIC_SOURCE_DIR}/asprintf.c
  ${LIBMAGIC_SOURCE_DIR}/ctime_r.c
  ${LIBMAGIC_SOURCE_DIR}/dprintf.c
  ${LIBMAGIC_SOURCE_DIR}/getline.c
  ${LIBMAGIC_SOURCE_DIR}/gmtime_r.c
  ${LIBMAGIC_SOURCE_DIR}/localtime_r.c
  ${LIBMAGIC_SOURCE_DIR}/pread.c
  ${LIBMAGIC_SOURCE_DIR}/strcasestr.c
  ${LIBMAGIC_SOURCE_DIR}/strlcat.c
  ${LIBMAGIC_SOURCE_DIR}/strlcpy.c
  ${LIBMAGIC_SOURCE_DIR}/vasprintf.c
  ${LIBMAGIC_SOURCE_DIR}/fmtcheck.c
  ${WIN_HEADERS_DIR}/magic.def
)

set(LIBMAGIC_SOURCE_FILES
  ${WIN_COMPAT_SOURCES}
  ${LIBMAGIC_SOURCE_DIR}/apprentice.c
  ${LIBMAGIC_SOURCE_DIR}/apptype.c
  ${LIBMAGIC_SOURCE_DIR}/ascmagic.c
  ${LIBMAGIC_SOURCE_DIR}/buffer.c
  ${LIBMAGIC_SOURCE_DIR}/cdf.c
  ${LIBMAGIC_SOURCE_DIR}/cdf_time.c
  ${LIBMAGIC_SOURCE_DIR}/compress.c
  ${LIBMAGIC_SOURCE_DIR}/der.c
  ${LIBMAGIC_SOURCE_DIR}/encoding.c
  ${LIBMAGIC_SOURCE_DIR}/fsmagic.c
  ${LIBMAGIC_SOURCE_DIR}/funcs.c
  ${LIBMAGIC_SOURCE_DIR}/is_json.c
  ${LIBMAGIC_SOURCE_DIR}/is_tar.c
  ${CMAKE_CURRENT_BINARY_DIR}/magic.c
  ${LIBMAGIC_SOURCE_DIR}/print.c
  ${LIBMAGIC_SOURCE_DIR}/readcdf.c
  ${CMAKE_CURRENT_BINARY_DIR}/readelf.c
  ${LIBMAGIC_SOURCE_DIR}/softmagic.c
  ${LIBMAGIC_SOURCE_DIR}/is_csv.c
)


# replace the version in the magic.h.in and write it to magic.h
FILE(READ ${LIBMAGIC_SOURCE_DIR}/magic.h.in MAGIC_H_CONTENT)
STRING(REPLACE "." "" FILE_VERSION_WITHOUT_DOT "${FILE_VERSION}")
STRING(REPLACE "X.YY" ${FILE_VERSION_WITHOUT_DOT} MAGIC_H_CONTENT_NEW "${MAGIC_H_CONTENT}")
FILE(WRITE ${LIBMAGIC_SOURCE_DIR}/magic.h "${MAGIC_H_CONTENT_NEW}")


FILE(READ ${LIBMAGIC_SOURCE_DIR}/readelf.c READELF_C_CONTENT)
STRING(CONCAT READELF_C_CONTENT_NEW "#include <dirent.h>\n" "${READELF_C_CONTENT}")
FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/readelf.c "${READELF_C_CONTENT_NEW}")

FILE(READ ${LIBMAGIC_SOURCE_DIR}/magic.c MAGIC_C_CONTENT)
STRING(CONCAT MAGIC_C_CONTENT_NEW "#include <dirent.h>\n" "${MAGIC_C_CONTENT}")
FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/magic.c "${MAGIC_C_CONTENT_NEW}")

FILE(READ ${LIBMAGIC_SOURCE_DIR}/file.h FILE_H_CONTENT)
STRING(CONCAT FILE_H_CONTENT_NEW "#ifdef WIN32\n#include <unistd.h>\n#include <dirent.h>\n#undef S_IFLNK\n#undef S_IFSOCK\n#endif\n" "${FILE_H_CONTENT}")
FILE(WRITE ${LIBMAGIC_SOURCE_DIR}/file.h "${FILE_H_CONTENT_NEW}")

add_definitions(-DHAVE_CONFIG_H -DVERSION="${FILE_VERSION}" -DWIN32_LEAN_AND_MEAN -DWIN32 -DPCRE2_STATIC )
if(BUILD_SHARED_LIBS)
  add_library(libmagic SHARED ${LIBMAGIC_SOURCE_FILES})
else()
  add_library(libmagic STATIC ${LIBMAGIC_SOURCE_FILES})
endif()
include_directories (${WIN_HEADERS_DIR} ${PCRE2_INCLUDE_DIRS} ${LIBMAGIC_SOURCE_DIR} dirent/include getopt)
target_link_libraries(libmagic PRIVATE ${PCRE2_LIBRARIES} ${PCRE2_POSIX_LIBRARIES} shlwapi)

target_include_directories(libmagic
                           PUBLIC
                           "$<BUILD_INTERFACE:${LIBMAGIC_SOURCE_DIR}>"
                           "$<INSTALL_INTERFACE:include>"
)

# add_subdirectory(pcre2)

# copy /pcre2posix.h to regex.h so it can be used as posix regex libary
configure_file(${PCRE2_INCLUDE_DIRS}/pcre2posix.h ${PCRE2_INCLUDE_DIRS}/regex.h COPYONLY)

add_executable(file ${LIBMAGIC_SOURCE_DIR}/file.c)
add_executable(file_test ${LIBMAGIC_TEST_DIR}/test.c)
target_link_libraries(file_test PRIVATE libmagic shlwapi)
target_link_libraries(file PRIVATE libmagic shlwapi)

# this tests all because of time-zone or crlf errors
set(DISABLED_TESTS 
  gedcom
  fit-map-data
  regex-eol
  )

enable_testing()
file(GLOB TESTFILES "${LIBMAGIC_TEST_DIR}/*.testfile")
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

install(TARGETS file file_test DESTINATION binary)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/magic.mgc DESTINATION binary)
install(FILES ${LIBMAGIC_SOURCE_DIR}/magic.h DESTINATION include)
install(TARGETS libmagic
  EXPORT libmagic-target
  RUNTIME DESTINATION lib
  RUNTIME DESTINATION binary
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