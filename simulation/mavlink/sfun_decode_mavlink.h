/*
DO NOT EDIT.
This file was automatically created by the Matlab function 'create_sfun_decode' on 30-Jul-2020 21:21:18
as part of Simulink MAVLink library.
*/

#include "D:\FirmamentPilot\tool\simulink_mavlink-master\simulink_mavlink-master\include\sfun_mavlink_msg_fmt_pilot_cmd.h"

#define NFIELDS_OUTPUT_BUS (NFIELDS_BUS_FMT_PILOT_CMD)

#define OFFSET_FMT_PILOT_CMD 0

/*
Decode the incoming MAVLink message
*/
static inline void decode_mavlink_msg (SimStruct *S, const mavlink_message_t *msg)
{
	int_T *busInfo = (int_T *) ssGetUserData(S);

	char* yvec0 = (char *) ssGetOutputPortRealSignal(S, 0);
	switch (msg->msgid) {

		case MAVLINK_MSG_ID_FMT_PILOT_CMD:
			decode_msg_fmt_pilot_cmd(msg, busInfo, yvec0, OFFSET_FMT_PILOT_CMD);
			break;
	}
}
