# logInterface
logInterface.py
Purpose: Extract error messages with specific pattern and update a database with those details, and at the same time enriching by adding more characteristics. The tool also aggregates the number of failures for a certain resource as well as counting repeated failures. The tool evaluates first the complete log file and subsequently only the recent entries that are created after the full log file evaluation. The script can be scheduled by using the operating system tools.

Changes that are required: The tool assumes that the log file in the default location. However, database details must be updated. Therefore the "conn" variable must be defined with correct database details. A database must be created prior to executing the script, and the related details are provided as part of the complete package.
Development environment: 
Development program: Python 3.6.5
OS: OpenSuSe Linux 15.0
Database: MySql 8.1.3
