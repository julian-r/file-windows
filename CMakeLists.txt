cmake_minimum_required(VERSION 3.7)

project(file)

set(FILE_VERSION 5.31)

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
        file/src/cdf.c
        file/src/cdf_time.c
        file/src/compress.c
        file/src/der.c
        file/src/encoding.c
        file/src/fsmagic.c
        file/src/funcs.c
        file/src/is_tar.c
        ${CMAKE_CURRENT_BINARY_DIR}/magic.c
        file/src/print.c
        file/src/readcdf.c
        ${CMAKE_CURRENT_BINARY_DIR}/readelf.c
        file/src/softmagic.c
)

# replace the version in the magic.h.in and write it to magic.h
FILE(READ file/src/magic.h.in MAGIC_H_CONTENT)
STRING(REPLACE "X.YY" ${FILE_VERSION} MAGIC_H_CONTENT_NEW "${MAGIC_H_CONTENT}")
FILE(WRITE file/src/magic.h "${MAGIC_H_CONTENT_NEW}")


FILE(READ file/src/readelf.c READELF_C_CONTENT)
STRING(CONCAT READELF_C_CONTENT_NEW "#include <dirent.h>\n" "${READELF_C_CONTENT}")
FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/readelf.c "${READELF_C_CONTENT_NEW}")

FILE(READ file/src/magic.c MAGIC_C_CONTENT)
STRING(CONCAT MAGIC_C_CONTENT_NEW "#include <dirent.h>\n" "${MAGIC_C_CONTENT}")
FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/magic.c "${MAGIC_C_CONTENT_NEW}")


add_definitions(-DHAVE_CONFIG_H -DVERSION="${FILE_VERSION}" -DWIN32_LEAN_AND_MEAN -DWIN32 -DPCRE2_STATIC )
add_library(libmagic SHARED ${LIBMAGIC_SOURCE_FILES})
include_directories (${CMAKE_CURRENT_SOURCE_DIR}/win-headers pcre2/src file/src dirent/include getopt)
target_link_libraries(libmagic pcre2-posix shlwapi)

add_subdirectory(pcre2)
add_executable(file file/src/file.c)
target_link_libraries(file libmagic pcre2-posix shlwapi)

# add_custom_command(TARGET ${PROJECT_NAME}
# COMMAND file 
# DEPENDS file
# )

# file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/pcre/src/pcre2posix.h
#         DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/pcre/src/regex.h)