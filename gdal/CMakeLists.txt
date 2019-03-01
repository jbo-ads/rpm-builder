cmake_minimum_required (VERSION 3.13)

project (gdal)
set(VERSION "2.2.4")

set(INSTALL_DIR ".")
file(GLOB libs "/usr/local/lib/libgdal*")
install(PROGRAMS ${libs} DESTINATION "${INSTALL_DIR}/lib")
file(GLOB incs "/usr/local/include/cpl*"
               "/usr/local/include/gdal*"
               "/usr/local/include/ogr*"
               "/usr/local/include/gnm*"
               "/usr/local/include/geodesic.h"
               "/usr/local/include/gvgcpfit.h"
               "/usr/local/include/internal_qhull_headers.h"
               "/usr/local/include/memdataset.h"
               "/usr/local/include/rawdataset.h"
               "/usr/local/include/thinplatespline.h"
               "/usr/local/include/vrtdataset.h")
install(FILES ${incs} DESTINATION "${INSTALL_DIR}/include")
install(FILES "/usr/local/lib/pkgconfig/gdal.pc"
        DESTINATION "${INSTALL_DIR}/lib/pkgconfig")
file(GLOB bins "/usr/local/bin/gdal*"
               "/usr/local/bin/gnm*"
               "/usr/local/bin/ogr*"
               "/usr/local/bin/nearblack"
               "/usr/local/bin/testepsg")
install(PROGRAMS ${bins} DESTINATION "${INSTALL_DIR}/bin")
install(DIRECTORY "/usr/local/share/gdal" DESTINATION "${INSTALL_DIR}/share")

set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_NAME "gdal")
set(CPACK_PACKAGE_VERSION ${VERSION})
set(CPACK_PACKAGE_RELEASE 1)
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}")
include(CPack)
