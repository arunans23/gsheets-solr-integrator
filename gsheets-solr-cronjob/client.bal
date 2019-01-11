import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/runtime;
import ballerina/task;

import wso2/gsheets4;

import arunans23/solr;


task:Timer? timer = ();

gsheets4:SpreadsheetConfiguration spreadsheetConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: config:getAsString("ACCESS_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET"),
            refreshToken: config:getAsString("REFRESH_TOKEN")
        }
    }
};

gsheets4:Client spreadsheetClient = new(spreadsheetConfig);

solr:Client solrClient;

public function main() {


    gsheets4:Spreadsheet spreadsheet = new;

    var response = spreadsheetClient->openSpreadsheetById(config:getAsString("SPREAD_SHEET_ID"));
    if (response is gsheets4:Spreadsheet) {
        spreadsheet = response;
    } else {
        io:println(response);
    }
    io:println(spreadsheet);

    (function() returns error?) onTriggerFunction = fetchandIndex;

    function(error) onErrorFunction = fetchIndexError;

    timer = new task:Timer(onTriggerFunction, onErrorFunction, config:getAsInt("TIMER_PERIOD", default = 10000),
        delay = 500);

    timer.start();

    runtime:sleep(30000); // Temp. workaround to stop the process from exiting.


}

function fetchandIndex() returns error?{

    solr:SolrConfiguration solrConfig = {
        baseUrl : config:getAsString("BASE_URL"),
        collectionName : config:getAsString("COLLECTION_NAME")
    };

    solrClient = new(solrConfig);

    var response1 = spreadsheetClient->getSheetValues(config:getAsString("SPREAD_SHEET_ID"),
        config:getAsString("SHEET_NAME"),
        topLeftCell = config:getAsString("TOP_LEFT_CELL"),
        bottomRightCell = config:getAsString("BOTTOM_RIGHT_CELL")
    );


    if (response1 is string[][]) {

        string[][] data;

        data = response1;

        json output = [];

        int i = 0;

        foreach var s in data {
            json temp = { TimeStamp : s[0],
                Emailaddress : s[1],
                Firstname : s[2],
                IndexNo : s[3],
                TshirtSize : s[4]
            };

            output[i] = temp;

            i = i + 1;
        }

        io:println("Data fetched from Google sheets");
        io:println(output);

        var deleteResponse = solrClient->deleteIndexData();

        if (deleteResponse is boolean){
            boolean deleteResponseStatus = deleteResponse;

            if (deleteResponseStatus) {
                io:println("Successfully deleted previous index");

                var indexResponse = solrClient->indexJsonData(untaint output);

                if (indexResponse is boolean){
                    io:println("Successfully indexed the data");

                    return;

                } else {
                    error e = error("Indexing failed");
                    return e;
                }

            } else {

                error e = error("Deleting previous index failed");
                return e;
            }
        }

    } else {
        io:println(response1);
        error e = error("Fetching data from spreadsheets failed");
        return e;
    }
}

function fetchIndexError(error e) {
    io:print("[ERROR] cleanup failed: ");
    io:println(e);
}