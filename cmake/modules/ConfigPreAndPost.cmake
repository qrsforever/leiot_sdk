# cmake/modules/ConfigPreAndPost.cmake

# Configure Pre
FUNCTION (LEIOT_CONFIG_PRE file)
    MESSAGE (STATUS "+++++++++++++++++++ Configure Pre +++++++++++++++++++")
    EXECUTE_PROCESS (COMMAND date "+%Y%m%d%H%M%S"
        OUTPUT_VARIABLE TIMESTAMP
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    LEIOT_GLOBAL_APPEND (GLOBAL_DEFINITIONS 
        -DBUILD_VERSION=\"${LEIOT_SDK_VERSION}\"
        -DBUILD_TIMESTAMP=\"${TIMESTAMP}\"
        )
    SET (LEIOT_BUILD_VERSION "${LEIOT_SDK_VERSION}-${TIMESTAMP}" CACHE STRING "Build version Info")
    FILE (WRITE  ${file} "#ifndef _LEIOT_CONFIG_H_\n")
    FILE (APPEND ${file} "#define _LEIOT_CONFIG_H_\n\n")
    FILE (APPEND ${file} "#define BUILD_VERSION   \"${LEIOT_SDK_VERSION}\"\n")
    FILE (APPEND ${file} "#define BUILD_TIMESTAMP \"${TIMESTAMP}\"\n")
ENDFUNCTION ()

# Configure post
FUNCTION (LEIOT_CONFIG_POST file)
    FILE (APPEND ${file} "\n\n#endif // end _LEIOT_CONFIG_H_\n")
    LEIOT_GLOBAL_DEBUG()
    MESSAGE (STATUS "+++++++++++++++++++ Configure Post +++++++++++++++++++")
ENDFUNCTION ()
