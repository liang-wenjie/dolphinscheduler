ALTER TABLE t_ds_schedules
    ADD COLUMN misfire_policy smallint NOT NULL DEFAULT 2;
