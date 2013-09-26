# #!/usr/bin/env python
import os
import unittest
import json
from lib.client import MavensMateClient
import lib.project as project
import logging
import pprint
import shutil

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
artifact_directory = os.environ.get("CIRCLE_ARTIFACTS", result_path)

##set up client
username = 'ferraro_joe@gso1.lly.mercurycfg'
password = 'mavens123'
org_type = 'sandbox' 
client = MavensMateClient(credentials={
    "username" : username,
    "password" : password,
    "org_type" : org_type
})


pp = pprint.PrettyPrinter(indent=4)

class MercuryBuildTest(unittest.TestCase):
    
    def test_compile_project(self):
        result, log, html = project.compile(client, project_path)
        json_result = json.dumps(result, sort_keys=True, indent=2, separators=(',', ': '))

        #result = json.loads(json_result)
        if result["success"] == False:
            os.system("echo '"+json_result+"' | python -mjson.tool")
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

        self.assertTrue(result["success"] == False)

    # def test_apex_classes(self):
    #     test_result_json = client.run_async_apex_tests({
    #         "classes" : ["CompileAndTest", "MyClassNameTESTER"]
    #     })
    #     test_result = json.loads(test_result_json)

    #     #logging.debug(pprint.pformat(test_result, indent=2))

    #     if type(test_result) is not list:
    #         test_result = [test_result]
    #     success = True
    #     for apex_class in test_result:
    #         class_tests_passed = True
    #         for s in apex_class["detailed_results"]:
    #             if "Outcome" in s and s["Outcome"] == "Fail":
    #                 class_tests_passed = False
    #                 break
    #         if not class_tests_passed:
    #             success = False
    #             break
    #     if not success:
    #         os.system("echo '"+test_result_json+"' | python -mjson.tool")
    #     self.assertTrue(success)


def main():
    unittest.main()

if __name__ == '__main__':
    main()