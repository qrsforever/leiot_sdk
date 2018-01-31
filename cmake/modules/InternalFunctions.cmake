# InternalFunctions.cmake

# check file exist before include cmake file
MACRO (LEIOT_MACRO_INCLUDE path) 
    IF (EXISTS ${path})
        INCLUDE (${path})
    ELSE()
        MESSAGE (WARNING "Not found ${path}")
    ENDIF()
ENDMACRO ()

MACRO (LEIOT_MACRO_OPTION var desc value)
    OPTION (${var} ${desc} ${value})
    MESSAGE (STATUS "${desc}: ${value}")
ENDMACRO ()

FUNCTION (LEIOT_CMAKE_ECHO message)
    IF (LEIOT_CMAKE_ECHO)
        MESSAGE (STATUS ${message})
    ENDIF ()
ENDFUNCTION ()
