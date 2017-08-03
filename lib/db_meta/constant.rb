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
    'VIEW' => 5,
    'MATERIALIZED VIEW' => 6,
    'FUNCTION' => 7,
    'PROCEDURE' => 8,
    'PACKAGE' => 9,
    'PACKAGE BODY' => 9,
    'SYNONYM' => 10,
    'TRIGGER' => 11,
    'GRANT' => 12,
    'GRANT EXTERNAL' => 13,
    'TYPE' => 14,
    'LOB' => 20,
    'INDEX' => 22,
    'DATA' => 40,
    'CONSTRAINT' => 60
  }

  EXTRACT_FORMATS = [:sql]

end
