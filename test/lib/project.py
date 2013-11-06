import os
import sys
import mm_util
import shutil
import json
import xmltodict
import collections
import pprint
pp = pprint.PrettyPrinter(indent=4)

#compiles the entire project
def compile(client, project_path, **kwargs):
    try:
        tmp = mm_util.put_tmp_directory_on_disk()
        shutil.copytree(os.path.join(project_path,"src"), os.path.join(tmp,"src"))
        mm_util.rename_directory(os.path.join(tmp,"src"), os.path.join(tmp,"unpackaged"))
        zip_file = mm_util.zip_directory(tmp, tmp)
        deploy_params = {
            "zip_file"          : zip_file,
            "rollback_on_error" : kwargs.get('rollback_on_error', True),
            "ret_xml"           : kwargs.get('ret_xml', True),
            "run_tests"         : kwargs.get('run_tests', False),
            "classes"           : kwargs.get('classes', []),
            "check_only"        : kwargs.get('check_only', True),
            "debug_categories"  : [
                {
                    "category"  : "Apex_code",
                    "level"     : "DEBUG"
                },
                {
                    "category"  : "Db",
                    "level"     : "WARN"
                },
                {
                    "category"  : "Workflow",
                    "level"     : "WARN"
                },
                {
                    "category"  : "Validation",
                    "level"     : "WARN"
                },
                {
                    "category"  : "Callout",
                    "level"     : "WARN"
                },
                {
                    "category"  : "Apex_profiling",
                    "level"     : "WARN"
                }
            ]
        }
        deploy_result = client.deploy(deploy_params)
        d = xmltodict.parse(deploy_result,postprocessor=mm_util.xmltodict_postprocessor)

        dictionary = collections.OrderedDict()
        dictionary2 = []
        log = 'Not available'
        result      = d["soapenv:Envelope"]["soapenv:Body"]['checkDeployStatusResponse']['result']
        test_result = d["soapenv:Envelope"]["soapenv:Body"]['checkDeployStatusResponse']['result']['runTestResult']
        try:
            test_result['log'] = d["soapenv:Envelope"]["soapenv:Header"]["DebuggingInfo"]["debugLog"]
            log = test_result['log']
        except:
            test_result['log'] = 'Log not available.'
        for x, y in result.iteritems():
            if(x == "id"):
                dictionary["id"] = y
            if(x == "runTestResult"):
                dictionary["runTestResult"] = y
            if(x == "success"):
                dictionary["success"] = y
        for a in result['messages']:
            for key, value in a.iteritems():
                if(key == 'problemType' and value == 'Error'):
                    dictionary2.append(a)
        dictionary["Messages"] = dictionary2 

        #pp.pprint(dictionary)

        shutil.rmtree(tmp)

        #self.refresh_selected_properties({'project_name':self.project_name, 'directories': [os.path.join(self.location, 'src')]})
        html = mm_util.generate_html_response('test', test_result)
        #print html
        dictionary["runTestResult"].pop("log", None)
        return dictionary, log, html
        #return dictionary, html
        #return json.dumps(d["soapenv:Envelope"]["soapenv:Body"]['checkDeployStatusResponse']['result'], sort_keys=True, indent=2, separators=(',', ': ')), html
    except BaseException, e:
        raise e

