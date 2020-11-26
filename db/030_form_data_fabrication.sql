


DO $$

DECLARE

_user_id bigint;
_group_id bigint;
_form_id bigint;
_ts timestamp;
_surgery_date date := '2017-03-24';
_person_id bigint := -101;


_session_id bigint;
_answer_set_id bigint;

_form_field_id bigint;
_epic_numbers varchar[] := array['1','2','3','4|1','4|2','4|3','4|4','4|5','5','6|1','6|2','6|3','6|4','6|5', '7',
						'8|1','8|2','9','10','11','13|1','13|2','13|3','13|4','13|5','14','15','16|1','16|2','16|3','16|4','16|5'];
_epic_answers varchar[];

BEGIN



-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- EPIC
-- ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤


	
_user_id :=(select app_user_id from base.app_user where email = 'foo@zzxxyy.com');
_group_id := (select group_id from base.user_group where group_name = 'Urologinen potilas');
_form_id := (select wtf.get_form_id('Urologian potilaslomakkeet|EPIC', 'Urologinen potilas'));



------------------------------------
-- first EPIC 10 days before surgery
_ts := (_surgery_date - interval '10 day' - interval '13 hour');

insert into wtf.session (app_user_id, group_id, person_id, session_started_ts, session_ended_ts) values 
(_user_id, _group_id, _person_id, _ts, (_ts + interval '10 minute'))
returning session_id into _session_id;


insert into wtf.answer_set(session_id, form_id, open_ts, number, save_ts) values 
(_session_id, _form_id, (_ts), 1, (_ts + interval '10 minute'))
returning answer_set_id into _answer_set_id;


_epic_answers := array['Noin kerran viikossa', 'Tiputtelua toisinaan', 'En yhtään', 'Hyvin pieni ongelma', 'Ei ongelmaa', 'Ei ongelmaa',
					'Pieni ongelma', 'Hyvin pieni ongelma', 'Hyvin pieni ongelma', 'Ei ongelmaa', 'Ei ongelmaa', 'Ei ongelmaa', 'Ei ongelmaa', 'Ei ongelmaa',
					'Ei ongelmaa',
					'Huono', 'Kohtalainen', 'Riittävän jäykkä yhdyntään', 'Sain erektion ALLE PUOLESSA niistä kerroista, kun halusin',
					'Kohtalainen', 'Hyvin pieni ongelmaa', 'Ei ongelmaa', 'Ei ongelmaa', 'Ei ongelmaa', 'Ei ongelmaa',
					'Melko paljon', 'Ei', 'En ole kokeillut', 'En ole kokeillut', 'En ole kokeillut', 'En ole kokeillut', 'En ole kokeillut'];

-- insert answers
FOR i in 1..array_length(_epic_numbers, 1) loop

	_form_field_id := (SELECT wtf.get_form_field_id(_form_id, _epic_numbers[i]));
	
	
	insert into wtf.answer (form_field_id , choice_id, answer_set_id) values 
	(_form_field_id, (select wtf.get_choice_id(_form_field_id, _epic_answers[i])),
	_answer_set_id);

end loop;


--------------------------------------
-- second EPIC 13 weeks after surgery
_ts := (_surgery_date + interval '13 week' - interval '10 hour');

insert into wtf.session (app_user_id, group_id, person_id, session_started_ts, session_ended_ts) values 
(_user_id, _group_id, _person_id, _ts, (_ts + interval '10 minute'))
returning session_id into _session_id;

insert into wtf.answer_set(session_id, form_id, open_ts, number, save_ts) values 
(_session_id, _form_id, (_ts), 1, (_ts + interval '10 minute'))
returning answer_set_id into _answer_set_id;


_epic_answers := array['Noin kerran päivässä','Tiputtelua toistuvasti','Kaksi vuorokaudessa','Pieni ongelma',
				'Pieni ongelma','Ei ongelmaa','Hyvin pieni ongelma','Suuri ongelma',
				'Kohtalainen ongelma','Hyvin pieni ongelma','Hyvin pieni ongelma','Ei ongelmaa',
				'Ei ongelmaa','Pieni ongelma','Hyvin pieni ongelma','Hyvin huonosta olemattomaan',
				'Hyvin huonosta olemattomaan','Riittämättömän jäykkä mihinkään seksuaaliseen toimintaan',
				'Sain erektion ALLE PUOLESSA niistä kerroista, kun halusin','Erittäin huono',
				'Kohtalainen ongelma','Ei ongelmaa','Ei ongelmaa','Hyvin pieni ongelma',
				'Pieni ongelma','Pieni ongelma','Vähän','Ei',
				'En ole kokeillut','En ole kokeillut','En ole kokeillut','En ole kokeillut',
				'En ole kokeillut'];


-- insert answers
FOR i in 1..array_length(_epic_numbers, 1) loop

	_form_field_id := (SELECT wtf.get_form_field_id(_form_id, _epic_numbers[i]));
	
	insert into wtf.answer (form_field_id , choice_id, answer_set_id) values 
	(_form_field_id, (select wtf.get_choice_id(_form_field_id, _epic_answers[i])),
	_answer_set_id);

end loop;

-------------------------------------
-- third EPIC one year after surgery
_ts := (_surgery_date + interval '58 week' - interval '9 hour');

insert into wtf.session (app_user_id, group_id, person_id, session_started_ts, session_ended_ts) values 
(_user_id, _group_id, _person_id, _ts, (_ts + interval '10 minute'))
returning session_id into _session_id;


insert into wtf.answer_set(session_id, form_id, open_ts, number, save_ts) values 
(_session_id, _form_id, (_ts), 1, (_ts + interval '10 minute'))
returning answer_set_id into _answer_set_id;


_epic_answers := array['Useammin kuin kerran viikossa','Tiputtelua toistuvasti','En yhtään','Pieni ongelma',
				'Ei ongelmaa','Ei ongelmaa','Pieni ongelma','Hyvin pieni ongelma',
				'Hyvin pieni ongelma','Ei ongelmaa','Ei ongelmaa','Ei ongelmaa',
				'Ei ongelmaa','Ei ongelmaa','Ei ongelmaa','Hyvä',
				'Hyvä','Riittävän jäykkä yhdyntään','Sain erektion YLI PUOLESSA niistä kerroista, kun halusin','Hyvä',
				'Hyvin pieni ongelma','Ei ongelmaa','Ei ongelmaa','Ei ongelmaa',
				'Ei ongelmaa','Ei ongelmaa','Melko paljon','Kyllä',
				'Auttoi ja käytän joskus','En ole kokeillut','En ole kokeillut','En ole kokeillut',
				'En ole kokeillut'];

-- insert answers
FOR i in 1..array_length(_epic_numbers, 1) loop

	_form_field_id := (SELECT wtf.get_form_field_id(_form_id, _epic_numbers[i]));
	
	insert into wtf.answer (form_field_id , choice_id, answer_set_id) values
	(_form_field_id, (select wtf.get_choice_id(_form_field_id, _epic_answers[i])),
	_answer_set_id);

end loop;



END $$;



