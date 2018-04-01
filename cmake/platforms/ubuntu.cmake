# Config for linux template.

# Platform feature configure
LEIOT_OPTION (LEIOT_ENABLE_TLS      "Enable tls"        ON)
LEIOT_OPTION (LEIOT_ENABLE_MQTT     "Enable mqtt"       ON)
LEIOT_OPTION (LEIOT_ENABLE_OTA      "Enable ota"        ON)
LEIOT_OPTION (LEIOT_ENABLE_SUBDEV   "Enable sub device" ON)

SET (LEIOT_OTA_SIGNAL_CHANNEL MQTT CACHE STRING "Set ota signal channel(MQTT/COAP/HTTP)" FORCE)

# DEFS: platform definitions
LIST (APPEND PLATFORM_DEFINITIONS
    "-D_PLATFORM_IS_LINUX_"
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
    )

# LDFLAG: linked flags
LIST (APPEND PLATFORM_LDFLAGS

    )

# DIR: link directories
LIST (APPEND PLATFORM_LINKS_DIR

    )

# DIR: include directories
LIST (APPEND PLATFORM_INCLUDE_DIR

    )

# LIB: dynamic platform libraries
LIST (APPEND PLATFORM_SHARED_LIBS

    )

# LIB: static platform libraries
LIST (APPEND PLATFORM_STATIC_LIBS

    )
