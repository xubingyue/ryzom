#
# Find the W3C libwww includes and library
#
# This module defines
# LIBWWW_INCLUDE_DIR, where to find tiff.h, etc.
# LIBWWW_LIBRARY, where to find the LibWWW library.
# LIBWWW_FOUND, If false, do not try to use LibWWW.

OPTION(WITH_LIBWWW_STATIC "Use only static libraries for libwww" OFF)

SET(LIBWWW_FIND_QUIETLY ${Libwww_FIND_QUIETLY})

# also defined, but not for general use are
IF(LIBWWW_LIBRARIES AND LIBWWW_INCLUDE_DIR)
  # in cache already
  SET(LIBWWW_FIND_QUIETLY TRUE)
ENDIF(LIBWWW_LIBRARIES AND LIBWWW_INCLUDE_DIR)

FIND_PATH(LIBWWW_INCLUDE_DIR
  WWWInit.h
  PATHS
  /usr/local/include
  /usr/include
  /sw/include
  /opt/local/include
  /opt/csw/include
  /opt/include
  PATH_SUFFIXES libwww w3c-libwww
)

# when installing libwww on mac os x using macports the file wwwconf.h resides
# in /opt/local/include and not in the real libwww include dir :/
FIND_PATH(LIBWWW_ADDITIONAL_INCLUDE_DIR
  wwwconf.h
  PATHS
  /usr/local/include
  /usr/include
  /sw/include
  /opt/local/include
  /opt/csw/include
  /opt/include
)

# combine both include directories into one variable
IF(LIBWWW_ADDITIONAL_INCLUDE_DIR)
  SET(LIBWWW_INCLUDE_DIR ${LIBWWW_INCLUDE_DIR} ${LIBWWW_ADDITIONAL_INCLUDE_DIR})
ENDIF(LIBWWW_ADDITIONAL_INCLUDE_DIR)

# helper to find all the libwww sub libraries
MACRO(FIND_WWW_LIBRARY MYLIBRARY OPTION)
  IF(WITH_LIBWWW_STATIC AND UNIX AND NOT APPLE AND NOT WITH_STATIC_EXTERNAL)
    SET(CMAKE_FIND_LIBRARY_SUFFIXES_OLD ${CMAKE_FIND_LIBRARY_SUFFIXES})
    SET(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
  ENDIF(WITH_LIBWWW_STATIC AND UNIX AND NOT APPLE AND NOT WITH_STATIC_EXTERNAL)

  FIND_LIBRARY(${MYLIBRARY}
    NAMES ${ARGN}
    PATHS
    /usr/local/lib
    /usr/lib
    /usr/local/X11R6/lib
    /usr/X11R6/lib
    /sw/lib
    /opt/local/lib
    /opt/csw/lib
    /opt/lib
    /usr/freeware/lib64
  )

  IF(CMAKE_FIND_LIBRARY_SUFFIXES_OLD)
    SET(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES_OLD})
  ENDIF(CMAKE_FIND_LIBRARY_SUFFIXES_OLD)

  IF(${MYLIBRARY})
    IF(${OPTION} STREQUAL REQUIRED OR WITH_STATIC OR WITH_LIBWWW_STATIC)
      SET(LIBWWW_LIBRARIES ${LIBWWW_LIBRARIES} ${${MYLIBRARY}})
    ENDIF(${OPTION} STREQUAL REQUIRED OR WITH_STATIC OR WITH_LIBWWW_STATIC)
  ELSE(${MYLIBRARY})
    IF(NOT LIBWWW_FIND_QUIETLY AND NOT WIN32)
      MESSAGE(STATUS "Warning: Libwww: Library not found: ${MYLIBRARY}")
    ENDIF(NOT LIBWWW_FIND_QUIETLY AND NOT WIN32)
  ENDIF(${MYLIBRARY})

  MARK_AS_ADVANCED(${MYLIBRARY})
ENDMACRO(FIND_WWW_LIBRARY)

MACRO(LINK_WWW_LIBRARY MYLIBRARY OTHERLIBRARY SYMBOL)
  IF(NOT WITH_LIBWWW_STATIC AND NOT  WITH_STATIC_EXTERNAL)
    LINK_DEPENDS(LIBWWW_LIBRARIES ${MYLIBRARY} ${OTHERLIBRARY} ${SYMBOL})
  ENDIF(NOT WITH_LIBWWW_STATIC AND NOT  WITH_STATIC_EXTERNAL)
ENDMACRO(LINK_WWW_LIBRARY)

