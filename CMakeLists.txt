cmake_minimum_required (VERSION 3.13)


if (NOT DEFINED NAME)
  message(FATAL_ERROR "Missing \"-DNAME=...\" package specification")
endif()
set(IDIR "$ENV{HOME}/install/${NAME}")
if (NOT EXISTS "${IDIR}" OR NOT IS_DIRECTORY "${IDIR}")
  message(FATAL_ERROR "\"${NAME}\" is not a known package (check ${IDIR}/)")
endif()


project(${NAME})


if(${NAME} STREQUAL ecw)
  set(VERSION_FILE "${IDIR}/include/ECWJP2BuildNumber.h")
  set(VSUFFIX " ")
  set(VPATCH "SERVICE")
  set(DIRS "etc")
  file(GLOB libs "${IDIR}/redistributable/x64/*")
elseif(${NAME} STREQUAL kdu)
  set(VERSION_FILE "${IDIR}/coresys/common/kdu_compressed.h")
  set(VSUFFIX "_")
  set(VPATCH "PATCH")
  set(DIRS "lib")
elseif(${NAME} STREQUAL expat)
  set(VERSION_FILE "${IDIR}/include/expat.h")
  set(VSUFFIX "_")
  set(VPATCH "MICRO")
  set(DIRS "include" "lib" "share")
elseif(${NAME} STREQUAL proj)
  set(VERSION_FILE "${IDIR}/include/proj.h")
  set(VSUFFIX " ")
  set(VPATCH "PATCH")
  set(DIRS "bin" "include" "lib" "share")
elseif(${NAME} STREQUAL sqlite)
  set(VERSION_FILE "${IDIR}/include/sqlite3.h")
  set(VSTRING "SQLITE_VERSION")
  set(DIRS "bin" "include" "lib")
elseif(${NAME} STREQUAL gdal)
  set(VERSION_FILE "${IDIR}/include/gdal_version.h")
  set(VSUFFIX " ")
  set(VPATCH "REV")
  set(DIRS "bin" "include" "lib" "share")
else()
  message(FATAL_ERROR "\"${NAME}\" is not implemented yet")
endif()


if (DEFINED VSUFFIX AND DEFINED VPATCH)
  execute_process(
      COMMAND awk "/_MAJOR${VSUFFIX}.*[0-9]\$/{printf \"%s\",$NF}" "${VERSION_FILE}"
      OUTPUT_VARIABLE VERSION_MAJOR)
  execute_process(
      COMMAND awk "/_MINOR${VSUFFIX}.*[0-9]\$/{printf \"%s\",$NF}" "${VERSION_FILE}"
      OUTPUT_VARIABLE VERSION_MINOR)
  execute_process(
      COMMAND awk "/_${VPATCH}${VSUFFIX}.*[0-9]\$/{printf \"%s\",$NF}" "${VERSION_FILE}"
      OUTPUT_VARIABLE VERSION_PATCH)
elseif(DEFINED VSTRING)
  execute_process(
      COMMAND awk "-F[.\"]" "/define *${VSTRING} /{printf \"%s\",$(NF-3)}" "${VERSION_FILE}"
      OUTPUT_VARIABLE VERSION_MAJOR)
  execute_process(
      COMMAND awk "-F[.\"]" "/define *${VSTRING} /{printf \"%s\",$(NF-2)}" "${VERSION_FILE}"
      OUTPUT_VARIABLE VERSION_MINOR)
  execute_process(
      COMMAND awk "-F[.\"]" "/define *${VSTRING} /{printf \"%s\",$(NF-1)}" "${VERSION_FILE}"
      OUTPUT_VARIABLE VERSION_PATCH)
endif()
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")


message(STATUS "PACKAGE: ${NAME} ${VERSION}")


set(INSTALL_DIR ".")
if(DEFINED libs)
  install(PROGRAMS ${libs} DESTINATION "${INSTALL_DIR}/lib")
endif()
if(DEFINED DIRS)
  foreach(DIR ${DIRS})
    install(DIRECTORY "${IDIR}/${DIR}" DESTINATION "${INSTALL_DIR}" USE_SOURCE_PERMISSIONS)
  endforeach()
endif()


set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_NAME ${NAME})
set(CPACK_PACKAGE_VERSION ${VERSION})
set(CPACK_PACKAGE_RELEASE 1)
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}")
# set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/local")
set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION
  ${CPACK_PACKAGING_INSTALL_PREFIX}
  ${CPACK_PACKAGING_INSTALL_PREFIX}/bin
  ${CPACK_PACKAGING_INSTALL_PREFIX}/etc
  ${CPACK_PACKAGING_INSTALL_PREFIX}/include
  ${CPACK_PACKAGING_INSTALL_PREFIX}/lib
  ${CPACK_PACKAGING_INSTALL_PREFIX}/lib/pkgconfig
  ${CPACK_PACKAGING_INSTALL_PREFIX}/share)
include(CPack)

