# Config for Linux.

LIST (APPEND PLATFORM_DEFINITIONS
    "-DOS_LINUX"
    )

# Platform feature configure
LEIOT_MACRO_OPTION (LEIOT_ENABLE_TLS  "Enable tls" ON)
LEIOT_MACRO_OPTION (LEIOT_ENABLE_MQTT "Enable mqtt" ON)
