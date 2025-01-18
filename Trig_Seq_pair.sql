DECLARE
    -- Cursor to select tables with a single-column numeric primary key
    CURSOR table_cursor IS
        SELECT DISTINCT ucc.table_name, ucc.column_name
        FROM user_cons_columns ucc
        JOIN user_constraints uc
            ON ucc.constraint_name = uc.constraint_name
        INNER JOIN user_tab_columns utc
            ON utc.column_name = ucc.column_name
        WHERE uc.constraint_type = 'P' -- Only primary keys
          AND utc.data_type LIKE '%NUMBER%' -- Numeric columns
          AND ucc.table_name NOT IN (
              SELECT table_name
              FROM user_cons_columns
              WHERE constraint_name IN (
                  SELECT constraint_name
                  FROM user_constraints
                  WHERE constraint_type = 'P'
              )
              GROUP BY table_name
              HAVING COUNT(*) > 1 -- Exclude tables with composite primary keys
          );

    max_id NUMBER; -- Variable to hold the maximum primary key value for each table

BEGIN
    -- Drop all existing sequences in the schema
    FOR seq IN (
        SELECT sequence_name 
        FROM user_sequences
    )
    LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP SEQUENCE ' || seq.sequence_name; -- Drop each sequence
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Failed to drop sequence: ' || seq.sequence_name); -- Log errors if sequence drop fails
        END;
    END LOOP;

    -- Process each table with a numeric primary key (single-column primary keys)
    FOR table_record IN table_cursor LOOP
        BEGIN
            -- Find the maximum primary key value dynamically for the table
            EXECUTE IMMEDIATE 
                'SELECT NVL(MAX(' || table_record.column_name || '), 0) FROM ' || table_record.table_name
            INTO max_id;

            -- Create a sequence starting with max_id + 1
            EXECUTE IMMEDIATE 
                'CREATE SEQUENCE ' || table_record.table_name || '_SEQ START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';

            -- Create or replace the trigger for automatic primary key assignment
            EXECUTE IMMEDIATE
                'CREATE OR REPLACE TRIGGER ' || table_record.table_name || '_TRG ' ||
                'BEFORE INSERT ON ' || table_record.table_name ||
                ' FOR EACH ROW ' ||
                'BEGIN ' ||
                '   :NEW.' || table_record.column_name || ' := ' || table_record.table_name || '_SEQ.NEXTVAL; ' ||
                'END;';
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error processing table: ' || table_record.table_name || 
                                     ' - ' || SQLERRM); -- Log errors if sequence or trigger creation fails
        END;
    END LOOP;
END;
/