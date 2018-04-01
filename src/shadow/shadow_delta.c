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
#include "utils_list.h"
#include "shadow_delta.h"

static uint32_t iotx_shadow_get_timestamp(const char *pmetadata_desired,
        size_t len_metadata_desired,
        const char *pname)
{
    const char *pdata;

    /* attribute be matched, and then get timestamp */

    pdata = LITE_json_value_of((char *)pname, (char *)pmetadata_desired);

    if (NULL != pdata) {
        pdata = LITE_json_value_of((char *)"timestamp", (char *)pdata);
        if (NULL != pdata) {
            return atoi(pdata);
        }
    }

    log_err("NOT timestamp in JSON doc");
    return 0;
}


static iotx_err_t iotx_shadow_delta_update_attr_value(
            iotx_shadow_attr_pt pattr,
            const char *pvalue,
            size_t value_len)
{
    return iotx_ds_common_convert_string2data(pvalue, value_len, pattr->attr_type, pattr->pattr_data);
}


static void iotx_shadow_delta_update_attr(iotx_shadow_pt pshadow,
        const char *json_doc_attr,
        uint32_t json_doc_attr_len,
        const char *json_doc_metadata,
        uint32_t json_doc_metadata_len)
{
    const char *pvalue;
    iotx_shadow_attr_pt pattr;
    list_iterator_t *iter;
    list_node_t *node;

    /* Iterate the list and check JSON document according to list_node.val.pattr_name */
    /* If the attribute be found, call the function registered by calling iotx_shadow_delta_register_attr() */

    HAL_MutexLock(pshadow->mutex);
    iter = list_iterator_new(pshadow->inner_data.attr_list, LIST_TAIL);
    if (NULL == iter) {
        HAL_MutexUnlock(pshadow->mutex);
        log_warning("Allocate memory failed");
        return ;
    }

    while (node = list_iterator_next(iter), NULL != node) {
        pattr = (iotx_shadow_attr_pt)node->val;
        pvalue = LITE_json_value_of((char *)pattr->pattr_name, (char *)json_doc_attr);

        /* check if match attribute or not be matched */
        if (NULL != pvalue) { /* attribute be matched */
            /* get timestamp */
            pattr->timestamp = iotx_shadow_get_timestamp(
                                           json_doc_metadata,
                                           json_doc_metadata_len,
                                           pattr->pattr_name);

            /* convert string of JSON value according to destination data type. */
            if (SUCCESS_RETURN != iotx_shadow_delta_update_attr_value(pattr, pvalue, strlen(pvalue))) {
                log_warning("Update attribute value failed.");
            }

            if (NULL != pattr->callback) {
                HAL_MutexUnlock(pshadow->mutex);
                /* call related callback function */
                pattr->callback(pattr);
                HAL_MutexLock(pshadow->mutex);
            }
        }
    }

    list_iterator_destroy(iter);
    HAL_MutexUnlock(pshadow->mutex);
}

void iotx_shadow_delta_entry(
            iotx_shadow_pt pshadow,
            const char *json_doc,
            size_t json_doc_len)
{
    const char *key_metadata;
    const char *pstate, *pmetadata;

#ifdef ENABLE_TENCENT_CLOUD
    const char *pname;
    pname = LITE_json_value_of((char *)"type", (char *)json_doc);
    if ((strlen("delta") == strlen(pname)) && !strcmp(pname, "delta")) {
        pstate = LITE_json_value_of((char *)"payload.state", (char *)json_doc);
        key_metadata = "payload.metadata";
    } else {
        pstate = LITE_json_value_of((char *)"payload.state.delta", (char *)json_doc);
        if (NULL != pstate) {
            key_metadata = "payload.metadata.delta";
        } else {
#endif
            pstate = LITE_json_value_of((char *)"payload.state.desired", (char *)json_doc);
            if (NULL != pstate) {
                key_metadata = "payload.metadata.desired";
            } else {
                /* if have not desired key, get reported key instead. */
                pstate = LITE_json_value_of((char *)"payload.state.reported", (char *)json_doc);
                key_metadata = "payload.metadata.reported";
            }
#ifdef ENABLE_TENCENT_CLOUD
        }
    }
    LITE_free(pname);
#endif

    pmetadata = LITE_json_value_of((char *)key_metadata, (char *)json_doc);

    if ((NULL == pstate) || (NULL == pmetadata)) {
        log_err("Invalid JSON Doc");
        return;
    }

    iotx_shadow_delta_update_attr(pshadow,
                                  pstate,
                                  strlen(pstate),
                                  pmetadata,
                                  strlen(pmetadata));

    LITE_free(pstate);
    LITE_free(pmetadata);

    /* generate ACK and publish to @update topic using QOS1 */
    IOT_Shadow_Desired_Null(pshadow);
}

