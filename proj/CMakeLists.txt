cmake_minimum_required (VERSION 3.13)

project (proj)
set(VERSION "5.2.0")

set(INSTALL_DIR ".")
file(GLOB libs "/usr/local/lib/libproj*")
install(PROGRAMS ${libs} DESTINATION "${INSTALL_DIR}/lib")
file(GLOB incs "/usr/local/include/proj*")
install(FILES ${incs} DESTINATION "${INSTALL_DIR}/include")
install(FILES "/usr/local/lib/pkgconfig/proj.pc"
        DESTINATION "${INSTALL_DIR}/lib/pkgconfig")
file(GLOB bins "/usr/local/bin/cct"
               "/usr/local/bin/cs2cs"
               "/usr/local/bin/geod"
               "/usr/local/bin/gie"
               "/usr/local/bin/invgeod"
               "/usr/local/bin/invproj"
               "/usr/local/bin/nad2bin"
               "/usr/local/bin/proj")
install(PROGRAMS ${bins} DESTINATION "${INSTALL_DIR}/bin")
file(GLOB man1 "/usr/local/share/man/man1/geod.1"
               "/usr/local/share/man/man1/proj.1"
               "/usr/local/share/man/man1/cs2cs.1"
               "/usr/local/share/man/man1/cct.1"
               "/usr/local/share/man/man1/gie.1")
install(FILES ${man1} DESTINATION "${INSTALL_DIR}/share/man/man1")
file(GLOB man3 "/usr/local/share/man/man3/pj_init.3"
               "/usr/local/share/man/man3/geodesic.3")
install(FILES ${man3} DESTINATION "${INSTALL_DIR}/share/man/man3")
install(DIRECTORY "/usr/local/share/proj" DESTINATION "${INSTALL_DIR}/share")

set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_NAME "proj")
set(CPACK_PACKAGE_VERSION ${VERSION})
set(CPACK_PACKAGE_RELEASE 1)
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}")
include(CPack)
