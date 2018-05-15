cmake_minimum_required(VERSION 3.7)

project(file)

function(cat IN_FILE OUT_FILE)
  file(READ ${IN_FILE} CONTENTS)
  file(APPEND ${OUT_FILE} "${CONTENTS}")
endfunction()

set(FILE_VERSION 5.32)

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
STRING(REPLACE "." "" FILE_VERSION_WITHOUT_DOT "${FILE_VERSION}")
STRING(REPLACE "X.YY" ${FILE_VERSION_WITHOUT_DOT} MAGIC_H_CONTENT_NEW "${MAGIC_H_CONTENT}")
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
add_executable(file_test file/tests/test.c)
target_link_libraries(file_test libmagic pcre2-posix shlwapi)
target_link_libraries(file libmagic pcre2-posix shlwapi)

# TODO: testing
# enable_testing()
# file(GLOB files "file/tests/*.testfile")
# foreach(FILE ${files})
#   string(REGEX MATCH "(.*).testfile" TESTPATH ${FILE})
#   string(REGEX MATCH "\\/(.*).testfile" TESTNAME ${FILE})
#   MESSAGE(${TESTNAME})
#   add_test(NAME ${TESTNAME} COMMAND ${CMAKE_CURRENT_BINARY_DIR}/file_test ${FILE} ${TESTPATH}.result)
# endforeach()


