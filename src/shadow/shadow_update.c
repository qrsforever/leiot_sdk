/*
 * Copyright (c) 2014-2016 Alibaba Group. All rights reserved.
 * License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */



#include "iot_import.h"

#include "lite-log.h"
#include "lite-utils.h"
#include "device.h"

#include "shadow_update.h"

extern void iotx_shadow_delta_entry(
            iotx_shadow_pt pshadow,
            const char *json_doc,
            size_t json_doc_len);


/* add a new wait element */
/* return: NULL, failed; others, pointer of element. */
iotx_update_ack_wait_list_pt iotx_shadow_update_wait_ack_list_add(
            iotx_shadow_pt pshadow,
            const char *ptoken, /* NOTE: this is NOT a string. */
            size_t token_len,
            iotx_push_cb_fpt cb,
            void *pcontext,
            uint32_t timeout_ms)
{
    int i;
    iotx_update_ack_wait_list_pt list = pshadow->inner_data.update_ack_wait_list;

    HAL_MutexLock(pshadow->mutex);

    for (i = 0; i < IOTX_DS_UPDATE_WAIT_ACK_LIST_NUM; ++i) {
        if (0 == list[i].flag_busy) {
            list[i].flag_busy = 1;
            break;
        }
    }

    HAL_MutexUnlock(pshadow->mutex);

    if (i >= IOTX_DS_UPDATE_WAIT_ACK_LIST_NUM) {
        return NULL;
    }

    list[i].callback = cb;
    list[i].pcontext = pcontext;

    if (token_len >= IOTX_DS_TOKEN_LEN) {
        log_warning("token is too long.");
        token_len = IOTX_DS_TOKEN_LEN - 1;
    }
    memcpy(list[i].token, ptoken, token_len);
    list[i].token[token_len] = '\0';

    iotx_time_init(&list[i].timer);
    utils_time_countdown_ms(&list[i].timer, timeout_ms);

    log_debug("Add update ACK list");

    return &list[i];
}


void iotx_shadow_update_wait_ack_list_remove(iotx_shadow_pt pshadow, iotx_update_ack_wait_list_pt element)
{
    HAL_MutexLock(pshadow->mutex);
    element->flag_busy = 0;
    memset(element, 0, sizeof(iotx_update_ack_wait_list_t));
    HAL_MutexUnlock(pshadow->mutex);
}


void iotx_ds_update_wait_ack_list_handle_expire(iotx_shadow_pt pshadow)
{
    size_t i;

    iotx_update_ack_wait_list_pt pelement = pshadow->inner_data.update_ack_wait_list;

    HAL_MutexLock(pshadow->mutex);

    for (i = 0; i < IOTX_DS_UPDATE_WAIT_ACK_LIST_NUM; ++i) {
        if (0 != pelement[i].flag_busy) {
            if (utils_time_is_expired(&pelement[i].timer)) {
                if (NULL != pelement[i].callback) {
                    pelement[i].callback(pelement[i].pcontext, IOTX_SHADOW_ACK_TIMEOUT, NULL, 0);
                }
                /* free it. */
                memset(&pelement[i], 0, sizeof(iotx_update_ack_wait_list_t));
            }
        }
    }

    HAL_MutexUnlock(pshadow->mutex);
}


