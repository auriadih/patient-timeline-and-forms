

delete from base.person;
alter sequence base.person_id_seq restart with 1;


-- create surgery dates for each patient as an 'anchor' for the timeline events
drop table if exists patient_data.surgery_dates;
create table patient_data.surgery_dates (
person_id bigint not null primary key,
surgery_date timestamp without time zone not null);


-- generate patients
insert into base.person (person_id, birth_date, death_date, gender, lastname, firstname, henkilotunnus) values
(-101, '1903-03-03', null, 1, 'Doe', 'John', '030303-0303')
;

-- to insert more test patients with a SSN/henkilotunnus in valid Finnish format,
-- you can use 040404-0404, 050505-0505 etc.


DO $$

DECLARE

_loop_var integer;
_person_id bigint := -101;
_surgery_date date := '2017-03-24';
_surgery_id bigint;
_element_id bigint;
_pathology_id bigint;
_pathology_answer_id bigint;
_medication_set_id bigint;
_episode_of_care_id bigint;
_visit_id bigint;
_lab_package_id bigint;
_lab_test varchar;
_lab_test_unit varchar;
_lab_pks varchar[];
_lab_values varchar[];
_lab_offsets integer[];
_radiology_procedure_set_id bigint;
_int_pks integer[];
_char_pks varchar[];
_max_int_pk integer := 0;
_max_char_pk integer := 0;


_session_id bigint;
_user_id bigint;
_group_id bigint;
_ts timestamp;
_form_id bigint;
_answer_set_id bigint;
_form_field_id bigint;
_epic_numbers varchar[] := array['1','2','3','4|1','4|2','4|3','4|4','4|5','5','6|1','6|2','6|3','6|4','6|5', '7',
						'8|1','8|2','9','10','11','13|1','13|2','13|3','13|4','13|5','14','15','16|1','16|2','16|3','16|4','16|5'];
_epic_answers varchar[];

BEGIN

	

-- generate surgery dates
insert into patient_data.surgery_dates values 
(_person_id, _surgery_date);




-- ####################################
-- Insert elements
-- ####################################


-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- surgery
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit)
values (_person_id, _surgery_date, _surgery_date, 'surgery', 'URO')
	returning element_id into _element_id;

insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 1);

_max_int_pk := _max_int_pk + 1;

insert into patient_data.surgery (element_id, treating_unit_code, treating_unit_name, source_pk) values 
( _element_id, 'URO', 'UROLOGIA', _max_int_pk) returning surgery_id into _surgery_id;

-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- surgery procedures
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤


insert into patient_data.surgery_procedure (surgery_id, procedure_code, procedure_name, diagnosis_code, diagnosis_name,
is_main_procedure, source_pk, surgery_source_pk) values
(_surgery_id, 'KEC01', 'ETURAUHASEN TÄYDELLINEN POISTO TÄHYSTYKSESSÄ IHOLTA', 'C61', 'C61 - Eturauhassyöpä', true, 1, 1),
(_surgery_id, 'WX408', 'YLEISANESTESIAN YLLÄPITO SEKÄ LASKIMOON ANNETTAVALLA ETTÄ INHALOITAVALLA ANESTEETILLA', 'C61', 'C61 - Eturauhassyöpä', false, 2, _max_int_pk),
(_surgery_id, 'ZXC96', 'ROBOTIN KÄYTTÖ LEIKKAUKSESSA', 'C61', 'C61 - Eturauhassyöpä', false, 3, 1),
(_surgery_id, 'PJD64', 'IMUSOLMUKKEIDEN RADIKAALINEN POISTO TÄHYSTYKSESSÄ LONKKAVALTIMOIDEN YMPÄRILTÄ','C61', 'C61 - Eturauhassyöpä', false, 4, _max_int_pk);




-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- pathology: biopsy
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤


insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
(_person_id, _surgery_date - 30, _surgery_date - 14, 'pathology', 'UR1L ERIKOISLÄÄKÄRI, UR1L ERIKOISLÄÄKÄRI')
returning element_id into _element_id;

insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 1);

insert into patient_data.pathology (element_id, source_pk) values 
( _element_id, 'B99887') returning pathology_id into _pathology_id;

_max_int_pk := _max_int_pk + 1;

