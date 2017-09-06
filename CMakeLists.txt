cmake_minimum_required(VERSION 3.7)

project(libmagic)

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
        file/src/magic.c
        file/src/print.c
        file/src/readcdf.c
        file/src/readelf.c
        file/src/softmagic.c
)

# configure_file(${CMAKE_CURRENT_SOURCE_DIR}/file/src/magic.h.in ${CMAKE_CURRENT_SOURCE_DIR}/file/src/magic.h)
add_definitions(-DHAVE_CONFIG_H -DVERSION="5.31" -DWIN32_LEAN_AND_MEAN -DPCRE2_STATIC)
add_library(libmagic ${LIBMAGIC_SOURCE_FILES})
include_directories (${CMAKE_CURRENT_SOURCE_DIR}/win-headers pcre/src file/src dirent/include getopt)

add_subdirectory(pcre)
add_executable(file file/src/file.c)
target_link_libraries(file libmagic pcre2-posix shlwapi)


# file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/pcre/src/pcre2posix.h
#         DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/pcre/src/regex.h)