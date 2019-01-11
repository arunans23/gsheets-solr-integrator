import ballerina/config;
import ballerina/io;

import arunans23/solr;

solr:Client solrClient;

public function main(string... args) {

    solr:SolrConfiguration solrConfig = {
        baseUrl : config:getAsString("BASE_URL"),
        collectionName : config:getAsString("COLLECTION_NAME")
    };

    solrClient = new(solrConfig);

    if (args.length() != 1) {
        io:println("Usage : <query>");
        return;

    } else {
        var response = solrClient->queryJsonData(untaint args[0]);

        if (response is json){

            json outputJson = response;

            io:print("Num Found : ");
            io:println(outputJson.response.numFound);

            io:println(outputJson);

        } else {
            io:println(response);
            io:println("Querying solr failed. Check the solr instance up and proper configurations are defined");
        }
    }
}