insert into patient_data.pathology_answer (pathology_id, order_number, answer_number, acked, ordering_unit, receiving_unit,
source_pk) values 
( _pathology_id, 1, 1, _surgery_date - 14, 'UR1L ERIKOISLÄÄKÄRI', 'UR1L ERIKOISLÄÄKÄRI', _max_int_pk)
returning pathology_answer_id into _pathology_answer_id;

_max_int_pk := _max_int_pk + 1;

insert into patient_data.pathology_diagnosis (pathology_answer_id, organ, diagnosis, diagnosis_suffix,
diagnosis_row_number, source_pk)
values
( _pathology_answer_id, 'PROSTATE', 'ADENOCARCINOMA', null, 1, _max_int_pk );


-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- pathology: surgery sample
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤


insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
(_person_id, _surgery_date + 7, _surgery_date + 7,
'pathology', 'UR1V UROLOGIAN OSASTO, UR1V UROLOGIAN OSASTO')
 returning element_id into _element_id;
 
insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 1);

insert into patient_data.pathology (element_id, source_pk) values 
( _element_id, 'B11223') returning pathology_id into _pathology_id;

_max_int_pk := _max_int_pk + 1;

insert into patient_data.pathology_answer (pathology_id, order_number, answer_number, acked, ordering_unit, receiving_unit,
source_pk) values 
( _pathology_id, 1, 1, _surgery_date + 7,
 'UR1V UROLOGIAN OSASTO', 'UR1V UROLOGIAN OSASTO', _max_int_pk)
returning pathology_answer_id into _pathology_answer_id;


_max_int_pk := _max_int_pk + 1;

insert into patient_data.pathology_diagnosis (pathology_answer_id, organ, diagnosis, diagnosis_suffix,
diagnosis_row_number, source_pk) values
( _pathology_answer_id, 'PROSTATE', 'ADENOCARCINOMA', '(GRADUS II, GLEASON SCORE 5)', 1, _max_int_pk);

_max_int_pk := _max_int_pk + 1;

insert into patient_data.pathology_diagnosis (pathology_answer_id, organ, diagnosis, diagnosis_suffix,
diagnosis_row_number, source_pk) values
( _pathology_answer_id, 'LYMPH NODE', 'NO SIGNS OF MALIGNANCY', null, 2, _max_int_pk);

_max_int_pk := _max_int_pk + 1;

insert into patient_data.pathology_diagnosis (pathology_answer_id, organ, diagnosis, diagnosis_suffix,
diagnosis_row_number, source_pk) values
( _pathology_answer_id, 'SEMINAL VESICLE', 'NO SIGNS OF MALIGNANCY', null, 3, _max_int_pk);



-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- post-op pain medication
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤


insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
	(_person_id, _surgery_date, _surgery_date,
	'medication_set', 'URO')
	 returning element_id into _element_id;
	 
_max_char_pk := _max_char_pk + 1;

insert into patient_data.medication_set (element_id, prescribing_unit_code, source_pk, insert_ts) values 
(_element_id, 'URO', _max_char_pk, now()) returning medication_set_id into _medication_set_id;


insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 3);
 
 _max_char_pk := _max_char_pk + 1;
 

 
insert into patient_data.medication (medication_set_id, source_pk, atc_code, atc_name, generic_name, product_name, strength, dosage,
is_inpatient,inpatient_medication_source_pk, outpatient_medication_source_pk, insert_ts) values
(_medication_set_id, _max_char_pk, 'M01AE01', 'Ibuprofeeni', 'ibuprofeeni', 'BURANA', '800 mg',
'1 tabl. tarvittaessa 3 kertaa vuorokaudessa. Kipulääke.', false, null, _max_char_pk + 1, now());

 _max_char_pk := _max_char_pk + 1; -- because incremented once inside previous insert


-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- hormone medication 4kk after surgery
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
(_person_id, _surgery_date + 120, _surgery_date + 120, 'medication_set', 'URO')
returning element_id into _element_id;

 _max_char_pk := _max_char_pk + 1;

insert into patient_data.medication_set (element_id, prescribing_unit_code, source_pk, insert_ts) values 
(_element_id, 'URO', _max_char_pk, now()) returning medication_set_id into _medication_set_id;

insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 3);

 _max_char_pk := _max_char_pk + 1;
 
insert into patient_data.medication (medication_set_id, source_pk, atc_code, atc_name, generic_name, product_name, strength, dosage,
is_inpatient,inpatient_medication_source_pk, outpatient_medication_source_pk, insert_ts) values
(_medication_set_id, _max_char_pk, 'L02AE02', 'Leuproreliini', 'leuproreliiniasetaatti', 'ENANTON DEPOT DUAL', '11,25 mg',
'1 pistos kolmen kuukauden välein.', false, null, _max_char_pk + 1, now());

 _max_char_pk := _max_char_pk + 1; -- because incremented once inside previous insert

-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- in-patient period after surgery
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
(_person_id, _surgery_date,_surgery_date + 1, 'episode_of_care', 'URO')
 returning element_id into _element_id;
 
insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 1);

_max_char_pk := _max_char_pk + 1;

insert into patient_data.episode_of_care
(element_id, unit_code, unit_name, resource_code, resource_name, source_pk)  values
(_element_id, 'URO', 'Urologia', 'UR2V', 'Leiko potilaat',  _max_char_pk)
returning episode_of_care_id into _episode_of_care_id;

_max_char_pk := _max_char_pk + 1;

insert into patient_data.diagnosis (visit_id, episode_of_care_id, service_type,
diagnosis_code, diagnosis_name, is_main_diagnosis, is_cause_diagnosis, source_pk) values 
(null, 	_episode_of_care_id, 'episode of care', 'C61&', 'Eturauhassyöpä', true, true, _max_char_pk);



-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- radiotherapy one year from surgery
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤


insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
(_person_id, _surgery_date + 380, _surgery_date + 455, 'episode_of_care', 'URO')
 returning element_id into _element_id;
 
insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 1);

_max_int_pk := _max_int_pk + 1;

insert into patient_data.radiotherapy (element_id, course_id, number_of_fractions, total_dose_per_ref_point, source_pk) values 
(_element_id, 'Prostatapesä', 20, 'PTV 1 prost.p.: 40.00Gy', _max_int_pk);


-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- lab results
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

-- PSA

_lab_test := 'P-PSA (4869)';
_lab_test_unit := 'ug/l';
_lab_offsets := array[-365, -180, -60, -7, 30, 75, 115, 180, 240, 330, 400, 430];
_lab_values := array['2.0', '2.5', '7.4', '10.3', '0.004', '0.15',
	'1.5', '0.05', '1.5', '1.8', '0.04', '0.06'];
	
-- generate pks
for _loop_var in 1..array_length(_lab_offsets, 1) LOOP
	_max_char_pk := _max_char_pk + 1;
	_lab_pks := array_append(_lab_pks, _max_char_pk::varchar);
END LOOP;


-- insert measurements
FOR _loop_var in 1..array_length(_lab_offsets, 1) LOOP

insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
(_person_id, _surgery_date + _lab_offsets[_loop_var], _surgery_date + _lab_offsets[_loop_var], 'lab_package', null)
 returning element_id into _element_id;

insert into patient_data.lab_package (element_id, source_pk, insert_ts) values
(_element_id, _lab_pks[_loop_var], now())
returning lab_package_id into _lab_package_id;

insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 3);

insert into patient_data.lab_test (lab_package_id, test, result, unit, source_pk) values 
(_lab_package_id, _lab_test, _lab_values[_loop_var], _lab_test_unit, _lab_pks[_loop_var]::integer);

END LOOP;



-- Hb

_lab_test := 'B-Hb (1552)';
_lab_test_unit := 'g/l';
_lab_offsets := array[-500, -300, -100, -40, -17, -2, 1, 30, 100, 150, 200, 300, 400, 430];
_lab_values := array[]::varchar[];
_lab_pks := array[]::varchar[];
	
-- generate pks
for _loop_var in 1..array_length(_lab_offsets, 1) LOOP
	_max_char_pk := _max_char_pk + 1;
	_lab_pks := array_append(_lab_pks, _max_char_pk::varchar);
END LOOP;

-- generate random Hb measurements between 120 and 150
for _loop_var in 1..array_length(_lab_offsets, 1) LOOP
	_lab_values := array_append(_lab_values, (120 + floor(random() * 30 + 1)::int)::varchar); 
