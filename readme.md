README: Oracle PL/SQL Script for Managing Sequences and Triggers

Overview

This PL/SQL script automates the creation of sequences and triggers for tables in an Oracle database schema that have single-column numeric primary keys. The script ensures that primary key values are automatically generated for new rows, starting from the maximum existing value in each table.

Key Features
	1.	Dynamic Identification of Tables:
	•	Uses a cursor to identify tables with a single-column numeric primary key.
	•	Excludes tables with composite primary keys.
	2.	Sequence Management:
	•	Drops all existing sequences in the schema.
	•	Creates new sequences for eligible tables, starting from MAX(primary_key) + 1.
	3.	Trigger Management:
	•	Dynamically creates triggers for each eligible table to automatically assign primary key values using the corresponding sequence.
	4.	Error Logging:
	•	Logs errors if sequence deletion, creation, or trigger creation fails.

Script Components
	1.	Cursor Definition:
	•	Queries USER_CONS_COLUMNS, USER_CONSTRAINTS, and USER_TAB_COLUMNS to identify tables with a single-column numeric primary key.
	2.	Sequence Deletion:
	•	Drops all existing sequences in the schema to ensure a clean slate.
	3.	Sequence Creation:
	•	Dynamically determines the maximum primary key value (MAX(primary_key)).
	•	Creates a new sequence starting from MAX + 1.
	4.	Trigger Creation:
	•	Creates or replaces a BEFORE INSERT trigger for each table.
	•	Ensures that primary keys are automatically populated using the sequence.

Usage Instructions
	1.	Prerequisites:
	•	The script requires Oracle database access with appropriate privileges to query metadata views and create/drop sequences and triggers.
	2.	Execution Steps:
	•	Connect to the Oracle database using a PL/SQL-compatible client (e.g., SQL*Plus, SQL Developer).
	•	Run the script in a schema where you want to automate primary key management.
	3.	Error Logging:
	•	Errors during sequence or trigger operations are logged using DBMS_OUTPUT.PUT_LINE.

