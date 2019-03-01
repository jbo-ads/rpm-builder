cmake_minimum_required (VERSION 3.13)

project (libexpat)
set(VERSION "2.2.6")

set(INSTALL_DIR ".")
file(GLOB libs "/usr/local/lib/libexpat*")
install(PROGRAMS ${libs} DESTINATION "${INSTALL_DIR}/lib")
install(FILES "/usr/local/lib/pkgconfig/expat.pc"
        DESTINATION "${INSTALL_DIR}/lib/pkgconfig")
file(GLOB incs "/usr/local/include/expat*.h")
install(FILES ${incs} DESTINATION "${INSTALL_DIR}/include")
install(DIRECTORY "/usr/local/share/doc/expat"
        DESTINATION "${INSTALL_DIR}/share/doc")

set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_NAME "libexpat")
set(CPACK_PACKAGE_VERSION ${VERSION})
set(CPACK_PACKAGE_RELEASE 1)
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}")
include(CPack)
