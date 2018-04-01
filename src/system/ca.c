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


#include <stdlib.h>

#ifndef IOTX_WITHOUT_TLS
#ifndef ENABLE_LOCAL_CLOUD
#ifndef ENABLE_TENCENT_CLOUD

/* ali ca */
static const char *iotx_ca_crt = \
{
    \
    "-----BEGIN CERTIFICATE-----\r\n"
    "MIIDdTCCAl2gAwIBAgILBAAAAAABFUtaw5QwDQYJKoZIhvcNAQEFBQAwVzELMAkG\r\n" \
    "A1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNVBAsTB1Jv\r\n" \
    "b3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw05ODA5MDExMjAw\r\n" \
    "MDBaFw0yODAxMjgxMjAwMDBaMFcxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i\r\n" \
    "YWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290IENBMRswGQYDVQQDExJHbG9iYWxT\r\n" \
    "aWduIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDaDuaZ\r\n" \
    "jc6j40+Kfvvxi4Mla+pIH/EqsLmVEQS98GPR4mdmzxzdzxtIK+6NiY6arymAZavp\r\n" \
    "xy0Sy6scTHAHoT0KMM0VjU/43dSMUBUc71DuxC73/OlS8pF94G3VNTCOXkNz8kHp\r\n" \
    "1Wrjsok6Vjk4bwY8iGlbKk3Fp1S4bInMm/k8yuX9ifUSPJJ4ltbcdG6TRGHRjcdG\r\n" \
    "snUOhugZitVtbNV4FpWi6cgKOOvyJBNPc1STE4U6G7weNLWLBYy5d4ux2x8gkasJ\r\n" \
    "U26Qzns3dLlwR5EiUWMWea6xrkEmCMgZK9FGqkjWZCrXgzT/LCrBbBlDSgeF59N8\r\n" \
    "9iFo7+ryUp9/k5DPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E\r\n" \
    "BTADAQH/MB0GA1UdDgQWBBRge2YaRQ2XyolQL30EzTSo//z9SzANBgkqhkiG9w0B\r\n" \
    "AQUFAAOCAQEA1nPnfE920I2/7LqivjTFKDK1fPxsnCwrvQmeU79rXqoRSLblCKOz\r\n" \
    "yj1hTdNGCbM+w6DjY1Ub8rrvrTnhQ7k4o+YviiY776BQVvnGCv04zcQLcFGUl5gE\r\n" \
    "38NflNUVyRRBnMRddWQVDf9VMOyGj/8N7yy5Y0b2qvzfvGn9LhJIZJrglfCm7ymP\r\n" \
    "AbEVtQwdpf5pLGkkeB6zpxxxYu7KyJesF12KwvhHhm4qxFYxldBniYUr+WymXUad\r\n" \
    "DKqC5JlR3XC321Y9YeRq4VzW9v493kHMB65jUr9TU/Qr6cf9tveCX4XSQRjbgbME\r\n" \
    "HMUfpIBvFSDJ3gyICh3WZlXi/EjJKSZp4A==\r\n" \
    "-----END CERTIFICATE-----"
};

#else

