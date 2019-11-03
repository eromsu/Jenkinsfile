import re
import argparse
from os import listdir
from os.path import isfile, join
import collections
import sys
import glob
import yaml
import pprint

class MyDict(collections.OrderedDict):
    def __missing__(self, key):
        val = self[key] = MyDict()
        return val

def read_arguments():
    parser = argparse.ArgumentParser("Usage: generate_documentation.py")
    parser.add_argument("-t", "--template-path", dest="templates_path", help="ATAG templates path", default="../templates/", required=False)
    parser.add_argument("-c", "--config", dest="config", help="ATAG config file", default="../atag_config.yaml", required=False)
    parser.add_argument("-d", "--datamodel", dest="data_model", help="ATAG datamodel file", default="../data_validation.yaml", required=False)

    args = parser.parse_args()
    return args

def load_templates(templates_path):
    template_dict = MyDict()
    template_types = []

    # Find template types
    try:
        globber = join(templates_path,"*","")
        raw_types = glob.glob(globber)
        raw_types.sort()
        for type in raw_types:
            template_types.append(type.split("/")[-2])      # Split to get actual sub-directory name and not fullpath
    except OSError as _:
        print "ERROR: Can't find template directory '%s'" % templates_path
        sys.exit(1)
    except:
        print "ERROR: Undefined error in finding template categories"
        raise

    # Verify that test types where found
    if len(template_types) == 0:
        print "ERROR: No template types (sub-dirctories) where found in template directory '%s'" % templates_path
        sys.exit(1)

    # Load templates in each type
    for type in template_types:
        try:
            globber = join(templates_path,type,"*.robot")
            files = glob.glob(globber)
            files.sort()
            for template in files:
                fo = open(template, "r")
                template_dict[type][(template.split("/")[-1])] = fo.readlines()     # Split to get actual filename and not fullpath
                fo.close()
        except OSError as _:
            print "ERROR: Can't find template directory '%s/%s'" % (templates_path,type)
        except:
            print "ERROR: Undefined error in loading template"
            raise
    return template_dict

def get_template_data(config_file):
    # Read config file
    try:
        with open(config_file, 'r') as ymlfile:
            cfg_dict = yaml.load(ymlfile)
    except:
        print "ERROR: Error reading config_file '%s'" % config_file
        sys.exit(1)

    # Re-work the template information so that it is easier to process later on (change key from test category to template file)
    template_dict = {}
    for category in cfg_dict['testcase_templates'].keys():
        category_dict = {}
        category_dict['category'] = category
        category_dict['description'] = cfg_dict['testcase_templates'][category]['description']
        try:
            category_dict['input_sheet'] = cfg_dict['testcase_templates'][category]['input_sheet']
        except KeyError:
            category_dict['input_sheet'] = "N/A"
        except:
            print "ERROR: Undefined error processing config file"

        template_dict[cfg_dict['testcase_templates'][category]['template']] = category_dict

    # Add re-worked template information to config dict
    cfg_dict['template_data'] = template_dict

    # Return template data
    return cfg_dict

def get_template_metadata(template_content):
    """
    """
    jinja_comment_start = re.compile(r'^{#')
    jinja_comment_stop = re.compile(r'^#}')
    template_metadata = ["### Template Description:\n"]
    found_metadata = False
    template_body_pointer = 0 
    end_of_metadata = False
    line = template_content[template_body_pointer]
    while (not end_of_metadata) and (template_body_pointer <= len(template_content)-1):
        line = template_content[template_body_pointer]
        if jinja_comment_start.match(line):
            found_metadata = True
        elif jinja_comment_stop.match(line):
            end_of_metadata = True 
        elif found_metadata :
            template_metadata.append(line)
        template_body_pointer += 1
    if not found_metadata :
        template_body_pointer = 0
    template_metadata[-1]="\n"
    return [template_metadata,template_body_pointer]

