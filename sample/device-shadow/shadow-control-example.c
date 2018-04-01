/*
 * Copyright (C) 2018 LeEco, all rights reserved.
 */

#ifdef ENABLE_TENCENT_CLOUD

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <unistd.h>

#include "iot_import.h"
#include "iot_export.h"

#define PRODUCT_KEY             "S7JV8369SF"
#define DEVICE_NAME             "testcontrol"
#define DEVICE_SECRET           "123456"
#define QCLOUD_IOT_CERT_FILENAME          "testcontrol_cert.crt"
#define QCLOUD_IOT_KEY_FILENAME           "testcontrol_private.key"
static char sg_cert_file[128];
static char sg_key_file[128];

#define CONTROL_ACTION          "volume_switch"
#define TARGET_DEVICE_NAME      "testshadow"

#define SHADOW_MQTT_MSGLEN      (1024)

#define SHADOW_TRACE(fmt, ...)  \
    do { \
        HAL_Printf("%s|%03d :: ", __func__, __LINE__); \
        HAL_Printf(fmt, ##__VA_ARGS__); \
        HAL_Printf("%s", "\r\n"); \
    } while(0)

int main()
{
    IOT_OpenLog("shadow");
    IOT_SetLogLevel(IOT_LOG_DEBUG);

    char *msg_buf = (char *)HAL_Malloc(SHADOW_MQTT_MSGLEN);
    char *msg_readbuf = (char *)HAL_Malloc(SHADOW_MQTT_MSGLEN);

    char buf[1024];
    iotx_err_t rc;
    iotx_conn_info_pt puser_info;
    void *h_shadow;
    iotx_shadow_para_t shadow_para;

    /* Device AUTH */
    rc = IOT_SetupConnInfo(PRODUCT_KEY, DEVICE_NAME, DEVICE_SECRET, (void **)&puser_info);
    if (SUCCESS_RETURN != rc) {
        SHADOW_TRACE("rc = IOT_SetupConnInfo() = %d", rc);
        return rc;
    }

    /* Construct a device shadow */
    memset(&shadow_para, 0, sizeof(iotx_shadow_para_t));

    char current_path[256];
    char *cwd = getcwd(current_path, sizeof(current_path));
    if (cwd == NULL) {
        SHADOW_TRACE("getcwd return NULL");
        return -1;
    }
    sprintf(sg_cert_file, "%s/certs/%s", current_path, QCLOUD_IOT_CERT_FILENAME);
    sprintf(sg_key_file, "%s/certs/%s", current_path, QCLOUD_IOT_KEY_FILENAME);
    shadow_para.mqtt.cert_file = sg_cert_file;
    shadow_para.mqtt.key_file = sg_key_file;

    shadow_para.mqtt.port = puser_info->port;
    shadow_para.mqtt.host = puser_info->host_name;
    shadow_para.mqtt.client_id = puser_info->client_id;
    shadow_para.mqtt.username = puser_info->username;
    shadow_para.mqtt.password = puser_info->password;
    shadow_para.mqtt.pub_key = puser_info->pub_key;

    shadow_para.mqtt.request_timeout_ms = 2000;
    shadow_para.mqtt.clean_session = 0;
    shadow_para.mqtt.keepalive_interval_ms = 60000;
    shadow_para.mqtt.pread_buf = msg_readbuf;
    shadow_para.mqtt.read_buf_size = SHADOW_MQTT_MSGLEN;
    shadow_para.mqtt.pwrite_buf = msg_buf;
    shadow_para.mqtt.write_buf_size = SHADOW_MQTT_MSGLEN;

    shadow_para.mqtt.handle_event.h_fp = NULL;
    shadow_para.mqtt.handle_event.pcontext = NULL;

    h_shadow = IOT_Shadow_Construct(&shadow_para);
    if (NULL == h_shadow) {
        SHADOW_TRACE("construct device shadow failed!");
        return rc;
    }

    char data[128] = {0};
    int size = HAL_Snprintf(data, sizeof(data),
        "{\"command\": \"%s\", \"parameters\":{\"shift\":\"up\"}, \"targetDevice\": \"%s\"}",
        CONTROL_ACTION,
        TARGET_DEVICE_NAME);
    while (1) {
        SHADOW_TRACE("report event: %s\n", data);
        IOT_Shadow_Event_Report(h_shadow, data, size);
        IOT_Shadow_Yield(h_shadow, 10000);
    }

    HAL_Free(msg_buf);
    HAL_Free(msg_readbuf);

    SHADOW_TRACE("out of demo!");
    IOT_DumpMemoryStats(IOT_LOG_DEBUG);
    IOT_CloseLog();
    return 0;
}
#endif
