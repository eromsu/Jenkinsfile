import yaml
import re


def check_valid_type(data,data_type):
        """
        Method whose goal is to validate data type
        :param data= data to be validated  
        :param data_type= expected type data will be evaluated against as defined by schema
        :return True if data is from correct type False otherwise
        """
        try:
            if data_type == "int":
                return type(int(data)) is int
            else:
                return type(str(data)) is str
        except:
            return False
                    
def check_valid_regex(data,data_reg_exp):
        """
        Validate data against regular expression. Regex match 
        :param data=data to be validated
        :param data_reg_exp= Dictionary containing pattern and exact_match Boolean
        :return True if data matches regular expression False otherwise
        """
        try:
            #regular_expression = re.escape(data_reg_exp["pattern"])
            #regex = re.compile(data_reg_exp["pattern"])
            if data_reg_exp["exact_match"]: #Validate string
                return re.match(data_reg_exp["pattern"],data)
            else:
                for char in data:
                    if not re.match(data_reg_exp["pattern"],char):
                        return False
                return True
        except:
            return False
            
def check_valid_range(data,min_value,max_value):
        """
        Method whose goal is to validate that data is in valid range
        :param data data=data to be validated  expected int type 
        :param min_value = minimum vamue int 
        :param max_value  = maxixum value  int
        :return True if data is in (min_value,max_value) False otherwise
        """
        try:
            return min_value <= int(data) and int(data) <= max_value
        except:
            return False

def check_valid_enum(data,enum_list):
        """
        Method whose goal is to validate that data is in the schema enum_list
        :param data data= data to be validated
        :param enum_list = list of acceptable values
        :return True if data is in the enum_lust False otherwise
        """
        try:
            return data in enum_list
            pattern = "^"+data+"$"
            print enum_list
            for item in enum_list:
                print item
                if re.match(pattern,item):
                    return True
            return False
        except:
            return False

def check_valid_length(data,min_length,max_length):
        """
        Method whose goal is to validate that data is in valid range
        :param data data=data to be validated  expected int type 
        :param min_value = minimum vamue int 
        :param max_value  = maxixum value  int
        :return True if data is in (min_value,max_value) False otherwise
        """
        try:
            return min_length <= len(data) and len(data) <= max_length
        except:
            return False

def validate_data(data_dict,schema_dict):
        """
        :param data_dict= input data list 
        :param schema_dict = data validation schema
        :return True if data valid , meaning matches all data validation , False otherwise
        """
        for key in data_dict:
            if schema_dict.has_key(key):
                data_validation_schema = schema_dict[key]
                if data_dict[key]:
                    for rule in data_validation_schema:
                        if rule == "type":
                            if not check_valid_type(data_dict[key],data_validation_schema["type"]):
                                print "+-Error:Fail type check for variable %s" %key
                                return False
                        elif rule == "regex":
                            if not check_valid_regex(data_dict[key],data_validation_schema["regex"]):
                                print "+-Error:Fail regex check for variable %s" %key
                                return False
                        elif rule == "range":
                            if not check_valid_range(data_dict[key],data_validation_schema["range"][0],data_validation_schema["range"][1]):
                                print "+-Error:Fail Range Check for variable %s" %key
                                return False
                        elif rule =="enum":
                            if not check_valid_enum(data_dict[key],data_validation_schema["enum"]):
                                print "+-Error:Fail enum check for variable %s" %key
                                return False
                        elif rule =="length":
                            if not check_valid_length(data_dict[key],data_validation_schema["length"][0],data_validation_schema["length"][1]):
                                print "+-Error:Fail Lenght Check for %s" %key
                                return False

                elif data_validation_schema["mandatory"] == True:
                    print "+-Error: Mandatory value not defined for variable %s" %key
                    return False
        return True

def validate_input(worksheet_input,validation_schema):
    failed_entries = []
    line_number = 2
    for entry in worksheet_input:
        if ("status" in entry.keys() and entry["status"] != "ignored") or ("status" not in entry.keys()):
            if not validate_data(entry,validation_schema):
                failed_entries.append(line_number)
        line_number = line_number + 1
    return failed_entries