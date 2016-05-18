module DbMeta

  SUMMARY_COLUMN_FORMAT_NAME = "%-40s"
  SUMMARY_COLUMN_FORMAT_NAME_RIGHT = "%40s"

  TYPE_SEQUENCE = {
    summary: 0,
    create: 1,
    drop: 1,

    database_link: 2,
    sequence: 3,
    table: 4,
    view: 5,
    materialized_view: 6,
    function: 7,
    procedure: 8,
    package: 9,
    package_body: 9,
    synonym: 10,
    trigger: 11,
    grant: 12,
    grant_external: 13,
    type: 14,
    lob: 20,
    index: 22,
    data: 40,
    constraint: 60
  }

  EXTRACT_FORMATS = [:sql]

end
