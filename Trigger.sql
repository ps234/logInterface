CREATE DEFINER=`prem`@`%` TRIGGER `modelDataTrigger` AFTER INSERT ON `hac_main` FOR EACH ROW BEGIN
DECLARE v_reinitialization_factor int(11);
DECLARE v_dependency_type int(11);
DECLARE new_v_reinitialization_factor varchar(30);
DECLARE v_redundancy_factor varchar(5);
DECLARE new_v_dependency_type varchar(8);
DECLARE v_critical_factor varchar(5);
DECLARE v_dependency_levels_up varchar(5); 
DECLARE v_dependency_levels_down varchar(5);
DECLARE v_current_state varchar(16);

SELECT `reinitialization_factor`, IF(redundancy_factor=1, "true", "false"), `dependency_type`,  IF(critical_factor=1, "true", "false"),  IF(dependency_levels_up < 2, "low", "high"), IF(dependency_levels_down < 2, "low", "high") INTO v_reinitialization_factor, v_redundancy_factor, v_dependency_type, v_critical_factor, v_dependency_levels_up, v_dependency_levels_down FROM `hacdata`.`configuration` WHERE resource_id=NEW.configuration_resource_id and HAC_resource_name=NEW.HAC_resource_name;

IF v_reinitialization_factor=1 THEN
SET new_v_reinitialization_factor = 'true';
ELSEIF v_reinitialization_factor= 2 THEN
SET new_v_reinitialization_factor = 'false';
END IF;

IF v_dependency_type=1 THEN
SET new_v_dependency_type = 'local';
ELSEIF v_dependency_type= 2 THEN
SET new_v_dependency_type = 'shared';
ELSE
SET new_v_dependency_type = 'global';
END IF;

IF NEW.error_message='not running' THEN 
SET v_current_state = 'offline';
ELSEIF NEW.error_message='running'THEN
SET v_current_state = 'online';
ELSE
SET v_current_state = 'unknown';
END IF;


INSERT INTO `hacdata`.`model_data` (resource_id, resource_name, HAC_resource_name, group_id, cluster_id, node_id, event_date, current_state, critical_factor, failure_repetition, redundancy_factor, aggeregated_failure_count, reinitialization_factor, dependency_type, dependency_levels_up, dependency_levels_down ) 
VALUES
(NEW.configuration_resource_id, NEW.resource_name, NEW.HAC_resource_name, NEW.group_id, NEW.cluster_id,  NEW.node_id,  NEW.event_date,  v_current_state, v_critical_factor, IF(NEW.failure_repetition < 4, "low", "high"), v_redundancy_factor, IF(NEW.aggeregated_failure_count < 8, "low", "high"), new_v_reinitialization_factor , new_v_dependency_type, v_dependency_levels_up, v_dependency_levels_down);

END