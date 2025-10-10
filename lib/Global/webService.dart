// const String BASE_URL= "https://smartfzco.milaap.ai";
// const String BASE_URL= "https://mantratec.milaap.ai";
const String BASE_URL = "http://192.168.11.66:8011";

const String SUB_BASE_URL = BASE_URL + "/api/method/";
const String SUB_RESOURCE_URL = BASE_URL + "/resource/";

const String URLLogin = SUB_BASE_URL + "erp_mobile.api.login.login";
const String URLOTPVerification =
    SUB_BASE_URL + "erp_mobile.api.login.verify_code";

const String URLGetMenu =
    SUB_BASE_URL + "erp_mobile.api.masterdata.check_serial_no";

const String URLGetProfile =
    SUB_BASE_URL + "erp_mobile.api.masterdata.get_user_profile";

const String URLGetAttendance =
    SUB_BASE_URL + "erp_mobile.api.masterdata.get_attendance";

const String URLLogout = SUB_BASE_URL + "logout";
