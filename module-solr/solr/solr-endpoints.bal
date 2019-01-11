import ballerina/http;
import ballerina/io;


# Apache Solr Client object.
#
# + solrClient - SolrConnector client endpont
public type Client client object {
    public http:Client solrClient;

    public function __init(SolrConfiguration solrConfig) {
        self.solrClient = new(solrConfig.baseUrl + PATH_SEPARATOR + solrConfig.collectionName);
    }

    # Query Solr Index.
    #
    # + query1 - query string (eg: *:*)
    # + return - If success, returns json with relevant solr docs, else returns `error` object
    public remote function queryJsonData(string query1) returns (json)|error;

    # Add json to index in solr
    #
    # + jsonData - json data to be indexed
    # + return - If success, returns true, else returns `error` object
    public remote function indexJsonData(json jsonData) returns (boolean)|error;

    # Deletes all the data in the index
    #
    # + return - If success, returns true, else returns `error` object
    public remote function deleteIndexData() returns (boolean)|error;

};

remote function Client.queryJsonData(string query1) returns (json)|error {

    string value = EMPTY_STRING;

    string getSolrPath = PATH_SEPARATOR + SELECT + QUESTION_MARK + QUERY + EQUAL_MARK + query1;

    var httpResponse = self.solrClient->get(getSolrPath);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                return jsonResponse;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(SOLR_ERROR_CODE,
            { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SOLR_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }

}

remote function Client.indexJsonData(json jsonData) returns (boolean)|error {
    string postSolrPath = PATH_SEPARATOR + UPDATE + QUESTION_MARK + COMMIT + EQUAL_MARK + TRUE;

    http:Request request = new();

    request.setJsonPayload(jsonData, contentType = "application/json");

    var httpResponse = self.solrClient->post(postSolrPath, request);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var stringResponse = httpResponse.getPayloadAsString();
        if (stringResponse is string) {
            if (statusCode == http:OK_200) {
                return true;
            } else {
                return setResponseError(stringResponse);
            }
        } else {
            error err = error(SOLR_ERROR_CODE,
            { message: "Error occurred while accessing the String payload of the response" });
            return err;
        }
    } else {
        error err = error(SOLR_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

remote function Client.deleteIndexData() returns (boolean)|error {
    string postSolrPath = PATH_SEPARATOR + UPDATE + QUESTION_MARK + COMMIT + EQUAL_MARK + TRUE;

    http:Request request = new();

    xml payload = xml `<delete><query>*:*</query></delete>`;

    request.setXmlPayload(payload, contentType = "application/xml");

    var httpResponse = self.solrClient->post(postSolrPath, request);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var stringResponse = httpResponse.getPayloadAsString();
        if (stringResponse is string) {
            if (statusCode == http:OK_200) {
                return true;
            } else {
                return setResponseError(stringResponse);
            }
        } else {
            error err = error(SOLR_ERROR_CODE,
            { message: "Error occurred while accessing the String payload of the response" });
            return err;
        }
    } else {
        error err = error(SOLR_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

# Object for Solr configuration.
#
# + baseUrl - Base Url to access Solr (eg: http://localhost:8983)
# + collectionName - The Solr collection name
public type SolrConfiguration record {
    string baseUrl;
    string collectionName;
};