END LOOP;

-- insert measurements
FOR _loop_var in 1..array_length(_lab_offsets, 1) LOOP

insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
(_person_id, _surgery_date + _lab_offsets[_loop_var], _surgery_date + _lab_offsets[_loop_var], 'lab_package', null)
 returning element_id into _element_id;

insert into patient_data.lab_package (element_id, source_pk, insert_ts) values
(_element_id, _lab_pks[_loop_var], now())
returning lab_package_id into _lab_package_id;

insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 3);

insert into patient_data.lab_test (lab_package_id, test, result, unit, source_pk) values 
(_lab_package_id, _lab_test, _lab_values[_loop_var], _lab_test_unit, _lab_pks[_loop_var]::integer);

END LOOP;


-- Krea

_lab_test := 'P-Krea (2142)';
_lab_test_unit := 'umol/l';
_lab_offsets := array[-365, -150, -80, -7, 30, 75, 115, 180, 240, 330];
_lab_values := array[]::varchar[];
_lab_pks := array[]::varchar[];
	
-- generate pks
for _loop_var in 1..array_length(_lab_offsets, 1) LOOP
	_max_char_pk := _max_char_pk + 1;
	_lab_pks := array_append(_lab_pks, _max_char_pk::varchar);
END LOOP;

-- generate random Krea measurements between 60 and 100
for _loop_var in 1..array_length(_lab_offsets, 1) LOOP
	_lab_values := array_append(_lab_values, (60 + floor(random() * 40 + 1)::int)::varchar); 
END LOOP;

-- insert measurements
FOR _loop_var in 1..array_length(_lab_offsets, 1) LOOP

insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
(_person_id, _surgery_date + _lab_offsets[_loop_var], _surgery_date + _lab_offsets[_loop_var], 'lab_package', null)
 returning element_id into _element_id;

insert into patient_data.lab_package (element_id, source_pk, insert_ts) values
(_element_id, _lab_pks[_loop_var], now())
returning lab_package_id into _lab_package_id;

insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 3);

insert into patient_data.lab_test (lab_package_id, test, result, unit, source_pk) values 
(_lab_package_id, _lab_test, _lab_values[_loop_var], _lab_test_unit, _lab_pks[_loop_var]::integer);

END LOOP;




-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- radiology
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

-- two months before surgery
insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
(_person_id, _surgery_date - 600, _surgery_date - 60,'radiology_procedure_set', 'UR1L') 
returning element_id into _element_id;

_max_char_pk := _max_char_pk + 1;

insert into patient_data.radiology_procedure_set (element_id, source_pk,
	ordering_unit_code, procedure_type,insert_ts) values
(_element_id, _max_char_pk, 'UR1L', 'MRI', now())
returning radiology_procedure_set_id into _radiology_procedure_set_id;

insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 1);

_max_int_pk := _max_int_pk + 1;

insert into patient_data.radiology_procedure (radiology_procedure_set_id, procedure_code, procedure_name, source_pk) values 
(_radiology_procedure_set_id, 'JN2CM', 'ALAVATSAN LAAJA 3 TESLAN MT', _max_int_pk);


-- one year after surgery
insert into patient_data.timeline_element (person_id, start_ts, end_ts, category, unit) values 
(_person_id, _surgery_date + 350, _surgery_date + 350, 'radiology_procedure_set', 'UR1L') 
returning element_id into _element_id;

_max_char_pk := _max_char_pk + 1;

insert into patient_data.radiology_procedure_set (element_id, source_pk, ordering_unit_code, procedure_type,insert_ts)
values
(_element_id, _max_char_pk, 'UR1L', 'TT', now())
returning radiology_procedure_set_id into _radiology_procedure_set_id;

insert into patient_data.element_significance (element_id, specialty_id, significance_id) values 
(_element_id, 1, 1);

_max_int_pk := _max_int_pk + 1;

insert into patient_data.radiology_procedure (radiology_procedure_set_id, procedure_code, procedure_name, source_pk) values 
(_radiology_procedure_set_id, 'JN4BD', 'VARTALON VARJOAINE-TT', _max_int_pk);


END $$;


