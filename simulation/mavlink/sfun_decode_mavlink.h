/*
DO NOT EDIT.
This file was automatically created by the Matlab function 'create_sfun_decode' on 05-Oct-2023 08:14:04
as part of Simulink MAVLink library.
*/

#include "sfun_mavlink_msg_fmt_pilot_cmd.h"
#include "sfun_mavlink_msg_fmt_environment_info.h"

#define NFIELDS_OUTPUT_BUS (NFIELDS_BUS_FMT_PILOT_CMD + NFIELDS_BUS_FMT_ENVIRONMENT_INFO)

#define OFFSET_FMT_PILOT_CMD 0
#define OFFSET_FMT_ENVIRONMENT_INFO 2*(NFIELDS_BUS_FMT_PILOT_CMD)

/*
Decode the incoming MAVLink message
*/
static inline void decode_mavlink_msg (SimStruct *S, const mavlink_message_t *msg)
{
	int_T *busInfo = (int_T *) ssGetUserData(S);

	real_T  *ystatus = ssGetOutputPortRealSignal(S, 0);

	char* yvec1 = (char *) ssGetOutputPortRealSignal(S, 1);
	char* yvec2 = (char *) ssGetOutputPortRealSignal(S, 2);
	switch (msg->msgid) {

		case MAVLINK_MSG_ID_FMT_PILOT_CMD:
			ystatus[0] = 1;
			decode_msg_fmt_pilot_cmd(msg, busInfo, yvec1, OFFSET_FMT_PILOT_CMD);
			break;

		case MAVLINK_MSG_ID_FMT_ENVIRONMENT_INFO:
			ystatus[1] = 1;
			decode_msg_fmt_environment_info(msg, busInfo, yvec2, OFFSET_FMT_ENVIRONMENT_INFO);
			break;
	}
}
