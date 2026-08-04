ALTER TABLE `t_ds_schedules`
    ADD COLUMN `misfire_policy` tinyint NOT NULL DEFAULT '2' COMMENT 'misfire policy: 0 do nothing, 1 fire and proceed, 2 ignore misfires' AFTER `crontab`;
