


drop schema if exists cdc cascade;
create schema cdc;

-- DROP TABLE cdc.cdc_time;

CREATE TABLE cdc.cdc_time (
	cdc_time_id serial NOT NULL,
	schema_name varchar NULL,
	process_name varchar NULL,
	last_load timestamp NULL,
	current_load timestamp NULL,
	CONSTRAINT cdc_time_pkey PRIMARY KEY (cdc_time_id),
	CONSTRAINT schema_name_process_name_unique UNIQUE (schema_name, process_name)
);



