
-- refresh materialized views
refresh materialized view mining.mv_epic_scores with data;
refresh materialized view patient_data.mv_lab with data;
refresh materialized view patient_data.mv_eventinfo_contents with data;
refresh materialized view patient_data.mv_timeline_element with data;
refresh materialized view patient_data.mv_visits_and_episodes with data;
