import ballerina/mongodb;
import ballerina/http;
import ballerina/log;
//import ballerina/io;

mongodb:ClientEndpointConfig  mongoConfig = {
	host: "localhost",
	dbName: "covid-nam",
	username: "",
	password: "",
	options: {sslEnabled: false, serverSelectionTimeout: 500}
};

mongodb:Client dbClient = check new (mongoConfig);

listener http:Listener apiListener2 = new (6549);

@http: ServiceConfig {
	basePath: "/covid/v1/statistics"
}
service awareness on apiListener2 {
	@http: ResourceConfig {
		methods: ["GET"],
		path: "/latest"
	}
	resource function getLatestStatistics(http:Caller caller, http:Request ltReq) {
		http:Response latestResp = new;

		// pull the latest news data
		var latestData = dbClient->find("covidstats", ());

		// fill the repsonse payload with the new content
		if (latestData is error) {
			log:printError("An error occurred while pulling the latest statistics", err=latestData);
		} else {
			latestResp.setJsonPayload(latestData);

			// send the response to the caller and log errors
			var respResult = caller->respond(latestResp);
			if (respResult is error) {
				log:printError(respResult.reason(), respResult);
			}
		}
	}

	@http: ResourceConfig {
		methods: ["GET"],
		path: "/allstats"
	}
	resource function getAllStatistics(http:Caller caller, http:Request defReq) {
		http:Response allStatResp = new;

		// pull the official virus definition data
		var allStatData = dbClient->find("covidstats", ());

		if (allStatData is error) {
			log:printError("An error occurred while pulling all statistics", err=allStatData);
		} else {
			// fill the response payload with the new content
			allStatResp.setJsonPayload(allStatData);

			// send the response to the caller and log errors
			var respResult = caller->respond(allStatResp);
			if (respResult is error) {
				log:printError(respResult.reason(), respResult);
			}
		}
	}  
}
