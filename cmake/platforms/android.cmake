# Config for android template.

SET (ANDROID_API "23")
SET (ANDROID_ARCH "arm64")
SET (CROSS_PREFIX "aarch64-linux-android-")

SET (ANDROID_STANDALONE_TOOLCHAIN  "${PROJECT_OUTPUT_PATH}/${SYSROOT_DIR}/sysroot_api${ANDROID_API}_${ANDROID_ARCH}")

SET (CMAKE_SYSROOT          "${ANDROID_STANDALONE_TOOLCHAIN}/sysroot")
SET (LEIOT_CROSS_PREFIX     "${ANDROID_STANDALONE_TOOLCHAIN}/bin/${CROSS_PREFIX}")

IF (NOT EXISTS "${ANDROID_STANDALONE_TOOLCHAIN}")
    MESSAGE (STATUS "Prepare the android build envirenment, please wait for a moment.")
    EXECUTE_PROCESS (
        COMMAND ${PROJECT_SCRIPT_DIR}/make_standalone_toolchain.sh ${ANDROID_API} ${ANDROID_ARCH} ${ANDROID_STANDALONE_TOOLCHAIN}
        RESULT_VARIABLE result
        )
    IF (NOT ${result} EQUAL 0)
        EXECUTE_PROCESS (COMMAND rm -rf ${ANDROID_STANDALONE_TOOLCHAIN})
        MESSAGE (FATAL_ERROR "run make_standalone_toolchain.sh error! [${result}]")
    ENDIF ()
ENDIF()

# Platform feature configure
LEIOT_OPTION (LEIOT_ENABLE_TLS      "Enable tls"        ON)
LEIOT_OPTION (LEIOT_ENABLE_MQTT     "Enable mqtt"       ON)
LEIOT_OPTION (LEIOT_ENABLE_OTA      "Enable ota"        ON)
LEIOT_OPTION (LEIOT_ENABLE_SUBDEV   "Enable sub device" ON)

SET (LEIOT_OTA_SIGNAL_CHANNEL MQTT CACHE STRING "Set ota signal channel(MQTT/COAP/HTTP)" FORCE)

# DEFS: platform definitions
LIST (APPEND PLATFORM_DEFINITIONS
    "-D_PLATFORM_IS_ANDROID_"
    "-D__UBUNTU_SDK_DEMO__"
    "-DCONFIG_HTTP_AUTH_TIMEOUT=500"
    "-DCONFIG_MID_HTTP_TIMEOUT=500"
    "-DCONFIG_GUIDER_AUTH_TIMEOUT=500"
    )

# CFLAG: compile c flags
LIST (APPEND PLATFORM_CFLAGS
    "-Wall"
    "-g3"
    "-rdynamic"
    "-fPIE"
    "-pie"
    )

# LDFLAG: linked flags
LIST (APPEND PLATFORM_LDFLAGS
    "-fPIE"
    "-pie"
    )

# DIR: link directories
LIST (APPEND PLATFORM_LINKS_DIR

    )

# DIR: include directories
LIST (APPEND PLATFORM_INCLUDE_DIR

    )

# LIB: dynamic platform libraries
LIST (APPEND PLATFORM_SHARED_LIBS
    "android"
    "log"
    )

# LIB: static platform libraries
LIST (APPEND PLATFORM_STATIC_LIBS

    )
