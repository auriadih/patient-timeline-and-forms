

-- ########################################
-- V_ANALYTICS_FIELD_SYNONYMS


drop view if exists wtf.v_analytics_field_synonyms;


CREATE OR REPLACE VIEW wtf.v_analytics_field_synonyms
AS SELECT ff.form_field_id,
    s.referred_id AS component_id,
    ff.field_name,
    func.simplify_characters(COALESCE(concat_ws('_'::text, ( SELECT wtf.get_field_lineage(ff.form_field_id, 'analytics'::text) AS get_field_lineage), COALESCE(s.synonym_name, ff.field_name)))) AS field_analytics_name
   FROM wtf.v_form_fields ff
     LEFT JOIN wtf.synonym s ON ff.component_id = s.referred_id AND s.referred_table::text = 'component'::text
     LEFT JOIN wtf.context c ON s.context_id = c.context_id AND c.context_name::text = 'analytics'::text
  WHERE ff.form_field_id IS NOT NULL;
  
  
  
-- ########################################
-- V_ANALYTICS_FORM_SYNONYMS



drop view  wtf.v_analytics_form_synonyms;


CREATE OR REPLACE VIEW wtf.v_analytics_form_synonyms
AS SELECT DISTINCT f.form_id,
    f.form_name,
    func.simplify_characters(ug.group_name::text) AS analytics_schema_name,
    func.simplify_characters(COALESCE(concat_ws('_'::text, ( SELECT wtf.get_form_lineage(f.form_id, 'analytics'::text) AS get_form_lineage), COALESCE(s.synonym_name, f.form_name)))) AS form_analytics_name
   FROM wtf.form f
     JOIN base.user_group ug ON f.owner_group_id = ug.group_id
     JOIN wtf.user_group_analytics_activity_status ugaas ON ug.group_id = ugaas.user_group_id AND ugaas.analytics_active = true
     LEFT JOIN wtf.synonym s ON f.form_id = s.referred_id AND s.referred_table::text = 'form'::text
     LEFT JOIN wtf.context c ON s.context_id = c.context_id AND c.context_name::text = 'analytics'::text;
