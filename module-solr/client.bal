import ballerina/io;

import arunans23/solr;

solr:Client solrClient;

public function main() {
    solr:SolrConfiguration solrConfig = {

        baseUrl : "http://localhost:8983/solr",
        collectionName: "ballerina-google-sheets"

    };

    solrClient = new(solrConfig);

    string query2 = "*:*";

    var output = solrClient->queryJsonData(query2);

    if (output is json){

        json outputJson = output;

        io:print("Num Found : ");
        io:println(outputJson.response.numFound);
        //io:println(outputJson);
    }
}
