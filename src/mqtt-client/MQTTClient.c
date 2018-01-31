#include "MQTTPacket.h"
#include <stdio.h>

void mqtt_client_test() 
{
    unsigned char* pptr = "aabb";
    int len = readInt(&pptr);
    printf("len = %d\n", len);
}
