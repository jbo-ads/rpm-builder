cmake_minimum_required (VERSION 3.13)

project (libtiff)
set(VERSION "4.0.10")

set(INSTALL_DIR ".")
file(GLOB libs "/usr/local/lib/libtiff*")
install(PROGRAMS ${libs} DESTINATION "${INSTALL_DIR}/lib")
file(GLOB incs "/usr/local/include/tiff*")
install(FILES ${incs} DESTINATION "${INSTALL_DIR}/include")
install(FILES "/usr/local/lib/pkgconfig/libtiff-4.pc"
        DESTINATION "${INSTALL_DIR}/lib/pkgconfig")
file(GLOB bins "/usr/local/bin/tiff*"
               "/usr/local/bin/*2tiff"
               "/usr/local/bin/fax2ps"
               "/usr/local/bin/pal2rgb")
install(PROGRAMS ${bins} DESTINATION "${INSTALL_DIR}/bin")
file(GLOB man1 "/usr/local/share/man/man1/tiff*.1"
               "/usr/local/share/man/man1/*2tiff.1"
               "/usr/local/share/man/man1/fax2ps.1"
               "/usr/local/share/man/man1/pal2rgb.1")
install(FILES ${man1} DESTINATION "${INSTALL_DIR}/share/man/man1")
file(GLOB man3 "/usr/local/share/man/man3/*.3tiff")
install(FILES ${man3} DESTINATION "${INSTALL_DIR}/share/man/man3")
install(DIRECTORY "/usr/local/share/doc/tiff-${VERSION}" DESTINATION "${INSTALL_DIR}/share/doc")


set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_NAME "libtiff")
set(CPACK_PACKAGE_VERSION ${VERSION})
set(CPACK_PACKAGE_RELEASE 1)
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}")
include(CPack)
