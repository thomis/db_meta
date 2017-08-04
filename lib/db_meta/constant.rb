module DbMeta

  SUMMARY_COLUMN_FORMAT_NAME = "%-40s"
  SUMMARY_COLUMN_FORMAT_NAME_RIGHT = "%40s"

  TYPE_SEQUENCE = {
    'SUMMARY' => 0,
    'CREATE' => 1,
    'DROP' => 1,

    'DATABASE LINK' => 2,
    'SEQUENCE' => 3,
    'TABLE' => 4,
    'LOB' => 4.1,
    'VIEW' => 5,
    'MATERIALIZED VIEW' => 6,
    'FUNCTION' => 7,
    'PROCEDURE' => 8,
    'PACKAGE' => 9,
    'PACKAGE BODY' => 9.1,
    'SYNONYM' => 10,
    'TRIGGER' => 11,
    'GRANT' => 12,
    'GRANT EXTERNAL' => 13,
    'TYPE' => 14,
    'INDEX' => 22,
    'DATA' => 40,
    'CONSTRAINT' => 60
  }

  EXTRACT_FORMATS = [:sql]

  OBJECT_QUERY = "
    select * from (
      select OBJECT_TYPE, OBJECT_NAME, STATUS from user_objects
      union all
      select 'CONSTRAINT' as OBJECT_TYPE, CONSTRAINT_NAME as OBJECT_NAME, STATUS from user_constraints
      union all
      select 'GRANT' as OBJECT_TYPE, privilege || ' ON '|| owner || '.' || table_name || ' TO ' || grantee as object_name, 'VALID' as status from user_tab_privs
    ) order by object_type, object_name
  "

  OBJECT_FILTER = ['LOB', 'PACKAGE BODY', 'CONSTRAINT', 'GRANT']

end
