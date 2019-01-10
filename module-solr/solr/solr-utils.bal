import ballerina/http;

function setResponseError(json jsonResponse) returns error {
    error err = error(SOLR_ERROR_CODE, { message: jsonResponse.message.toString() });
    return err;
}