def get_template_variables(data_model,template_file_name,test_type):
    print "Doing template %s" %template_file_name
    template_variables = ["### Templates Variables:\n"]
    template_variables.append("Variable | Description | Mandatory | Default Value | Data Source\n")
    template_variables.append(" --- | --- | --- | --- | ---\n")
    if data_model[test_type].has_key(template_file_name):
        for variable in data_model[test_type][template_file_name]:
            if "descr" in data_model[test_type][template_file_name][variable].keys():
                tabdescr = str(data_model[test_type][template_file_name][variable]["descr"])
            else:
                tabdescr = " "
            if "mandatory" in data_model[test_type][template_file_name][variable].keys():
                tabmandatory = str(data_model[test_type][template_file_name][variable]["mandatory"])
            else:
                tabmandatory = " "
            if "default" in data_model[test_type][template_file_name][variable].keys():
                tabdefault = str(data_model[test_type][template_file_name][variable]["default"])
            else:
                tabdefault = " "
            if "source" in data_model[test_type][template_file_name][variable].keys():
                if str(data_model[test_type][template_file_name][variable]["source"]) == "workbook":
                    tabsource = "DAFE Excel Sheet"
                elif str(data_model[test_type][template_file_name][variable]["source"]) == "config":
                    tabsource = "ATAG config file"
                else:
                    tabsource = str(data_model[test_type][template_file_name][variable]["source"])
            else:
                tabsource = " "

            table_row = variable + " | " + tabdescr + " | " + tabmandatory + " | " + tabdefault + " | " + tabsource + "\n"
            template_variables.append(table_row)
        template_variables.append("\n")
        template_variables.append("\n")
    return template_variables

def get_template_body(template_content):
    template_body = ["### Template Body:\n"]
    body_markdown_start_line = "```\n"
    body_markdown_stop_line = "```\n"
    template_body.append(body_markdown_start_line)
    for line in template_content:
        template_body.append(line)
    template_body.append("\n")
    template_body.append(body_markdown_stop_line)
    return template_body

def get_template_data_model(data_model,template_file_name,test_type):
    """
    """
    template_data_model = ["### Template Data Validation Model:\n"]
    if data_model[test_type].has_key(template_file_name):
        template_data_model.append("```json\n")
        template_data_model.append(pprint.pformat(data_model[test_type][template_file_name]))
        template_data_model.append("\n")
        template_data_model.append("```\n")
    else:
        template_data_model.append("No Validation model defined\n")
    return template_data_model

def split_template_content(template_file_name,template_content,data_model,test_type):
    """
    """
    template_header = "## " + template_file_name + "\n"
    template_metadata, template_body_pointer = get_template_metadata(template_content)
    template_body = get_template_body(template_content[template_body_pointer:])
    template_data_model = get_template_data_model(data_model,template_file_name,test_type)
    template_variables = get_template_variables(data_model,template_file_name, test_type)
    print "Just did template:%s" %template_file_name
    return [template_header,template_metadata,template_body,template_data_model,template_variables]

def write_to_markdown(markdown_file,string_list):
    for line in string_list:
        markdown_file.write(line)
    return True

def main():
    args = read_arguments()
    templates_path = args.templates_path
    config_file = args.config

    # Load Templates
    template_data = get_template_data(config_file)      # Load template data
    template_files = load_templates(templates_path)     # Load templates

    # Load Data Model
    data_model_file = open(args.data_model,"r")
    data_model = yaml.load(data_model_file)

    if sys.getsizeof(template_files) > 0:
        # Process templates in each test_type
        for test_type in template_files.keys():
            # Open template documentation file
            output_filename = "Templates-%s.md" % test_type
            markdown_document = open(output_filename,"w")

            test_type_headline = ["# Overview\n"]
            test_type_headline.append(template_data['testcase_types'][test_type]['description'] + "\n")

            write_to_markdown(markdown_document,test_type_headline)

            # Iterate through each template
            for template in template_files[test_type].keys():
                template_header, template_metadata, template_body, template_data_model, template_variables = split_template_content(template,template_files[test_type][template],data_model,test_type)

                if template_metadata:
                    write_to_markdown(markdown_document,template_header)
                    write_to_markdown(markdown_document,template_metadata)
                    write_to_markdown(markdown_document,template_variables)
                    write_to_markdown(markdown_document,template_body)
                    write_to_markdown(markdown_document,template_data_model)

            # Close template documentation file
            markdown_document.close()

if __name__ == '__main__':
    main()