/* tencent cloud */
static const char *iotx_ca_crt = \
{
    \
    "-----BEGIN CERTIFICATE-----\r\n"
    "MIIDxTCCAq2gAwIBAgIJALM1winYO2xzMA0GCSqGSIb3DQEBCwUAMHkxCzAJBgNV\r\n" \
    "BAYTAkNOMRIwEAYDVQQIDAlHdWFuZ0RvbmcxETAPBgNVBAcMCFNoZW5aaGVuMRAw\r\n" \
    "DgYDVQQKDAdUZW5jZW50MRcwFQYDVQQLDA5UZW5jZW50IElvdGh1YjEYMBYGA1UE\r\n" \
    "AwwPd3d3LnRlbmNlbnQuY29tMB4XDTE3MTEyNzA0MjA1OVoXDTMyMTEyMzA0MjA1\r\n" \
    "OVoweTELMAkGA1UEBhMCQ04xEjAQBgNVBAgMCUd1YW5nRG9uZzERMA8GA1UEBwwI\r\n" \
    "U2hlblpoZW4xEDAOBgNVBAoMB1RlbmNlbnQxFzAVBgNVBAsMDlRlbmNlbnQgSW90\r\n" \
    "aHViMRgwFgYDVQQDDA93d3cudGVuY2VudC5jb20wggEiMA0GCSqGSIb3DQEBAQUA\r\n" \
    "A4IBDwAwggEKAoIBAQDVxwDZRVkU5WexneBEkdaKs4ehgQbzpbufrWo5Lb5gJ3i0\r\n" \
    "eukbOB81yAaavb23oiNta4gmMTq2F6/hAFsRv4J2bdTs5SxwEYbiYU1teGHuUQHO\r\n" \
    "iQsZCdNTJgcikga9JYKWcBjFEnAxKycNsmqsq4AJ0CEyZbo//IYX3czEQtYWHjp7\r\n" \
    "FJOlPPd1idKtFMVNG6LGXEwS/TPElE+grYOxwB7Anx3iC5ZpE5lo5tTioFTHzqbT\r\n" \
    "qTN7rbFZRytAPk/JXMTLgO55fldm4JZTP3GQsPzwIh4wNNKhi4yWG1o2u3hAnZDv\r\n" \
    "UVFV7al2zFdOfuu0KMzuLzrWrK16SPadRDd9eT17AgMBAAGjUDBOMB0GA1UdDgQW\r\n" \
    "BBQrr48jv4FxdKs3r0BkmJO7zH4ALzAfBgNVHSMEGDAWgBQrr48jv4FxdKs3r0Bk\r\n" \
    "mJO7zH4ALzAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQDRSjXnBc3T\r\n" \
    "d9VmtTCuALXrQELY8KtM+cXYYNgtodHsxmrRMpJofsPGiqPfb82klvswpXxPK8Xx\r\n" \
    "SuUUo74Fo+AEyJxMrRKlbJvlEtnpSilKmG6rO9+bFq3nbeOAfat4lPl0DIscWUx3\r\n" \
    "ajXtvMCcSwTlF8rPgXbOaSXZidRYNqSyUjC2Q4m93Cv+KlyB+FgOke8x4aKAkf5p\r\n" \
    "XR8i1BN1OiMTIRYhGSfeZbVRq5kTdvtahiWFZu9DGO+hxDZObYGIxGHWPftrhBKz\r\n" \
    "RT16Amn780rQLWojr70q7o7QP5tO0wDPfCdFSc6CQFq/ngOzYag0kJ2F+O5U6+kS\r\n" \
    "QVrcRBDxzx/G\r\n" \
     "-----END CERTIFICATE-----"
};

#endif

#else

/* local cloud */
static const char *iotx_ca_crt = \
{
    \
    "-----BEGIN CERTIFICATE-----\r\n" \
    "MIIC0jCCAboCCQCiTuy6qwHzuTANBgkqhkiG9w0BAQUFADArMSkwJwYDVQQKDCBB\r\n" \
    "cmVzIERvZGd5IENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0xODAyMDEwNzQwMzVa\r\n" \
    "Fw0zMTEwMTEwNzQwMzVaMCsxKTAnBgNVBAoMIEFyZXMgRG9kZ3kgQ2VydGlmaWNh\r\n" \
    "dGUgQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtn35\r\n" \
    "Jbx1jV+jqTvYn9iQsiGUcJ4aaYvUuylkUvwnw7IJOhpjwtfeOsyAngLwmFz+Ylb6\r\n" \
    "pJ62LoThBjK4MRzdngjBl9numPlwxqXJ4FKZ91vm3+IjMD3f/HT+j4EQoW0C9euv\r\n" \
    "xZfRvFMDcKm3IgoYMXgTatdwhH7HzjQIzVGN1F8UJL/i/UCK5GRCXEsjhjrLSvuX\r\n" \
    "jcOb3NjDgXaVcxjzxMxQN6cI4zxplFetmFUN7hUa/hA8Df0SUkFkTP6p7o2T80ZT\r\n" \
    "xQj75xLZFkpv0FTY65rlDJxt4vwOxGrZ4L7mA4rxhksMp7BO3zGkxqQDsqDYJCm4\r\n" \
    "nOG6QTP2aFqtG2SDIwIDAQABMA0GCSqGSIb3DQEBBQUAA4IBAQBeFUXZU7qzNxyB\r\n" \
    "w5pM6YoXl7VqnnKprZHFQDXrW9tIXjp+5CjbZn9VWhgvfAqk2nXfeSk2hEi1/k6C\r\n" \
    "Li0mqZz4p5uuXPVDTKtA8941q4hFWpIwFTgfnD+oep0rSc8gxcm/ikLuCY8K4+Lq\r\n" \
    "UiXIaqJLyu/WKRx7BLBw9QWUwnO6U08zl+oofnG8WlXLzsA68t8Zk7hRTj07naa0\r\n" \
    "6pxySKTuQHn9T7iyLhlcctfvmt7mUXz8WaB83Eqiu/R3u/+m3RZ46PmiJTUO15If\r\n" \
    "Ydn3sXxxDGQvYsEKJqIDUTwzwH5ZGQgkzfJst0brFewwxQkwKZ11amctShrNs1Ia\r\n" \
    "Dbn+kQhh\r\n" \
    "-----END CERTIFICATE-----"
};

#endif  /* #ifndef ENABLE_LOCAL_CLOUD */
#endif  /* #ifndef IOTX_WITHOUT_TLS */

const char *iotx_ca_get(void)
{
#ifdef IOTX_WITHOUT_TLS
    return NULL;
#else
    return iotx_ca_crt;
#endif
}
