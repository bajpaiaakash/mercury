# #!/usr/bin/env python
import os
import unittest
import json
from lib.client import MavensMateClient
import lib.project as project
import logging
import pprint
import shutil

pp = pprint.PrettyPrinter(indent=4)

logging.raiseExceptions = False
logging.basicConfig(level=logging.DEBUG)
logging.getLogger('suds.client').setLevel(logging.CRITICAL)
logging.getLogger('suds.transport').setLevel(logging.CRITICAL) # MUST BE THIS?
logging.getLogger('suds.xsd.schema').setLevel(logging.CRITICAL)
logging.getLogger('suds.wsdl').setLevel(logging.CRITICAL)
logging.getLogger('suds.resolver').setLevel(logging.CRITICAL)
logging.getLogger('suds.xsd.query').setLevel(logging.CRITICAL)
logging.getLogger('suds.xsd.basic').setLevel(logging.CRITICAL)
logging.getLogger('suds.xsd.sxbasic').setLevel(logging.CRITICAL)
logging.getLogger('suds.xsd.sxbase').setLevel(logging.CRITICAL)
logging.getLogger('suds.metrics').setLevel(logging.CRITICAL)
logging.getLogger('suds.mx.core').setLevel(logging.CRITICAL)
logging.getLogger('suds.mx.literal').setLevel(logging.CRITICAL)
logging.getLogger('suds.binding.marshaller').setLevel(logging.CRITICAL)
logging.getLogger('suds.umx.typed').setLevel(logging.CRITICAL)

project_path = os.path.dirname(os.path.dirname(__file__))
result_path = os.path.join(project_path, "test", "result")

##set up client
username = 'ferraro_joe@gso1.lly.mercurycfg'
password = 'mavens123'
org_type = 'sandbox' 
client = MavensMateClient(credentials={
    "username" : username,
    "password" : password,
    "org_type" : org_type
})

class MercuryBuildTest(unittest.TestCase):
    
    def test_compile_project(self):
        
        #####################
        ## validate deploy ##
        #####################

        classes = []
        qr = client.query("Select ID, Name FROM ApexClass WHERE NamespacePrefix = null AND Name LIKE '%Test%'")
        records = None
        if qr["done"] == True and 'records' in qr:
            if type(qr['records']) is not list:
                records = [qr['records']]
            else:
                records = qr['records']
            for r in records:
                classes.append(r["Name"])


        result, log, html = project.compile(client, project_path, classes=classes, check_only=True) #running tests below, bc run all tests runs managed package tests which can fail
        json_result = json.dumps(result, sort_keys=True, indent=2, separators=(',', ': '))
        result = json.loads(json_result)
        
        #if result["success"] == False:
        #    os.system("echo '"+json_result+"' | python -mjson.tool")
        
        if os.path.exists(result_path):
            shutil.rmtree(result_path)
        os.makedirs(result_path)
        f = open(os.path.join(result_path, "result.html"), 'w')
        f.write(html)
        f.close()
        f = open(os.path.join(result_path, "result.log"), 'w')
        f.write(log)
        f.close()
        f = open(os.path.join(result_path, "result.json"), 'w')
        f.write(json_result)
        f.close()

        compile_success = True

        if 'runTestResult' in result and 'failures' in result['runTestResult']:
            failures = result['runTestResult']['failures']
            if type(failures) is not list:
                failures = [failures]

            for f in failures:
                if f['namespace'] != '' and f['namespace'] != None:
                    print f
                    compile_success = False
                    break

        if 'Messages' in result and type(result['Messages'] is list and len(result['Messages'] > 0)):
            for m in result['Messages']:
                if m['problemType'] != '' and m['problemType'] == 'Error':
                    print m
                    compile_success = False
                    break

        if compile_success:
            if 'runTestResult' in result and 'codeCoverageWarnings' in result['runTestResult']:
                warnings = result['runTestResult']['codeCoverageWarnings']
                if type(warnings) is not list:
                    warnings = [warnings]

                for w in warnings:
                    if 'Average test coverage across all Apex Classes and Triggers' in w['message']:
                        compile_success = False

        self.assertTrue(compile_success)

        # ####################
        # ## validate tests ##
        # ####################

        # # test_result_json = client.run_async_apex_tests({
        # #     "classes" : ["CompileAndTest", "MyClassNameTESTER"]
        # # })
        # test_result_json = client.run_async_apex_tests(None, True) #run all non-namespace tests
        # test_result = json.loads(test_result_json)

        # if type(test_result) is not list:
        #     test_result = [test_result]
        # success = True
        # for apex_class in test_result:
        #     class_tests_passed = True
        #     for s in apex_class["detailed_results"]:
        #         if "Outcome" in s and s["Outcome"] == "Fail":
        #             class_tests_passed = False
        #             break
        #     if not class_tests_passed:
        #         success = False
        #         break
        
        # #to write test result to stdout
        # #os.system("echo '"+test_result_json+"' | python -mjson.tool")

        # ##TODO: Winter '14 update will give us coverage details here, so we'll factor this into our build success
        
        # f = open(os.path.join(result_path, "tests.json"), 'w')
        # f.write(test_result_json)
        # f.close()

        # self.assertTrue(success)

def main():
    unittest.main()

if __name__ == '__main__':
    main()