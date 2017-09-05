module DbMeta

  SUMMARY_COLUMN_FORMAT_NAME = "%-40s"
  SUMMARY_COLUMN_FORMAT_NAME_RIGHT = "%40s"

  TYPE_SEQUENCE = {
    'SUMMARY' => 0,
    'CREATE' => 1,
    'DROP' => 1,

    'DATABASE LINK' => 2,
    'SEQUENCE' => 3,
    'TYPE' => 4,
    'TABLE' => 5,
    'QUEUE' => 6,
    'LOB' => 7,
    'VIEW' => 8,
    'MATERIALIZED VIEW' => 9,
    'FUNCTION' => 10,
    'PROCEDURE' => 11,
    'PACKAGE' => 12,
    'PACKAGE BODY' => 12.1,
    'SYNONYM' => 13,
    'TRIGGER' => 14,
    'GRANT' => 15,
    'GRANT EXTERNAL' => 16,
    'INDEX' => 17,
    'DATA' => 20,
    'CONSTRAINT' => 30
  }

  EXTRACT_FORMATS = [:sql]

  OBJECT_QUERY = "
    select * from (
      select OBJECT_TYPE, OBJECT_NAME, STATUS from user_objects
      union all
      select 'CONSTRAINT' as OBJECT_TYPE, CONSTRAINT_NAME as OBJECT_NAME, STATUS from user_constraints
      union all
      select 'GRANT' as OBJECT_TYPE, grantee || ',' || owner || ',' || table_name || ',' || grantor || ',' || privilege || ',' || grantable as object_name, 'VALID' as status from user_tab_privs
    ) order by object_type, object_name
  "

  OBJECT_FILTER = ['LOB', 'PACKAGE BODY', 'CONSTRAINT', 'GRANT']

end
