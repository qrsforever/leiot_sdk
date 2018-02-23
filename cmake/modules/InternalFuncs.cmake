# InternalFuncs.cmake

# Instead of cmake INCLUDE: Check file exist before include cmake file
MACRO (LEIOT_INCLUDE path)
    IF (EXISTS ${CMAKE_CURRENT_LIST_DIR}/${path})
        INCLUDE (${CMAKE_CURRENT_LIST_DIR}/${path})
    ELSE()
        MESSAGE (WARNING "Not found ${CMAKE_CURRENT_LIST_DIR}/${path}")
    ENDIF()
ENDMACRO ()

# Instead of cmake OPTION: Option and message
MACRO (LEIOT_OPTION var desc value)
    OPTION (${var} ${desc} ${value})
    MESSAGE (STATUS "${desc}: ${value}")
ENDMACRO ()

# Instead of cmake MESSAGE: Using LEIOT_CMAKE_DEBUG control
FUNCTION (LEIOT_ECHO message)
    IF (LEIOT_CMAKE_DEBUG)
        MESSAGE (STATUS ${message})
    ENDIF ()
ENDFUNCTION ()

MACRO (LEIOT_COMPILE_INFO target)
    LEIOT_ECHO ("Target: ${target}")
    GET_DIRECTORY_PROPERTY(incs INCLUDE_DIRECTORIES)
    FOREACH (inc ${incs})
        LEIOT_ECHO ("\t includedir: ${inc}")
    ENDFOREACH ()
    GET_DIRECTORY_PROPERTY(defs COMPILE_DEFINITIONS)
    FOREACH (def ${defs})
        LEIOT_ECHO ("\t definition: ${def}")
    ENDFOREACH ()
    GET_TARGET_PROPERTY (libs ${target} LINK_LIBRARIES)
    FOREACH (lib ${libs})
        LEIOT_ECHO ("\t librarydir: ${lib}")
    ENDFOREACH ()
    GET_TARGET_PROPERTY (opts ${target} COMPILE_OPTIONS)
    FOREACH (opt ${opts})
        LEIOT_ECHO ("\t cflagsopts: ${opt}")
    ENDFOREACH ()
    LEIOT_ECHO ("------------------------------------------------------")
ENDMACRO ()

# Filter out
MACRO (LEIOT_FILTER_OUT output input arg0)
    LIST (APPEND ${output} ${${input}})
    LIST (REMOVE_ITEM ${output} ${arg0} ${ARGN})
ENDMACRO ()

# Global variable storage
MACRO (LEIOT_REGISTER_GLOBAL_PROPERTIES arg0)
    LEIOT_GLOBAL_APPEND (GLOBAL_PROPERTIES_LIST ${arg0} ${ARGN})
ENDMACRO ()

MACRO (LEIOT_GLOBAL_SET var arg0)
    SET_PROPERTY (GLOBAL PROPERTY ${var} ${arg0} ${ARGN})
ENDMACRO ()

MACRO (LEIOT_GLOBAL_GET var)
    GET_PROPERTY (${var} GLOBAL PROPERTY ${var})
ENDMACRO ()

MACRO (LEIOT_GLOBAL_APPEND var arg0)
    SET_PROPERTY (GLOBAL APPEND PROPERTY ${var} ${arg0} ${ARGN})
ENDMACRO ()

MACRO (LEIOT_GLOBAL_DEBUG)
    LEIOT_GLOBAL_GET (GLOBAL_PROPERTIES_LIST)
    FOREACH (var ${GLOBAL_PROPERTIES_LIST})
        LEIOT_GLOBAL_GET (${var})
        FOREACH (val ${${var}})
            LEIOT_ECHO ("${var}: ${val}")
        ENDFOREACH ()
    ENDFOREACH ()
ENDMACRO ()
