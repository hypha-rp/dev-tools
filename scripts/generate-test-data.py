import os
import random
import xml.etree.ElementTree as ET

INTEGRATION_ID = os.getenv('INTEGRATION_ID', 'default-integration-id')

def generate_testcase(id, classname, name, time, status, assertions, message=None):
    testcase = ET.Element('testcase', {
        'id': id,
        'classname': classname,
        'name': name,
        'time': time,
        'status': status,
        'assertions': assertions
    })
    if status == 'fail':
        failure = ET.SubElement(testcase, 'failure', {'message': message})
        failure.text = "Assertion failed"
    elif status == 'error':
        error = ET.SubElement(testcase, 'error', {'message': message})
        error.text = "Exception occurred"
    elif status == 'skipped':
        ET.SubElement(testcase, 'skipped')
    
    properties = ET.SubElement(testcase, 'properties')
    if random.choice([True, False]):
        ET.SubElement(properties, 'property', {'name': 'hypha.integration', 'value': INTEGRATION_ID})
    
    return testcase

def generate_testsuite(id, name, tests, failures, errors, skipped, assertions, time, properties, testcases):
    testsuite = ET.Element('testsuite', {
        'id': id,
        'name': name,
        'tests': tests,
        'failures': failures,
        'errors': errors,
        'skipped': skipped,
        'assertions': assertions,
        'time': time
    })
    properties_element = ET.SubElement(testsuite, 'properties')
    for prop_name, prop_value in properties.items():
        ET.SubElement(properties_element, 'property', {'name': prop_name, 'value': prop_value})
    
    if random.choice([True, False]):
        ET.SubElement(properties_element, 'property', {'name': 'hypha.integration', 'value': INTEGRATION_ID})
    
    for testcase in testcases:
        testsuite.append(testcase)
    return testsuite

def generate_junit_xml(index):
    testsuites = ET.Element('testsuites')
    num_suites = random.randint(1, 5)
    max_sample_size = min(num_suites, 4)
    integration_suites = random.sample(range(num_suites), k=random.randint(1, max_sample_size))
    
    for i in range(num_suites):
        testcases = []
        for j in range(random.randint(1, 30)):
            status = random.choices(
                ['pass', 'fail', 'error', 'skipped'],
                weights=[0.7, 0.1, 0.1, 0.1],  # Increase the weight for 'pass'
                k=1
            )[0]
            message = None
            if status in ['fail', 'error']:
                message = "Random failure message" if status == 'fail' else "Random error message"
            testcases.append(generate_testcase(
                id=f"test-{index}-{i}-{j}",
                classname=f"Example.Tests.TestClass{i}",
                name=f"TestMethod{j}",
                time=f"{random.uniform(0.001, 1.0):.3f}",
                status=status,
                assertions=str(random.randint(1, 5)),
                message=message
            ))
        
        properties = {}
        if i in integration_suites:
            properties['hypha.integration'] = INTEGRATION_ID
        
        testsuite = generate_testsuite(
            id=f"suite-{index}-{i}",
            name=f"Example.Tests.Suite{i}",
            tests=str(len(testcases)),
            failures=str(sum(1 for tc in testcases if tc.find('failure') is not None)),
            errors=str(sum(1 for tc in testcases if tc.find('error') is not None)),
            skipped=str(sum(1 for tc in testcases if tc.find('skipped') is not None)),
            assertions=str(sum(int(tc.attrib['assertions']) for tc in testcases)),
            time=f"{random.uniform(1.0, 10.0):.3f}",
            properties=properties,
            testcases=testcases
        )
        testsuites.append(testsuite)
    
    tree = ET.ElementTree(testsuites)
    tree.write(f"dev/junit/junit-{index}.xml", encoding='utf-8', xml_declaration=True)

for i in range(10):
    generate_junit_xml(i)