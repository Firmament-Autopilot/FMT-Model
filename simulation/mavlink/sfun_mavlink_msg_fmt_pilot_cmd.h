/*
DO NOT EDIT.
This file was automatically created by the Matlab function 'create_sfun_header' on 30-Jul-2020 21:21:18
as part of Simulink MAVLink library.
*/

#include "D:\FirmamentPilot\tool\simulink_mavlink-master\simulink_mavlink-master\include\mavlink\v2.0\firmament\mavlink_msg_fmt_pilot_cmd.h"

#define BUS_NAME_FMT_PILOT_CMD "mavlink_fmt_pilot_cmd_t"
#define NFIELDS_BUS_FMT_PILOT_CMD 8
#define ENCODED_LEN_FMT_PILOT_CMD (MAVLINK_NUM_NON_PAYLOAD_BYTES + MAVLINK_MSG_ID_FMT_PILOT_CMD_LEN)

/*
Encode the busInfo vector. This vector stores the starting index and total offset
for every element of the message bus. This is the standard way Simulink s-functions
handle bus interfaces.
*/
static inline void encode_businfo_fmt_pilot_cmd(SimStruct *S, int_T *busInfo, const int_T offset)
{
	slDataTypeAccess *dta = ssGetDataTypeAccess(S);
	const char *bpath = ssGetPath(S);
	DTypeId BUSId = ssGetDataTypeId(S, BUS_NAME_FMT_PILOT_CMD);
	
	busInfo[offset+0] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 0);
	busInfo[offset+1] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "uint32"));
	busInfo[offset+2] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 1);
	busInfo[offset+3] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+4] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 2);
	busInfo[offset+5] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+6] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 3);
	busInfo[offset+7] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+8] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 4);
	busInfo[offset+9] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+10] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 5);
	busInfo[offset+11] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "uint32"));
	busInfo[offset+12] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 6);
	busInfo[offset+13] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "uint32"));
	busInfo[offset+14] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 7);
	busInfo[offset+15] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "uint32"));
	ssSetUserData(S, busInfo);
}


/*
Encode the incoming character vector into the MAVLink bitstream. This process
consists of two stages - encode this character vector into a bus (using the
busInfo vector), and pass this struct to the MAVLink library to encode it into
a bitstream.
*/
static inline uint16_t encode_vector_fmt_pilot_cmd(const char *uvec, const int_T *busInfo, uint8_T *yvec, const int_T offset)
{
	mavlink_fmt_pilot_cmd_t ubus;
	mavlink_message_t msg_encoded;
	
	
	(void) memcpy(&ubus.timestamp, uvec + busInfo[offset+0], busInfo[offset+1]);
	(void) memcpy(&ubus.ls_lr, uvec + busInfo[offset+2], busInfo[offset+3]);
	(void) memcpy(&ubus.ls_ud, uvec + busInfo[offset+4], busInfo[offset+5]);
	(void) memcpy(&ubus.rs_lr, uvec + busInfo[offset+6], busInfo[offset+7]);
	(void) memcpy(&ubus.rs_ud, uvec + busInfo[offset+8], busInfo[offset+9]);
	(void) memcpy(&ubus.mode, uvec + busInfo[offset+10], busInfo[offset+11]);
	(void) memcpy(&ubus.command_1, uvec + busInfo[offset+12], busInfo[offset+13]);
	(void) memcpy(&ubus.command_2, uvec + busInfo[offset+14], busInfo[offset+15]);
	
	mavlink_msg_fmt_pilot_cmd_encode(SYS_ID, COMP_ID, &msg_encoded, &ubus);
	return mavlink_msg_to_send_buffer(yvec, &msg_encoded);
}


/*
Decode the incoming MAVLink message into an output character vector. This process
consists of two stages - use the MAVLink library to convert the MAVLink message
into its appropriate struct, and then decode this struct into the output character
vector according to busInfo.
*/
static inline void decode_msg_fmt_pilot_cmd(const mavlink_message_t* msg_encoded, const int_T *busInfo, char *yvec, const int_T offset)
{
	mavlink_fmt_pilot_cmd_t ybus;
	mavlink_msg_fmt_pilot_cmd_decode(msg_encoded, &ybus);
	
	
	(void) memcpy(yvec + busInfo[offset+0], &ybus.timestamp, busInfo[offset+1]);
	(void) memcpy(yvec + busInfo[offset+2], &ybus.ls_lr, busInfo[offset+3]);
	(void) memcpy(yvec + busInfo[offset+4], &ybus.ls_ud, busInfo[offset+5]);
	(void) memcpy(yvec + busInfo[offset+6], &ybus.rs_lr, busInfo[offset+7]);
	(void) memcpy(yvec + busInfo[offset+8], &ybus.rs_ud, busInfo[offset+9]);
	(void) memcpy(yvec + busInfo[offset+10], &ybus.mode, busInfo[offset+11]);
	(void) memcpy(yvec + busInfo[offset+12], &ybus.command_1, busInfo[offset+13]);
	(void) memcpy(yvec + busInfo[offset+14], &ybus.command_2, busInfo[offset+15]);
}
