# Set variable from env.sh

SET (LEIOT_ENV_PATH $ENV{PATH})
SET (LEIOT_ENABLE_DEBUG $ENV{ENABLE_DEBUG})
SET (LEIOT_CLOUD_SERVER $ENV{CLOUD_SERVER})
SET (LEIOT_OS_PLATFORM $ENV{OS_PLATFORM})
SET (LEIOT_LIBS_STATIC $ENV{ENABLE_STATIC})

IF (NOT LEIOT_OS_PLATFORM)
    MESSAGE (FATAL_ERROR "Please specify the os platform!")
ENDIF ()

# Display on ccmake
SET (LEIOT_CROSS_PREFIX ${LEIOT_CROSS_PREFIX} CACHE STRING "RO Compiler prefix")
SET (LEIOT_OS_PLATFORM ${LEIOT_OS_PLATFORM} CACHE STRING "RO OS Platform")

# Console show env info
MESSAGE (STATUS "ENV LEIOT_ENABLE_DEBUG: ${LEIOT_ENABLE_DEBUG}")
MESSAGE (STATUS "ENV LEIOT_CLOUD_SERVER: ${LEIOT_CLOUD_SERVER}")
MESSAGE (STATUS "ENV LEIOT_ENABLE_STATIC: ${LEIOT_ENABLE_STATIC}")
MESSAGE (STATUS "ENV LEIOT_OS_PLATFORM: ${LEIOT_OS_PLATFORM}")
