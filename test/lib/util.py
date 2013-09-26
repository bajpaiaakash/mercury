import json 

SFDC_API_VERSION = "27.0" #is overridden upon instantiation of mm_connection if plugin specifies mm_api_version

PRODUCTION_ENDPOINT = "https://www.salesforce.com/services/Soap/u/"+SFDC_API_VERSION
SANDBOX_ENDPOINT    = "https://test.salesforce.com/services/Soap/u/"+SFDC_API_VERSION
PRERELEASE_ENDPOINT = "https://prerellogin.pre.salesforce.com/services/Soap/u/"+SFDC_API_VERSION

PRODUCTION_ENDPOINT_SHORT = "https://www.salesforce.com"
SANDBOX_ENDPOINT_SHORT    = "https://test.salesforce.com"
PRERELEASE_ENDPOINT_SHORT = "https://prerellogin.pre.salesforce.com"

ENDPOINTS = {
    "production" : PRODUCTION_ENDPOINT,
    "developer"  : PRODUCTION_ENDPOINT,
    "sandbox"    : SANDBOX_ENDPOINT,
    "prerelease" : PRERELEASE_ENDPOINT
}

URL_TO_ENDPOINT_TYPE = {
    PRODUCTION_ENDPOINT : "production",
    SANDBOX_ENDPOINT    : "sandbox",
    PRERELEASE_ENDPOINT : "prerelease"
}

def get_sfdc_endpoint(url):
    endpoint = PRODUCTION_ENDPOINT
    if "test" in url:
        endpoint = SANDBOX_ENDPOINT
    elif "prerellogin.pre.salesforce.com" in url:
        endpoint = PRERELEASE_ENDPOINT
    return endpoint

def get_endpoint_type_by_url(endpoint):
    if endpoint in URL_TO_ENDPOINT_TYPE: 
        return URL_TO_ENDPOINT_TYPE[endpoint] 
    else: 
        return ""

def get_sfdc_endpoint_by_type(type):
    if type in ENDPOINTS: 
        return ENDPOINTS[type] 
    else: 
        return ""

def print_pretty_json(json_body):
    print json.dumps(json_body, sort_keys=True, indent=4)
