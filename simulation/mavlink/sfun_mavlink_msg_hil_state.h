/*
DO NOT EDIT.
This file was automatically created by the Matlab function 'create_sfun_header' on 05-Oct-2023 08:13:59
as part of Simulink MAVLink library.
*/

#include "D:\ws\FMT\simulink_mavlink\include\mavlink\v2.0\common\mavlink_msg_hil_state.h"
#define BUS_NAME_HIL_STATE "mavlink_hil_state_t"
#define NFIELDS_BUS_HIL_STATE 16
#define ENCODED_LEN_HIL_STATE (MAVLINK_NUM_NON_PAYLOAD_BYTES + MAVLINK_MSG_ID_HIL_STATE_LEN)

/*
Encode the busInfo vector. This vector stores the starting index and total offset
for every element of the message bus. This is the standard way Simulink s-functions
handle bus interfaces.
*/
static inline void encode_businfo_hil_state(SimStruct *S, int_T *busInfo, const int_T offset)
{
	slDataTypeAccess *dta = ssGetDataTypeAccess(S);
	const char *bpath = ssGetPath(S);
	DTypeId BUSId = ssGetDataTypeId(S, BUS_NAME_HIL_STATE);
	
	busInfo[offset+0] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 0);
	busInfo[offset+1] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "double"));
	busInfo[offset+2] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 1);
	busInfo[offset+3] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+4] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 2);
	busInfo[offset+5] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+6] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 3);
	busInfo[offset+7] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+8] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 4);
	busInfo[offset+9] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+10] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 5);
	busInfo[offset+11] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+12] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 6);
	busInfo[offset+13] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+14] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 7);
	busInfo[offset+15] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "int32"));
	busInfo[offset+16] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 8);
	busInfo[offset+17] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "int32"));
	busInfo[offset+18] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 9);
	busInfo[offset+19] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "int32"));
	busInfo[offset+20] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 10);
	busInfo[offset+21] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "int16"));
	busInfo[offset+22] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 11);
	busInfo[offset+23] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "int16"));
	busInfo[offset+24] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 12);
	busInfo[offset+25] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "int16"));
	busInfo[offset+26] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 13);
	busInfo[offset+27] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "int16"));
	busInfo[offset+28] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 14);
	busInfo[offset+29] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "int16"));
	busInfo[offset+30] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 15);
	busInfo[offset+31] = dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "int16"));
	ssSetUserData(S, busInfo);
}


/*
Encode the incoming character vector into the MAVLink bitstream. This process
consists of two stages - encode this character vector into a bus (using the
busInfo vector), and pass this struct to the MAVLink library to encode it into
a bitstream.
*/
static inline uint16_t encode_vector_hil_state(const char *uvec, const int_T *busInfo, uint8_T *yvec, const int_T offset)
{
	mavlink_hil_state_t ubus;
	mavlink_message_t msg_encoded;
	
	double time_usec;
	
	(void) memcpy(&time_usec, uvec + busInfo[offset+0], busInfo[offset+1]);
	ubus.time_usec = (uint64_t) time_usec;
	(void) memcpy(&ubus.roll, uvec + busInfo[offset+2], busInfo[offset+3]);
	(void) memcpy(&ubus.pitch, uvec + busInfo[offset+4], busInfo[offset+5]);
	(void) memcpy(&ubus.yaw, uvec + busInfo[offset+6], busInfo[offset+7]);
	(void) memcpy(&ubus.rollspeed, uvec + busInfo[offset+8], busInfo[offset+9]);
	(void) memcpy(&ubus.pitchspeed, uvec + busInfo[offset+10], busInfo[offset+11]);
	(void) memcpy(&ubus.yawspeed, uvec + busInfo[offset+12], busInfo[offset+13]);
	(void) memcpy(&ubus.lat, uvec + busInfo[offset+14], busInfo[offset+15]);
	(void) memcpy(&ubus.lon, uvec + busInfo[offset+16], busInfo[offset+17]);
	(void) memcpy(&ubus.alt, uvec + busInfo[offset+18], busInfo[offset+19]);
	(void) memcpy(&ubus.vx, uvec + busInfo[offset+20], busInfo[offset+21]);
	(void) memcpy(&ubus.vy, uvec + busInfo[offset+22], busInfo[offset+23]);
	(void) memcpy(&ubus.vz, uvec + busInfo[offset+24], busInfo[offset+25]);
	(void) memcpy(&ubus.xacc, uvec + busInfo[offset+26], busInfo[offset+27]);
	(void) memcpy(&ubus.yacc, uvec + busInfo[offset+28], busInfo[offset+29]);
	(void) memcpy(&ubus.zacc, uvec + busInfo[offset+30], busInfo[offset+31]);
	
	mavlink_msg_hil_state_encode(SYS_ID, COMP_ID, &msg_encoded, &ubus);
	return mavlink_msg_to_send_buffer(yvec, &msg_encoded);
}


/*
Decode the incoming MAVLink message into an output character vector. This process
consists of two stages - use the MAVLink library to convert the MAVLink message
into its appropriate struct, and then decode this struct into the output character
vector according to busInfo.
*/
static inline void decode_msg_hil_state(const mavlink_message_t* msg_encoded, const int_T *busInfo, char *yvec, const int_T offset)
{
	mavlink_hil_state_t ybus;
	mavlink_msg_hil_state_decode(msg_encoded, &ybus);
	
	double time_usec = (double) ybus.time_usec;
	
	(void) memcpy(yvec + busInfo[offset+0], &time_usec, busInfo[offset+1]);
	(void) memcpy(yvec + busInfo[offset+2], &ybus.roll, busInfo[offset+3]);
	(void) memcpy(yvec + busInfo[offset+4], &ybus.pitch, busInfo[offset+5]);
	(void) memcpy(yvec + busInfo[offset+6], &ybus.yaw, busInfo[offset+7]);
	(void) memcpy(yvec + busInfo[offset+8], &ybus.rollspeed, busInfo[offset+9]);
	(void) memcpy(yvec + busInfo[offset+10], &ybus.pitchspeed, busInfo[offset+11]);
	(void) memcpy(yvec + busInfo[offset+12], &ybus.yawspeed, busInfo[offset+13]);
	(void) memcpy(yvec + busInfo[offset+14], &ybus.lat, busInfo[offset+15]);
	(void) memcpy(yvec + busInfo[offset+16], &ybus.lon, busInfo[offset+17]);
	(void) memcpy(yvec + busInfo[offset+18], &ybus.alt, busInfo[offset+19]);
	(void) memcpy(yvec + busInfo[offset+20], &ybus.vx, busInfo[offset+21]);
	(void) memcpy(yvec + busInfo[offset+22], &ybus.vy, busInfo[offset+23]);
	(void) memcpy(yvec + busInfo[offset+24], &ybus.vz, busInfo[offset+25]);
	(void) memcpy(yvec + busInfo[offset+26], &ybus.xacc, busInfo[offset+27]);
	(void) memcpy(yvec + busInfo[offset+28], &ybus.yacc, busInfo[offset+29]);
	(void) memcpy(yvec + busInfo[offset+30], &ybus.zacc, busInfo[offset+31]);
}
