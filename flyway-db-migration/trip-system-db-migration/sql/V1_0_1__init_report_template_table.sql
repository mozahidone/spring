CREATE TABLE report_template
(
    uid                BIGINT NOT NULL,
    deleted            BIT(1) NULL,
    version            BIGINT NULL,
    name               VARCHAR(82) NULL,
    `description`      VARCHAR(200) NULL,
    required_privilege VARCHAR(40) NULL,
    created_by         VARCHAR(50) NULL,
    created_datetime   datetime NULL,
    last_modified_by        VARCHAR(50) NULL,
    last_modified_datetime  datetime NULL,
    CONSTRAINT pk_report_template PRIMARY KEY (uid)
);

ALTER TABLE report_template
    ADD CONSTRAINT report_template_name_unique UNIQUE (name);

CREATE INDEX name_index ON report_template (name);