/* handle response ACK of UPDATE */
void iotx_ds_update_wait_ack_list_handle_response(
            iotx_shadow_pt pshadow,
            const char *json_doc,
            size_t json_doc_len)
{
    int i;
    char *pdata, *ppayload, *pToken, *pdelta = NULL;
    iotx_update_ack_wait_list_pt pelement = pshadow->inner_data.update_ack_wait_list;

#ifdef ENABLE_TENCENT_CLOUD
    const char  *ptype;
    int result_code = 0;
#endif

    /* get token */
    pToken = LITE_json_value_of("clientToken", (char *)json_doc);
    if (NULL == pToken) {
        log_warning("Invalid JSON document: not 'clientToken' key");
        return;
    }

    ppayload = LITE_json_value_of("payload", (char *)json_doc);
    if (NULL == ppayload) {
        log_warning("Invalid JSON document: not 'payload' key");
        LITE_free(pToken);
        return;
    } else {
        log_debug("ppayload = %s", ppayload);
    }

    HAL_MutexLock(pshadow->mutex);
    for (i = 0; i < IOTX_DS_UPDATE_WAIT_ACK_LIST_NUM; ++i) {
        if (0 != pelement[i].flag_busy) {
            /* check the related */
            if (0 == memcmp(pToken, pelement[i].token, strlen(pelement[i].token))) {
                LITE_free(pToken);
                HAL_MutexUnlock(pshadow->mutex);
                log_debug("token=%s", pelement[i].token);
                do {
#ifndef ENABLE_TENCENT_CLOUD
                    pdata = LITE_json_value_of("status", (char *)ppayload);
                    if (NULL == pdata) {
                        log_warning("Invalid JSON document: not 'payload.status' key");
                        break;
                    }

                    if (0 == strncmp(pdata, "success", strlen(pdata))) {
                        LITE_free(pdata);
                        /* If have 'state' keyword in @json_shadow.payload, attribute value should be updated. */
                        pdelta = LITE_json_value_of("state", (char *)ppayload);
                        /*
                           if (NULL != pdelta) {
                           iotx_shadow_delta_entry(pshadow, json_doc, json_doc_len);
                           LITE_free(pdelta);
                           }
                           */
                        pelement[i].callback(pelement[i].pcontext, IOTX_SHADOW_ACK_SUCCESS, pelement[i].token, strlen(pelement[i].token));
                    } else if (0 == strncmp(pdata, "error", strlen(pdata))) {
                        LITE_free(pdata);
                        int ack_code;

                        pdata = LITE_json_value_of("content.errorcode", (char *)ppayload);
                        if (NULL == pdata) {
                            log_warning("Invalid JSON document: not 'content.errorcode' key");
                            break;
                        }
                        ack_code = atoi(pdata);
                        LITE_free(pdata);

                        pdata = LITE_json_value_of("content.errormessage", (char *)ppayload);
                        if (NULL == pdata) {
                            log_warning("Invalid JSON document: not 'content.errormessage' key");
                            break;
                        }

                        pelement[i].callback(pelement[i].pcontext, ack_code, pdata, strlen(pdata));
                        LITE_free(pdata);
                    } else {
                        log_warning("Invalid JSON document: value of 'status' key is invalid.");
                        LITE_free(pdata);
                    }
#else
                    /* tencent (update or get)*/
                    ptype = LITE_json_value_of("type", (char *)json_doc);
                    if (NULL == ptype) {
                        log_warning("Invalid JSON document: not 'type' key");
                        break;
                    }
                    pdata = LITE_json_value_of("result", (char *)json_doc);
                    if (NULL == pdata) {
                        log_warning("Invalid JSON document: not 'result' key");
                        LITE_free(ptype);
                        break;
                    }
                    result_code = atoi(pdata);
                    LITE_free(pdata);

                    /* TODO */
                    switch (result_code) {
                    case 0:
                        result_code = IOTX_SHADOW_ACK_SUCCESS;
                        break;
                    case 5003:
                        result_code = IOTX_SHADOW_ACK_ERR_JSON_FMT_IS_INVALID;
                        break;
                    case 5004:
                        result_code = IOTX_SHADOW_ACK_ERR_JSON_FMT_IS_INVALID;
                        break;
                    case 5005:
                        result_code = IOTX_SHADOW_ACK_ERR_VERSION_IS_INVALID;
                        break;
                    case 5006:
                        result_code = IOTX_SHADOW_ACK_ERR_JSON_FMT_IS_INVALID;
                        break;
                    case 5100:
                        result_code = IOTX_SHADOW_ACK_ERR_SERVER_FAILED;
                        break;
                    }
                    pelement[i].callback(pelement[i].pcontext, result_code, pelement[i].token, strlen(pelement[i].token));

                    log_debug("type[%s] result[%d]\n", ptype, result_code);
                    if ((strcmp(ptype, "get") == 0 && 0 == result_code) ||
                        (strcmp(ptype, "update") && 0 != result_code)) {
                        pdelta = LITE_json_value_of((char *)"payload.state.delta", (char *)json_doc);
                        /* TODO Fatal BUG.
                         * Indirectly call IOT_Shadow_Yield(), maybe modify pelement[i] or cause deadlock.
                         * */
                        /*
                        if (NULL != pdelta) {
                            iotx_shadow_delta_entry(pshadow, json_doc, json_doc_len);
                            LITE_free(pdelta);
                        }
                        */
                    }
                    LITE_free(ptype);
#endif
                } while (0);
                LITE_free(ppayload);
                HAL_MutexLock(pshadow->mutex);
                memset(&pelement[i], 0, sizeof(iotx_update_ack_wait_list_t));
                HAL_MutexUnlock(pshadow->mutex);

                /* Place here avoid the case of deadlock when call IOT_Shadow_Yield Indirectly */
                if (NULL != pdelta) {
                    iotx_shadow_delta_entry(pshadow, json_doc, json_doc_len);
                    LITE_free(pdelta);
                }
                return;
            }
        }
    }

    LITE_free(pToken);
    LITE_free(ppayload);
    HAL_MutexUnlock(pshadow->mutex);
    log_warning("Not match any wait element in list.");
}