# Following is the compilation of the magic file
set(MAGIC_FRAGMENT_DIR file/magic/Magdir)
set(MAGIC_FRAGMENTS 
  ${MAGIC_FRAGMENT_DIR}/acorn 
  ${MAGIC_FRAGMENT_DIR}/adi 
  ${MAGIC_FRAGMENT_DIR}/adventure 
  ${MAGIC_FRAGMENT_DIR}/algol68 
  ${MAGIC_FRAGMENT_DIR}/allegro 
  ${MAGIC_FRAGMENT_DIR}/alliant 
  ${MAGIC_FRAGMENT_DIR}/amanda 
  ${MAGIC_FRAGMENT_DIR}/amigaos 
  ${MAGIC_FRAGMENT_DIR}/android 
  ${MAGIC_FRAGMENT_DIR}/animation 
  ${MAGIC_FRAGMENT_DIR}/aout 
  ${MAGIC_FRAGMENT_DIR}/apache 
  ${MAGIC_FRAGMENT_DIR}/apl 
  ${MAGIC_FRAGMENT_DIR}/apple 
  ${MAGIC_FRAGMENT_DIR}/application 
  ${MAGIC_FRAGMENT_DIR}/applix 
  ${MAGIC_FRAGMENT_DIR}/apt 
  ${MAGIC_FRAGMENT_DIR}/archive 
  ${MAGIC_FRAGMENT_DIR}/assembler 
  ${MAGIC_FRAGMENT_DIR}/asterix 
  ${MAGIC_FRAGMENT_DIR}/att3b 
  ${MAGIC_FRAGMENT_DIR}/audio 
  ${MAGIC_FRAGMENT_DIR}/basis 
  ${MAGIC_FRAGMENT_DIR}/ber 
  ${MAGIC_FRAGMENT_DIR}/bflt 
  ${MAGIC_FRAGMENT_DIR}/bioinformatics 
  ${MAGIC_FRAGMENT_DIR}/blackberry 
  ${MAGIC_FRAGMENT_DIR}/blcr 
  ${MAGIC_FRAGMENT_DIR}/blender 
  ${MAGIC_FRAGMENT_DIR}/blit 
  ${MAGIC_FRAGMENT_DIR}/bout 
  ${MAGIC_FRAGMENT_DIR}/bsdi 
  ${MAGIC_FRAGMENT_DIR}/bsi 
  ${MAGIC_FRAGMENT_DIR}/btsnoop 
  ${MAGIC_FRAGMENT_DIR}/c-lang 
  ${MAGIC_FRAGMENT_DIR}/c64 
  ${MAGIC_FRAGMENT_DIR}/cad 
  ${MAGIC_FRAGMENT_DIR}/cafebabe 
  ${MAGIC_FRAGMENT_DIR}/cbor 
  ${MAGIC_FRAGMENT_DIR}/cddb 
  ${MAGIC_FRAGMENT_DIR}/chord 
  ${MAGIC_FRAGMENT_DIR}/cisco 
  ${MAGIC_FRAGMENT_DIR}/citrus 
  ${MAGIC_FRAGMENT_DIR}/clarion 
  ${MAGIC_FRAGMENT_DIR}/claris 
  ${MAGIC_FRAGMENT_DIR}/clipper 
  ${MAGIC_FRAGMENT_DIR}/coff 
  ${MAGIC_FRAGMENT_DIR}/commands 
  ${MAGIC_FRAGMENT_DIR}/communications 
  ${MAGIC_FRAGMENT_DIR}/compress 
  ${MAGIC_FRAGMENT_DIR}/console 
  ${MAGIC_FRAGMENT_DIR}/convex 
  ${MAGIC_FRAGMENT_DIR}/coverage 
  ${MAGIC_FRAGMENT_DIR}/cracklib 
  ${MAGIC_FRAGMENT_DIR}/ctags 
  ${MAGIC_FRAGMENT_DIR}/ctf 
  ${MAGIC_FRAGMENT_DIR}/cubemap 
  ${MAGIC_FRAGMENT_DIR}/cups 
  ${MAGIC_FRAGMENT_DIR}/dact 
  ${MAGIC_FRAGMENT_DIR}/database 
  ${MAGIC_FRAGMENT_DIR}/der 
  ${MAGIC_FRAGMENT_DIR}/diamond 
  ${MAGIC_FRAGMENT_DIR}/diff 
  ${MAGIC_FRAGMENT_DIR}/digital 
  ${MAGIC_FRAGMENT_DIR}/dolby 
  ${MAGIC_FRAGMENT_DIR}/dump 
  ${MAGIC_FRAGMENT_DIR}/dyadic 
  ${MAGIC_FRAGMENT_DIR}/ebml 
  ${MAGIC_FRAGMENT_DIR}/editors 
  ${MAGIC_FRAGMENT_DIR}/efi 
  ${MAGIC_FRAGMENT_DIR}/elf 
  ${MAGIC_FRAGMENT_DIR}/encore 
  ${MAGIC_FRAGMENT_DIR}/epoc 
  ${MAGIC_FRAGMENT_DIR}/erlang 
  ${MAGIC_FRAGMENT_DIR}/esri 
  ${MAGIC_FRAGMENT_DIR}/fcs 
  ${MAGIC_FRAGMENT_DIR}/filesystems 
  ${MAGIC_FRAGMENT_DIR}/finger 
  ${MAGIC_FRAGMENT_DIR}/flash 
  ${MAGIC_FRAGMENT_DIR}/flif 
  ${MAGIC_FRAGMENT_DIR}/fonts 
  ${MAGIC_FRAGMENT_DIR}/fortran 
  ${MAGIC_FRAGMENT_DIR}/frame 
  ${MAGIC_FRAGMENT_DIR}/freebsd 
  ${MAGIC_FRAGMENT_DIR}/fsav 
  ${MAGIC_FRAGMENT_DIR}/fusecompress 
  ${MAGIC_FRAGMENT_DIR}/games 
  ${MAGIC_FRAGMENT_DIR}/gcc 
  ${MAGIC_FRAGMENT_DIR}/geo 
  ${MAGIC_FRAGMENT_DIR}/geos 
  ${MAGIC_FRAGMENT_DIR}/gimp 
  ${MAGIC_FRAGMENT_DIR}/gnome 
  ${MAGIC_FRAGMENT_DIR}/gnu 
  ${MAGIC_FRAGMENT_DIR}/gnumeric 
  ${MAGIC_FRAGMENT_DIR}/gpt 
  ${MAGIC_FRAGMENT_DIR}/gpu 
  ${MAGIC_FRAGMENT_DIR}/grace 
  ${MAGIC_FRAGMENT_DIR}/graphviz 
  ${MAGIC_FRAGMENT_DIR}/gringotts 
  ${MAGIC_FRAGMENT_DIR}/guile 
  ${MAGIC_FRAGMENT_DIR}/hitachi-sh 
  ${MAGIC_FRAGMENT_DIR}/hp 
  ${MAGIC_FRAGMENT_DIR}/human68k 
  ${MAGIC_FRAGMENT_DIR}/ibm370 
  ${MAGIC_FRAGMENT_DIR}/ibm6000 
  ${MAGIC_FRAGMENT_DIR}/icc 
  ${MAGIC_FRAGMENT_DIR}/iff 
  ${MAGIC_FRAGMENT_DIR}/images 
  ${MAGIC_FRAGMENT_DIR}/inform 
  ${MAGIC_FRAGMENT_DIR}/intel 
  ${MAGIC_FRAGMENT_DIR}/interleaf 
  ${MAGIC_FRAGMENT_DIR}/island 
  ${MAGIC_FRAGMENT_DIR}/ispell 
  ${MAGIC_FRAGMENT_DIR}/isz 
  ${MAGIC_FRAGMENT_DIR}/java 
  ${MAGIC_FRAGMENT_DIR}/javascript 
  ${MAGIC_FRAGMENT_DIR}/jpeg 
  ${MAGIC_FRAGMENT_DIR}/karma 
  ${MAGIC_FRAGMENT_DIR}/kde 
  ${MAGIC_FRAGMENT_DIR}/keepass 
  ${MAGIC_FRAGMENT_DIR}/kerberos 
  ${MAGIC_FRAGMENT_DIR}/kml 
  ${MAGIC_FRAGMENT_DIR}/lecter 
  ${MAGIC_FRAGMENT_DIR}/lex 
  ${MAGIC_FRAGMENT_DIR}/lif 
  ${MAGIC_FRAGMENT_DIR}/linux 
  ${MAGIC_FRAGMENT_DIR}/lisp 
  ${MAGIC_FRAGMENT_DIR}/llvm 
  ${MAGIC_FRAGMENT_DIR}/lua 
  ${MAGIC_FRAGMENT_DIR}/luks 
  ${MAGIC_FRAGMENT_DIR}/m4 
  ${MAGIC_FRAGMENT_DIR}/mach 
  ${MAGIC_FRAGMENT_DIR}/macos 
  ${MAGIC_FRAGMENT_DIR}/macintosh 
  ${MAGIC_FRAGMENT_DIR}/magic 
  ${MAGIC_FRAGMENT_DIR}/mail.news 
  ${MAGIC_FRAGMENT_DIR}/make 
  ${MAGIC_FRAGMENT_DIR}/map 
  ${MAGIC_FRAGMENT_DIR}/maple 
  ${MAGIC_FRAGMENT_DIR}/marc21 
  ${MAGIC_FRAGMENT_DIR}/mathcad 
  ${MAGIC_FRAGMENT_DIR}/mathematica 
  ${MAGIC_FRAGMENT_DIR}/matroska 
  ${MAGIC_FRAGMENT_DIR}/mcrypt 
  ${MAGIC_FRAGMENT_DIR}/mercurial 
  ${MAGIC_FRAGMENT_DIR}/metastore 
  ${MAGIC_FRAGMENT_DIR}/meteorological 
  ${MAGIC_FRAGMENT_DIR}/microfocus 
  ${MAGIC_FRAGMENT_DIR}/mime 
  ${MAGIC_FRAGMENT_DIR}/mips 
  ${MAGIC_FRAGMENT_DIR}/mirage 
  ${MAGIC_FRAGMENT_DIR}/misctools 
  ${MAGIC_FRAGMENT_DIR}/mkid 
  ${MAGIC_FRAGMENT_DIR}/mlssa 
  ${MAGIC_FRAGMENT_DIR}/mmdf 
  ${MAGIC_FRAGMENT_DIR}/modem 
  ${MAGIC_FRAGMENT_DIR}/motorola 
  ${MAGIC_FRAGMENT_DIR}/mozilla 
  ${MAGIC_FRAGMENT_DIR}/msdos 
  ${MAGIC_FRAGMENT_DIR}/msooxml 
  ${MAGIC_FRAGMENT_DIR}/msx 
  ${MAGIC_FRAGMENT_DIR}/msvc 
  ${MAGIC_FRAGMENT_DIR}/mup 
  ${MAGIC_FRAGMENT_DIR}/music 
  ${MAGIC_FRAGMENT_DIR}/nasa 
  ${MAGIC_FRAGMENT_DIR}/natinst 
  ${MAGIC_FRAGMENT_DIR}/ncr 
  ${MAGIC_FRAGMENT_DIR}/neko 
  ${MAGIC_FRAGMENT_DIR}/netbsd 
  ${MAGIC_FRAGMENT_DIR}/netscape 
  ${MAGIC_FRAGMENT_DIR}/netware 
  ${MAGIC_FRAGMENT_DIR}/news 
  ${MAGIC_FRAGMENT_DIR}/nitpicker 
  ${MAGIC_FRAGMENT_DIR}/oasis 
  ${MAGIC_FRAGMENT_DIR}/ocaml 
  ${MAGIC_FRAGMENT_DIR}/octave 
  ${MAGIC_FRAGMENT_DIR}/ole2compounddocs 
  ${MAGIC_FRAGMENT_DIR}/olf 
  ${MAGIC_FRAGMENT_DIR}/os2 
  ${MAGIC_FRAGMENT_DIR}/os400 
  ${MAGIC_FRAGMENT_DIR}/os9 
  ${MAGIC_FRAGMENT_DIR}/osf1 
  ${MAGIC_FRAGMENT_DIR}/palm 
  ${MAGIC_FRAGMENT_DIR}/parix 
  ${MAGIC_FRAGMENT_DIR}/parrot 
  ${MAGIC_FRAGMENT_DIR}/pascal 
  ${MAGIC_FRAGMENT_DIR}/pbf 
  ${MAGIC_FRAGMENT_DIR}/pbm 
  ${MAGIC_FRAGMENT_DIR}/pc88 
  ${MAGIC_FRAGMENT_DIR}/pc98 
  ${MAGIC_FRAGMENT_DIR}/pdf 
  ${MAGIC_FRAGMENT_DIR}/pdp 
  ${MAGIC_FRAGMENT_DIR}/perl 
  ${MAGIC_FRAGMENT_DIR}/pgf 
  ${MAGIC_FRAGMENT_DIR}/pgp 
  ${MAGIC_FRAGMENT_DIR}/pkgadd 
  ${MAGIC_FRAGMENT_DIR}/plan9 
  ${MAGIC_FRAGMENT_DIR}/plus5 
  ${MAGIC_FRAGMENT_DIR}/polyml 
  ${MAGIC_FRAGMENT_DIR}/printer 
  ${MAGIC_FRAGMENT_DIR}/project 
  ${MAGIC_FRAGMENT_DIR}/psdbms 
  ${MAGIC_FRAGMENT_DIR}/psl 
  ${MAGIC_FRAGMENT_DIR}/pulsar 
  ${MAGIC_FRAGMENT_DIR}/pwsafe 
  ${MAGIC_FRAGMENT_DIR}/pyramid 
  ${MAGIC_FRAGMENT_DIR}/python 
  ${MAGIC_FRAGMENT_DIR}/qt 
  ${MAGIC_FRAGMENT_DIR}/revision 
  ${MAGIC_FRAGMENT_DIR}/riff 
  ${MAGIC_FRAGMENT_DIR}/rpm 
  ${MAGIC_FRAGMENT_DIR}/rtf 
  ${MAGIC_FRAGMENT_DIR}/ruby 
  ${MAGIC_FRAGMENT_DIR}/sc 
  ${MAGIC_FRAGMENT_DIR}/sccs 
  ${MAGIC_FRAGMENT_DIR}/scientific 
  ${MAGIC_FRAGMENT_DIR}/securitycerts 
  ${MAGIC_FRAGMENT_DIR}/selinux 
  ${MAGIC_FRAGMENT_DIR}/sendmail 
  ${MAGIC_FRAGMENT_DIR}/sequent 
  ${MAGIC_FRAGMENT_DIR}/sereal 
  ${MAGIC_FRAGMENT_DIR}/sgi 
  ${MAGIC_FRAGMENT_DIR}/sgml 
  ${MAGIC_FRAGMENT_DIR}/sharc 
  ${MAGIC_FRAGMENT_DIR}/sinclair 
  ${MAGIC_FRAGMENT_DIR}/sisu 
  ${MAGIC_FRAGMENT_DIR}/sketch 
  ${MAGIC_FRAGMENT_DIR}/smalltalk 
  ${MAGIC_FRAGMENT_DIR}/smile 
  ${MAGIC_FRAGMENT_DIR}/sniffer 
  ${MAGIC_FRAGMENT_DIR}/softquad 
  ${MAGIC_FRAGMENT_DIR}/spec 
  ${MAGIC_FRAGMENT_DIR}/spectrum 
  ${MAGIC_FRAGMENT_DIR}/sql 
  ${MAGIC_FRAGMENT_DIR}/ssh 
  ${MAGIC_FRAGMENT_DIR}/ssl 
  ${MAGIC_FRAGMENT_DIR}/sun 
  ${MAGIC_FRAGMENT_DIR}/symbos 
  ${MAGIC_FRAGMENT_DIR}/sysex 
  ${MAGIC_FRAGMENT_DIR}/tcl 
  ${MAGIC_FRAGMENT_DIR}/teapot 
  ${MAGIC_FRAGMENT_DIR}/terminfo 
  ${MAGIC_FRAGMENT_DIR}/tex 
  ${MAGIC_FRAGMENT_DIR}/tgif 
  ${MAGIC_FRAGMENT_DIR}/ti-8x 
  ${MAGIC_FRAGMENT_DIR}/timezone 
  ${MAGIC_FRAGMENT_DIR}/troff 
  ${MAGIC_FRAGMENT_DIR}/tuxedo 
  ${MAGIC_FRAGMENT_DIR}/typeset 
  ${MAGIC_FRAGMENT_DIR}/unicode 
  ${MAGIC_FRAGMENT_DIR}/unknown 
  ${MAGIC_FRAGMENT_DIR}/uterus 
  ${MAGIC_FRAGMENT_DIR}/uuencode 
  ${MAGIC_FRAGMENT_DIR}/varied.out 
  ${MAGIC_FRAGMENT_DIR}/vacuum-cleaner 
  ${MAGIC_FRAGMENT_DIR}/varied.script 
  ${MAGIC_FRAGMENT_DIR}/vax 
  ${MAGIC_FRAGMENT_DIR}/vicar 
  ${MAGIC_FRAGMENT_DIR}/virtual 
  ${MAGIC_FRAGMENT_DIR}/virtutech 
  ${MAGIC_FRAGMENT_DIR}/visx 
  ${MAGIC_FRAGMENT_DIR}/vms 
  ${MAGIC_FRAGMENT_DIR}/vmware 
  ${MAGIC_FRAGMENT_DIR}/vorbis 
  ${MAGIC_FRAGMENT_DIR}/vxl 
  ${MAGIC_FRAGMENT_DIR}/warc 
  ${MAGIC_FRAGMENT_DIR}/weak 
  ${MAGIC_FRAGMENT_DIR}/webassembly 
  ${MAGIC_FRAGMENT_DIR}/windows 
  ${MAGIC_FRAGMENT_DIR}/wireless 
  ${MAGIC_FRAGMENT_DIR}/wordprocessors 
  ${MAGIC_FRAGMENT_DIR}/wsdl 
  ${MAGIC_FRAGMENT_DIR}/x68000 
  ${MAGIC_FRAGMENT_DIR}/xdelta 
  ${MAGIC_FRAGMENT_DIR}/xenix 
  ${MAGIC_FRAGMENT_DIR}/xilinx 
  ${MAGIC_FRAGMENT_DIR}/xo65 
  ${MAGIC_FRAGMENT_DIR}/xwindows 
  ${MAGIC_FRAGMENT_DIR}/yara 
  ${MAGIC_FRAGMENT_DIR}/zfs 
  ${MAGIC_FRAGMENT_DIR}/zilog 
  ${MAGIC_FRAGMENT_DIR}/zyxel
)

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
