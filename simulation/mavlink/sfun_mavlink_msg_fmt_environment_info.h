/*
DO NOT EDIT.
This file was automatically created by the Matlab function 'create_sfun_header' on 05-Oct-2023 08:14:04
as part of Simulink MAVLink library.
*/

#include "D:\ws\FMT\simulink_mavlink\include\mavlink\v2.0\fmt\mavlink_msg_fmt_environment_info.h"
#define BUS_NAME_FMT_ENVIRONMENT_INFO "mavlink_fmt_environment_info_t"
#define NFIELDS_BUS_FMT_ENVIRONMENT_INFO 3
#define ENCODED_LEN_FMT_ENVIRONMENT_INFO (MAVLINK_NUM_NON_PAYLOAD_BYTES + MAVLINK_MSG_ID_FMT_ENVIRONMENT_INFO_LEN)

/*
Encode the busInfo vector. This vector stores the starting index and total offset
for every element of the message bus. This is the standard way Simulink s-functions
handle bus interfaces.
*/
static inline void encode_businfo_fmt_environment_info(SimStruct *S, int_T *busInfo, const int_T offset)
{
	slDataTypeAccess *dta = ssGetDataTypeAccess(S);
	const char *bpath = ssGetPath(S);
	DTypeId BUSId = ssGetDataTypeId(S, BUS_NAME_FMT_ENVIRONMENT_INFO);
	
	busInfo[offset+0] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 0);
	busInfo[offset+1] = 3* dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+2] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 1);
	busInfo[offset+3] = 3* dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	busInfo[offset+4] = dtaGetDataTypeElementOffset(dta, bpath, BUSId, 2);
	busInfo[offset+5] = 3* dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "single"));
	ssSetUserData(S, busInfo);
}


/*
Encode the incoming character vector into the MAVLink bitstream. This process
consists of two stages - encode this character vector into a bus (using the
busInfo vector), and pass this struct to the MAVLink library to encode it into
a bitstream.
*/
static inline uint16_t encode_vector_fmt_environment_info(const char *uvec, const int_T *busInfo, uint8_T *yvec, const int_T offset)
{
	mavlink_fmt_environment_info_t ubus;
	mavlink_message_t msg_encoded;
	
	
	(void) memcpy(ubus.hit_point, uvec + busInfo[offset+0], busInfo[offset+1]);
	(void) memcpy(ubus.hit_normal, uvec + busInfo[offset+2], busInfo[offset+3]);
	(void) memcpy(ubus.hit_location, uvec + busInfo[offset+4], busInfo[offset+5]);
	
	mavlink_msg_fmt_environment_info_encode(SYS_ID, COMP_ID, &msg_encoded, &ubus);
	return mavlink_msg_to_send_buffer(yvec, &msg_encoded);
}


/*
Decode the incoming MAVLink message into an output character vector. This process
consists of two stages - use the MAVLink library to convert the MAVLink message
into its appropriate struct, and then decode this struct into the output character
vector according to busInfo.
*/
static inline void decode_msg_fmt_environment_info(const mavlink_message_t* msg_encoded, const int_T *busInfo, char *yvec, const int_T offset)
{
	mavlink_fmt_environment_info_t ybus;
	mavlink_msg_fmt_environment_info_decode(msg_encoded, &ybus);
	
	
	(void) memcpy(yvec + busInfo[offset+0], ybus.hit_point, busInfo[offset+1]);
	(void) memcpy(yvec + busInfo[offset+2], ybus.hit_normal, busInfo[offset+3]);
	(void) memcpy(yvec + busInfo[offset+4], ybus.hit_location, busInfo[offset+5]);
}
