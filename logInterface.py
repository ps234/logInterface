"""
logInterface.py
Purpose: Extract error messages with specific pattern and update a database with those details, and at the same time enriching by adding more characteristics. The tool also aggregates the number of failures for a certain resource as well as counting repeated failures. The tool evaluates first the complete log file and subsequently only the recent entries that are created after the full log file evaluation. The script can be scheduled by using the operating system tools.

Changes that are required: The tool assumes that the log file in the default location. However, database details must be updated. Therefore the "conn" variable must be defined with correct database details. A database must be created prior to executing the script, and the related details are provided as part of the complete package.
Development environment: 
Development: Python 3.6.5
OS: OpenSuSe Linux 15.0
Database: MySql 8.1.3

"""


import pymysql
from dateutil import parser
from datetime import timedelta
conn = pymysql.connect(host='localhost',user='root',password='D#3Qh!hHYt45Bn',db='hacdata')
resource_id = []
count_for_skipping = 0
a = conn.cursor()
sqlQuery = "select count(event_date),event_date from hacdata.hac_main group by event_date ORDER by event_date DESC LIMIT 1"
date_time_for_comparison = None
try:
    a.execute(sqlQuery)
    rows = a.fetchall()
    for row in rows:
        number_of_rows_in_log_file_to_be_skipped = row[0]
        date_time_for_comparison = row[1]
except :
    print("Something went wrong deleting previous data from table")
with open('/var/log/pacemaker/pacemaker.log','r') as rf:

    for line in rf:
        if line.find("not running")!= -1:
            time_stamp = line[0:15]
            date_time = parser.parse(time_stamp)

            server = line.split()[4]
            process = line.split()[5].split(":")[0]
            if line.find("=not running")!= -1:
                hac_resource_name = line.split("=")[0].split()[-1]
            else:
                hac_resource_name = line.split(":")[5].split()[-3]
            sqlQuery = ("select * FROM hacdata.configuration WHERE HAC_resource_name = '%s' limit 1" % hac_resource_name)
            a.execute(sqlQuery)
            rows = a.fetchall()
            length_of_data_tuple = len(rows)
            if length_of_data_tuple != 0:
                for row in rows:
                    configuration_resource_id = row[0]
                    resource_name = row[1]
                    group_id = row[3]
                    cluster_id = row[4]
                    node_id= row[5]
                    error_msg = "not running"
                    dependency_factor = int(row[9] + row[13] + row[14])
                    current_state = row[8]
                failure_repetition = 0
                aggregated_failure_count = 0
                two_minutes_time = date_time - timedelta(0, 120)
                four_hours = date_time - timedelta(0, 14400)
                resource_tuple_name_time = [item for item in resource_id if item[0] == hac_resource_name]
                flag_for_same_time_resource = False
                for resource_tuple_name_time_item in resource_tuple_name_time:
                    item_time = resource_tuple_name_time_item[1]
                    if item_time == date_time and resource_tuple_name_time_item[0] == hac_resource_name:
                        flag_for_same_time_resource = True
                        break
                        # if item_time >= four_hours and item_time <= date_time:
                        #     aggregated_failure_count = aggregated_failure_count + 1
                        # if item_time >= two_minutes_time and item_time <= date_time:
                        #     failure_repetition = failure_repetition + 1
                if not flag_for_same_time_resource:
                    for resource_tuple_name_time_item in resource_tuple_name_time:
                        item_time = resource_tuple_name_time_item[1]
                        if item_time >= four_hours and item_time <= date_time:
                            aggregated_failure_count = aggregated_failure_count + 1
                        if item_time >= two_minutes_time and item_time <= date_time:
                            failure_repetition = failure_repetition + 1
                    resource_id.append((hac_resource_name, date_time))
                    if date_time_for_comparison == None:
                        sqlQuery = "INSERT INTO hacdata.hac_main(`configuration_resource_id`, `resource_name`, `HAC_resource_name`, `group_id`, `cluster_id`, `node_id`, `error_message`, `event_date`,`current_state`, `aggeregated_failure_count`, `failure_repetition`, `error_rating`,`dependency_factor`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,%s, %s )"
                        try:
                            a.execute(sqlQuery, (
                            configuration_resource_id, resource_name, hac_resource_name, group_id, cluster_id, node_id,
                            error_msg, date_time, current_state, aggregated_failure_count, failure_repetition, 1,
                            dependency_factor))
                            conn.commit()
                        except:
                            print("Something went wrong for : " + hac_resource_name + " with timestamp " + time_stamp)
                    elif (date_time > date_time_for_comparison) or (number_of_rows_in_log_file_to_be_skipped == 0):
                        sqlQuery = "INSERT INTO hacdata.hac_main(`configuration_resource_id`, `resource_name`, `HAC_resource_name`, `group_id`, `cluster_id`, `node_id`, `error_message`, `event_date`,`current_state`, `aggeregated_failure_count`, `failure_repetition`, `error_rating`,`dependency_factor`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,%s, %s )"
                        try:
                            a.execute(sqlQuery, (configuration_resource_id,resource_name, hac_resource_name, group_id, cluster_id, node_id, error_msg, date_time, current_state, aggregated_failure_count, failure_repetition, 1, dependency_factor))
                            conn.commit()
                        except :
                            print("Something went wrong for : "+ hac_resource_name + " with timestamp " + time_stamp)
                    else:
                        if date_time_for_comparison == date_time:
                            number_of_rows_in_log_file_to_be_skipped = number_of_rows_in_log_file_to_be_skipped - 1
