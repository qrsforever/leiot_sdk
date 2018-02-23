# InternalFuncs.cmake

# Instead of cmake INCLUDE: Check file exist before include cmake file
MACRO (LEIOT_MACRO_INCLUDE path)
    IF (EXISTS ${path})
        INCLUDE (${path})
    ELSE()
        MESSAGE (WARNING "Not found ${path}")
    ENDIF()
ENDMACRO ()

# Instead of cmake OPTION: Option and message
MACRO (LEIOT_MACRO_OPTION var desc value)
    OPTION (${var} ${desc} ${value})
    MESSAGE (STATUS "${desc}: ${value}")
ENDMACRO ()

# Instead of cmake MESSAGE: Using LEIOT_CMAKE_DEBUG control
FUNCTION (LEIOT_CMAKE_ECHO message)
    IF (LEIOT_CMAKE_DEBUG)
        MESSAGE (STATUS ${message})
    ENDIF ()
ENDFUNCTION ()

MACRO (LEIOT_COMPILE_INFO target)
    GET_DIRECTORY_PROPERTY(incs INCLUDE_DIRECTORIES)
    FOREACH (inc ${incs})
        MESSAGE (STATUS "Current ${target} inc dir: ${inc}")
    ENDFOREACH ()
    GET_DIRECTORY_PROPERTY(defs COMPILE_DEFINITIONS)
    FOREACH (def ${defs})
        MESSAGE (STATUS "Current ${target} definition: ${def}")
    ENDFOREACH ()
    GET_TARGET_PROPERTY (libs ${target} LINK_LIBRARIES)
    FOREACH (lib ${libs})
        MESSAGE (STATUS "Current ${target} library: ${lib}")
    ENDFOREACH ()
ENDMACRO ()