# Find and link required libs for static or dynamic
FIND_WWW_LIBRARY(LIBWWWAPP_LIBRARY REQUIRED wwwapp) # cache core file ftp gopher html http mime news stream telnet trans utils zip xml xmlparse
FIND_WWW_LIBRARY(LIBWWWCORE_LIBRARY REQUIRED wwwcore) # utils
FIND_WWW_LIBRARY(LIBWWWFILE_LIBRARY REQUIRED wwwfile) # core trans utils html
FIND_WWW_LIBRARY(LIBWWWHTML_LIBRARY REQUIRED wwwhtml) # core utils
FIND_WWW_LIBRARY(LIBWWWHTTP_LIBRARY REQUIRED wwwhttp) # md5 core mime stream utils
FIND_WWW_LIBRARY(LIBWWWMIME_LIBRARY REQUIRED wwwmime) # core cache stream utils

# Required for static or if underlinking
FIND_WWW_LIBRARY(LIBWWWCACHE_LIBRARY OPTIONAL wwwcache) # core trans utils
FIND_WWW_LIBRARY(LIBWWWSTREAM_LIBRARY OPTIONAL wwwstream) # core file utils

FIND_WWW_LIBRARY(LIBWWWTRANS_LIBRARY REQUIRED wwwtrans) # core utils
FIND_WWW_LIBRARY(LIBWWWUTILS_LIBRARY REQUIRED wwwutils)


# Required only if underlinking

# Unused protocols
FIND_WWW_LIBRARY(LIBWWWFTP_LIBRARY OPTIONAL wwwftp) # core file utils
FIND_WWW_LIBRARY(LIBWWWGOPHER_LIBRARY OPTIONAL wwwgopher) # core html utils file
FIND_WWW_LIBRARY(LIBWWWNEWS_LIBRARY OPTIONAL wwwnews) # core html mime stream utils
FIND_WWW_LIBRARY(LIBWWWTELNET_LIBRARY OPTIONAL wwwtelnet) # core utils

# Other used by app
FIND_WWW_LIBRARY(LIBWWWDIR_LIBRARY OPTIONAL wwwdir) # file
FIND_WWW_LIBRARY(LIBWWWINIT_LIBRARY OPTIONAL wwwinit) # app cache core file html utils
FIND_WWW_LIBRARY(LIBWWWMUX_LIBRARY OPTIONAL wwwmux) # core stream trans utils
FIND_WWW_LIBRARY(LIBWWWXML_LIBRARY OPTIONAL wwwxml) # core utils xmlparse
FIND_WWW_LIBRARY(LIBWWWZIP_LIBRARY OPTIONAL wwwzip) # core utils
FIND_WWW_LIBRARY(LIBXMLPARSE_LIBRARY OPTIONAL xmlparse) # xmltok

# Other used by other
FIND_WWW_LIBRARY(LIBXMLTOK_LIBRARY OPTIONAL xmltok)
FIND_WWW_LIBRARY(LIBWWWSSL_LIBRARY OPTIONAL wwwssl)
FIND_WWW_LIBRARY(LIBMD5_LIBRARY OPTIONAL md5)
FIND_WWW_LIBRARY(LIBPICS_LIBRARY OPTIONAL pics)

# Other external libraries
FIND_PACKAGE(EXPAT QUIET)
FIND_PACKAGE(OpenSSL QUIET)
FIND_WWW_LIBRARY(LIBREGEX_LIBRARY OPTIONAL gnu_regex)

# Now link all libs together
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWCACHE_LIBRARY HTLoadCache)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWCACHE_LIBRARY HTCacheAppend)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWFTP_LIBRARY HTLoadFTP)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWGOPHER_LIBRARY HTLoadGopher)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWNEWS_LIBRARY HTLoadNews)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWTELNET_LIBRARY HTLoadTelnet)

LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWSTREAM_LIBRARY HTStreamToChunk)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWSTREAM_LIBRARY HTGuess_new)
LINK_WWW_LIBRARY(LIBWWWFILE_LIBRARY LIBWWWDIR_LIBRARY HTDir_new)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWINIT_LIBRARY HTProtocolInit)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWXML_LIBRARY HTXML_new)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBWWWZIP_LIBRARY HTZLib_inflate)

# libwwwxml can be linked to xmlparse or expat
LINK_WWW_LIBRARY(LIBWWWXML_LIBRARY LIBXMLPARSE_LIBRARY XML_ParserCreate)

IF(LIBXMLPARSE_LIBRARY_LINKED)
  LINK_WWW_LIBRARY(LIBXMLPARSE_LIBRARY EXPAT_LIBRARY XmlInitEncoding)
ELSE(LIBXMLPARSE_LIBRARY_LINKED)
  LINK_WWW_LIBRARY(LIBWWWXML_LIBRARY EXPAT_LIBRARY XML_ParserCreate)
ENDIF(LIBXMLPARSE_LIBRARY_LINKED)

LINK_WWW_LIBRARY(LIBWWWHTTP_LIBRARY LIBMD5_LIBRARY MD5Init)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY LIBREGEX_LIBRARY regexec)
LINK_WWW_LIBRARY(LIBWWWAPP_LIBRARY OPENSSL_LIBRARIES SSL_new)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibWWW DEFAULT_MSG
  LIBWWW_LIBRARIES
  LIBWWW_INCLUDE_DIR
)