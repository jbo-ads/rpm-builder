cmake_minimum_required (VERSION 3.13)

project (sqlite3)
set(VERSION "3.27.1")

set(INSTALL_DIR ".")
file(GLOB libs "/usr/local/lib/libsqlite3*")
install(PROGRAMS ${libs} DESTINATION "${INSTALL_DIR}/lib")
file(GLOB incs "/usr/local/include/sqlite3*")
install(FILES ${incs} DESTINATION "${INSTALL_DIR}/include")
install(PROGRAMS "/usr/local/bin/sqlite3"
        DESTINATION "${INSTALL_DIR}/bin")


set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_NAME "sqlite3")
set(CPACK_PACKAGE_VERSION ${VERSION})
set(CPACK_PACKAGE_RELEASE 1)
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}")
include(CPack)
