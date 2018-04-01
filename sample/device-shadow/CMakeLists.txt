# sample/device-shadow/CMakeLists.txt

LEIOT_GLOBAL_GET (GLOBAL_STATIC_LIBS)
LEIOT_GLOBAL_GET (GLOBAL_SHARED_LIBS)

##############################
###     shadow-example     ###
##############################

SET (SAMPLE_NAME shadow-example)

ADD_EXECUTABLE (${SAMPLE_NAME} shadow-example.c)

IF (GLOBAL_STATIC_LIBS)
    TARGET_LINK_LIBRARIES (${SAMPLE_NAME} -Wl,--start-group ${GLOBAL_STATIC_LIBS} -Wl,--end-group)
ENDIF ()

IF (GLOBAL_SHARED_LIBS)
    TARGET_LINK_LIBRARIES (${SAMPLE_NAME} ${GLOBAL_SHARED_LIBS})
ENDIF ()

IF (ENABLE_TENCENT_CLOUD)
    ADD_CUSTOM_COMMAND( TARGET ${SAMPLE_NAME} POST_BUILD
        COMMAND cp -arf ${PROJECT_TOP_DIR}/doc/qcloud/certs ${EXECUTABLE_OUTPUT_PATH}
        )
ENDIF ()

# Debug
LEIOT_TARGET_COMPILE_INFO (${SAMPLE_NAME})

##############################
### shadow-control-example ###
##############################

SET (SAMPLE_CTR_NAME shadow-control-example)

ADD_EXECUTABLE (${SAMPLE_CTR_NAME} shadow-control-example.c)

IF (GLOBAL_STATIC_LIBS)
    TARGET_LINK_LIBRARIES (${SAMPLE_CTR_NAME} -Wl,--start-group ${GLOBAL_STATIC_LIBS} -Wl,--end-group)
ENDIF ()

IF (GLOBAL_SHARED_LIBS)
    TARGET_LINK_LIBRARIES (${SAMPLE_CTR_NAME} ${GLOBAL_SHARED_LIBS})
ENDIF ()

# Debug
LEIOT_TARGET_COMPILE_INFO (${SAMPLE_CTR_NAME})
