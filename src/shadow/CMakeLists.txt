# shadow/CMakeLists.txt

FILE (GLOB_RECURSE SHADOW_C_SOURCES "${CMAKE_CURRENT_LIST_DIR}/*.c")

LIST (APPEND LEIOT_INCLUDES ${CMAKE_CURRENT_LIST_DIR})

LIST (APPEND LEIOT_C_SOURCES ${SHADOW_C_SOURCES})
