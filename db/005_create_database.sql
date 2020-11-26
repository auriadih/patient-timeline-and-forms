--
-- PostgreSQL database dump
--

-- Dumped from database version 11.10
-- Dumped by pg_dump version 11.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: base; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA base;


--
-- Name: SCHEMA base; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA base IS 'Objects that are common for the timeline (patient_data) and forms (wtf),
such as users, groups, features and persons.';


--
-- Name: func; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA func;


--
-- Name: SCHEMA func; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA func IS 'General utility functions';


--
-- Name: mining; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mining;


--
-- Name: SCHEMA mining; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mining IS 'Data that is mined from the forms and shown on the patient timeline';


--
-- Name: patient_data; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA patient_data;


--
-- Name: SCHEMA patient_data; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA patient_data IS 'Objects related to the patient timeline';


--
-- Name: wtf; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA wtf;


--
-- Name: SCHEMA wtf; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA wtf IS 'Objects related to the dynamic forms';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: get_feature_access(bigint[]); Type: FUNCTION; Schema: base; Owner: -
--

CREATE FUNCTION base.get_feature_access(_group_id bigint[]) RETURNS TABLE(feature_id bigint, feature_name character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

	if ( _group_id is null or array_length(_group_id,1) = 0 ) then
		return query select null::bigint as feature_id, null::varchar as feature_name limit 0;
	else 
		return query
		-- a union of all features the group_id's together have access to 
		select distinct f.feature_id, f.name as feature_name
		from base.feature as f
		inner join base.group_feature_access as gfa on f.feature_id = gfa.feature_id
			and gfa.group_id = ANY(_group_id)

		union
		-- Get the features that the recursive parent groups of the given group_id's
		-- have access to. Groups automatically inherit all feature access from their parent groups.
		select distinct t.feature_id, t.feature_name
		from base.get_feature_access(
			(select array_agg(gm.group_id)
			from base.user_group as g
			inner join base.member as m on g.group_id = m.member_id and m.member_type = 'group'
			left outer join base.group_membership as gm on m.member_id = gm.member_id
			where g.group_id = ANY(_group_id)))
		as t;
	end if;

END;
$$;


--
-- Name: FUNCTION get_feature_access(_group_id bigint[]); Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON FUNCTION base.get_feature_access(_group_id bigint[]) IS 'Returns the features that the group_id''s in array _group_id have access to.
The returned result is a union of all the features that any of the given groups
or their recursive parent groups have access to.
Available features are listed in the base.feature table.

Parameters:

_group_id: An array of user group id''s whose feature access needs to be retrieved 

Returns records with fields:

feature_id: The id''s of the features that any of the groups has access to

feature_name: The names of the features that any of the groups has access to';


--
-- Name: get_feature_access(bigint); Type: FUNCTION; Schema: base; Owner: -
--

CREATE FUNCTION base.get_feature_access(_group_id bigint) RETURNS TABLE(feature_id bigint, feature_name character varying)
    LANGUAGE plpgsql
    AS $$

DECLARE

BEGIN
	if (_group_id is null) then
		return query select null::bigint as feature_id, null::varchar as feature_name limit 0;
	else
		return query select t.feature_id, t.feature_name from base.get_feature_access(array[_group_id]) as t;
	end if;
END;
$$;


--
-- Name: FUNCTION get_feature_access(_group_id bigint); Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON FUNCTION base.get_feature_access(_group_id bigint) IS 'Returns the features that the given _group_id has access to.
The returned result is a union of all the features that the given group
or its recursive parent group has access to.
Available features are listed in the base.feature table.

Parameters:

_group_id: The id of the user group whose feature access needs to be retrieved 

Returns records with fields:

feature_id: The id''s of the features the group has access to

feature_name: The names of the features the group has access to';


--
-- Name: insert_group(text, text); Type: FUNCTION; Schema: base; Owner: -
--

CREATE FUNCTION base.insert_group(_group_name text, _parent_group_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
_group_id int default null;
_parent_group_id int default null;

BEGIN
	
	if (_group_name is null) then
		raise EXCEPTION 'Group name cannot be null';
	else
		_group_id := (select group_id from base.user_group where group_name = _group_name);
		if (_group_id is null) then
			
			insert into base.user_group (group_id, group_name) values
				((select base.insert_member('group')), _group_name)
					returning group_id into _group_id;
		end if;
	end if;
	 
	if (_parent_group_name is not null) then
		
		_parent_group_id := (select group_id from base.user_group
			where group_name = _parent_group_name);

		
		if (_parent_group_id is null) then
			raise EXCEPTION 'The given parent group % does not exist', _parent_group_name;
		else

			insert into base.group_membership(group_id, member_id,
				valid_since, valid_until, valid, insert_ts, update_ts)
				values (_parent_group_id, _group_id, now(), null, true, now(), null)
				on conflict on constraint group_membership_pk
				do update set valid = true,
					valid_since =
					(case when group_membership.valid_until is not null
					then now()
					else group_membership.valid_since end),
					valid_until = null, update_ts = now();
		end if;
	end if;
END;

$$;


--
-- Name: FUNCTION insert_group(_group_name text, _parent_group_name text); Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON FUNCTION base.insert_group(_group_name text, _parent_group_name text) IS 'Inserts the given group to the user_group table.
Sets it as a subgroup of the given parent group.
If either group already exists, does not add a duplicate
but uses the existing group.

Parameters:

_ group_name: The name of the new group

_parent_group_name: The parent of the new group';


--
-- Name: insert_member(text); Type: FUNCTION; Schema: base; Owner: -
--

CREATE FUNCTION base.insert_member(_member_type text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
_member_id bigint default null;

BEGIN
	if (_member_type not in ('group', 'user')) then
		raise exception 'Allowed member types are "user" and "group"';
	else
		insert into base.member (member_type) values (_member_type)
			returning member_id into _member_id;
	end if;

	return _member_id;
END;

$$;


--
-- Name: FUNCTION insert_member(_member_type text); Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON FUNCTION base.insert_member(_member_type text) IS 'Inserts a row of the given type (user or group) into the member table.
The table group_membership connects members (users or groups) to groups.

Parameters:

_member_type: varchar with two options: "group" or "user"

Returns: the auto-generated member.member_id.';


--
-- Name: insert_person(text); Type: FUNCTION; Schema: base; Owner: -
--

CREATE FUNCTION base.insert_person(_henkilotunnus text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE

_person_id bigint;
_birth_date date;
_henkilotunnus_upper text;

BEGIN

	-- transform _henkilotunnus to uppercase (because in Finland is always is, thus case has no significance)
	_henkilotunnus_upper := upper(_henkilotunnus);

	-- does person with the given henkilotunnus already exist?
	_person_id := (select person_id from base.person
	where henkilotunnus = _henkilotunnus_upper);


	-- if person does not exist yet
	if (_person_id is null) THEN

		-- if the given henkilotunnus is valid
		if ( func.henkilotunnus_valid(_henkilotunnus_upper) ) THEN
		
			-- extract birth date from _henkilotunnus
			_birth_date := (concat(
				case when substr(_henkilotunnus_upper, 7,1)='+' then '18'
				when substr(_henkilotunnus_upper, 7,1)='-' then '19'
				else '20' end,
				substr(_henkilotunnus_upper, 5,2), '-',
				substr(_henkilotunnus_upper, 3,2), '-',
				substr(_henkilotunnus_upper, 1,2)));

			-- insert into person table
			insert into base.person (henkilotunnus, birth_date)
			values (_henkilotunnus_upper, _birth_date)
			returning person_id into _person_id;
		ELSE
			_person_id := null;
		END IF;

	END IF;
	
	return _person_id;

END;
$$;


--
-- Name: FUNCTION insert_person(_henkilotunnus text); Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON FUNCTION base.insert_person(_henkilotunnus text) IS 'Inserts the person with the given Finnish social security number (henkilotunnus)
to the base.person table, if the person does not exist yet.
Returns the person_id.
Checks the validity of the format of the henkilotunnus
before inserting.

Parameters:

_henkilotunnus: varchar containing a valid Finnish social security number (= henkilotunnus in Finnish)

Returns: the auto-increment base.person.person_id (regardless of whether the person
was newly created or existed previously)';


--
-- Name: insert_user(text, text, text, text, text); Type: FUNCTION; Schema: base; Owner: -
--

CREATE FUNCTION base.insert_user(_username text, _first_name text, _last_name text, _email text, _password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	insert into base.app_user (app_user_id, username, first_name, last_name, email, password) values
		((select base.insert_member('user')), _username, _first_name, _last_name, _email, _password);

END;
$$;


--
-- Name: FUNCTION insert_user(_username text, _first_name text, _last_name text, _email text, _password text); Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON FUNCTION base.insert_user(_username text, _first_name text, _last_name text, _email text, _password text) IS 'Inserts a user to the app_user table.
In the process, generates a member_id corresponding to the new user.
Depending on the software configuration and the authentication method,
a password may or may not be necessary for users.
The email is important, because it must be unique
and it is used as an identifying attribute in some other functions
such as join_user_to_group(_email, _group_name)

Parameters:

_username: A username to be used for logging in. Either Microsoft AD name or other.

_first_name: First name

_last_name: Last name

_email: Email. Must be unique accross base.app_user.email column

_password: Password for login. Depending on the login method, this may be irrelevant.';


--
-- Name: join_user_to_group(text, text); Type: FUNCTION; Schema: base; Owner: -
--

CREATE FUNCTION base.join_user_to_group(_email text, _group_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
_user_id int default null;
_group_id int default null;


BEGIN

	if (_email is null or _group_name is null ) then
		raise EXCEPTION 'Both email and group name must be provided';
	else
		
		_user_id := (select app_user_id from base.app_user where email = _email);
		_group_id := (select group_id from base.user_group where group_name = _group_name);

		if (_user_id is null or _group_id is null) then
			raise EXCEPTION 'The given email or group name doesn''t exist.';
		else
			insert into base.group_membership(group_id, member_id,
				valid_since, valid_until, valid,
				insert_ts, update_ts)
				values (_group_id, _user_id, now(), null, true, now(), null)
				on conflict on constraint group_membership_pk
				do update set valid = true,
					valid_since = (case when group_membership.valid_until is not null
					then now()
					else group_membership.valid_since end),
					valid_until = null, update_ts = now();
		end if;
	end if;

END;

$$;


--
-- Name: FUNCTION join_user_to_group(_email text, _group_name text); Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON FUNCTION base.join_user_to_group(_email text, _group_name text) IS 'Joins the given user to the given group.
Here, the user is identified by email.

Parameters:

_email: the email that uniquely identifies the base.app_user

_group_name: the group that the user should be joined to';


--
-- Name: cast_to_boolean(text); Type: FUNCTION; Schema: func; Owner: -
--

CREATE FUNCTION func.cast_to_boolean(_input text) RETURNS boolean
    LANGUAGE plpgsql COST 1
    AS $$
DECLARE

_output boolean;

BEGIN
	IF (lower(btrim(_input)) in ('k', 'kyllä', 'kylla', '1', 'true', 't', 'yes', 'y', 'not 0', 'not false')) THEN
		_output := true;
	elsif (lower(btrim(_input)) in ('e', 'ei', '0', 'false', 'f', 'no', 'n', 'not 1', 'not true')) THEN
		_output = false;
	else _output = null;	
END IF;
	return _output;
END;

$$;


--
-- Name: FUNCTION cast_to_boolean(_input text); Type: COMMENT; Schema: func; Owner: -
--

COMMENT ON FUNCTION func.cast_to_boolean(_input text) IS 'Casts the input string to boolean.
If not possible to interpret as boolean, returns null::boolean.

Parameters:

_input: a varchar that could be interpreted as a boolean

Returns: a boolean interpretation of the given varchar.
	if the varchar is uninterpretable, returns null.';


--
-- Name: get_data_type(anyelement, name); Type: FUNCTION; Schema: func; Owner: -
--

CREATE FUNCTION func.get_data_type(_table_name anyelement, _column_name name) RETURNS SETOF text
    LANGUAGE plpgsql
    AS $$
DECLARE
   _column_name text := _column_name;
BEGIN
   RETURN QUERY EXECUTE format('
      SELECT pg_typeof('||_column_name||')::TEXT from %s limit 1'
      , pg_typeof(_table_name));
 END
$$;


--
-- Name: get_precision(oid, integer); Type: FUNCTION; Schema: func; Owner: -
--

CREATE FUNCTION func.get_precision(_attrelid oid, _attnum integer) RETURNS integer
    LANGUAGE sql
    AS $$
SELECT
   CASE atttypid
         WHEN 21 /*int2*/ THEN 16
         WHEN 23 /*int4*/ THEN 32
         WHEN 20 /*int8*/ THEN 64
         WHEN 1700 /*numeric*/ THEN
              CASE WHEN atttypmod = -1
                   THEN null
                   ELSE ((atttypmod - 4) >> 16) & 65535     -- calculate the precision
                   END
         WHEN 700 /*float4*/ THEN 24 /*FLT_MANT_DIG*/
         WHEN 701 /*float8*/ THEN 53 /*DBL_MANT_DIG*/
         ELSE null
  END   AS numeric_precision
  from pg_catalog.pg_attribute
 where attrelid = _attrelid
	and attnum = _attnum;
$$;


--
-- Name: get_scale(oid, integer); Type: FUNCTION; Schema: func; Owner: -
--

CREATE FUNCTION func.get_scale(_attrelid oid, _attnum integer) RETURNS integer
    LANGUAGE sql
    AS $$
SELECT
  CASE 
    WHEN atttypid IN (21, 23, 20) THEN 0
    WHEN atttypid IN (1700) THEN            
        CASE 
            WHEN atttypmod = -1 THEN null       
            ELSE (atttypmod - 4) & 65535            -- calculate the scale  
        END
       ELSE null
  END AS numeric_scale
  from pg_catalog.pg_attribute
 where attrelid = _attrelid
	and attnum = _attnum;
$$;


--
-- Name: get_scale_and_precision(oid, integer); Type: FUNCTION; Schema: func; Owner: -
--

CREATE FUNCTION func.get_scale_and_precision(_attrelid oid, _attnum integer, OUT numeric_precision integer, OUT numeric_scale integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
BEGIN
return query SELECT
  CASE atttypid
         WHEN 21 /*int2*/ THEN 16
         WHEN 23 /*int4*/ THEN 32
         WHEN 20 /*int8*/ THEN 64
         WHEN 1700 /*numeric*/ THEN
              CASE WHEN atttypmod = -1
                   THEN null
                   ELSE ((atttypmod - 4) >> 16) & 65535     -- calculate the precision
                   END
         WHEN 700 /*float4*/ THEN 24 /*FLT_MANT_DIG*/
         WHEN 701 /*float8*/ THEN 53 /*DBL_MANT_DIG*/
         ELSE null
  END   AS numeric_precision,
  CASE 
    WHEN atttypid IN (21, 23, 20) THEN 0
    WHEN atttypid IN (1700) THEN            
        CASE 
            WHEN atttypmod = -1 THEN null       
            ELSE (atttypmod - 4) & 65535            -- calculate the scale  
        END
       ELSE null
  END AS numeric_scale
  from pg_catalog.pg_attribute
 where attrelid = _attrelid
	and attnum = _attnum;
END
$$;


--
-- Name: henkilotunnus_valid(character varying); Type: FUNCTION; Schema: func; Owner: -
--

CREATE FUNCTION func.henkilotunnus_valid(_henkilotunnus character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE

_henkilotunnus_upper character varying;
_tarkistusmerkki varchar;
_numerot integer;
_jaannos integer;
_vuosi varchar;
_jaannokset int[];
_merkit varchar[];

BEGIN

	_jaannokset := array[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
		21,22,23,24,25,26,27,28,29,30];
	_merkit := array['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','H','J','K',
		'L','M','N','P','R','S','T','U','V','W','X','Y'];

	_henkilotunnus_upper := upper(_henkilotunnus);

	IF (_henkilotunnus_upper !~ '^(0[1-9]|[12]\d|3[01])(0[1-9]|1[0-2])([5-9]\d\+|\d\d-|[01]\dA)\d{3}[\dA-Z]$') THEN
		RETURN false;
	ELSE
		
		_tarkistusmerkki := RIGHT(_henkilotunnus_upper,1);
		_numerot := to_number(LEFT(_henkilotunnus_upper,6) || SUBSTR(_henkilotunnus_upper, 8, 3), '999999999');
		_jaannos := _numerot % 31;
	
		IF (_tarkistusmerkki = _merkit[array_position(_jaannokset, _jaannos)]) THEN
			RETURN true;
		ELSE
			RETURN false;
		END IF;
	END IF;
		
			
END;
$_$;


--
-- Name: FUNCTION henkilotunnus_valid(_henkilotunnus character varying); Type: COMMENT; Schema: func; Owner: -
--

COMMENT ON FUNCTION func.henkilotunnus_valid(_henkilotunnus character varying) IS 'Checks the given Finnish social security number (henkilotunnus)
and determines that its form is valid.

Parameters:

_henkilotunnus: A Finnish social security number

Returns: boolean for whether the social security number is valid or not.';


--
-- Name: html_div(text, text[], text[]); Type: FUNCTION; Schema: func; Owner: -
--

CREATE FUNCTION func.html_div(divname text, data_rows text[], headers text[] DEFAULT NULL::text[]) RETURNS text
    LANGUAGE plpgsql COST 2
    AS $$
declare
result text;
row text[];

begin

	-- set div class attribute
	result := concat('<div class="', divname, '"><table>');

	-- make a header row out of the headers parameter
	if headers is not null then
		result := concat(result, func.html_tr(headers, true));
	end if;

	if (array_length(data_rows, 2) is not null) then

		-- make a regular table row out of each element (i.e. sub-array) in the data_rows array
		foreach row SLICE 1 in ARRAY data_rows
		loop
			result := concat(result, func.html_tr(row));
		end loop;
	end if;	
	result := concat(result, '</table></div>');
	return result;
end;
$$;


--
-- Name: FUNCTION html_div(divname text, data_rows text[], headers text[]); Type: COMMENT; Schema: func; Owner: -
--

COMMENT ON FUNCTION func.html_div(divname text, data_rows text[], headers text[]) IS 'Formats the input data as a HTML div containing one HTML table.

Parameters:

divname:  value of the class attribute of the HTML div

headers: the header row cells

data_rows: array of arrays, each sub-array is a row of cells

Returns: text that is a html div representation of the input parameters as a table';


--
-- Name: html_tr(text[], boolean); Type: FUNCTION; Schema: func; Owner: -
--

CREATE FUNCTION func.html_tr(row_data text[], is_header boolean DEFAULT false) RETURNS text
    LANGUAGE plpgsql COST 1
    AS $$
/*
 * Formats the input data as a HTML table row.
 * Each element in the row_data array is considered a table cell.
 * If the row is meant to become a header row, is_header should be set to true.
 */

declare
result text;
-- regular table cell
start_tag varchar default '<td>';
end_tag varchar default '</td>';

begin

	if is_header then
		-- header row cell
		start_tag := '<th>';
		end_tag := '</th>';
	end if;

	-- the elements in the row_data become cells on the row
	result := concat('<tr>', start_tag,  array_to_string(row_data, concat(end_tag, start_tag), ''), end_tag, '</tr>');
		return result;
end;
$$;


--
-- Name: FUNCTION html_tr(row_data text[], is_header boolean); Type: COMMENT; Schema: func; Owner: -
--

COMMENT ON FUNCTION func.html_tr(row_data text[], is_header boolean) IS 'Formats the input data as a HTML table row.
Each element in the row_data array is considered a table cell.
If the row is meant to become a header row, is_header should be set to true.

Parameters:

row_data: array containing the cells for the HTML table row

is_header: if the row is meant to become a header row, this should be set to true

Returns: text representing a HTML table row';


--
-- Name: simplify_characters(text); Type: FUNCTION; Schema: func; Owner: -
--

CREATE FUNCTION func.simplify_characters(_input text) RETURNS text
    LANGUAGE plpgsql COST 1
    AS $$

DECLARE

_output text;

BEGIN
	_output := lower(_input);
	-- accents removed from common Finnish accented characters
	_output := replace(_output, 'ä', 'a');
	_output := replace(_output, 'ö', 'o');
	_output := replace(_output, 'Å', 'a');
	-- special characters replaced with underscore
	_output := regexp_replace(_output, '[,:?|/\s().-]', '_', 'g');
	-- multiple underscores replaced with one
	_output := regexp_replace(_output, '__+', '_', 'g');
	_output := btrim(_output, '_');

	-- shortens the result to 63 characters
	_output := substring(_output, length(_output)-62, 63);

	return _output;
END;

$$;


--
-- Name: FUNCTION simplify_characters(_input text); Type: COMMENT; Schema: func; Owner: -
--

COMMENT ON FUNCTION func.simplify_characters(_input text) IS 'Utility function for replacing typical Finnish special characters 
with other characters that are more suitable for use in column names.

Parameters:

_input: text to be simplified

Returns: simplified version of _input text';


--
-- Name: get_epic_scores(); Type: FUNCTION; Schema: mining; Owner: -
--

CREATE FUNCTION mining.get_epic_scores(OUT person_id bigint, OUT open_ts timestamp without time zone, OUT subsection_name character varying, OUT average_points double precision) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
declare

BEGIN

	return query select a.person_id, a.open_ts, e.subsection_name, avg(a.choice_points) as average_points
		from mining.v_epic_answers a
		inner join mining.epic_scoring as e on a.field_number_nesting_order = e.field_number_nesting_order
		where  a.field_number_nesting_order[1] not in (5,14,15,16)
		group by a.person_id, a.open_ts, e.subsection_name
		having count(*) >= max(subsection_required_count)
		order by a.open_ts, e.subsection_name;

END;

$$;


--
-- Name: FUNCTION get_epic_scores(OUT person_id bigint, OUT open_ts timestamp without time zone, OUT subsection_name character varying, OUT average_points double precision); Type: COMMENT; Schema: mining; Owner: -
--

COMMENT ON FUNCTION mining.get_epic_scores(OUT person_id bigint, OUT open_ts timestamp without time zone, OUT subsection_name character varying, OUT average_points double precision) IS 'Returns the summarized EPIC form scores for all persons.
Calculates the scores based on mining.epic_scoring.
Returns the average score per subsection,
if the person has answered enough many question in the subsection.

Parameters: none

Returns records with fields:

person_id: The primary key of the base.person

open_ts: The open_ts of the EPIC form of the person (doubling as answer_set_id here)

subsection_name: Name of EPIC form subsection

average_points: Average of points for the person in the subsection';


--
-- Name: get_default_significance(); Type: FUNCTION; Schema: patient_data; Owner: -
--

CREATE FUNCTION patient_data.get_default_significance() RETURNS integer
    LANGUAGE plpgsql COST 1
    AS $$

declare _result integer;

begin

	_result := (select s.significance_id
		from patient_data.significance as s
		where s.significance = 'Muu');

	return _result;
end;
$$;


--
-- Name: FUNCTION get_default_significance(); Type: COMMENT; Schema: patient_data; Owner: -
--

COMMENT ON FUNCTION patient_data.get_default_significance() IS 'Returns the significance_id of the default significance from patient_data.significance.
The value significance ="Muu" means "Other" in Finnish
and is the default for the timeline UI elements.

Returns: the significance_id of the significance "Muu"';


--
-- Name: aggregate_conditions(bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.aggregate_conditions(_form_field_id bigint, OUT conditional_form_field_id bigint, OUT determining_form_id bigint, OUT determining_form_fields_and_choices json) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
declare

begin
	
return query

	-- choices aggregated by determining form_field
	with cte as ( -- the conditions that the visibility of _form_field_id depends on
		select  cc.conditional_form_field_id, -- same as _form_field_id, i.e. whose visibility is conditional
			cc.determining_form_id, -- the determining form
			cc.determining_form_field_id, -- the determining field on the determining form
			array_agg(cc.determining_choice_id) as choice_ids -- the determining choices aggregated to array
		from wtf.v_component_conditions as cc
		where cc.conditional_form_field_id = _form_field_id
		group by cc.conditional_form_field_id, cc.determining_form_id, cc.determining_form_field_id
)
-- determining form_fields and their choices aggregated by determining_form
select cte.conditional_form_field_id,
	cte.determining_form_id,
	json_object_agg(cte.determining_form_field_id,
		cte.choice_ids)
from cte
group by  cte.conditional_form_field_id,
	cte.determining_form_id;

END;

$$;


--
-- Name: FUNCTION aggregate_conditions(_form_field_id bigint, OUT conditional_form_field_id bigint, OUT determining_form_id bigint, OUT determining_form_fields_and_choices json); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.aggregate_conditions(_form_field_id bigint, OUT conditional_form_field_id bigint, OUT determining_form_id bigint, OUT determining_form_fields_and_choices json) IS 'For a given form_field, returns the conditionality associated with displaying the field.
Returns all forms that house fields that determine the visibility of this field.
Also returns all fields on those forms and all choices in those fields that determine
the visibility of this field.


Parameters:

_form_field_id: The primary key of the wtf.form_field

_person_id: The primary key of the base.person

Returns records with fields:

conditional_form_field_id: the same as input parameter _form_field_id

determining_form_id: the id of the form that determines the visibility of the _form_field_id-denoted field

determining_form_fields_and_choices: json structure containing a list of fields and their respective choice lists
on determining_form_id that determine the visibility of the _form_field_id-denoted field
';


--
-- Name: allow_access_to_own_root_forms(bigint, boolean, boolean, boolean); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.allow_access_to_own_root_forms(_group_id bigint, _view_privilege boolean DEFAULT false, _insert_privilege boolean DEFAULT false, _modify_privilege boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
_root_form_id int default null;

BEGIN

for _root_form_id in select distinct form_id
	from wtf.v_forms
	where owner_group_id = _group_id
	and is_root_form
	LOOP

		perform wtf.set_group_form_access( _group_id,
			_root_form_id,
			_view_privilege,
			_insert_privilege,
			_modify_privilege);

	END LOOP;

END;

$$;


--
-- Name: FUNCTION allow_access_to_own_root_forms(_group_id bigint, _view_privilege boolean, _insert_privilege boolean, _modify_privilege boolean); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.allow_access_to_own_root_forms(_group_id bigint, _view_privilege boolean, _insert_privilege boolean, _modify_privilege boolean) IS 'Sets the given access and modification privileges for the given group
to the root forms owned by the group.

Parameters:

_group_id: The group_id of the user_group whose privileges are being set

_view_privilege: Boolean for whether the group can view answers on the form

_insert_privilege: Boolean for whether the group can insert answers to the form

_modify_privilege: Boolean for whether the group can edit existing answers on the form';


--
-- Name: answer_exists(bigint, boolean, bigint, bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.answer_exists(_person_id bigint, _negation boolean, _form_field_id bigint, _choice_id bigint DEFAULT NULL::bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
_answer_id bigint;
_result boolean;


BEGIN

	_answer_id := (select a.answer_id
		from wtf.answer as a
		inner join wtf.answer_set as ans on a.answer_set_id = ans.answer_set_id
		inner join wtf.session as s on ans.session_id = s.session_id
		where s.person_id = _person_id
		and a.form_field_id = _form_field_id
		and (a.choice_id = _choice_id or _choice_id is null)
		limit 1
		);
	-- no answer is found if _negation, _form_field_id and _choice_id are null

	
	if (_answer_id is not null and _negation) THEN
		_result := false;
	
	elsif (_answer_id is null and not _negation) THEN
		_result := false;
	else
		_result := true; -- if all parameters are null, or all except _person_id are null, returns this as well
	end if;
		

	return _result;

END;
$$;


--
-- Name: FUNCTION answer_exists(_person_id bigint, _negation boolean, _form_field_id bigint, _choice_id bigint); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.answer_exists(_person_id bigint, _negation boolean, _form_field_id bigint, _choice_id bigint) IS 'Does a specific answer or any answer exist for the given person in the given form_field.

Parameters:

_person_id: The primary key of the base.person

_negation: shoud the final answer returned by the function be original or negated.
If this is confusing, set _negation = false. This is probably a remnant of old code
that should be removed.

_form_field_id: The form_field for which the answer is looked for

_choice_id: If this parameter is non-null, an answer is considered to exists only if
this specific choice is selected as the answer.
If this parameter is null, any answer for the form_field is accepted as an existing answer.

Returns: If _negation = false, returns true when the answer exists, false otherwise.
	If _negation = true, returns false when the answer exists, true otherwise.';


--
-- Name: delete_answers(bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.delete_answers(_person_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
-- Deletes all answers and answer sets belonging to the given _person_id.
declare
 
BEGIN

-- delete answers
delete from  wtf.answer as a
	using wtf.answer_set as ans
	inner join wtf.session as s on ans.session_id = s.session_id
	where ans.answer_set_id = a.answer_set_id
	and s.person_id = _person_id;

-- delete answer_sets
delete from  wtf.answer_set as ans
	using wtf.session as s
	where ans.session_id = s.session_id
	and s.person_id = _person_id;

END;

$$;


--
-- Name: FUNCTION delete_answers(_person_id bigint); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.delete_answers(_person_id bigint) IS 'This operation is not reversible! Use with caution.

Deletes all answers and answer_sets for the given person.
This function is overloaded.
This version identifies the person by person_id.

Parameters:

_person_id: The primary key of the base.person';


--
-- Name: delete_answers(text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.delete_answers(_henkilotunnus text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
_person_id bigint;

BEGIN

	_person_id := (select person_id
		from base.person
		where henkilotunnus = _henkilotunnus);
	perform wtf.delete_answers(_person_id);
	
END;

$$;


--
-- Name: FUNCTION delete_answers(_henkilotunnus text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.delete_answers(_henkilotunnus text) IS 'This operation is not reversible! Use with caution.

Deletes all answers and answer_sets for the given person.
This function is overloaded.
This version identifies the person by henkilotunnus.

Parameters:

_henkilotunnus: The base.person.henkilotunnus of the person
whose answers should be deleted';


--
-- Name: delete_form(bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.delete_form(_form_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
	
	delete from wtf.answer as a
	using wtf.answer_set as ans
	where a.answer_set_id = ans.answer_set_id
	and ans.form_id = _form_id;
	
	delete from wtf.answer_set where form_id = _form_id;
	
	delete from wtf.form_field_choice as ffc
	using wtf.form_field as ff
	where ffc.form_field_id = ff.form_field_id
	and ff.form_id = _form_id;
	
	delete from wtf.form_field where form_id = _form_id;
	
	delete from wtf.form where form_id = _form_id;


END;

$$;


--
-- Name: FUNCTION delete_form(_form_id bigint); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.delete_form(_form_id bigint) IS 'This operation is not reversible! Use with caution.

Deletes the form with the given form_id.
Before deleting the form, deletes all
answers, answer_sets, form_field_choices and form_fields
associated with the form.

Parameters:

_form_id: The primary key of the wtf.form row to be deleted';


--
-- Name: form_filled(bigint, bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.form_filled(_form_id bigint, _person_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE

_answer_set_id bigint;

BEGIN

	_answer_set_id := (select answer_set_id
		from wtf.answer_set as a
		inner join wtf.session as s on a.session_id = s.session_id
		where a.form_id = _form_id
		and s.person_id = _person_id
		and a.save_ts is not null
		limit 1);

		return (_answer_set_id is not null);
END;

$$;


--
-- Name: FUNCTION form_filled(_form_id bigint, _person_id bigint); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.form_filled(_form_id bigint, _person_id bigint) IS 'Has the given form been filled for the given person.

Parameters:

_form_id: The primary key of the wtf.form

_person_id: The primary key of the base.person

Returns: Boolean for whether the form has been filled or not';


--
-- Name: get_all_fields_to_show_aggregated(bigint, bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_all_fields_to_show_aggregated(_person_id bigint, _form_id bigint, OUT section_number integer, OUT form_field_id bigint, OUT field_id bigint, OUT field_long_name text, OUT field_number_nesting_order integer[], OUT data_type_name character varying, OUT field_type_name character varying, OUT field_is_required boolean, OUT is_event_ts_field boolean, OUT field_description character varying, OUT gui_element_type character varying, OUT gui_element_orientation character varying, OUT determining_form_fields_and_choices character varying, OUT show_field boolean) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
declare

-- The OUT field determining_form_fields_and_choices
-- contains a json object (cast as a varchar)
-- where names are form_field_ids and values are choice_ids.

BEGIN
	return query select distinct t1.section_number,
	t1.form_field_id,
	t1.field_id,
	t1.field_long_name,
	t1.field_number_nesting_order,
	t1.data_type_name,
	t1.field_type_name,
	t1.field_is_required,
	t1.is_event_ts_field,
	t1.field_description,
	t1.gui_element_type,
	t1.gui_element_orientation,
	-- necessary to cast as varchar to be able to use distinct in the query
	agg.determining_form_fields_and_choices::varchar,
	case when (t3.choice_id = t2.determining_choice_id -- an answer with the required choice exists
	or t3.choice_id is null and t2.determining_choice_id is null -- or (any answer is sufficient)
	or t2.determining_form_id = t1.form_id) -- the determining field will be filled after the form is rendered
		then true else false end as show_field
	
	-- form fields t1, where the field is the given _form
	from wtf.v_form_fields as t1
	left outer join wtf.v_component_conditions as t2 on t1.form_id = t2.conditional_form_id
		and t1.form_field_id = t2.conditional_form_field_id
		and t2.conditional_component_type = 'form_field'
	left outer join wtf.v_answers as t3 on t2.determining_form_field_id = t3.form_field_id
		and t2.conditional_form_id != t3.form_id
		and t3.person_id = _person_id
	-- trivial join condition, because the function only returns relevant rows, one field per row,
	-- so the join condition is effectively in the function call
	left outer join wtf.aggregate_conditions(t2.conditional_form_field_id) as agg on agg.determining_form_id = _form_id
	where t1.form_id = _form_id
	order by field_number_nesting_order;

	return;

END;

$$;


--
-- Name: FUNCTION get_all_fields_to_show_aggregated(_person_id bigint, _form_id bigint, OUT section_number integer, OUT form_field_id bigint, OUT field_id bigint, OUT field_long_name text, OUT field_number_nesting_order integer[], OUT data_type_name character varying, OUT field_type_name character varying, OUT field_is_required boolean, OUT is_event_ts_field boolean, OUT field_description character varying, OUT gui_element_type character varying, OUT gui_element_orientation character varying, OUT determining_form_fields_and_choices character varying, OUT show_field boolean); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_all_fields_to_show_aggregated(_person_id bigint, _form_id bigint, OUT section_number integer, OUT form_field_id bigint, OUT field_id bigint, OUT field_long_name text, OUT field_number_nesting_order integer[], OUT data_type_name character varying, OUT field_type_name character varying, OUT field_is_required boolean, OUT is_event_ts_field boolean, OUT field_description character varying, OUT gui_element_type character varying, OUT gui_element_orientation character varying, OUT determining_form_fields_and_choices character varying, OUT show_field boolean) IS 'Returns a list of form_fields that should be shown in the UI on the given form for the given person.
Returns all fields and indicates with boolean output parameter show_field
whether the field should be shown in light of existing answers for the person.
The fields may be shown or not shown on the form also depending on other answers
given on the same form. This type of conditions are in the return value determining_form_fields_and_choices,
which is a json cast as varchar.

Parameters: 

_person_id: The primary key of the base.person

_form_id: The primary key of the wtf.form

Returns records with fields:

section_number

form_field_id: describes the form_field. Most of the other output parameters are directly derivable from this
and are hence not explained in detail.

field_id
field_long_name
field_number_nesting_order
data_type_name
field_type_name
field_is_required
field_description
gui_element_type
gui_element_orientation

determining_form_fields_and_choices: json cast as varchar, where  names are form_field_ids and values are choice_ids
that determine the visibility of the field on this return row in this form

show_field: Boolean for whether the field should be shown in light of the person''s existing answers on other forms';


--
-- Name: get_choice_id(bigint, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_choice_id(_form_field_id bigint, _choice_name text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE

_choice_id bigint default null;

BEGIN

	
	_choice_id := (select c.choice_id
		from wtf.choice as c
		inner join wtf.form_field_choice as ffc
			on c.choice_id = ffc.choice_id
		where c.choice_name = _choice_name
		and ffc.form_field_id = _form_field_id);
	return _choice_id;

END;

$$;


--
-- Name: FUNCTION get_choice_id(_form_field_id bigint, _choice_name text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_choice_id(_form_field_id bigint, _choice_name text) IS 'Returns the choice_id of a choice based on the form_field_id it appears in and the choice_name.

Parameters:

_form_field_id: The primary key of the form_field

_choice_name: the name of the choice as found in wtf.choice.choice_name

Returns: the choice.choice_id';


--
-- Name: get_choice_id(text, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_choice_id(_choice_name text, _description text DEFAULT NULL::text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE

_choice_id bigint default null;

BEGIN

	
	_choice_id := (select choice_id from wtf.choice
		where choice_name = _choice_name
		and coalesce(description, '') = coalesce(_description, ''));
	return _choice_id;

END;

$$;


--
-- Name: FUNCTION get_choice_id(_choice_name text, _description text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_choice_id(_choice_name text, _description text) IS 'Returns the choice_id of a choice based on the choice_name and choice_description,
if it does not exist yet.

Parameters:

_choice_name: the name of the choice as found in wtf.choice.choice_name

_choice_description: the description of the choice as found in wtf.choice.choice_description

Returns: the choice.choice_id';


--
-- Name: get_choices_to_show(bigint, bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_choices_to_show(_person_id bigint, _form_field_id bigint, OUT choice_id bigint, OUT choice_name character varying, OUT choice_description character varying, OUT choice_number integer, OUT choice_identifier character varying, OUT choice_long_name text, OUT determining_form_field_id bigint, OUT determining_choice_id bigint) RETURNS SETOF record
    LANGUAGE plpgsql ROWS 5
    AS $$
DECLARE

BEGIN

	return query select
	t1.choice_id,
	t1.choice_name,
	t1.choice_description,
	t1.choice_number,
	t1.choice_identifier,
	t1.choice_long_name,
	t2.determining_form_field_id,
	t2.determining_choice_id
	from  wtf.v_form_field_choices as t1 -- all choices
	left outer join  wtf.v_component_conditions as t2 on 
 		t1.form_field_id = t2.conditional_form_field_id -- is this form_field listed as conditional?
 		and t2.conditional_component_type = 'form_field_choice' -- the conditionality concerns which choices to show in this form_field
 		and t2.conditional_choice_id = t1.choice_id -- this choice is meant to be shown only conditionally
	
	where t1.form_field_id = _form_field_id -- show only choices available for this form_field
	and t1.choice_id is not null -- this form field has at least some choices and is not a free-text field
	
	
	and  (wtf.answer_exists(_person_id, t2.determining_component_negated,
		t2.determining_form_field_id, t2.determining_choice_id) -- answer exists for this person
		or t2.determining_form_id = t1.form_id)  --  or another answer on the current form will determine the visibility of this choice
	order by t1.choice_number;


END;

$$;


--
-- Name: FUNCTION get_choices_to_show(_person_id bigint, _form_field_id bigint, OUT choice_id bigint, OUT choice_name character varying, OUT choice_description character varying, OUT choice_number integer, OUT choice_identifier character varying, OUT choice_long_name text, OUT determining_form_field_id bigint, OUT determining_choice_id bigint); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_choices_to_show(_person_id bigint, _form_field_id bigint, OUT choice_id bigint, OUT choice_name character varying, OUT choice_description character varying, OUT choice_number integer, OUT choice_identifier character varying, OUT choice_long_name text, OUT determining_form_field_id bigint, OUT determining_choice_id bigint) IS 'Returns a list of choices that should be shown in the UI in the given form_field for the given person.
Returns only the choices that should be availble to the user
in light of existing answers for the person.

Some choices may be shown or not shown in the field also depending on other answers
given on the same form.
This type of conditions are in the return values determining_form_field_id and determining_choice_id.

Warning: If there are several determining_form_field_id''s and/or several determining_choice_id''s
for one conditional choice,
this function should be modified to look like get_all_fields_to_show_aggregated(),
in that it should only return one row per choice in all conditions, with determining form_fields and choices aggreagted
into one field as json.

Parameters: 

_person_id: The primary key of the base.person

_form_field_id: The primary key of the wtf.form_field

Returns records with fields:

choice_id: describes the choice. Most of the other output parameters are directly derivable from this
and are hence not explained in detail.
choice_name
choice_description
choice_number
choice_identifier
choice_long_name

determining_form_field_id: the form_field whose answer determines the visibility of this choice
determining_choice_id: the form_field_choice that determines the visibility of this choice';


--
-- Name: get_component_id(bigint, bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_component_id(_form_field_id bigint, _choice_id bigint DEFAULT NULL::bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$

DECLARE
_component_id bigint default null;

BEGIN
	
	if (_choice_id is not null) then
		_component_id := (select component_id from wtf.form_field_choice
			where form_field_id = _form_field_id
			and choice_id = _choice_id);
			if (_component_id is null) then
				raise exception 'Given choice % was not defined for given form_field %.',
				_choice_id,
				_form_field_id;
			end if;
		
	else
		_component_id := (select component_id from wtf.form_field
			where form_field_id = _form_field_id);
	end if;

	return _component_id;

END;

$$;


--
-- Name: FUNCTION get_component_id(_form_field_id bigint, _choice_id bigint); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_component_id(_form_field_id bigint, _choice_id bigint) IS 'Returns the component_id of the component.
If both parameters are given,
assumes the component to be a form_field_choice.
If only the first parameter is given,
assumes the component to be a form_field.

Parameters:

_form_field_id:  IF the component is a form_field, this is its form_field_id.
If the component is a form_field_choice, this is the form_field_id of the form_field
in which the form_field_choice is located.

_choice_id: If the component is a form_field_choice, this is its choice_id.
If the component is a form_field, this should be NULL.

Returns: wtf.component.component_id';


--
-- Name: get_field_lineage(bigint, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_field_lineage(_form_field_id bigint, _context_name text DEFAULT NULL::text) RETURNS text
    LANGUAGE plpgsql
    AS $$

DECLARE

_parent_form_field record;
_result text;
_parent_field_name text;
_context_id bigint default null;


BEGIN

	select parent.form_field_id, parent.component_id into _parent_form_field
		from wtf.form_field as child
		left outer join wtf.form_field as parent on child.parent_form_field_id = parent.form_field_id
		where child.form_field_id = _form_field_id;

	-- if this form_field has a parent
	if (_parent_form_field.form_field_id is not null) THEN

		if (_context_name is not null) THEN
			_context_id := (select context_id
				from wtf.context
				where context_name = _context_name);
			
			_parent_field_name := (select synonym_name
				from wtf.synonym
				where referred_id = _parent_form_field.component_id
				and referred_table = 'component'
				and context_id = _context_id);
			
		ELSE
			_parent_field_name := (select field_name
				from wtf.field as f
				inner join wtf.form_field as ff on f.field_id = ff.field_id
				where ff.form_field_id = _parent_form_field.form_field_id);
			
		END IF;

		-- recursively find the lineage of the parent field
		_result := (concat((select wtf.get_field_lineage(_parent_form_field.form_field_id, _context_name)), '|',
				_parent_field_name));

	END IF;
	
	_result := btrim(_result, '|');
	return _result;

END;
$$;


--
-- Name: FUNCTION get_field_lineage(_form_field_id bigint, _context_name text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_field_lineage(_form_field_id bigint, _context_name text) IS 'Returns the lineage of the specified form_field, with hierarchy levels separated by "|".
The lineage does not include the name of the given field itself, only its ancestors.
For example, the lineage of field "Please select the most appropriate answer:|How many times a week do you excercise?"
is "Please select the most appropriate answer:".

Parameters:

_form_field_id: The primary key of the form_field

_context_name: If the field names in the lineage should be returned as synonyms
from a specific context, the context_id is given here. If no context_id is given,
the field names will be returned as found in the field.field_name.

Returns: text containing all field names in the requested field''s ancestry,
concatenated together separated by "|"';


--
-- Name: get_field_number_lineage(bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_field_number_lineage(_form_field_id bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE

_parent_form_field_id bigint;
_result text;
_parent_field_number text;

BEGIN

	_parent_form_field_id := (select parent_form_field_id
		from wtf.form_field
		where form_field_id = _form_field_id);

	if (_parent_form_field_id is not null) then
		_parent_field_number := (select ff.number from wtf.field as f
		inner join wtf.form_field as ff on f.field_id = ff.field_id
			where ff.form_field_id = _parent_form_field_id);
			
		-- recursively find the field number lineage of the parent
		_result := (concat((select wtf.get_field_number_lineage(_parent_form_field_id)),
			'|', _parent_field_number));

	end if;
	_result := regexp_replace(_result, '^\|','');
	return _result;

END;

$$;


--
-- Name: FUNCTION get_field_number_lineage(_form_field_id bigint); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_field_number_lineage(_form_field_id bigint) IS 'Returns the lineage of the specified form_field in field numbers, with hierarchy levels separated by "|".
The lineage does not include the number of the given field itself, only its ancestors.
For example, the lineage of field "question 3|subquestion 1" is "question 3".

Parameters:

_form_field_id: The primary key of the form_field

Returns: text containing all field numbers in the requested field''s ancestry
concatenated together separated by "|"';


--
-- Name: get_form_field_id(bigint, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_form_field_id(_form_id bigint, _field_number_path text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$

DECLARE
_form_field_id bigint;
_number_parts text[];

BEGIN
	
	_number_parts := (select regexp_split_to_array(_field_number_path, '\|'));

	_form_field_id := (select form_field_id 
		from wtf.form_field as ff
		where ff.form_id = _form_id
		and regexp_split_to_array(concat_ws('|',
			wtf.get_field_number_lineage(ff.form_field_id),
			ff.number), '\|') = _number_parts);
	
	return _form_field_id;
	
END;

$$;


--
-- Name: FUNCTION get_form_field_id(_form_id bigint, _field_number_path text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_form_field_id(_form_id bigint, _field_number_path text) IS 'Returns the form_field_id of the form_field specified by the parameters.

Parameters:

_form_id: The form that the field is in

_field_number_path: The description of the field in field numbers.
For e.g. "question 3|subquestion 1",
the _field_number_path would be "3|1".

Returns: wtf.for_field.form_field_id';


--
-- Name: get_form_field_id(bigint, text, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_form_field_id(_form_id bigint, _field_path text, _field_number_path text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
_form_field_id bigint;
BEGIN
	_form_field_id := (select wtf.get_form_field_id(_form_id, _field_number_path));
	
	return _form_field_id;
	
END;

$$;


--
-- Name: FUNCTION get_form_field_id(_form_id bigint, _field_path text, _field_number_path text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_form_field_id(_form_id bigint, _field_path text, _field_number_path text) IS 'Returns the form_field_id of the form_field specified by the parameters.
Takes human-readable parameters specifying the field. 

This function is kept for backwards-compatibility.
Is is recommended to use
wtf.get_form_field_id(bigint, text) instead
because the parameter _field_number_path adequately
specifies a field on a form.

Parameters:

_form_id: The form that the field is in

_field_path: The complete path of field names specifying the field lineage on the form.
Fields can be arranged as sub-fields of other fields, and this is where the lineage is useful.
For hierarchical fields, the _field_path is the concatenation of the field names
starting from the top level of the hierarchy and ending in the child/leaf field.
The concatenated sections are separated with "|".
An example of such a _field_path would be
"Please select the most appropriate answer:|How many times a week do you excercise?",
which has two hierarchy levels.
For fields with only one hierarchy level, the _field_path is simply the name of the field alone.

_field_number_path: Similarly to _field_path, this is the lineage of the field but in field numbers,
not field names. Assuming the above example would be question 3 subquestion 1,
the _field_number_path would be "3|1".

Returns: wtf.for_field.form_field_id';


--
-- Name: get_form_field_id(text, text, text, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_form_field_id(_form_path text, _owner_group_name text, _field_path text, _field_number_path text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
_form_field_id bigint;
_form_id bigint;

BEGIN

	
	_form_id := (select wtf.get_form_id(_form_path, _owner_group_name));
	
	_form_field_id := (select wtf.get_form_field_id(_form_id,
		_field_path,
		_field_number_path));

	return _form_field_id;
	
END;

$$;


--
-- Name: FUNCTION get_form_field_id(_form_path text, _owner_group_name text, _field_path text, _field_number_path text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_form_field_id(_form_path text, _owner_group_name text, _field_path text, _field_number_path text) IS 'Returns the form_field_id of the form_field specified by the parameters.
Takes human-readable parameters.

Parameters:

_form_path: The complete path to the form, with form hierarchy levels separater with "|".
E.g. General questionnaires|Health questions|Eating habits. Here, Health questions is
the parent form of Eating habits.

_owner_group_name: The name of the user_group who owns the form

_field_path: The complete path of field names specifying the field lineage on the form.
Fields can be arranged as sub-fields of other fields, and this is where the lineage is useful.
For hierarchical fields, the _field_path is the concatenation of the field names
starting from the top level of the hierarchy and ending in the child/leaf field.
The concatenated sections are separated with "|".
An example of such a _field_path would be
"Please select the most appropriate answer:|How many times a week do you excercise?",
which has two hierarchy levels.
For fields with only one hierarchy level, the _field_path is simply the name of the field alone.

_field_number_path: Similarly to _field_path, this is the lineage of the field but in field numbers,
not field names. Assuming the above example would be question 3 subquestion 1,
the _field_number_path would be "3|1".

Returns: wtf.for_field.form_field_id';


--
-- Name: get_form_id(text, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_form_id(_form_path text, _owner_group_name text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE

_form_id bigint default null;
_parts text[];
_owner_group_id int default null;

BEGIN

	_owner_group_id := (select group_id from base.user_group
		where group_name = _owner_group_name);

	_parts := (select regexp_split_to_array(_form_path, '\|'));

	if (array_length(_parts, 1) = 1) then

		_form_id := (select form_id from wtf.form where owner_group_id = _owner_group_id
			and form_name = _parts[1]
			and parent_form_id is null);
	else 
		_form_id := (select form_id from wtf.form where owner_group_id = _owner_group_id
			and form_name = _parts[array_length(_parts, 1)]
			and parent_form_id =
				(wtf.get_form_id(array_to_string(_parts[1:array_length(_parts,1)-1], '|'),
					_owner_group_name)));

	end if;

	return _form_id;

END;

$$;


--
-- Name: FUNCTION get_form_id(_form_path text, _owner_group_name text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_form_id(_form_path text, _owner_group_name text) IS 'Returns the form_id of the form specified by the parameters.

Parameters:

_form_path: The complete path to the form, with form hierarchy levels separater with "|".
E.g. General questionnaires|Health questions|Eating habits. Here, Health questions is
the parent form of Eating habits.

_owner_group_name: The name of the user_group who owns the form

Returns: wtf.form_form_id';


--
-- Name: get_form_lineage(bigint, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_form_lineage(_form_id bigint, _context_name text DEFAULT NULL::text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE

_context_id bigint;
_parent_form_id bigint;
_parent_form_name text;
_result text;

BEGIN
	_context_id := (select context_id
		from wtf.context
		where context_name = _context_name);
	
	
	_parent_form_id := (select parent_form_id from wtf.form where form_id = _form_id);

	-- if this form is not a root form
	if (_parent_form_id is not null) then

		-- if synonyms shoud be used instead of actual form_names
		if (_context_id is not null) THEN		

			-- find the direct parent form synonym
			_parent_form_name := (select synonym_name
				from wtf.synonym
				where referred_id = _parent_form_id
				and referred_table = 'form'
				and context_id = _context_id);
			
		ELSE
			_parent_form_name := (select form_name from wtf.form
				where form_id = _parent_form_id);
			

		END IF;

		-- recursively call this function to go up the form lineage tree
		_result := (concat((select wtf.get_form_lineage(_parent_form_id, _context_name)),
			'|',
			_parent_form_name));

	end if;

	_result := btrim(_result, '|');

	return _result;

END;

$$;


--
-- Name: FUNCTION get_form_lineage(_form_id bigint, _context_name text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_form_lineage(_form_id bigint, _context_name text) IS 'Returns the lineage of the specified form, with hierarchy levels separated by ''|''.
The lineage does not include the name of the given form itself, only its ancestors.
For example, the lineage of ''Form 1|Subform 2|Sub-subform 1'' is ''Form 1|Subform 2''.
The lineage of ''Form 1'' is null.

Parameters:

_form_id: The primary key of the form

_context_name: If the form names in the lineage should be returned as synonyms
from a specific context, the context_id is given here. If no context_id is given,
the form names will be returned as found in the form.form_name.

Returns: text containing all form names in the requested form''s ancestry
concatenated together separated with "|"';


--
-- Name: get_gui_element_type_id(text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_gui_element_type_id(_gui_element_type_name_and_orientation text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE

_gui_element_type_id bigint;
_parts text[];
_default_orientation_name varchar;


BEGIN

	_parts := (select regexp_split_to_array(_gui_element_type_name_and_orientation, '\|'));
		
		if (array_length(_parts, 1) = 1) then
			_default_orientation_name := (SELECT regexp_replace(regexp_replace(column_default,
				'::character varying', ''),
				'''', '', 'g')
				FROM information_schema.columns
				WHERE table_schema = 'wtf'
				and table_name = 'gui_element_type'
				and column_name = 'orientation');
	
	_gui_element_type_id := (select gui_element_type_id
		from wtf.gui_element_type
		where name = _parts[1]
		and orientation = _default_orientation_name);

	else
		
		_gui_element_type_id := (select gui_element_type_id
			from wtf.gui_element_type
			where name = _parts[1]
			and orientation = _parts[2]);
	
	end if;

	return _gui_element_type_id;

END;

$$;


--
-- Name: FUNCTION get_gui_element_type_id(_gui_element_type_name_and_orientation text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_gui_element_type_id(_gui_element_type_name_and_orientation text) IS 'Returns the gui_element_type_id of the element type described by the parameter.

Parameters:

_gui_element_type_name_and_orientation: A concatenation of a gui_element_type.name and
gui_element_type.orientation separated by "|", e.g. "radio_button|horizontal".
If these is no "|" in the parameter value, the function assumes that it represents
only a name and defaults the orientation to the default value of
the gui_element_type.orientation column.

Returns: wtf.gui_element_type.gui_element_type_id';


--
-- Name: get_privileges(bigint, bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_privileges(_group_id bigint, _form_id bigint, OUT view_privilege boolean, OUT insert_privilege boolean, OUT modify_privilege boolean) RETURNS SETOF record
    LANGUAGE plpgsql ROWS 1
    AS $$
DECLARE

_privileges record;
_parent_form_id bigint;
_parent_group_id bigint;

BEGIN

	-- privileges for this group for this form
	select a.view_privilege, a.insert_privilege, a.modify_privilege
		into _privileges
	from wtf.group_form_access as a
	where group_id = _group_id
	and form_id = _form_id
	and valid = true
	limit 1;

	-- parent of form
	_parent_form_id := (select parent_form_id from wtf.v_forms where form_id = _form_id);

	-- if this pair of group and form has no privileges defined
	if (_privileges.view_privilege is null) then

		if (_parent_form_id is not null) then
			-- check if the group has access to this form's parent form
			return query select b.view_privilege, b.insert_privilege, b.modify_privilege
				from wtf.get_privileges(_group_id, _parent_form_id) as b;
		-- if there is no parent form
		else
			-- check the parent group for privileges to this form
			_parent_group_id := (select gm.group_id
				from wtf.group_membership as gm
				inner join wtf.member as m on gm.member_id = m.member_id and m.member_type = 'group'
				inner join wtf.user_group as g on m.member_id = g.group_id
				where g.group_id = _group_id);

			
			if (_parent_group_id is not null) then
				return query select b.view_privilege, b.insert_privilege, b.modify_privilege
				from wtf.get_privileges(_parent_group_id, _form_id) as b;
			else 
				-- if the whole group ancestry has been traversed with no result
				return query select false, false, false;
			end if;
		end if;
	else
		return query select _privileges.view_privilege, _privileges.insert_privilege, _privileges.modify_privilege;
	end if;

END;

$$;


--
-- Name: FUNCTION get_privileges(_group_id bigint, _form_id bigint, OUT view_privilege boolean, OUT insert_privilege boolean, OUT modify_privilege boolean); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_privileges(_group_id bigint, _form_id bigint, OUT view_privilege boolean, OUT insert_privilege boolean, OUT modify_privilege boolean) IS 'Returns the access and modification privileges of the given group on the given form.

Parameters:

_group_id: The group whose privileges should be returned

_form_id: The form to which the privileges of interest apply

Returns a record with fields:

view_privilege: Boolean for whether the group can view answers on the form

insert_privilege: Boolean for whether the group can insert answers to the form

modify_privilege: Boolean for whether the group can edit existing answers on the form';


--
-- Name: get_privileges(bigint, bigint, bigint); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.get_privileges(_group_id bigint, _form_id bigint, _person_id bigint, OUT view_privilege boolean, OUT insert_privilege boolean, OUT modify_privilege boolean) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE

_privileges record;
_filled boolean;

BEGIN

		-- get the privileges of this group for this form
		select a.view_privilege, a.insert_privilege, a.modify_privilege
		into _privileges
		from wtf.get_privileges(_group_id, _form_id) as a;

		-- is the form filled for the given person?
		_filled := (select wtf.form_filled(
					_form_id, _person_id));

		-- if the form is filled and is NOT refillable,
		-- nobody has insert privilege
		if (_filled and
			(select not form_refillable from wtf.v_forms where form_id = _form_id)) THEN

			if ( _privileges.view_privilege is null) then
				return query select false, false, false;
			else
				return query select _privileges.view_privilege, false, _privileges.modify_privilege;
			end if;
		else
			return query select _privileges.view_privilege,_privileges.insert_privilege, _privileges.modify_privilege;
		end if;
END;

$$;


--
-- Name: FUNCTION get_privileges(_group_id bigint, _form_id bigint, _person_id bigint, OUT view_privilege boolean, OUT insert_privilege boolean, OUT modify_privilege boolean); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.get_privileges(_group_id bigint, _form_id bigint, _person_id bigint, OUT view_privilege boolean, OUT insert_privilege boolean, OUT modify_privilege boolean) IS 'Returns the access and modification privileges of the given group on the given form
in the case of the given person.
If the form is not refillable and has already been filled for the person,
the function always returns a false insert_privilege.
Otherwise, works the same was as the overloaded function with two parameters.

Parameters:

_group_id: The group whose privileges should be returned

_form_id: The form to which the privileges of interest apply

_person_id: The person whose information is examined

Returns a record with fields:

view_privilege: Boolean for whether the group can view answers on the form

insert_privilege: Boolean for whether the group can insert answers to the form

modify_privilege: Boolean for whether the group can edit existing answers on the form';


--
-- Name: ignore_empty_answer(); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.ignore_empty_answer() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 IF NEW.choice_id is null
 and (NEW.free_text is null or btrim(NEW.free_text) = '') THEN
	return null;
 else
	RETURN NEW;
END IF;
END;
$$;


--
-- Name: FUNCTION ignore_empty_answer(); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.ignore_empty_answer() IS 'Trigger function that makes sure an answer is not inserted
as part of an answer set is the answer free text and is null or empty.';


--
-- Name: insert_choice(bigint, text, integer, text, text, double precision); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.insert_choice(_form_field_id bigint, _choice_name text, _choice_number integer, _description text DEFAULT NULL::text, _identifier text DEFAULT NULL::text, _points double precision DEFAULT NULL::double precision) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE

_form_id bigint;
_choice_id bigint;

BEGIN

	_choice_id := (select wtf.get_choice_id(_choice_name, _description));

	-- if choice does not exist yet, insert it
	if (_choice_id is null) then
		
		insert into wtf.choice (choice_name, description) values
			(_choice_name, _description)
			returning choice_id into _choice_id;

	end if;

	-- then insert form_field_choice,
	-- i.e. connect the choice to the form_field
	insert into wtf.form_field_choice 
		(form_field_id, choice_id,
		component_id, number,
		identifier, points)
		values 
		(_form_field_id, _choice_id,
		(select wtf.insert_component('form_field_choice')),
			_choice_number, _identifier, _points)
			on conflict(choice_id, form_field_id) do nothing;

END;

$$;


--
-- Name: FUNCTION insert_choice(_form_field_id bigint, _choice_name text, _choice_number integer, _description text, _identifier text, _points double precision); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.insert_choice(_form_field_id bigint, _choice_name text, _choice_number integer, _description text, _identifier text, _points double precision) IS 'Inserts a choice with the given properties as an available answer
in the given form_field.
If the choice does not exists yet, inserts it into the choice table.
After that, inserts a row in form_field_choice that binds the choice to the form_field.
If that row also already exists, this function does nothing.

The function name is overloaded.
This version is useful for automatic calling,
because the form_field is referenced by id and not by name and such properties.

Parameters:

_form_field_id: the id of the form_field to which this choice is to be connected.

_choice_name: the name of the choice, i.e. the text visible to the filler of the form

_choice_number: the position of the choice in the list of choices
available in the form_field

_description: The help text describing the choice

_identifier: A number or letter (e.g. 3., c. or iii) that should be shown in front of the field name
in the UI, if any.

_points: If the form answers are to be summed up into a points total,
the number of points granted from this choice.';


--
-- Name: insert_choice(text, text, text, text, text, integer, text, text, double precision); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.insert_choice(_form_path text, _owner_group_name text, _field_path text, _field_number_path text, _choice_name text, _choice_number integer, _description text DEFAULT NULL::text, _identifier text DEFAULT NULL::text, _points double precision DEFAULT NULL::double precision) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE

_form_field_id bigint;

begin
	-- finds the form_field_id of the form in question
	_form_field_id := (select wtf.get_form_field_id(_form_path,
		_owner_group_name,
		_field_path,
		_field_number_path));

	perform wtf.insert_choice(_form_field_id,
		_choice_name,
		_choice_number,
		_description,
		_identifier,
		_points);

END;

$$;


--
-- Name: FUNCTION insert_choice(_form_path text, _owner_group_name text, _field_path text, _field_number_path text, _choice_name text, _choice_number integer, _description text, _identifier text, _points double precision); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.insert_choice(_form_path text, _owner_group_name text, _field_path text, _field_number_path text, _choice_name text, _choice_number integer, _description text, _identifier text, _points double precision) IS 'Inserts a choice with the given properties as an available answer
in the given form_field.
The function name is overloaded.
This version is useful for humans running the function,
because the form_field''s properties such as data type and field type are referred to by name,
not by id.

Parameters:

_form_path, _owner_group_name, _field_path, _field_number_path:
These are directly passed on to the function
wtf.get_form_field_id(text, text, text, text).
See the description of that function for reference.

_choice_name, _choice_number, _description, _identifier, _points:
These are directly passed on to the overloaded function
wtf.insert_choice(bigint, text, integer, text, text, double precision).
See the description of that function for reference.';


--
-- Name: insert_component(text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.insert_component(_component_type text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
_component_id bigint default null;

BEGIN
	if (_component_type not in ('form_field', 'form_field_choice')) then
		raise exception 'Allowed component types are "form_field" and "form_field_choice"';
	else
		insert into wtf.component (component_type) values (_component_type)
			returning component_id into _component_id;
	end if;

	return _component_id;
END;

$$;


--
-- Name: FUNCTION insert_component(_component_type text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.insert_component(_component_type text) IS 'Inserts a component of either type form_field or form_field_choice into the component table.
Returns the auto-generated primary key component_id.
Is mainly called from within inser_field() and insert_choice() functions.

Parameters:

_component_type: Recognized options are "form_field" and "form_field_choice".

Returns: auto-generated wtf.component.component_id';


--
-- Name: insert_field(bigint, text, text, text, text, text, boolean, text, text, boolean, boolean, integer); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.insert_field(_form_id bigint, _field_path text, _field_number_path text, _field_type text, _gui_element_type_name_and_orientation text DEFAULT NULL::text, _data_type text DEFAULT NULL::text, _is_required boolean DEFAULT true, _description text DEFAULT NULL::text, _identifier text DEFAULT NULL::text, _unique_to_form boolean DEFAULT true, _is_event_ts_field boolean DEFAULT false, _section_number integer DEFAULT 1) RETURNS bigint
    LANGUAGE plpgsql
    AS $$  
DECLARE

_data_type_id int;
_field_type_id int;
_field_id bigint;
_form_field_id bigint;
_parent_form_field_id bigint default null;
_name_parts text[];
_number_parts text[];
_gui_element_type_id bigint;


BEGIN


	-- data type can be null, in which case this will be null as well
	_data_type_id := (select data_type_id from wtf.data_type
		where lower(data_type_name) = lower(_data_type));
		
	-- field type cannot be null						
	_field_type_id := (select field_type_id from wtf.field_type
		where lower(field_type_name) = lower(_field_type));


	-- split field path into parts
	_name_parts := (select regexp_split_to_array(_field_path, '\|'));

	_number_parts := (select regexp_split_to_array(_field_number_path, '\|'));
	
		-- gui_element_type_id
	_gui_element_type_id := (select wtf.get_gui_element_type_id(
		_gui_element_type_name_and_orientation));
		
		
	-- if this is root field
	if (array_length(_name_parts, 1) = 1) then

		-- it has no parent
		_parent_form_field_id := null;
	
	else

		-- find its parent (the parent is expected to be in the database already)
		_parent_form_field_id :=
			(select wtf.get_form_field_id(_form_id,
				array_to_string(_name_parts[1:array_length(_name_parts,1)-1],
				'|'),
				array_to_string(_number_parts[1:array_length(_number_parts,1)-1],
				'|')));
	
	end if;
	
		-- check if field exists
		_field_id := (select field_id from wtf.field
			where field_name = _name_parts[array_length(_name_parts,1)] -- last element
			and data_type_id = _data_type_id
			and field_type_id = _field_type_id
			and (description = _description or description is null and _description is null));

		-- if field doesn't exist, insert it
		if (_field_id is null) then
			insert into wtf.field (field_name, field_type_id, data_type_id,
			description) values 
				(_name_parts[array_length(_name_parts,1)], _field_type_id, _data_type_id, _description)
				returning field_id into _field_id;
		-- root field now inserted
			
		end if;
	
		-- check if form_field link exists		
		_form_field_id := (select wtf.get_form_field_id(_form_id,
			_field_path,
			_field_number_path));

		-- insert form_field_link if it doesn't exist
		if (_form_field_id is null) then
	
			insert into wtf.form_field (form_id, field_id,
				component_id,
				gui_element_type_id,
				is_required,
				number, identifier,
				unique_to_form,
				is_event_ts_field,
				parent_form_field_id,
				section_number) values 
					(_form_id, _field_id,
					(select wtf.insert_component('form_field')),
					_gui_element_type_id,
					_is_required, _number_parts[array_length(_number_parts,1)]::int, _identifier,
					_unique_to_form, _is_event_ts_field, _parent_form_field_id,
					_section_number)
					returning form_field_id into _form_field_id;
	
	
		end if;
	
		return _form_field_id;
END;

$$;


--
-- Name: FUNCTION insert_field(_form_id bigint, _field_path text, _field_number_path text, _field_type text, _gui_element_type_name_and_orientation text, _data_type text, _is_required boolean, _description text, _identifier text, _unique_to_form boolean, _is_event_ts_field boolean, _section_number integer); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.insert_field(_form_id bigint, _field_path text, _field_number_path text, _field_type text, _gui_element_type_name_and_orientation text, _data_type text, _is_required boolean, _description text, _identifier text, _unique_to_form boolean, _is_event_ts_field boolean, _section_number integer) IS 'Inserts a field with the given properties onto the given form. Takes human-readable parameter values, apart from form_id.
Returns the auto-generated primary key form_field_id. The function name is overloaded.
This version is useful for humans running the function, because the field''s properties
such as data type and field type are referred to by name, not by id.

Parameters:

_form_id: the id of the form in table wtf.form
_field_path: The complete path of field names specifying the field lineage on the form.
	For hierarchical fields, the _field_path is the concatenation of the field names in the hierarchy from top to bottom.
	The separator is "|". E.g. field path"Please select the most appropriate answer:|How many times a week do you excercise?"
	has two hierarchy levels. For fields with only one hierarchy level, the _field_path is simply the name of the field alone.
_field_number_path: Similarly to _field_path, this is the lineage of the field but in field numbers,
	not field names. Assuming the above example would be question 3 subquestion 1, the _field_number_path would be "3|1".
_field_type: A value in wtf.field_type.field_type_name
_gui_element_type_name_and_orientation: a combination of name and orientation from wtf.gui_element_type.
	It is possible to give only the name, in which case the default wtf.gui_element_type.orientation is used.
_data_type: A value in wtf.data_type.data_type_name
_is_required: whether or not this field is a required field on the form (i.e. must be filled)
_description: A description of the meaning of the field. This text is used behind the help symbol of the field in the UI.
_identifier: If a number or letter (e.g. 3., c. or iii) should be shown in front of the field name in the UI.
_unique_to_form: If true, it means that the person-specific answer to this field must not be used
	as a default answer to the same field in another form. If unsure, set true.
_is_event_ts_field: Whether or not this field suggests where in the timeline this information should be shown
	(if the timeline component of the software is in use). If the timeline component is not in use,
	this field has no relevance.
_section_number: If the form is divided into sections, the number of the section in which this field is located.
	The default value 1 works well when the form is not divided into sections.

Returns: wtf.form_field.form_field_id';


--
-- Name: insert_field(text, text, text, text, text, text, text, boolean, text, text, boolean, boolean, integer); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.insert_field(_form_path text, _owner_group_name text, _field_path text, _field_number_path text, _field_type text, _gui_element_type_name_and_orientation text DEFAULT NULL::text, _data_type text DEFAULT NULL::text, _is_required boolean DEFAULT true, _description text DEFAULT NULL::text, _identifier text DEFAULT NULL::text, _unique_to_form boolean DEFAULT true, _is_event_ts_field boolean DEFAULT false, _section_number integer DEFAULT 1) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE

_form_id bigint;
_form_field_id bigint;

BEGIN
	
	-- find the id of the form
	_form_id := (select wtf.get_form_id(_form_path, _owner_group_name));

	-- call overloaded function with the form_id instead of name
	_form_field_id := (select wtf.insert_field(_form_id,
		_field_path,
		_field_number_path,
		_field_type,
		_gui_element_type_name_and_orientation,
		_data_type,
		_is_required,
		_description,
		_identifier,
		_is_event_ts_field,
		_unique_to_form,
		_section_number));
	
		return _form_field_id;
END;

$$;


--
-- Name: FUNCTION insert_field(_form_path text, _owner_group_name text, _field_path text, _field_number_path text, _field_type text, _gui_element_type_name_and_orientation text, _data_type text, _is_required boolean, _description text, _identifier text, _unique_to_form boolean, _is_event_ts_field boolean, _section_number integer); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.insert_field(_form_path text, _owner_group_name text, _field_path text, _field_number_path text, _field_type text, _gui_element_type_name_and_orientation text, _data_type text, _is_required boolean, _description text, _identifier text, _unique_to_form boolean, _is_event_ts_field boolean, _section_number integer) IS 'Inserts a field with the given properties onto the given form. Takes human-readable parameter values.
Returns the auto-generated primary key form_field_id.
The function name is overloaded. This version is useful for humans running the function,
because the form and the field''s properties such as data type and field type are referred to by name, not by id.

Parameters:

_form_path: The complete path to the form, with form hierarchy levels separater with "|".
	E.g. General questionnaires|Health questions|Eating habits. Here, Health questions is
	the parent form of Eating habits.
_owner_group_name: The name of the user_group who owns this form

_field_path: The complete path of field names specifying the field lineage on the form.
	Fields can be arranged as sub-fields of other fields, and this is where the lineage is useful.
	For hierarchical fields, the _field_path is the concatenation of the field names
	starting from the top level of the hierarchy and ending in the child/leaf field. The separator is "|".
	E.g. field path "Please select the most appropriate answer:|How many times a week do you excercise?" has two hierarchy levels.
	For fields with only one hierarchy level, the _field_path is simply the name of the field alone.
_field_number_path: Similarly to _field_path, this is the lineage of the field but in field numbers,
	not field names. Assuming the above example would be question 3 subquestion 1, the _field_number_path would be "3|1".
_field_type: A value in wtf.field_type.field_type_name
_gui_element_type_name_and_orientation: a combination of name and orientation from wtf.gui_element_type.
	It is possible to give only the name, in which case the default wtf.gui_element_type.orientation is used.
_data_type: A value in wtf.data_type.data_type_name
_is_required: whether or not this field is a required field on the form (i.e. must be filled)
_description: A description of the meaning of the field.
	This text is used behind the help symbol of the field in the UI.
_identifier: If a number or letter (e.g. 3., c. or iii) should be shown in front of the choice name in the UI.
_unique_to_form: If true, it means that the person-specific answer to this field must not be used
	as a default answer to the same field in another form. If unsure, set true.
_is_event_ts_field: Whether or not this field suggests where in the timeline this information should be shown
	(if the timeline component of the software is in use). If the timeline component is not in use,
	this field has no relevance.
_section_number: If the form is divided into sections,  the number of the section in which this field is located.
	The default value 1 works well when the form is not divided into sections.

Returns: wtf.form_field.form_field_id';


--
-- Name: insert_field_synonym(bigint, bigint, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.insert_field_synonym(_context_id bigint, _form_field_id bigint, _synonym text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
_component_id bigint;

begin
	
	_component_id := (select wtf.get_component_id(_form_field_id));

	INSERT INTO wtf.synonym (context_id, synonym_name, referred_table, referred_id)
		VALUES (_context_id, _synonym, 'component', _component_id);


	return;
	
END;

$$;


--
-- Name: FUNCTION insert_field_synonym(_context_id bigint, _form_field_id bigint, _synonym text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.insert_field_synonym(_context_id bigint, _form_field_id bigint, _synonym text) IS 'Inserts a synonym for a field name in a specific form.

Parameters:

_context_id: The context in which this synonym is used

_form_field_id: The form_field that this synonym is for

_synonym: The textual representation of the synonym';


--
-- Name: insert_field_synonym(bigint, bigint, text, text, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.insert_field_synonym(_context_id bigint, _form_id bigint, _field_path text, _field_number_path text, _synonym text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
_form_field_id bigint;

BEGIN

	_form_field_id := (select wtf.get_form_field_id(
		_form_id,
		_field_path,
		_field_number_path));
	
	perform wtf.insert_field_synonym(_context_id, _form_field_id, _synonym);

	return;
	
END;

$$;


--
-- Name: FUNCTION insert_field_synonym(_context_id bigint, _form_id bigint, _field_path text, _field_number_path text, _synonym text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.insert_field_synonym(_context_id bigint, _form_id bigint, _field_path text, _field_number_path text, _synonym text) IS 'Inserts a synonym for a field name in a specific form.

Parameters:

_context_id: The context in which this synonym is used.

_form_id, _field_path, _field_number_path:
These are directly passed on to the function
wtf.get_form_field_id(bigint, text, text).
See the description of that function for reference.

_synonym: The textual representation of the synonym';


--
-- Name: insert_form(text, integer, boolean, text, text, text, boolean); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.insert_form(_form_path text, _form_number integer, _refillable boolean, _owner_group_name text, _header text DEFAULT NULL::text, _footer text DEFAULT NULL::text, _person_specific boolean DEFAULT true) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
_current_form_name text;
_parent_name text;
_current_form_id int default null;
_current_parent_id int default null;
_owner_group_id int default null;
_form_id bigint default null;


BEGIN
	
	_owner_group_id := (select group_id from base.user_group
		where group_name = _owner_group_name);

	
	for _current_form_name in select regexp_split_to_table(_form_path, '\|')
	LOOP
		
		if (_current_parent_id is null ) then
				
			_current_form_id := (select form_id from wtf.form
				where form_name = _current_form_name
				and owner_group_id = _owner_group_id
				and parent_form_id is null);

				
			if (_current_form_id is null) then 
			
				insert into wtf.form (owner_group_id, form_name, valid_since,
					number, refillable, header, footer, person_specific) values
					(_owner_group_id, _current_form_name, now(),
					_form_number, _refillable, _header, _footer, _person_specific)
					returning form_id into _current_form_id;	
			end if;

				
			_current_parent_id := _current_form_id;


		else 
		
			
			_current_form_id := (select form_id from wtf.v_forms
				where form_name = _current_form_name
				and parent_form_id = _current_parent_id
				and owner_group_name = _owner_group_name);

			
			if (_current_form_id is null) then

				
				insert into wtf.form(owner_group_id, form_name, valid_since,
					number, parent_form_id, refillable, header, footer, person_specific) values
					(_owner_group_id,	_current_form_name, now(),
					_form_number, _current_parent_id, _refillable, _header, _footer, _person_specific)
					returning form_id into _current_form_id;
	
			end if;

			_current_parent_id := _current_form_id;

		end if;		
	END LOOP;

	return _current_form_id;
END;

$$;


--
-- Name: FUNCTION insert_form(_form_path text, _form_number integer, _refillable boolean, _owner_group_name text, _header text, _footer text, _person_specific boolean); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.insert_form(_form_path text, _form_number integer, _refillable boolean, _owner_group_name text, _header text, _footer text, _person_specific boolean) IS 'Insert the given form into the wtf.form table and returns its form_id.

Parameters:

_form_path: The complete path to the form, with form hierarchy levels separater with "|".
E.g. General questionnaires|Health questions|Eating habits. Here, Health questions is
the parent form of Eating habits.

_form_number: The ordinal number of the child form / leaf form among all child forms
of its parent. If the child form has no sibling forms, this should be 1.

_refillable: boolean for whether this form can be filled more than once
for the same person.

_owner_group_name: The name of the user_group who owns this form

_ header: If a header or introductory text is to be shown at the top of the form in the GUI,
it can be inserted here.

_footer: If a footer text or closing remark is to be shown at the bottom of the form
before the save button, it can be inserted here.
_person_specific: boolean for whether the answers to this form concern a specific person in base.person.

Returns: the auto-generated wtf.form.form_id';


--
-- Name: insert_group_form_access(text, text, text); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.insert_group_form_access(_group_name text, _form_path text, _form_owner_group_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
_group_id int default null;
_form_id int default null;

BEGIN
	if (_email is null or _group_name is null ) then
		raise EXCEPTION 'Both group and form must be provided';
	else
		
		_group_id := (select group_id from base.user_group where group_name = _group_name);
		_form_id := (select wtf.get_form_id(_form_path, _form_owner_group_name));

		if (_group_id is null or _form_id is null) then
			raise EXCEPTION 'The given group or form doesn''t exist.';
		else
			if (not exists (
				-- if group does not have access previously, insert it
				select * from wtf.group_form_access
					where group_id = _group_id
					and form_id = _form_id
					and valid = true)) then
				insert into wtf.group_form_access (group_id, form_id, valid) values
					(_group_id, _form_id, true);
			end if;
		end if;
	end if;
END;

$$;


--
-- Name: FUNCTION insert_group_form_access(_group_name text, _form_path text, _form_owner_group_name text); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.insert_group_form_access(_group_name text, _form_path text, _form_owner_group_name text) IS 'Grants access to a user_group to a form, i.e. inserts a row in table group_form_access.

Parameters:

_group_name: The group that will get access

_form_path: The path of the form to which the access is granted

_form_owner_group_name: The owner of the form to which the access is granted.
 The _form_path and _form_owner_group_name together uniquely specify the form.';


--
-- Name: set_default_form_field_gui_element_type(); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.set_default_form_field_gui_element_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

begin

	if new.gui_element_type_id is NULL then
		new.gui_element_type_id :=
			(select gui_element_type_id
			from wtf.gui_element_type
			where name = 'hidden');
	end if;
	return new;
end

$$;


--
-- Name: FUNCTION set_default_form_field_gui_element_type(); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.set_default_form_field_gui_element_type() IS 'Trigger function that replaces a null gui_element_type_id with
the id of the "hidden" gui_element_type.';


--
-- Name: set_group_form_access(bigint, bigint, boolean, boolean, boolean); Type: FUNCTION; Schema: wtf; Owner: -
--

CREATE FUNCTION wtf.set_group_form_access(_group_id bigint, _form_id bigint, _view_privilege boolean DEFAULT false, _insert_privilege boolean DEFAULT false, _modify_privilege boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
	insert into wtf.group_form_access (form_id, group_id, valid_since, valid_until,
		valid, insert_ts, update_ts,
		view_privilege,
		insert_privilege,
		modify_privilege)
	values (_form_id, _group_id, now(), null, true, now(), null,
	_view_privilege, _insert_privilege, _modify_privilege)
		on conflict on constraint group_form_access_pk
		do update set valid = true,
			valid_since = (case when group_form_access.valid_until is not null
			then now()
			else group_form_access.valid_since end),
			valid_until = null, update_ts = now();
			
END;

$$;


--
-- Name: FUNCTION set_group_form_access(_group_id bigint, _form_id bigint, _view_privilege boolean, _insert_privilege boolean, _modify_privilege boolean); Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON FUNCTION wtf.set_group_form_access(_group_id bigint, _form_id bigint, _view_privilege boolean, _insert_privilege boolean, _modify_privilege boolean) IS 'Sets the given access and modification privileges for the given group to the given form.

Parameters:

_group_id: The group_id of the user_group whose privileges are being set

_form_id: The form_id of the form to which the privileges apply

_view_privilege: Boolean for whether the group can view answers on the form

_insert_privilege: Boolean for whether the group can insert answers to the form

_modify_privilege: Boolean for whether the group can edit existing answers on the form';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: app_user; Type: TABLE; Schema: base; Owner: -
--

CREATE TABLE base.app_user (
    app_user_id bigint NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    username character varying,
    email character varying NOT NULL,
    password character varying,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone,
    serial_number character varying(16) DEFAULT NULL::character varying
);


--
-- Name: COLUMN app_user.app_user_id; Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON COLUMN base.app_user.app_user_id IS 'refers to member_id';


--
-- Name: feature; Type: TABLE; Schema: base; Owner: -
--

CREATE TABLE base.feature (
    feature_id bigint NOT NULL,
    name character varying NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: feature__seq; Type: SEQUENCE; Schema: base; Owner: -
--

CREATE SEQUENCE base.feature__seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feature__seq; Type: SEQUENCE OWNED BY; Schema: base; Owner: -
--

ALTER SEQUENCE base.feature__seq OWNED BY base.feature.feature_id;


--
-- Name: group_feature_access; Type: TABLE; Schema: base; Owner: -
--

CREATE TABLE base.group_feature_access (
    group_id bigint NOT NULL,
    feature_id bigint NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN group_feature_access.group_id; Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON COLUMN base.group_feature_access.group_id IS 'refers to member_id';


--
-- Name: group_membership; Type: TABLE; Schema: base; Owner: -
--

CREATE TABLE base.group_membership (
    member_id bigint NOT NULL,
    group_id bigint NOT NULL,
    valid_since timestamp without time zone DEFAULT now() NOT NULL,
    valid_until timestamp without time zone,
    valid boolean NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: COLUMN group_membership.group_id; Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON COLUMN base.group_membership.group_id IS 'refers to member_id';


--
-- Name: member; Type: TABLE; Schema: base; Owner: -
--

CREATE TABLE base.member (
    member_id bigint NOT NULL,
    member_type character varying NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: COLUMN member.member_type; Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON COLUMN base.member.member_type IS '"user" or "group"';


--
-- Name: member_seq; Type: SEQUENCE; Schema: base; Owner: -
--

CREATE SEQUENCE base.member_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: member_seq; Type: SEQUENCE OWNED BY; Schema: base; Owner: -
--

ALTER SEQUENCE base.member_seq OWNED BY base.member.member_id;


--
-- Name: parameters; Type: TABLE; Schema: base; Owner: -
--

CREATE TABLE base.parameters (
    parameter_name character varying(100) NOT NULL,
    parameter_value text
);


--
-- Name: person_id_seq; Type: SEQUENCE; Schema: base; Owner: -
--

CREATE SEQUENCE base.person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: person; Type: TABLE; Schema: base; Owner: -
--

CREATE TABLE base.person (
    person_id bigint DEFAULT nextval('base.person_id_seq'::regclass) NOT NULL,
    henkilotunnus character varying(50) NOT NULL,
    birth_date date NOT NULL,
    death_date date,
    gender integer,
    lastname character varying(100) DEFAULT NULL::character varying,
    firstname character varying(100) DEFAULT NULL::character varying,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: user_group; Type: TABLE; Schema: base; Owner: -
--

CREATE TABLE base.user_group (
    group_id bigint NOT NULL,
    group_name character varying NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: COLUMN user_group.group_id; Type: COMMENT; Schema: base; Owner: -
--

COMMENT ON COLUMN base.user_group.group_id IS 'refers to member_id';


--
-- Name: v_group_feature_access; Type: VIEW; Schema: base; Owner: -
--

CREATE VIEW base.v_group_feature_access AS
 SELECT gfa.group_id,
    g.group_name,
    gfa.feature_id,
    f.name AS feature_name
   FROM ((base.group_feature_access gfa
     JOIN base.user_group g ON ((gfa.group_id = g.group_id)))
     JOIN base.feature f ON ((gfa.feature_id = f.feature_id)));


--
-- Name: v_users; Type: VIEW; Schema: base; Owner: -
--

CREATE VIEW base.v_users AS
 SELECT u.app_user_id,
    u.first_name,
    u.last_name,
    u.username,
    u.email,
    u.password,
    m.valid,
    g.group_id,
    g.group_name
   FROM ((base.app_user u
     JOIN base.group_membership m ON ((u.app_user_id = m.member_id)))
     JOIN base.user_group g ON ((m.group_id = g.group_id)));


--
-- Name: cdc_time; Type: TABLE; Schema: mining; Owner: -
--

CREATE TABLE mining.cdc_time (
    cdc_time_id bigint NOT NULL,
    process_name character varying,
    last_load timestamp with time zone,
    current_load timestamp with time zone
);


--
-- Name: cdc_time_cdc_time_id_seq; Type: SEQUENCE; Schema: mining; Owner: -
--

CREATE SEQUENCE mining.cdc_time_cdc_time_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdc_time_cdc_time_id_seq; Type: SEQUENCE OWNED BY; Schema: mining; Owner: -
--

ALTER SEQUENCE mining.cdc_time_cdc_time_id_seq OWNED BY mining.cdc_time.cdc_time_id;


--
-- Name: epic_scoring; Type: TABLE; Schema: mining; Owner: -
--

CREATE TABLE mining.epic_scoring (
    field_number_nesting_order integer[] NOT NULL,
    subsection_name character varying(100),
    subsection_required_count integer
);


--
-- Name: mv_epic_scores; Type: MATERIALIZED VIEW; Schema: mining; Owner: -
--

CREATE MATERIALIZED VIEW mining.mv_epic_scores AS
 SELECT get_epic_scores.person_id,
    get_epic_scores.open_ts AS ts,
        CASE
            WHEN ((get_epic_scores.subsection_name)::text = 'Incontinence'::text) THEN 'EPIC keskeiset'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Urinary irritative/obstructive'::text) THEN 'EPIC muut'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Bowel'::text) THEN 'EPIC muut'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Sexual'::text) THEN 'EPIC keskeiset'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Hormonal'::text) THEN 'EPIC muut'::text
            ELSE NULL::text
        END AS series_group,
        CASE
            WHEN ((get_epic_scores.subsection_name)::text = 'Incontinence'::text) THEN 'Virtsankarkailu'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Urinary irritative/obstructive'::text) THEN 'Virtsan kerääntymis- ja tyhjennysoireet'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Bowel'::text) THEN 'Suolioireet'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Sexual'::text) THEN 'Erektiokyky'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Hormonal'::text) THEN 'Hormonaalinen osa-alue'::text
            ELSE NULL::text
        END AS series_name,
    get_epic_scores.average_points AS value
   FROM mining.get_epic_scores() get_epic_scores(person_id, open_ts, subsection_name, average_points)
  WITH NO DATA;


--
-- Name: answer; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.answer (
    answer_id bigint NOT NULL,
    form_field_id bigint NOT NULL,
    choice_id bigint,
    free_text character varying,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone,
    answer_set_id bigint
);


--
-- Name: answer_set; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.answer_set (
    answer_set_id bigint NOT NULL,
    session_id bigint NOT NULL,
    form_id bigint NOT NULL,
    number integer NOT NULL,
    open_ts timestamp without time zone DEFAULT now() NOT NULL,
    close_ts timestamp without time zone,
    save_ts timestamp without time zone,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    invalidated_ts timestamp without time zone,
    replaced_by_answer_set_id bigint
);


--
-- Name: choice; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.choice (
    choice_id bigint NOT NULL,
    choice_name character varying NOT NULL,
    description character varying,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: data_type; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.data_type (
    data_type_id bigint NOT NULL,
    data_type_name character varying NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: field; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.field (
    field_id bigint NOT NULL,
    field_name character varying NOT NULL,
    description character varying,
    field_type_id bigint NOT NULL,
    data_type_id bigint,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: field_type; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.field_type (
    field_type_id bigint NOT NULL,
    field_type_name character varying NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    udpate_ts timestamp without time zone
);


--
-- Name: form; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.form (
    form_id bigint NOT NULL,
    form_name character varying NOT NULL,
    header character varying,
    footer character varying,
    valid_since timestamp without time zone NOT NULL,
    valid_until timestamp without time zone,
    owner_group_id bigint NOT NULL,
    number integer,
    refillable boolean NOT NULL,
    parent_form_id bigint,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone,
    person_specific boolean
);


--
-- Name: COLUMN form.owner_group_id; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.form.owner_group_id IS 'refers to member_id = group_id that owns this form';


--
-- Name: COLUMN form.number; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.form.number IS 'the number of this form among its sibling forms, i.e. the children of the same parent form';


--
-- Name: COLUMN form.refillable; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.form.refillable IS 'whether this form is refillable, i.e. can be filled twice for the same patient';


--
-- Name: form_field; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.form_field (
    form_field_id bigint NOT NULL,
    form_id bigint NOT NULL,
    field_id bigint NOT NULL,
    component_id bigint NOT NULL,
    number integer NOT NULL,
    identifier character varying,
    is_required boolean NOT NULL,
    parent_form_field_id bigint,
    unique_to_form boolean NOT NULL,
    gui_element_type_id bigint NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone,
    is_event_ts_field boolean DEFAULT false,
    section_number integer DEFAULT 1
);


--
-- Name: COLUMN form_field.number; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.form_field.number IS 'The order in which the fields are shown on the form.';


--
-- Name: COLUMN form_field.identifier; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.form_field.identifier IS 'The field number determines the order in which the fields are shown in the form. The field identifier determines the number or letter that is written in front of the field in the form. This is normally of the type 1,2,3, or a,b,c etc';


--
-- Name: COLUMN form_field.unique_to_form; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.form_field.unique_to_form IS 'whether the answer for this field should be transferred from a previous form if possible. TRUE = should not be transferred, FALSE = should be transferred';


--
-- Name: form_field_choice; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.form_field_choice (
    choice_id bigint NOT NULL,
    form_field_id bigint NOT NULL,
    component_id bigint NOT NULL,
    number integer NOT NULL,
    identifier character varying,
    points double precision,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: COLUMN form_field_choice.number; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.form_field_choice.number IS 'The order in which the choices are shown in the field.';


--
-- Name: COLUMN form_field_choice.identifier; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.form_field_choice.identifier IS 'The choice number determines the order in which the choices are shown in the field. The choice identifier determines the number or letter that is written in front of the choice name. This is normally of the type 1,2,3, or a,b,c etc';


--
-- Name: gui_element_type; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.gui_element_type (
    gui_element_type_id bigint NOT NULL,
    name character varying NOT NULL,
    orientation character varying DEFAULT 'vertical'::character varying NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: session; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.session (
    session_id bigint NOT NULL,
    app_user_id bigint NOT NULL,
    group_id bigint NOT NULL,
    person_id bigint,
    session_started_ts timestamp without time zone NOT NULL,
    session_ended_ts timestamp without time zone,
    session_end_type_id integer,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: COLUMN session.app_user_id; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.session.app_user_id IS 'refers to member_id';


--
-- Name: COLUMN session.group_id; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.session.group_id IS 'refers to member_id';


--
-- Name: COLUMN session.session_started_ts; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.session.session_started_ts IS 'The timestamp for opening the root form';


--
-- Name: COLUMN session.session_ended_ts; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.session.session_ended_ts IS 'The timestamp for closing the root form or being automatically logged out';


--
-- Name: COLUMN session.session_end_type_id; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.session.session_end_type_id IS 'Was user manually or automatically logged out';


--
-- Name: v_form_field_choices; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_form_field_choices AS
 SELECT ff.form_field_id,
    form.form_id,
    form.form_name,
    form.header AS form_header,
    form.footer AS form_footer,
    ff.component_id AS form_field_component_id,
    ff.field_id,
    ff.is_event_ts_field,
    ff.number AS field_number,
        CASE
            WHEN (ff.form_field_id IS NULL) THEN NULL::integer[]
            ELSE (regexp_split_to_array(concat_ws('|'::text, ( SELECT wtf.get_field_number_lineage(ff.form_field_id) AS get_field_number_lineage), ff.number), '\|'::text))::integer[]
        END AS field_number_nesting_order,
    ff.section_number,
    ff.identifier AS field_identifier,
    field.field_name,
    concat_ws(' '::text, ff.identifier, field.field_name) AS field_long_name,
    field.description AS field_description,
    dt.data_type_name,
    ft.field_type_name,
    et.name AS gui_element_type,
    et.orientation AS gui_element_orientation,
    ff.is_required AS field_is_required,
    ff.unique_to_form AS field_unique_to_form,
    ffc.component_id AS form_field_choice_component_id,
    c.choice_id,
    c.choice_name,
    c.description AS choice_description,
    ffc.number AS choice_number,
    ffc.identifier AS choice_identifier,
    concat_ws(' '::text, ffc.identifier, c.choice_name) AS choice_long_name,
    ffc.points AS choice_points
   FROM (((((((wtf.form
     JOIN wtf.form_field ff ON ((form.form_id = ff.form_id)))
     JOIN wtf.field ON ((ff.field_id = field.field_id)))
     LEFT JOIN wtf.data_type dt ON ((field.data_type_id = dt.data_type_id)))
     JOIN wtf.field_type ft ON ((field.field_type_id = ft.field_type_id)))
     LEFT JOIN wtf.gui_element_type et ON ((ff.gui_element_type_id = et.gui_element_type_id)))
     LEFT JOIN wtf.form_field_choice ffc ON ((ff.form_field_id = ffc.form_field_id)))
     LEFT JOIN wtf.choice c ON ((ffc.choice_id = c.choice_id)))
  ORDER BY form.form_name, ff.number, ffc.number;


--
-- Name: v_answers; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_answers AS
 SELECT ans.session_id,
    s.person_id,
    p.henkilotunnus,
    s.app_user_id,
    ans.open_ts,
    ans.save_ts,
    a.insert_ts AS answer_insert_ts,
    a.answer_id,
    a.answer_set_id,
    a.free_text,
    regexp_replace(wtf.get_form_lineage(ffc.form_id), '^.*? - '::text, ''::text) AS form_lineage,
    ffc.form_field_id,
    ffc.form_id,
    ffc.form_name,
    ffc.form_header,
    ffc.form_footer,
    ffc.form_field_component_id,
    ffc.field_id,
    ffc.is_event_ts_field,
    wtf.get_field_lineage(ffc.form_field_id) AS field_lineage,
    ffc.field_number,
    ffc.field_number_nesting_order,
    ffc.section_number,
    ffc.field_identifier,
    ffc.field_name,
    concat_ws(' '::text, ffc.field_identifier, ffc.field_name) AS field_long_name,
    ffc.field_description,
    ffc.data_type_name,
    ffc.field_type_name,
    ffc.field_is_required,
    ffc.field_unique_to_form,
    ffc.form_field_choice_component_id,
    ffc.choice_id,
    ffc.choice_name,
    ffc.choice_description,
    ffc.choice_number,
    ffc.choice_identifier,
    concat_ws(' '::text, ffc.choice_identifier, ffc.choice_name) AS choice_long_name,
    ffc.choice_points
   FROM ((((wtf.answer a
     JOIN wtf.answer_set ans ON (((a.answer_set_id = ans.answer_set_id) AND (ans.invalidated_ts IS NULL))))
     JOIN wtf.session s ON ((ans.session_id = s.session_id)))
     JOIN wtf.v_form_field_choices ffc ON (((a.form_field_id = ffc.form_field_id) AND ((a.choice_id = ffc.choice_id) OR ((ffc.choice_id IS NULL) AND ((ffc.field_type_name)::text = 'vapaa_teksti'::text))))))
     JOIN base.person p ON ((s.person_id = p.person_id)));


--
-- Name: v_epic_answers; Type: VIEW; Schema: mining; Owner: -
--

CREATE VIEW mining.v_epic_answers AS
 SELECT a.session_id,
    a.person_id,
    a.henkilotunnus,
    a.app_user_id,
    a.open_ts,
    a.save_ts,
    a.answer_insert_ts,
    a.answer_id,
    a.answer_set_id,
    a.free_text,
    a.form_lineage,
    a.form_field_id,
    a.form_id,
    a.form_name,
    a.form_header,
    a.form_footer,
    a.form_field_component_id,
    a.field_id,
    a.is_event_ts_field,
    a.field_lineage,
    a.field_number,
    a.field_number_nesting_order,
    a.section_number,
    a.field_identifier,
    a.field_name,
    a.field_long_name,
    a.field_description,
    a.data_type_name,
    a.field_type_name,
    a.field_is_required,
    a.field_unique_to_form,
    a.form_field_choice_component_id,
    a.choice_id,
    a.choice_name,
    a.choice_description,
    a.choice_number,
    a.choice_identifier,
    a.choice_long_name,
    a.choice_points
   FROM wtf.v_answers a
  WHERE ((a.form_lineage = 'Urologian potilaslomakkeet'::text) AND ((a.form_name)::text = 'EPIC'::text));


--
-- Name: v_epic_scores; Type: VIEW; Schema: mining; Owner: -
--

CREATE VIEW mining.v_epic_scores AS
 SELECT get_epic_scores.person_id,
    get_epic_scores.open_ts AS ts,
        CASE
            WHEN ((get_epic_scores.subsection_name)::text = 'Incontinence'::text) THEN 'EPIC keskeiset'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Urinary irritative/obstructive'::text) THEN 'EPIC muut'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Bowel'::text) THEN 'EPIC muut'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Sexual'::text) THEN 'EPIC keskeiset'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Hormonal'::text) THEN 'EPIC muut'::text
            ELSE NULL::text
        END AS series_group,
        CASE
            WHEN ((get_epic_scores.subsection_name)::text = 'Incontinence'::text) THEN 'Virtsankarkailu'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Urinary irritative/obstructive'::text) THEN 'Virtsan kerääntymis- ja tyhjennysoireet'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Bowel'::text) THEN 'Suolioireet'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Sexual'::text) THEN 'Erektiokyky'::text
            WHEN ((get_epic_scores.subsection_name)::text = 'Hormonal'::text) THEN 'Hormonaalinen osa-alue'::text
            ELSE NULL::text
        END AS series_name,
    get_epic_scores.average_points AS value
   FROM mining.get_epic_scores() get_epic_scores(person_id, open_ts, subsection_name, average_points);


--
-- Name: v_measurements; Type: VIEW; Schema: mining; Owner: -
--

CREATE VIEW mining.v_measurements AS
 SELECT v_epic_scores.person_id,
    v_epic_scores.ts,
    v_epic_scores.series_group,
    v_epic_scores.series_name,
    v_epic_scores.value
   FROM mining.v_epic_scores;


--
-- Name: cdc_time_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.cdc_time_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdc_time; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.cdc_time (
    cdc_time_id bigint DEFAULT nextval('patient_data.cdc_time_id_seq'::regclass) NOT NULL,
    process_name character varying,
    last_load timestamp with time zone,
    current_load timestamp with time zone
);


--
-- Name: chemotherapy_course_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.chemotherapy_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chemotherapy_course; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.chemotherapy_course (
    chemotherapy_course_id bigint DEFAULT nextval('patient_data.chemotherapy_course_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    source_pk character varying NOT NULL,
    course_name character varying NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: chemotherapy_cycle_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.chemotherapy_cycle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chemotherapy_cycle; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.chemotherapy_cycle (
    chemotherapy_cycle_id bigint DEFAULT nextval('patient_data.chemotherapy_cycle_id_seq'::regclass) NOT NULL,
    chemotherapy_course_id bigint NOT NULL,
    cycle_number integer NOT NULL,
    cycle_start_date date NOT NULL,
    cycle_end_date date NOT NULL,
    source_pk character varying(50) NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: chemotherapy_dose_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.chemotherapy_dose_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chemotherapy_dose; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.chemotherapy_dose (
    chemotherapy_dose_id bigint DEFAULT nextval('patient_data.chemotherapy_dose_id_seq'::regclass) NOT NULL,
    chemotherapy_cycle_id bigint NOT NULL,
    generic_name character varying(1000),
    product_name character varying(1000),
    strength character varying(100),
    dosage character varying(1000),
    dosage_unit character varying NOT NULL,
    administering_order integer,
    source_pk character varying NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: clinical_finding_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.clinical_finding_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clinical_finding; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.clinical_finding (
    clinical_finding_id bigint DEFAULT nextval('patient_data.clinical_finding_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    quantity character varying(200) NOT NULL,
    value text NOT NULL,
    unit character varying(200),
    specialty_page character varying(200) NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: diagnosis_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.diagnosis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diagnosis; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.diagnosis (
    diagnosis_id bigint DEFAULT nextval('patient_data.diagnosis_id_seq'::regclass) NOT NULL,
    visit_id bigint,
    episode_of_care_id bigint,
    service_type character varying(20) NOT NULL,
    diagnosis_code character varying(50),
    diagnosis_name character varying(500),
    is_main_diagnosis boolean,
    is_cause_diagnosis boolean NOT NULL,
    source_pk character varying(30),
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: element_significance; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.element_significance (
    element_id bigint NOT NULL,
    significance_id integer DEFAULT patient_data.get_default_significance() NOT NULL,
    specialty_id integer NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: episode_of_care_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.episode_of_care_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: episode_of_care; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.episode_of_care (
    episode_of_care_id bigint DEFAULT nextval('patient_data.episode_of_care_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    unit_code character varying(50),
    unit_name character varying(200),
    resource_code character varying(50),
    resource_name character varying(200),
    text_content text,
    text_pk text,
    source_pk character varying(50) NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: help_page; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.help_page (
    update_ts timestamp with time zone,
    content text
);


--
-- Name: lab_package_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.lab_package_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lab_package; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.lab_package (
    lab_package_id bigint DEFAULT nextval('patient_data.lab_package_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    text_content text,
    text_pk character varying(50),
    source_pk character varying(200) NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: lab_test_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.lab_test_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lab_test; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.lab_test (
    lab_test_id bigint DEFAULT nextval('patient_data.lab_test_id_seq'::regclass) NOT NULL,
    lab_package_id bigint NOT NULL,
    test character varying(100) NOT NULL,
    result character varying(100),
    unit character varying(100),
    text_content text,
    text_pk character varying(50),
    source_pk character varying NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: medication_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.medication_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: medication; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.medication (
    medication_id bigint DEFAULT nextval('patient_data.medication_id_seq'::regclass) NOT NULL,
    medication_set_id bigint NOT NULL,
    source_pk character varying(200) NOT NULL,
    atc_code character varying(20),
    atc_name character varying(500),
    generic_name character varying(1000),
    product_name character varying(1000),
    strength character varying(500),
    dosage character varying(1000),
    inpatient_medication_source_pk character varying(50),
    outpatient_medication_source_pk character varying(50),
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone,
    is_inpatient boolean
);


--
-- Name: medication_set_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.medication_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: medication_set; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.medication_set (
    medication_set_id bigint DEFAULT nextval('patient_data.medication_set_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    prescribing_unit_code character varying NOT NULL,
    source_pk character varying NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: radiotherapy_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.radiotherapy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: radiotherapy; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.radiotherapy (
    radiotherapy_id bigint DEFAULT nextval('patient_data.radiotherapy_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    course_id character varying(8000),
    number_of_fractions integer NOT NULL,
    total_dose_per_ref_point character varying(8000),
    source_pk bigint NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: referral_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.referral_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referral; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.referral (
    referral_id bigint DEFAULT nextval('patient_data.referral_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    sending_doctor_name character varying(200),
    sending_unit_name character varying(200),
    sending_institution_name character varying(200),
    receiving_unit_code character varying(200),
    receiving_unit_name character varying(200),
    receiving_institution_name character varying(200),
    speciality_code character varying(10),
    speciality_name character varying(100),
    direction character varying(20),
    text_content text,
    text_pk character varying(50),
    source_pk character varying(200),
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: v_chemotherapy_course_eventinfo_content; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_chemotherapy_course_eventinfo_content AS
SELECT
    NULL::text AS category,
    NULL::bigint AS element_id,
    NULL::bigint AS timeline_table_pk,
    NULL::text AS eventinfo_content,
    NULL::text AS eventinfo_tooltip,
    NULL::character varying AS icon_text;


--
-- Name: v_episode_of_care_eventinfo_content; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_episode_of_care_eventinfo_content AS
SELECT
    NULL::text AS category,
    NULL::bigint AS element_id,
    NULL::bigint AS timeline_table_pk,
    NULL::text AS eventinfo_content,
    NULL::text AS eventinfo_tooltip,
    NULL::character varying AS icon_text;


--
-- Name: v_lab_package_eventinfo_content; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_lab_package_eventinfo_content AS
SELECT
    NULL::text AS category,
    NULL::bigint AS element_id,
    NULL::bigint AS timeline_table_pk,
    NULL::text AS eventinfo_content,
    NULL::text AS eventinfo_tooltip,
    NULL::character varying AS icon_text;


--
-- Name: v_medication_set_eventinfo_content; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_medication_set_eventinfo_content AS
SELECT
    NULL::text AS category,
    NULL::bigint AS element_id,
    NULL::bigint AS timeline_table_pk,
    NULL::text AS eventinfo_content,
    NULL::text AS eventinfo_tooltip,
    NULL::character varying AS icon_text;


--
-- Name: v_pathology_eventinfo_content; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_pathology_eventinfo_content AS
SELECT
    NULL::text AS category,
    NULL::bigint AS element_id,
    NULL::bigint AS timeline_table_pk,
    NULL::text AS eventinfo_content,
    NULL::text AS eventinfo_tooltip,
    NULL::character varying AS icon_text;


--
-- Name: v_radiology_procedure_set_eventinfo_content; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_radiology_procedure_set_eventinfo_content AS
SELECT
    NULL::text AS category,
    NULL::bigint AS element_id,
    NULL::bigint AS timeline_table_pk,
    NULL::text AS eventinfo_content,
    NULL::text AS eventinfo_tooltip,
    NULL::text AS icon_text;


--
-- Name: v_radiotherapy_eventinfo_content; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_radiotherapy_eventinfo_content AS
 SELECT 'radiotherapy'::text AS category,
    radiotherapy.element_id,
    radiotherapy.radiotherapy_id AS timeline_table_pk,
    concat(func.html_div('eventinfo_main'::text, ARRAY[ARRAY[('Hoitojakso: '::character varying)::text, (radiotherapy.course_id)::text], (ARRAY[('Fraktioita: '::text)::character varying, ((radiotherapy.number_of_fractions)::text)::character varying])::text[], ARRAY[('Annos: '::character varying)::text, (radiotherapy.total_dose_per_ref_point)::text]])) AS eventinfo_content,
    func.html_div('eventinfo_main'::text, ARRAY[ARRAY[('Hoitojakso: '::character varying)::text, (radiotherapy.course_id)::text]]) AS eventinfo_tooltip,
    NULL::character varying AS icon_text
   FROM patient_data.radiotherapy;


--
-- Name: v_referral_eventinfo_content; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_referral_eventinfo_content AS
 SELECT 'referral'::text AS category,
    referral.element_id,
    referral.referral_id AS timeline_table_pk,
    concat(func.html_div('eventinfo_unit'::text, ARRAY[ARRAY['Erikoisala: '::text,
        CASE
            WHEN ((referral.speciality_name)::text ~* (referral.speciality_code)::text) THEN (referral.speciality_name)::text
            ELSE concat_ws(' '::text, referral.speciality_code, referral.speciality_name)
        END], ARRAY[('Lähettäjä: '::character varying)::text, (referral.sending_doctor_name)::text], ARRAY[(''::character varying)::text, (referral.sending_unit_name)::text], ARRAY[(''::character varying)::text, (referral.sending_institution_name)::text], ARRAY['Vastaanottaja: '::text, concat_ws(' '::text, referral.receiving_unit_code, referral.receiving_unit_name)], ARRAY[(''::character varying)::text, (referral.receiving_institution_name)::text]]),
        CASE
            WHEN (referral.text_content IS NULL) THEN ''::text
            ELSE func.html_div('eventinfo_text'::text, ARRAY[ARRAY[referral.text_content]])
        END) AS eventinfo_content,
    concat(func.html_div('eventinfo_tooltip'::text, ARRAY[ARRAY[concat(referral.sending_unit_name, ' (', referral.sending_institution_name, ')')], ARRAY['-->'::text], ARRAY[concat(referral.receiving_unit_name, ' (', referral.receiving_institution_name, ')')]])) AS eventinfo_tooltip,
    NULL::character varying AS icon_text
   FROM patient_data.referral;


--
-- Name: v_surgery_eventinfo_content; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_surgery_eventinfo_content AS
SELECT
    NULL::text AS category,
    NULL::bigint AS element_id,
    NULL::bigint AS timeline_table_pk,
    NULL::text AS eventinfo_content,
    NULL::text AS eventinfo_tooltip,
    NULL::character varying AS icon_text;


--
-- Name: v_visit_eventinfo_content; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_visit_eventinfo_content AS
SELECT
    NULL::text AS category,
    NULL::bigint AS element_id,
    NULL::bigint AS timeline_table_pk,
    NULL::text AS eventinfo_content,
    NULL::text AS eventinfo_tooltip,
    NULL::character varying(50) AS icon_text;


--
-- Name: mv_eventinfo_contents; Type: MATERIALIZED VIEW; Schema: patient_data; Owner: -
--

CREATE MATERIALIZED VIEW patient_data.mv_eventinfo_contents AS
 SELECT v_surgery_eventinfo_content.category,
    v_surgery_eventinfo_content.element_id,
    v_surgery_eventinfo_content.timeline_table_pk,
    v_surgery_eventinfo_content.eventinfo_content,
    v_surgery_eventinfo_content.eventinfo_tooltip,
    v_surgery_eventinfo_content.icon_text
   FROM patient_data.v_surgery_eventinfo_content
UNION ALL
 SELECT v_pathology_eventinfo_content.category,
    v_pathology_eventinfo_content.element_id,
    v_pathology_eventinfo_content.timeline_table_pk,
    v_pathology_eventinfo_content.eventinfo_content,
    v_pathology_eventinfo_content.eventinfo_tooltip,
    v_pathology_eventinfo_content.icon_text
   FROM patient_data.v_pathology_eventinfo_content
UNION ALL
 SELECT v_referral_eventinfo_content.category,
    v_referral_eventinfo_content.element_id,
    v_referral_eventinfo_content.timeline_table_pk,
    v_referral_eventinfo_content.eventinfo_content,
    v_referral_eventinfo_content.eventinfo_tooltip,
    v_referral_eventinfo_content.icon_text
   FROM patient_data.v_referral_eventinfo_content
UNION ALL
 SELECT v_visit_eventinfo_content.category,
    v_visit_eventinfo_content.element_id,
    v_visit_eventinfo_content.timeline_table_pk,
    v_visit_eventinfo_content.eventinfo_content,
    v_visit_eventinfo_content.eventinfo_tooltip,
    v_visit_eventinfo_content.icon_text
   FROM patient_data.v_visit_eventinfo_content
UNION ALL
 SELECT v_episode_of_care_eventinfo_content.category,
    v_episode_of_care_eventinfo_content.element_id,
    v_episode_of_care_eventinfo_content.timeline_table_pk,
    v_episode_of_care_eventinfo_content.eventinfo_content,
    v_episode_of_care_eventinfo_content.eventinfo_tooltip,
    v_episode_of_care_eventinfo_content.icon_text
   FROM patient_data.v_episode_of_care_eventinfo_content
UNION ALL
 SELECT v_radiology_procedure_set_eventinfo_content.category,
    v_radiology_procedure_set_eventinfo_content.element_id,
    v_radiology_procedure_set_eventinfo_content.timeline_table_pk,
    v_radiology_procedure_set_eventinfo_content.eventinfo_content,
    v_radiology_procedure_set_eventinfo_content.eventinfo_tooltip,
    v_radiology_procedure_set_eventinfo_content.icon_text
   FROM patient_data.v_radiology_procedure_set_eventinfo_content
UNION ALL
 SELECT v_chemotherapy_course_eventinfo_content.category,
    v_chemotherapy_course_eventinfo_content.element_id,
    v_chemotherapy_course_eventinfo_content.timeline_table_pk,
    v_chemotherapy_course_eventinfo_content.eventinfo_content,
    v_chemotherapy_course_eventinfo_content.eventinfo_tooltip,
    v_chemotherapy_course_eventinfo_content.icon_text
   FROM patient_data.v_chemotherapy_course_eventinfo_content
UNION ALL
 SELECT v_radiotherapy_eventinfo_content.category,
    v_radiotherapy_eventinfo_content.element_id,
    v_radiotherapy_eventinfo_content.timeline_table_pk,
    v_radiotherapy_eventinfo_content.eventinfo_content,
    v_radiotherapy_eventinfo_content.eventinfo_tooltip,
    v_radiotherapy_eventinfo_content.icon_text
   FROM patient_data.v_radiotherapy_eventinfo_content
UNION ALL
 SELECT v_lab_package_eventinfo_content.category,
    v_lab_package_eventinfo_content.element_id,
    v_lab_package_eventinfo_content.timeline_table_pk,
    v_lab_package_eventinfo_content.eventinfo_content,
    v_lab_package_eventinfo_content.eventinfo_tooltip,
    v_lab_package_eventinfo_content.icon_text
   FROM patient_data.v_lab_package_eventinfo_content
UNION ALL
 SELECT v_medication_set_eventinfo_content.category,
    v_medication_set_eventinfo_content.element_id,
    v_medication_set_eventinfo_content.timeline_table_pk,
    v_medication_set_eventinfo_content.eventinfo_content,
    v_medication_set_eventinfo_content.eventinfo_tooltip,
    v_medication_set_eventinfo_content.icon_text
   FROM patient_data.v_medication_set_eventinfo_content
  WITH NO DATA;


--
-- Name: timeline_element_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.timeline_element_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timeline_element; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.timeline_element (
    element_id bigint DEFAULT nextval('patient_data.timeline_element_id_seq'::regclass) NOT NULL,
    person_id bigint NOT NULL,
    start_ts timestamp with time zone,
    end_ts timestamp with time zone,
    category text NOT NULL,
    unit text,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: mv_lab; Type: MATERIALIZED VIEW; Schema: patient_data; Owner: -
--

CREATE MATERIALIZED VIEW patient_data.mv_lab AS
 SELECT e.person_id,
        CASE
            WHEN ((t.test)::text ~* 'P-PSA[gls]'::text) THEN 'P-PSA (4869)'::character varying
            ELSE t.test
        END AS test,
    regexp_replace((t.result)::text, '(Alle | Yli |< ?|> ?)'::text, ''::text) AS result,
    t.unit,
    e.start_ts
   FROM ((patient_data.timeline_element e
     JOIN patient_data.lab_package p ON ((e.element_id = p.element_id)))
     JOIN patient_data.lab_test t ON ((p.lab_package_id = t.lab_package_id)))
  WITH NO DATA;


--
-- Name: significance; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.significance (
    significance_id integer NOT NULL,
    significance character varying(100) NOT NULL,
    priority_order integer NOT NULL
);


--
-- Name: mv_timeline_element; Type: MATERIALIZED VIEW; Schema: patient_data; Owner: -
--

CREATE MATERIALIZED VIEW patient_data.mv_timeline_element AS
 SELECT e.element_id,
    p.person_id,
    p.henkilotunnus,
    e.start_ts,
    e.end_ts,
        CASE
            WHEN (e.category = 'chemotherapy_course'::text) THEN 'sytostaattihoito'::text
            WHEN (e.category = 'episode_of_care'::text) THEN 'osastohoito'::text
            WHEN (e.category = 'surgery'::text) THEN 'leikkaus'::text
            WHEN (e.category = 'radiology_procedure_set'::text) THEN 'kuvantamistutkimus'::text
            WHEN (e.category = 'referral'::text) THEN 'lähete'::text
            WHEN (e.category = 'radiotherapy'::text) THEN 'sädehoito'::text
            WHEN (e.category = 'visit'::text) THEN 'käynti'::text
            WHEN (e.category = 'pathology'::text) THEN 'patologia'::text
            WHEN (e.category = 'medication_set'::text) THEN 'lääkitys'::text
            WHEN (e.category = 'lab_package'::text) THEN 'labra'::text
            ELSE NULL::text
        END AS category,
    e.unit,
    ec.eventinfo_content,
    ec.eventinfo_tooltip,
    ec.icon_text,
    COALESCE(es.significance_id, 3) AS significance_id,
    s.significance
   FROM ((((patient_data.timeline_element e
     LEFT JOIN base.person p ON ((e.person_id = p.person_id)))
     LEFT JOIN patient_data.element_significance es ON ((e.element_id = es.element_id)))
     LEFT JOIN patient_data.significance s ON ((COALESCE(es.significance_id, 3) = s.significance_id)))
     JOIN patient_data.mv_eventinfo_contents ec ON ((e.element_id = ec.element_id)))
  WITH NO DATA;


--
-- Name: visit_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.visit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visit; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.visit (
    visit_id bigint DEFAULT nextval('patient_data.visit_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    visit_type character varying(100),
    unit_code character varying(50),
    unit_name character varying(200),
    resource_code character varying(50),
    resource_name character varying(200),
    text_content text,
    text_pk text,
    source_pk character varying(50) NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: mv_visits_and_episodes; Type: MATERIALIZED VIEW; Schema: patient_data; Owner: -
--

CREATE MATERIALIZED VIEW patient_data.mv_visits_and_episodes AS
 SELECT e.element_id,
    'visit'::text AS service_type,
    v.visit_id,
    NULL::integer AS episode_of_care_id,
    e.person_id,
    e.start_ts
   FROM (patient_data.visit v
     JOIN patient_data.timeline_element e ON ((v.element_id = e.element_id)))
UNION ALL
 SELECT e.element_id,
    'episode_of_care'::text AS service_type,
    NULL::integer AS visit_id,
    c.episode_of_care_id,
    e.person_id,
    e.start_ts
   FROM (patient_data.episode_of_care c
     JOIN patient_data.timeline_element e ON ((c.element_id = e.element_id)))
  WITH NO DATA;


--
-- Name: pathology_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.pathology_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pathology; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.pathology (
    pathology_id bigint DEFAULT nextval('patient_data.pathology_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    source_pk character varying(8000),
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: pathology_answer_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.pathology_answer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pathology_answer; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.pathology_answer (
    pathology_answer_id bigint DEFAULT nextval('patient_data.pathology_answer_id_seq'::regclass) NOT NULL,
    pathology_id bigint NOT NULL,
    order_number integer NOT NULL,
    answer_number integer NOT NULL,
    acked date,
    ordering_unit character varying(8000),
    receiving_unit character varying(8000),
    anamnesis_text_content text,
    statement_text_content text,
    source_pk bigint NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: pathology_diagnosis_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.pathology_diagnosis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pathology_diagnosis; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.pathology_diagnosis (
    pathology_diagnosis_id bigint DEFAULT nextval('patient_data.pathology_diagnosis_id_seq'::regclass) NOT NULL,
    pathology_answer_id bigint NOT NULL,
    organ_prefix character varying(8000),
    organ character varying(8000),
    organ_suffix character varying(8000),
    diagnosis character varying(8000),
    diagnosis_suffix character varying(8000),
    diagnosis_row_number integer,
    source_pk bigint NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: pathology_examination_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.pathology_examination_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pathology_examination; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.pathology_examination (
    pathology_examination_id bigint DEFAULT nextval('patient_data.pathology_examination_id_seq'::regclass) NOT NULL,
    pathology_answer_id bigint NOT NULL,
    examination character varying(8000),
    examination_count integer,
    examination_row_number integer,
    source_pk bigint NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: pathology_table_data_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.pathology_table_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pathology_table_data; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.pathology_table_data (
    pathology_table_data_id bigint DEFAULT nextval('patient_data.pathology_table_data_id_seq'::regclass) NOT NULL,
    pathology_answer_id bigint NOT NULL,
    table_name character varying(8000) NOT NULL,
    question character varying(8000) NOT NULL,
    result character varying(8000),
    source_pk bigint NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: radiology_procedure_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.radiology_procedure_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: radiology_procedure; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.radiology_procedure (
    radiology_procedure_id bigint DEFAULT nextval('patient_data.radiology_procedure_id_seq'::regclass) NOT NULL,
    radiology_procedure_set_id bigint NOT NULL,
    procedure_code character varying(20),
    procedure_name character varying(200),
    procedure_type character varying,
    source_pk bigint,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: radiology_procedure_set_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.radiology_procedure_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: radiology_procedure_set; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.radiology_procedure_set (
    radiology_procedure_set_id bigint DEFAULT nextval('patient_data.radiology_procedure_set_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    source_pk character varying NOT NULL,
    ordering_unit_code character varying(200),
    procedure_type text,
    referral_text text,
    statement_text text,
    text_pk text,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: surgery_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.surgery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: surgery; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.surgery (
    surgery_id bigint DEFAULT nextval('patient_data.surgery_id_seq'::regclass) NOT NULL,
    element_id bigint NOT NULL,
    treating_unit_code character varying(50),
    treating_unit_name character varying(200),
    text_content text,
    text_pk character varying(500),
    source_pk bigint NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: surgery_procedure_id_seq; Type: SEQUENCE; Schema: patient_data; Owner: -
--

CREATE SEQUENCE patient_data.surgery_procedure_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: surgery_procedure; Type: TABLE; Schema: patient_data; Owner: -
--

CREATE TABLE patient_data.surgery_procedure (
    surgery_procedure_id bigint DEFAULT nextval('patient_data.surgery_procedure_id_seq'::regclass) NOT NULL,
    surgery_id bigint NOT NULL,
    procedure_code character varying(50),
    procedure_name character varying(200),
    diagnosis_code character varying(50),
    diagnosis_name character varying(200),
    is_main_procedure boolean NOT NULL,
    source_pk bigint NOT NULL,
    surgery_source_pk bigint NOT NULL,
    insert_ts timestamp with time zone DEFAULT now(),
    update_ts timestamp with time zone
);


--
-- Name: v_patients_for_testing; Type: VIEW; Schema: patient_data; Owner: -
--

CREATE VIEW patient_data.v_patients_for_testing AS
 WITH category_count AS (
         SELECT timeline_element.person_id
           FROM patient_data.timeline_element
          GROUP BY timeline_element.person_id
         HAVING (count(DISTINCT timeline_element.category) = 10)
        ), surgery AS (
         SELECT DISTINCT e.person_id
           FROM ((patient_data.timeline_element e
             JOIN patient_data.surgery s ON ((e.element_id = s.element_id)))
             JOIN patient_data.surgery_procedure sp ON ((s.surgery_id = sp.surgery_id)))
          GROUP BY e.person_id, s.surgery_id
         HAVING (count(DISTINCT sp.surgery_procedure_id) > 1)
        ), pathology AS (
         SELECT DISTINCT e.person_id
           FROM ((patient_data.timeline_element e
             JOIN patient_data.pathology s ON ((e.element_id = s.element_id)))
             JOIN patient_data.pathology_answer sp ON ((s.pathology_id = sp.pathology_id)))
          GROUP BY e.person_id, s.pathology_id
         HAVING (count(DISTINCT sp.pathology_answer_id) > 1)
        ), radiology AS (
         SELECT DISTINCT e.person_id
           FROM ((patient_data.timeline_element e
             JOIN patient_data.radiology_procedure_set s ON ((e.element_id = s.element_id)))
             JOIN patient_data.radiology_procedure sp ON ((s.radiology_procedure_set_id = sp.radiology_procedure_set_id)))
          GROUP BY e.person_id, s.radiology_procedure_set_id
         HAVING (count(DISTINCT sp.radiology_procedure_id) > 1)
        ), lab AS (
         SELECT DISTINCT e.person_id
           FROM ((patient_data.timeline_element e
             JOIN patient_data.lab_package s ON ((e.element_id = s.element_id)))
             JOIN patient_data.lab_test sp ON ((s.lab_package_id = sp.lab_package_id)))
          GROUP BY e.person_id, s.lab_package_id
         HAVING (count(DISTINCT sp.lab_test_id) > 1)
        ), visit AS (
         SELECT DISTINCT e.person_id
           FROM ((patient_data.timeline_element e
             JOIN patient_data.visit s ON ((e.element_id = s.element_id)))
             JOIN patient_data.diagnosis sp ON ((s.visit_id = sp.visit_id)))
          GROUP BY e.person_id, s.visit_id
         HAVING (count(DISTINCT sp.diagnosis_id) > 1)
        ), episode AS (
         SELECT DISTINCT e.person_id
           FROM ((patient_data.timeline_element e
             JOIN patient_data.episode_of_care s ON ((e.element_id = s.element_id)))
             JOIN patient_data.diagnosis sp ON ((s.episode_of_care_id = sp.episode_of_care_id)))
          GROUP BY e.person_id, s.episode_of_care_id
         HAVING (count(DISTINCT sp.diagnosis_id) > 1)
        ), chemo AS (
         SELECT DISTINCT e.person_id
           FROM (((patient_data.timeline_element e
             JOIN patient_data.chemotherapy_course c ON ((e.element_id = c.element_id)))
             JOIN patient_data.chemotherapy_cycle s ON ((c.chemotherapy_course_id = s.chemotherapy_course_id)))
             JOIN patient_data.chemotherapy_dose d ON ((s.chemotherapy_cycle_id = d.chemotherapy_cycle_id)))
          GROUP BY e.person_id, s.chemotherapy_cycle_id
         HAVING (count(DISTINCT d.chemotherapy_dose_id) > 1)
        ), meds AS (
         SELECT DISTINCT e.person_id
           FROM ((patient_data.timeline_element e
             JOIN patient_data.medication_set s ON ((e.element_id = s.element_id)))
             JOIN patient_data.medication sp ON ((s.medication_set_id = sp.medication_set_id)))
          GROUP BY e.person_id, s.medication_set_id
         HAVING (count(DISTINCT sp.medication_id) > 1)
        )
 SELECT p.person_id,
    p.henkilotunnus
   FROM ((((((((base.person p
     JOIN category_count ON ((p.person_id = category_count.person_id)))
     JOIN surgery ON ((p.person_id = surgery.person_id)))
     JOIN pathology ON ((p.person_id = pathology.person_id)))
     JOIN radiology ON ((p.person_id = radiology.person_id)))
     JOIN lab ON ((p.person_id = lab.person_id)))
     JOIN chemo ON ((p.person_id = chemo.person_id)))
     JOIN visit ON ((p.person_id = visit.person_id)))
     JOIN episode ON ((p.person_id = episode.person_id)));


--
-- Name: zz_visits_and_episodes; Type: MATERIALIZED VIEW; Schema: patient_data; Owner: -
--

CREATE MATERIALIZED VIEW patient_data.zz_visits_and_episodes AS
 SELECT eoc.episode_of_care_id AS service_id,
    eoc.element_id,
    eoc.unit_code,
    eoc.unit_name,
    'eoc'::text AS type
   FROM patient_data.episode_of_care eoc
UNION ALL
 SELECT v.visit_id AS service_id,
    v.element_id,
    v.unit_code,
    v.unit_name,
    'v'::text AS type
   FROM patient_data.visit v
  WITH NO DATA;


--
-- Name: zz_c61_palvelut; Type: MATERIALIZED VIEW; Schema: patient_data; Owner: -
--

CREATE MATERIALIZED VIEW patient_data.zz_c61_palvelut AS
 SELECT e.person_id,
    e.start_ts
   FROM ((patient_data.zz_visits_and_episodes p
     JOIN patient_data.timeline_element e ON ((p.element_id = e.element_id)))
     JOIN patient_data.diagnosis d ON (((p.type = 'eoc'::text) AND (p.service_id = d.episode_of_care_id))))
  WHERE ((d.diagnosis_code)::text ~* 'C61'::text)
UNION ALL
 SELECT e.person_id,
    e.start_ts
   FROM ((patient_data.zz_visits_and_episodes p
     JOIN patient_data.timeline_element e ON ((p.element_id = e.element_id)))
     JOIN patient_data.diagnosis d ON (((p.type = 'v'::text) AND (p.service_id = d.visit_id))))
  WHERE ((d.diagnosis_code)::text ~* 'C61'::text)
  WITH NO DATA;


--
-- Name: zz_min_dgn; Type: MATERIALIZED VIEW; Schema: patient_data; Owner: -
--

CREATE MATERIALIZED VIEW patient_data.zz_min_dgn AS
 SELECT zz_c61_palvelut.person_id,
    min(zz_c61_palvelut.start_ts) AS min_dgn
   FROM patient_data.zz_c61_palvelut
  GROUP BY zz_c61_palvelut.person_id
  WITH NO DATA;


--
-- Name: answer_seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.answer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answer_seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.answer_seq OWNED BY wtf.answer.answer_id;


--
-- Name: answer_set__seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.answer_set__seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answer_set__seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.answer_set__seq OWNED BY wtf.answer_set.answer_set_id;


--
-- Name: choice_seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.choice_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: choice_seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.choice_seq OWNED BY wtf.choice.choice_id;


--
-- Name: component; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.component (
    component_id bigint NOT NULL,
    component_type character varying NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: COLUMN component.component_type; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.component.component_type IS '"form_field" or "form_field_choice"';


--
-- Name: component_condition; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.component_condition (
    conditional_component_id bigint NOT NULL,
    determining_component_id bigint NOT NULL,
    negation boolean DEFAULT false NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: COLUMN component_condition.determining_component_id; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.component_condition.determining_component_id IS 'The visibility of this component depends on whether specific answers exist for the determining component for the same person. This component may be a form_field or a form_field_choice.';


--
-- Name: COLUMN component_condition.negation; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.component_condition.negation IS 'A true value in this column negates the normal condition. In negated circumstances, if the determining component is a form_field, negation means that if that field is NOT filled for that person, then the conditional component should be shown. As for determining form_field_choices in negated circumstances, such an answer prevents the conditional component from being shown.';


--
-- Name: component_hide; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.component_hide (
    component_id bigint NOT NULL,
    group_id bigint NOT NULL,
    valid_since timestamp without time zone NOT NULL,
    valid_until timestamp without time zone,
    valid boolean NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: TABLE component_hide; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON TABLE wtf.component_hide IS 'The default assumption is that a group member gets to see all components present in a form that the group has access to. This tables lists the exceptions, i.e. which components in those forms should be hidden from the group.';


--
-- Name: COLUMN component_hide.group_id; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.component_hide.group_id IS 'refers to member_id';


--
-- Name: component_seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.component_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: component_seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.component_seq OWNED BY wtf.component.component_id;


--
-- Name: context; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.context (
    context_id bigint NOT NULL,
    context_name character varying NOT NULL
);


--
-- Name: context__seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.context__seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: context__seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.context__seq OWNED BY wtf.context.context_id;


--
-- Name: data_type_seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.data_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_type_seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.data_type_seq OWNED BY wtf.data_type.data_type_id;


--
-- Name: field_filter; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.field_filter (
    field_id bigint NOT NULL,
    filter_id bigint NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: field_seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.field_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: field_seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.field_seq OWNED BY wtf.field.field_id;


--
-- Name: field_type_seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.field_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: field_type_seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.field_type_seq OWNED BY wtf.field_type.field_type_id;


--
-- Name: filter; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.filter (
    filter_id bigint NOT NULL,
    filter_name character varying NOT NULL,
    regex character varying,
    min_int bigint,
    max_int bigint,
    min_double double precision,
    max_double double precision,
    min_timestamp timestamp without time zone,
    max_timestamp timestamp without time zone,
    min_date date,
    max_date date,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: filter_seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.filter_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filter_seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.filter_seq OWNED BY wtf.filter.filter_id;


--
-- Name: form_field__seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.form_field__seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: form_field__seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.form_field__seq OWNED BY wtf.form_field.form_field_id;


--
-- Name: form_seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.form_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: form_seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.form_seq OWNED BY wtf.form.form_id;


--
-- Name: group_form_access; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.group_form_access (
    form_id bigint NOT NULL,
    group_id bigint NOT NULL,
    view_privilege boolean DEFAULT false NOT NULL,
    insert_privilege boolean DEFAULT false NOT NULL,
    modify_privilege boolean DEFAULT false NOT NULL,
    valid_since timestamp without time zone NOT NULL,
    valid_until character varying,
    valid boolean NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: TABLE group_form_access; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON TABLE wtf.group_form_access IS 'stores the root forms that each group has access to';


--
-- Name: COLUMN group_form_access.group_id; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.group_form_access.group_id IS 'refers to member_id';


--
-- Name: gui_element_type__seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.gui_element_type__seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gui_element_type__seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.gui_element_type__seq OWNED BY wtf.gui_element_type.gui_element_type_id;


--
-- Name: session_end_type; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.session_end_type (
    session_end_type_id integer NOT NULL,
    session_end_type_name character varying NOT NULL,
    insert_ts timestamp without time zone DEFAULT now() NOT NULL,
    update_ts timestamp without time zone
);


--
-- Name: COLUMN session_end_type.session_end_type_name; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.session_end_type.session_end_type_name IS '"logout" or "kickout"';


--
-- Name: session_end_type_seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.session_end_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: session_end_type_seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.session_end_type_seq OWNED BY wtf.session_end_type.session_end_type_id;


--
-- Name: session_seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.session_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: session_seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.session_seq OWNED BY wtf.session.session_id;


--
-- Name: synonym; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.synonym (
    synonym_id bigint NOT NULL,
    context_id bigint NOT NULL,
    synonym_name character varying NOT NULL,
    referred_table character varying NOT NULL,
    referred_id bigint NOT NULL
);


--
-- Name: COLUMN synonym.referred_table; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.synonym.referred_table IS 'options "component", "form", "field", "choice"';


--
-- Name: COLUMN synonym.referred_id; Type: COMMENT; Schema: wtf; Owner: -
--

COMMENT ON COLUMN wtf.synonym.referred_id IS 'the primary key value of the table named in the "referred table" column. This points to the concept that this synonym is synonymous to.';


--
-- Name: synonym__seq; Type: SEQUENCE; Schema: wtf; Owner: -
--

CREATE SEQUENCE wtf.synonym__seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: synonym__seq; Type: SEQUENCE OWNED BY; Schema: wtf; Owner: -
--

ALTER SEQUENCE wtf.synonym__seq OWNED BY wtf.synonym.synonym_id;


--
-- Name: user_group_analytics_activity_status; Type: TABLE; Schema: wtf; Owner: -
--

CREATE TABLE wtf.user_group_analytics_activity_status (
    user_group_id bigint NOT NULL,
    analytics_active boolean NOT NULL
);


--
-- Name: v_forms; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_forms AS
 SELECT g.group_id AS owner_group_id,
    g.group_name AS owner_group_name,
    f.form_id,
    f.parent_form_id,
    wtf.get_form_lineage(f.form_id) AS form_lineage,
    f.form_name,
        CASE
            WHEN (f.parent_form_id IS NULL) THEN true
            ELSE false
        END AS is_root_form,
        CASE
            WHEN (EXISTS ( SELECT f2.form_id
               FROM wtf.form f2
              WHERE (f2.parent_form_id = f.form_id))) THEN false
            ELSE true
        END AS is_leaf_form,
    f.header AS form_header,
    f.footer AS form_footer,
    f.refillable AS form_refillable,
    f.person_specific AS form_person_specific,
    f.number AS form_number
   FROM (wtf.form f
     JOIN base.user_group g ON ((f.owner_group_id = g.group_id)))
  WHERE (f.valid_until IS NULL);


--
-- Name: v_form_fields; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_form_fields AS
 SELECT DISTINCT h.owner_group_id,
    h.owner_group_name,
    h.form_id,
    h.parent_form_id,
    h.form_lineage,
    h.form_name,
    h.is_root_form,
    h.is_leaf_form,
    h.form_header,
    h.form_footer,
    h.form_refillable,
    h.form_number,
    h.form_person_specific,
    ff.form_field_id,
    ff.component_id,
    f.field_id,
    ff.number AS field_number,
        CASE
            WHEN (ff.form_field_id IS NULL) THEN NULL::integer[]
            ELSE (regexp_split_to_array(concat_ws('|'::text, ( SELECT wtf.get_field_number_lineage(ff.form_field_id) AS get_field_number_lineage), ff.number), '\|'::text))::integer[]
        END AS field_number_nesting_order,
    ff.section_number,
    ff.identifier AS field_identifier,
    f.field_name,
    concat_ws(' '::text, ff.identifier, f.field_name) AS field_long_name,
    f.description AS field_description,
    ft.field_type_name,
    dt.data_type_name,
    et.name AS gui_element_type,
    et.orientation AS gui_element_orientation,
    ff.is_required AS field_is_required,
        CASE
            WHEN (cc.conditional_component_id IS NULL) THEN false
            ELSE true
        END AS is_conditional,
    ff.unique_to_form,
    ff.is_event_ts_field,
    ff_parent.form_field_id AS parent_form_field_id,
    f_parent.field_id AS parent_field_id,
    f_parent.field_name AS parent_field_name
   FROM ((((((((wtf.v_forms h
     JOIN wtf.form_field ff ON ((h.form_id = ff.form_id)))
     LEFT JOIN wtf.gui_element_type et ON ((ff.gui_element_type_id = et.gui_element_type_id)))
     LEFT JOIN wtf.field f ON ((ff.field_id = f.field_id)))
     LEFT JOIN wtf.field_type ft ON ((f.field_type_id = ft.field_type_id)))
     LEFT JOIN wtf.data_type dt ON ((f.data_type_id = dt.data_type_id)))
     LEFT JOIN wtf.component_condition cc ON ((ff.component_id = cc.conditional_component_id)))
     LEFT JOIN wtf.form_field ff_parent ON ((ff.parent_form_field_id = ff_parent.form_field_id)))
     LEFT JOIN wtf.field f_parent ON ((ff_parent.field_id = f_parent.field_id)))
  ORDER BY h.parent_form_id, h.form_number, ff.number;


--
-- Name: v_analytics_field_synonyms; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_analytics_field_synonyms AS
 SELECT ff.form_field_id,
    s.referred_id AS component_id,
    ff.field_name,
    func.simplify_characters(COALESCE(concat_ws('_'::text, ( SELECT wtf.get_field_lineage(ff.form_field_id, 'analytics'::text) AS get_field_lineage), COALESCE(s.synonym_name, ff.field_name)))) AS field_analytics_name
   FROM ((wtf.v_form_fields ff
     LEFT JOIN wtf.synonym s ON (((ff.component_id = s.referred_id) AND ((s.referred_table)::text = 'component'::text))))
     LEFT JOIN wtf.context c ON (((s.context_id = c.context_id) AND ((c.context_name)::text = 'analytics'::text))))
  WHERE (ff.form_field_id IS NOT NULL);


--
-- Name: v_analytics_form_synonyms; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_analytics_form_synonyms AS
 SELECT DISTINCT f.form_id,
    f.form_name,
    func.simplify_characters((ug.group_name)::text) AS analytics_schema_name,
    func.simplify_characters(COALESCE(concat_ws('_'::text, ( SELECT wtf.get_form_lineage(f.form_id, 'analytics'::text) AS get_form_lineage), COALESCE(s.synonym_name, f.form_name)))) AS form_analytics_name
   FROM ((((wtf.form f
     JOIN base.user_group ug ON ((f.owner_group_id = ug.group_id)))
     JOIN wtf.user_group_analytics_activity_status ugaas ON (((ug.group_id = ugaas.user_group_id) AND (ugaas.analytics_active = true))))
     LEFT JOIN wtf.synonym s ON (((f.form_id = s.referred_id) AND ((s.referred_table)::text = 'form'::text))))
     LEFT JOIN wtf.context c ON (((s.context_id = c.context_id) AND ((c.context_name)::text = 'analytics'::text))));


--
-- Name: v_answer_sets; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_answer_sets AS
 SELECT s.session_id,
    s.person_id,
    p.henkilotunnus,
    s.session_started_ts,
    s.session_ended_ts,
    set.session_end_type_name,
    s.app_user_id,
    concat_ws(' '::text, u.first_name, u.last_name) AS login_user,
    s.group_id AS user_group_id,
    ug.group_name AS user_group_name,
    sf.form_id,
    wtf.get_form_lineage(sf.form_id) AS form_lineage,
    f.form_name,
    sf.number,
    sf.answer_set_id,
    sf.open_ts,
    sf.close_ts,
    sf.save_ts,
    sf.insert_ts,
    sf.invalidated_ts,
    sf.replaced_by_answer_set_id
   FROM ((((((wtf.answer_set sf
     JOIN wtf.session s ON ((sf.session_id = s.session_id)))
     JOIN wtf.form f ON ((sf.form_id = f.form_id)))
     LEFT JOIN base.person p ON ((s.person_id = p.person_id)))
     JOIN base.app_user u ON ((s.app_user_id = u.app_user_id)))
     JOIN base.user_group ug ON ((s.group_id = ug.group_id)))
     LEFT JOIN wtf.session_end_type set ON ((s.session_end_type_id = set.session_end_type_id)))
  WHERE (sf.invalidated_ts IS NULL);


--
-- Name: v_answer_sets_history; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_answer_sets_history AS
 SELECT s.session_id,
    s.person_id,
    p.henkilotunnus,
    s.session_started_ts,
    s.session_ended_ts,
    set.session_end_type_name,
    s.app_user_id,
    concat_ws(' '::text, u.first_name, u.last_name) AS login_user,
    s.group_id AS user_group_id,
    ug.group_name AS user_group_name,
    sf.form_id,
    wtf.get_form_lineage(sf.form_id) AS form_lineage,
    f.form_name,
    sf.number,
    sf.answer_set_id,
    sf.open_ts,
    sf.close_ts,
    sf.save_ts,
    sf.insert_ts,
    sf.invalidated_ts,
    sf.replaced_by_answer_set_id
   FROM ((((((wtf.answer_set sf
     JOIN wtf.session s ON ((sf.session_id = s.session_id)))
     JOIN wtf.form f ON ((sf.form_id = f.form_id)))
     LEFT JOIN base.person p ON ((s.person_id = p.person_id)))
     JOIN base.app_user u ON ((s.app_user_id = u.app_user_id)))
     JOIN base.user_group ug ON ((s.group_id = ug.group_id)))
     LEFT JOIN wtf.session_end_type set ON ((s.session_end_type_id = set.session_end_type_id)));


--
-- Name: v_answers_content; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_answers_content AS
 SELECT a.person_id,
    a.answer_set_id,
    a.session_id,
    a.form_id,
    COALESCE(min(
        CASE
            WHEN ((a.is_event_ts_field = true) AND ((a.free_text)::date <> (a.open_ts)::date)) THEN (a.free_text)::timestamp with time zone
            ELSE NULL::timestamp with time zone
        END), (a.open_ts)::timestamp with time zone) AS open_ts,
    concat(func.html_div('wtf_form_name'::text, ARRAY[ARRAY[replace(concat_ws('|'::text, a.form_lineage, (a.form_name)::text), '|'::text, ' - '::text)]]),
        CASE
            WHEN ((a.form_lineage = 'Urologian potilaslomakkeet'::text) AND ((a.form_name)::text = 'EPIC'::text) AND (EXISTS ( SELECT views.table_name
               FROM information_schema.views
              WHERE (((views.table_schema)::text = 'mining'::text) AND ((views.table_name)::text = 'v_measurements'::text))))) THEN func.html_div('wtf_form_summary'::text, ( SELECT array_agg(ARRAY[concat(m.series_name, ': '), ((m.value)::integer)::text] ORDER BY m.series_group, m.series_name) AS array_agg
               FROM mining.v_measurements m
              WHERE ((a.person_id = m.person_id) AND (a.open_ts = m.ts) AND (m.series_group = ANY (ARRAY['EPIC keskeiset'::text, 'EPIC muut'::text])))
              GROUP BY m.person_id, m.ts))
            ELSE ''::text
        END, func.html_div('wtf_form'::text, array_agg(ARRAY[concat(a.field_name, ': '), (COALESCE(a.choice_name, a.free_text))::text] ORDER BY a.field_number_nesting_order))) AS answer_content
   FROM wtf.v_answers a
  GROUP BY a.form_lineage, a.form_name, a.session_id, a.form_id, a.answer_set_id, a.open_ts, a.person_id;


--
-- Name: v_answers_history; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_answers_history AS
 SELECT ans.session_id,
    s.person_id,
    p.henkilotunnus,
    s.app_user_id,
    ans.open_ts,
    ans.save_ts,
    a.insert_ts AS answer_insert_ts,
    a.answer_id,
    a.answer_set_id,
        CASE
            WHEN (ans.invalidated_ts IS NULL) THEN true
            ELSE false
        END AS answer_set_is_valid,
    ans.invalidated_ts,
    ans.replaced_by_answer_set_id,
    a.free_text,
    regexp_replace(wtf.get_form_lineage(ffc.form_id), '^.*? - '::text, ''::text) AS form_lineage,
    ffc.form_field_id,
    ffc.form_id,
    ffc.form_name,
    ffc.form_header,
    ffc.form_footer,
    ffc.form_field_component_id,
    ffc.field_id,
    ffc.is_event_ts_field,
    wtf.get_field_lineage(ffc.form_field_id) AS field_lineage,
    ffc.field_number,
    ffc.field_number_nesting_order,
    ffc.section_number,
    ffc.field_identifier,
    ffc.field_name,
    concat_ws(' '::text, ffc.field_identifier, ffc.field_name) AS field_long_name,
    ffc.field_description,
    ffc.data_type_name,
    ffc.field_type_name,
    ffc.field_is_required,
    ffc.field_unique_to_form,
    ffc.form_field_choice_component_id,
    ffc.choice_id,
    ffc.choice_name,
    ffc.choice_description,
    ffc.choice_number,
    ffc.choice_identifier,
    concat_ws(' '::text, ffc.choice_identifier, ffc.choice_name) AS choice_long_name,
    ffc.choice_points
   FROM ((((wtf.answer a
     JOIN wtf.answer_set ans ON ((a.answer_set_id = ans.answer_set_id)))
     JOIN wtf.session s ON ((ans.session_id = s.session_id)))
     JOIN wtf.v_form_field_choices ffc ON (((a.form_field_id = ffc.form_field_id) AND ((a.choice_id = ffc.choice_id) OR ((ffc.choice_id IS NULL) AND ((ffc.field_type_name)::text = 'vapaa_teksti'::text))))))
     JOIN base.person p ON ((s.person_id = p.person_id)));


--
-- Name: v_components; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_components AS
 SELECT DISTINCT 'form_field'::text AS component_type,
    v_form_field_choices.form_field_component_id AS component_id,
    v_form_field_choices.form_field_id,
    v_form_field_choices.form_id,
    v_form_field_choices.form_name,
    v_form_field_choices.form_header,
    v_form_field_choices.form_footer,
    v_form_field_choices.field_id,
    v_form_field_choices.field_number,
    v_form_field_choices.field_name,
    v_form_field_choices.field_description,
    v_form_field_choices.field_identifier,
    v_form_field_choices.data_type_name,
    v_form_field_choices.field_type_name,
    v_form_field_choices.field_is_required,
    NULL::integer AS choice_number,
    NULL::text AS choice_identifer,
    NULL::text AS choice_description,
    NULL::bigint AS choice_id,
    NULL::character varying AS choice_name
   FROM wtf.v_form_field_choices
UNION ALL
 SELECT 'form_field_choice'::text AS component_type,
    v_form_field_choices.form_field_choice_component_id AS component_id,
    v_form_field_choices.form_field_id,
    v_form_field_choices.form_id,
    v_form_field_choices.form_name,
    v_form_field_choices.form_header,
    v_form_field_choices.form_footer,
    v_form_field_choices.field_id,
    v_form_field_choices.field_number,
    v_form_field_choices.field_name,
    v_form_field_choices.field_description,
    v_form_field_choices.field_identifier,
    v_form_field_choices.data_type_name,
    v_form_field_choices.field_type_name,
    v_form_field_choices.field_is_required,
    v_form_field_choices.choice_number,
    v_form_field_choices.choice_identifier AS choice_identifer,
    v_form_field_choices.choice_description,
    v_form_field_choices.choice_id,
    v_form_field_choices.choice_name
   FROM wtf.v_form_field_choices
  WHERE (v_form_field_choices.choice_id IS NOT NULL)
  ORDER BY 1, 5, 9, 16;


--
-- Name: v_component_conditions; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_component_conditions AS
 SELECT c.component_type AS conditional_component_type,
    c.component_id AS conditional_component_id,
    c.form_field_id AS conditional_form_field_id,
    c.form_id AS conditional_form_id,
    c.form_name AS conditional_form_name,
    c.field_id AS conditional_field_id,
    c.field_name AS conditional_field_name,
    c.choice_id AS conditional_choice_id,
    c.choice_name AS conditional_choice_name,
    d.component_type AS determining_component_type,
    d.component_id AS determining_component_id,
    d.form_field_id AS determining_form_field_id,
    d.form_id AS determining_form_id,
    d.form_name AS determining_form_name,
    d.field_id AS determining_field_id,
    d.field_name AS determining_field_name,
    d.choice_id AS determining_choice_id,
    d.choice_name AS determining_choice_name,
    link.negation AS determining_component_negated
   FROM ((wtf.v_components c
     JOIN wtf.component_condition link ON ((c.component_id = link.conditional_component_id)))
     JOIN wtf.v_components d ON ((link.determining_component_id = d.component_id)));


--
-- Name: v_condition_definitions_for_export; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_condition_definitions_for_export AS
 SELECT cc.conditional_form_id,
    cc.conditional_field_name AS "Conditional_field_name",
    array_to_string(conditional_ff.field_number_nesting_order, '|'::text) AS "Conditional_field_number_with_pipe_separator",
    cc.conditional_choice_name AS "Conditional_choice_name",
    concat_ws('|'::text, wtf.get_form_lineage(cc.determining_form_id), cc.determining_form_name) AS "Determining_form_path_with_pipe_separator",
    cc.determining_field_name AS "Determining_field_name",
    concat_ws('|'::text, wtf.get_field_number_lineage(determining_ff.form_field_id), determining_ff.field_number) AS "Determining_field_number_with_pipe_separator",
    cc.determining_choice_name AS "Determining_choice_name",
    cc.determining_component_negated AS "Condition_negated"
   FROM ((wtf.v_component_conditions cc
     JOIN wtf.v_form_fields conditional_ff ON ((cc.conditional_form_field_id = conditional_ff.form_field_id)))
     JOIN wtf.v_form_fields determining_ff ON ((cc.determining_form_field_id = determining_ff.form_field_id)))
  ORDER BY cc.conditional_form_id, conditional_ff.field_number_nesting_order;


--
-- Name: v_form_field_definitions_for_export; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_form_field_definitions_for_export AS
 SELECT v_form_field_choices.form_id,
    v_form_field_choices.section_number AS "Form_subsection_number",
    wtf.get_form_lineage(v_form_field_choices.form_id) AS form_lineage,
    v_form_field_choices.form_name,
    v_form_field_choices.field_name AS "Field_name",
    array_to_string(v_form_field_choices.field_number_nesting_order, '|'::text) AS "Field_number_with_pipe_separator",
    v_form_field_choices.field_description AS "Field_help_text",
    v_form_field_choices.field_type_name AS "Field_type",
    v_form_field_choices.data_type_name AS "Data_type",
    v_form_field_choices.field_identifier AS "Field_identifier",
    v_form_field_choices.is_event_ts_field AS "Field_denotes_primary_event_time",
    v_form_field_choices.field_is_required AS "Field_is_obligatory",
    (NOT v_form_field_choices.field_unique_to_form) AS "Field_data_transferrable_to_other_form",
    vafs.field_analytics_name AS "Field_short_name_for_analytics",
    v_form_field_choices.gui_element_type AS "GUI_component",
    v_form_field_choices.gui_element_orientation AS "GUI_component_orientation",
    v_form_field_choices.choice_number AS "Choice_number",
    v_form_field_choices.choice_name AS "Choice_name",
    v_form_field_choices.choice_description AS "Choice_help_text",
    v_form_field_choices.choice_identifier AS "Choice_identifier",
    v_form_field_choices.choice_points AS "Choice_points"
   FROM (wtf.v_form_field_choices
     LEFT JOIN wtf.v_analytics_field_synonyms vafs ON ((v_form_field_choices.form_field_id = vafs.form_field_id)))
  ORDER BY v_form_field_choices.form_id, v_form_field_choices.field_number_nesting_order, v_form_field_choices.choice_number;


--
-- Name: v_group_form_access; Type: VIEW; Schema: wtf; Owner: -
--

CREATE VIEW wtf.v_group_form_access AS
 SELECT a.group_id,
    g.group_name,
    a.form_id,
    f.form_name,
    a.view_privilege,
    a.insert_privilege,
    a.modify_privilege,
    a.valid_since,
    a.valid_until,
    a.valid,
    a.insert_ts,
    a.update_ts
   FROM ((wtf.group_form_access a
     JOIN base.user_group g ON ((a.group_id = g.group_id)))
     JOIN wtf.form f ON ((a.form_id = f.form_id)));


--
-- Name: feature feature_id; Type: DEFAULT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.feature ALTER COLUMN feature_id SET DEFAULT nextval('base.feature__seq'::regclass);


--
-- Name: member member_id; Type: DEFAULT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.member ALTER COLUMN member_id SET DEFAULT nextval('base.member_seq'::regclass);


--
-- Name: cdc_time cdc_time_id; Type: DEFAULT; Schema: mining; Owner: -
--

ALTER TABLE ONLY mining.cdc_time ALTER COLUMN cdc_time_id SET DEFAULT nextval('mining.cdc_time_cdc_time_id_seq'::regclass);


--
-- Name: answer answer_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.answer ALTER COLUMN answer_id SET DEFAULT nextval('wtf.answer_seq'::regclass);


--
-- Name: answer_set answer_set_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.answer_set ALTER COLUMN answer_set_id SET DEFAULT nextval('wtf.answer_set__seq'::regclass);


--
-- Name: choice choice_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.choice ALTER COLUMN choice_id SET DEFAULT nextval('wtf.choice_seq'::regclass);


--
-- Name: component component_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.component ALTER COLUMN component_id SET DEFAULT nextval('wtf.component_seq'::regclass);


--
-- Name: context context_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.context ALTER COLUMN context_id SET DEFAULT nextval('wtf.context__seq'::regclass);


--
-- Name: data_type data_type_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.data_type ALTER COLUMN data_type_id SET DEFAULT nextval('wtf.data_type_seq'::regclass);


--
-- Name: field field_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.field ALTER COLUMN field_id SET DEFAULT nextval('wtf.field_seq'::regclass);


--
-- Name: field_type field_type_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.field_type ALTER COLUMN field_type_id SET DEFAULT nextval('wtf.field_type_seq'::regclass);


--
-- Name: filter filter_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.filter ALTER COLUMN filter_id SET DEFAULT nextval('wtf.filter_seq'::regclass);


--
-- Name: form form_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form ALTER COLUMN form_id SET DEFAULT nextval('wtf.form_seq'::regclass);


--
-- Name: form_field form_field_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field ALTER COLUMN form_field_id SET DEFAULT nextval('wtf.form_field__seq'::regclass);


--
-- Name: gui_element_type gui_element_type_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.gui_element_type ALTER COLUMN gui_element_type_id SET DEFAULT nextval('wtf.gui_element_type__seq'::regclass);


--
-- Name: session session_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.session ALTER COLUMN session_id SET DEFAULT nextval('wtf.session_seq'::regclass);


--
-- Name: session_end_type session_end_type_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.session_end_type ALTER COLUMN session_end_type_id SET DEFAULT nextval('wtf.session_end_type_seq'::regclass);


--
-- Name: synonym synonym_id; Type: DEFAULT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.synonym ALTER COLUMN synonym_id SET DEFAULT nextval('wtf.synonym__seq'::regclass);


--
-- Name: app_user app_user_pk; Type: CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.app_user
    ADD CONSTRAINT app_user_pk PRIMARY KEY (app_user_id);


--
-- Name: feature feature_pk; Type: CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.feature
    ADD CONSTRAINT feature_pk PRIMARY KEY (feature_id);


--
-- Name: group_feature_access group_feature_access_pk; Type: CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.group_feature_access
    ADD CONSTRAINT group_feature_access_pk PRIMARY KEY (group_id, feature_id);


--
-- Name: group_membership group_membership_pk; Type: CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.group_membership
    ADD CONSTRAINT group_membership_pk PRIMARY KEY (member_id, group_id);


--
-- Name: member member_pk; Type: CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.member
    ADD CONSTRAINT member_pk PRIMARY KEY (member_id);


--
-- Name: parameters parameters_pkey; Type: CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.parameters
    ADD CONSTRAINT parameters_pkey PRIMARY KEY (parameter_name);


--
-- Name: person person_henkilotunnus_key; Type: CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.person
    ADD CONSTRAINT person_henkilotunnus_key UNIQUE (henkilotunnus);


--
-- Name: person person_pk; Type: CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.person
    ADD CONSTRAINT person_pk PRIMARY KEY (person_id);


--
-- Name: user_group user_group_pk; Type: CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.user_group
    ADD CONSTRAINT user_group_pk PRIMARY KEY (group_id);


--
-- Name: cdc_time cdc_time_pkey; Type: CONSTRAINT; Schema: mining; Owner: -
--

ALTER TABLE ONLY mining.cdc_time
    ADD CONSTRAINT cdc_time_pkey PRIMARY KEY (cdc_time_id);


--
-- Name: epic_scoring epic_scoring_pkey; Type: CONSTRAINT; Schema: mining; Owner: -
--

ALTER TABLE ONLY mining.epic_scoring
    ADD CONSTRAINT epic_scoring_pkey PRIMARY KEY (field_number_nesting_order);


--
-- Name: cdc_time process_name_unique; Type: CONSTRAINT; Schema: mining; Owner: -
--

ALTER TABLE ONLY mining.cdc_time
    ADD CONSTRAINT process_name_unique UNIQUE (process_name);


--
-- Name: cdc_time cdc_time_pkey; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.cdc_time
    ADD CONSTRAINT cdc_time_pkey PRIMARY KEY (cdc_time_id);


--
-- Name: chemotherapy_course chemotherapy_course_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.chemotherapy_course
    ADD CONSTRAINT chemotherapy_course_pk PRIMARY KEY (chemotherapy_course_id);


--
-- Name: chemotherapy_cycle chemotherapy_cycle_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.chemotherapy_cycle
    ADD CONSTRAINT chemotherapy_cycle_pk PRIMARY KEY (chemotherapy_cycle_id);


--
-- Name: chemotherapy_dose chemotherapy_dose_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.chemotherapy_dose
    ADD CONSTRAINT chemotherapy_dose_pk PRIMARY KEY (chemotherapy_dose_id);


--
-- Name: clinical_finding clinical_finding_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.clinical_finding
    ADD CONSTRAINT clinical_finding_pk PRIMARY KEY (clinical_finding_id);


--
-- Name: diagnosis diagnosis_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.diagnosis
    ADD CONSTRAINT diagnosis_pk PRIMARY KEY (diagnosis_id);


--
-- Name: element_significance element_significance_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.element_significance
    ADD CONSTRAINT element_significance_pk PRIMARY KEY (element_id, specialty_id);


--
-- Name: episode_of_care episode_of_care_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.episode_of_care
    ADD CONSTRAINT episode_of_care_pk PRIMARY KEY (episode_of_care_id);


--
-- Name: lab_package lab_package_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.lab_package
    ADD CONSTRAINT lab_package_pk PRIMARY KEY (lab_package_id);


--
-- Name: lab_test lab_test_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.lab_test
    ADD CONSTRAINT lab_test_pk PRIMARY KEY (lab_test_id);


--
-- Name: medication medication_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.medication
    ADD CONSTRAINT medication_pk PRIMARY KEY (medication_id);


--
-- Name: medication_set medication_set_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.medication_set
    ADD CONSTRAINT medication_set_pk PRIMARY KEY (medication_set_id);


--
-- Name: pathology_answer pathology_answer_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.pathology_answer
    ADD CONSTRAINT pathology_answer_pk PRIMARY KEY (pathology_answer_id);


--
-- Name: pathology_diagnosis pathology_diagnosis_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.pathology_diagnosis
    ADD CONSTRAINT pathology_diagnosis_pk PRIMARY KEY (pathology_diagnosis_id);


--
-- Name: pathology_examination pathology_examination_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.pathology_examination
    ADD CONSTRAINT pathology_examination_pk PRIMARY KEY (pathology_examination_id);


--
-- Name: pathology pathology_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.pathology
    ADD CONSTRAINT pathology_pk PRIMARY KEY (pathology_id);


--
-- Name: pathology_table_data pathology_table_data_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.pathology_table_data
    ADD CONSTRAINT pathology_table_data_pk PRIMARY KEY (pathology_table_data_id);


--
-- Name: cdc_time process_name_unique; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.cdc_time
    ADD CONSTRAINT process_name_unique UNIQUE (process_name);


--
-- Name: radiology_procedure radiology_procedure_pkey; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.radiology_procedure
    ADD CONSTRAINT radiology_procedure_pkey PRIMARY KEY (radiology_procedure_id);


--
-- Name: radiology_procedure_set radiology_procedure_set_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.radiology_procedure_set
    ADD CONSTRAINT radiology_procedure_set_pk PRIMARY KEY (radiology_procedure_set_id);


--
-- Name: radiotherapy radiotherapy_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.radiotherapy
    ADD CONSTRAINT radiotherapy_pk PRIMARY KEY (radiotherapy_id);


--
-- Name: referral referral_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.referral
    ADD CONSTRAINT referral_pk PRIMARY KEY (referral_id);


--
-- Name: significance significance_pkey; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.significance
    ADD CONSTRAINT significance_pkey PRIMARY KEY (significance_id);


--
-- Name: significance significance_priority_order_key; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.significance
    ADD CONSTRAINT significance_priority_order_key UNIQUE (priority_order);


--
-- Name: significance significance_significance_key; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.significance
    ADD CONSTRAINT significance_significance_key UNIQUE (significance);


--
-- Name: surgery surgery_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.surgery
    ADD CONSTRAINT surgery_pk PRIMARY KEY (surgery_id);


--
-- Name: surgery_procedure surgery_procedure_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.surgery_procedure
    ADD CONSTRAINT surgery_procedure_pk PRIMARY KEY (surgery_procedure_id);


--
-- Name: timeline_element timeline_element_id_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.timeline_element
    ADD CONSTRAINT timeline_element_id_pk PRIMARY KEY (element_id);


--
-- Name: visit visit_pk; Type: CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.visit
    ADD CONSTRAINT visit_pk PRIMARY KEY (visit_id);


--
-- Name: answer answer_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.answer
    ADD CONSTRAINT answer_pk PRIMARY KEY (answer_id);


--
-- Name: answer_set answer_set_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.answer_set
    ADD CONSTRAINT answer_set_pk PRIMARY KEY (answer_set_id);


--
-- Name: choice choice_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.choice
    ADD CONSTRAINT choice_pk PRIMARY KEY (choice_id);


--
-- Name: component_condition component_condition_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.component_condition
    ADD CONSTRAINT component_condition_pk PRIMARY KEY (conditional_component_id, determining_component_id);


--
-- Name: component_hide component_hide_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.component_hide
    ADD CONSTRAINT component_hide_pk PRIMARY KEY (component_id, group_id);


--
-- Name: component component_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.component
    ADD CONSTRAINT component_pk PRIMARY KEY (component_id);


--
-- Name: context context_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.context
    ADD CONSTRAINT context_pk PRIMARY KEY (context_id);


--
-- Name: data_type data_type_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.data_type
    ADD CONSTRAINT data_type_pk PRIMARY KEY (data_type_id);


--
-- Name: field_filter field_filter_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.field_filter
    ADD CONSTRAINT field_filter_pk PRIMARY KEY (field_id, filter_id);


--
-- Name: field field_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.field
    ADD CONSTRAINT field_pk PRIMARY KEY (field_id);


--
-- Name: field_type field_type_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.field_type
    ADD CONSTRAINT field_type_pk PRIMARY KEY (field_type_id);


--
-- Name: filter filter_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.filter
    ADD CONSTRAINT filter_pk PRIMARY KEY (filter_id);


--
-- Name: form_field_choice form_field_choice_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field_choice
    ADD CONSTRAINT form_field_choice_pk PRIMARY KEY (choice_id, form_field_id);


--
-- Name: form_field form_field_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field
    ADD CONSTRAINT form_field_pk PRIMARY KEY (form_field_id);


--
-- Name: form form_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form
    ADD CONSTRAINT form_pk PRIMARY KEY (form_id);


--
-- Name: group_form_access group_form_access_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.group_form_access
    ADD CONSTRAINT group_form_access_pk PRIMARY KEY (form_id, group_id);


--
-- Name: gui_element_type gui_element_type_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.gui_element_type
    ADD CONSTRAINT gui_element_type_pk PRIMARY KEY (gui_element_type_id);


--
-- Name: session_end_type session_end_type_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.session_end_type
    ADD CONSTRAINT session_end_type_pk PRIMARY KEY (session_end_type_id);


--
-- Name: session session_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.session
    ADD CONSTRAINT session_pk PRIMARY KEY (session_id);


--
-- Name: synonym synonym_pk; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.synonym
    ADD CONSTRAINT synonym_pk PRIMARY KEY (synonym_id);


--
-- Name: user_group_analytics_activity_status user_group_analytics_activity_status_pkey; Type: CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.user_group_analytics_activity_status
    ADD CONSTRAINT user_group_analytics_activity_status_pkey PRIMARY KEY (user_group_id);


--
-- Name: app_user_email_unique; Type: INDEX; Schema: base; Owner: -
--

CREATE UNIQUE INDEX app_user_email_unique ON base.app_user USING btree (email);


--
-- Name: app_user_fname_lname_unique; Type: INDEX; Schema: base; Owner: -
--

CREATE UNIQUE INDEX app_user_fname_lname_unique ON base.app_user USING btree (first_name, last_name);


--
-- Name: app_user_serial_number_unique; Type: INDEX; Schema: base; Owner: -
--

CREATE UNIQUE INDEX app_user_serial_number_unique ON base.app_user USING btree (serial_number);


--
-- Name: app_username_idx; Type: INDEX; Schema: base; Owner: -
--

CREATE UNIQUE INDEX app_username_idx ON base.app_user USING btree (username);


--
-- Name: person_henkilotunnus_idx; Type: INDEX; Schema: base; Owner: -
--

CREATE INDEX person_henkilotunnus_idx ON base.person USING btree (henkilotunnus);


--
-- Name: user_group_group_name_unique; Type: INDEX; Schema: base; Owner: -
--

CREATE UNIQUE INDEX user_group_group_name_unique ON base.user_group USING btree (group_name);


--
-- Name: mv_epic_scores_person_subsection_open_ts_idx; Type: INDEX; Schema: mining; Owner: -
--

CREATE INDEX mv_epic_scores_person_subsection_open_ts_idx ON mining.mv_epic_scores USING btree (person_id, series_group, ts);


--
-- Name: chemotherapy_course_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX chemotherapy_course_source_pk_index ON patient_data.chemotherapy_course USING btree (source_pk);


--
-- Name: chemotherapy_cycle_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX chemotherapy_cycle_source_pk_index ON patient_data.chemotherapy_cycle USING btree (source_pk);


--
-- Name: chemotherapy_dose_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX chemotherapy_dose_source_pk_index ON patient_data.chemotherapy_dose USING btree (source_pk);


--
-- Name: diagnosis_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX diagnosis_source_pk_index ON patient_data.diagnosis USING btree (source_pk);


--
-- Name: episode_of_care_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX episode_of_care_source_pk_index ON patient_data.episode_of_care USING btree (source_pk);


--
-- Name: lab_package_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX lab_package_source_pk_index ON patient_data.lab_package USING btree (source_pk);


--
-- Name: lab_test_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX lab_test_source_pk_index ON patient_data.lab_test USING btree (source_pk);


--
-- Name: medication_set_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX medication_set_source_pk_index ON patient_data.medication_set USING btree (source_pk);


--
-- Name: medication_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX medication_source_pk_index ON patient_data.medication USING btree (source_pk);


--
-- Name: mv_eventinfo_contents_person_id_idx; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX mv_eventinfo_contents_person_id_idx ON patient_data.mv_eventinfo_contents USING btree (element_id, category);


--
-- Name: mv_lab_person_test_unit_idx; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX mv_lab_person_test_unit_idx ON patient_data.mv_lab USING btree (person_id, test, unit);


--
-- Name: mv_timeline_element_hetu_category_idx; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX mv_timeline_element_hetu_category_idx ON patient_data.mv_timeline_element USING btree (henkilotunnus, category);


--
-- Name: mv_timeline_element_person_category_idx; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX mv_timeline_element_person_category_idx ON patient_data.mv_timeline_element USING btree (person_id, category);


--
-- Name: mv_timeline_element_person_ts_idx; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX mv_timeline_element_person_ts_idx ON patient_data.mv_timeline_element USING btree (person_id, start_ts);


--
-- Name: pathology_answer_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX pathology_answer_source_pk_index ON patient_data.pathology_answer USING btree (source_pk);


--
-- Name: pathology_diagnosis_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX pathology_diagnosis_source_pk_index ON patient_data.pathology_diagnosis USING btree (source_pk);


--
-- Name: pathology_examination_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX pathology_examination_source_pk_index ON patient_data.pathology_examination USING btree (source_pk);


--
-- Name: pathology_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX pathology_source_pk_index ON patient_data.pathology USING btree (source_pk);


--
-- Name: pathology_table_data_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX pathology_table_data_source_pk_index ON patient_data.pathology_table_data USING btree (source_pk);


--
-- Name: radiology_procedure_set_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX radiology_procedure_set_source_pk_index ON patient_data.radiology_procedure_set USING btree (source_pk);


--
-- Name: radiology_procedure_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX radiology_procedure_source_pk_index ON patient_data.radiology_procedure USING btree (source_pk);


--
-- Name: radiotherapy_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX radiotherapy_source_pk_index ON patient_data.radiotherapy USING btree (source_pk);


--
-- Name: referral_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX referral_source_pk_index ON patient_data.referral USING btree (source_pk);


--
-- Name: surgery_procedure_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX surgery_procedure_source_pk_index ON patient_data.surgery_procedure USING btree (source_pk);


--
-- Name: surgery_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX surgery_source_pk_index ON patient_data.surgery USING btree (source_pk);


--
-- Name: timeline_element_person_id_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX timeline_element_person_id_index ON patient_data.timeline_element USING btree (person_id);


--
-- Name: visit_source_pk_index; Type: INDEX; Schema: patient_data; Owner: -
--

CREATE INDEX visit_source_pk_index ON patient_data.visit USING btree (source_pk);


--
-- Name: answer_answer_set_form_field_choice_idx; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX answer_answer_set_form_field_choice_idx ON wtf.answer USING btree (answer_set_id, form_field_id, choice_id);


--
-- Name: answer_answer_set_form_field_free_text_idx; Type: INDEX; Schema: wtf; Owner: -
--

CREATE INDEX answer_answer_set_form_field_free_text_idx ON wtf.answer USING btree (answer_set_id, form_field_id, free_text);


--
-- Name: answer_set_idx; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX answer_set_idx ON wtf.answer_set USING btree (session_id, form_id, open_ts);


--
-- Name: choice_name_description_unique; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX choice_name_description_unique ON wtf.choice USING btree (choice_name, description);


--
-- Name: context_name_idx; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX context_name_idx ON wtf.context USING btree (context_name);


--
-- Name: field_name_field_type_data_type_description_unique; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX field_name_field_type_data_type_description_unique ON wtf.field USING btree (field_name, field_type_id, data_type_id, description);


--
-- Name: field_type_name_unique; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX field_type_name_unique ON wtf.field_type USING btree (field_type_name);


--
-- Name: form_field_choice_component_id_unique; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX form_field_choice_component_id_unique ON wtf.form_field_choice USING btree (component_id);


--
-- Name: form_field_component_id_unique; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX form_field_component_id_unique ON wtf.form_field USING btree (component_id);


--
-- Name: form_field_idx; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX form_field_idx ON wtf.form_field USING btree (form_id, field_id, number, parent_form_field_id);


--
-- Name: form_name_parent_specialty_unique; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX form_name_parent_specialty_unique ON wtf.form USING btree (form_name, parent_form_id, owner_group_id);


--
-- Name: gui_element_type_idx; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX gui_element_type_idx ON wtf.gui_element_type USING btree (name, orientation);


--
-- Name: session_end_type_name_unique; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX session_end_type_name_unique ON wtf.session_end_type USING btree (session_end_type_name);


--
-- Name: synonym_context_table_id_idx; Type: INDEX; Schema: wtf; Owner: -
--

CREATE UNIQUE INDEX synonym_context_table_id_idx ON wtf.synonym USING btree (context_id, referred_table, referred_id);


--
-- Name: v_chemotherapy_course_eventinfo_content _RETURN; Type: RULE; Schema: patient_data; Owner: -
--

CREATE OR REPLACE VIEW patient_data.v_chemotherapy_course_eventinfo_content AS
 SELECT 'chemotherapy_course'::text AS category,
    course.element_id,
    course.chemotherapy_course_id AS timeline_table_pk,
    concat(func.html_div('eventinfo_main'::text, ARRAY[ARRAY['Kuuri: '::text, regexp_replace((course.course_name)::text, '\s'::text, ' '::text)]]), func.html_div('eventinfo_main'::text, (array_agg(ARRAY[(cycle.cycle_start_date)::character varying, (cycle.cycle_number)::character varying, dose.product_name, dose.strength, (concat_ws(' '::text, dose.dosage, dose.dosage_unit))::character varying, dose.generic_name] ORDER BY cycle.cycle_start_date, dose.administering_order))::text[], headers => ARRAY['Aika'::text, 'Sykli'::text, 'Lääke'::text, 'Vahvuus'::text, 'Annostelu'::text, 'Vaikuttava aine'::text])) AS eventinfo_content,
    func.html_div('eventinfo_tooltip'::text, ARRAY[ARRAY[regexp_replace((course.course_name)::text, '\s'::text, ' '::text)]]) AS eventinfo_tooltip,
    NULL::character varying AS icon_text
   FROM ((patient_data.chemotherapy_course course
     JOIN patient_data.chemotherapy_cycle cycle ON ((course.chemotherapy_course_id = cycle.chemotherapy_course_id)))
     JOIN patient_data.chemotherapy_dose dose ON ((cycle.chemotherapy_cycle_id = dose.chemotherapy_cycle_id)))
  GROUP BY course.chemotherapy_course_id, course.course_name;


--
-- Name: v_episode_of_care_eventinfo_content _RETURN; Type: RULE; Schema: patient_data; Owner: -
--

CREATE OR REPLACE VIEW patient_data.v_episode_of_care_eventinfo_content AS
 SELECT 'episode_of_care'::text AS category,
    v.element_id,
    v.episode_of_care_id AS timeline_table_pk,
    concat(func.html_div('eventinfo_unit'::text, ARRAY[ARRAY['Yksikkö: '::text, concat_ws(' '::text, v.unit_code, v.unit_name)], ARRAY['Resurssi: '::text, concat_ws(' '::text, v.resource_code, v.resource_name)]]),
        CASE
            WHEN bool_and((d.diagnosis_id IS NULL)) THEN ''::text
            ELSE func.html_div('eventinfo_main'::text, array_agg(ARRAY[concat_ws(' '::text, d.diagnosis_code, d.diagnosis_name)] ORDER BY d.is_main_diagnosis DESC))
        END,
        CASE
            WHEN (v.text_content IS NULL) THEN ''::text
            ELSE func.html_div('eventinfo_text'::text, ARRAY[ARRAY[v.text_content]])
        END) AS eventinfo_content,
    concat(func.html_div('eventinfo_tooltip'::text, ARRAY[ARRAY[(v.unit_code)::text, (v.unit_name)::text]]),
        CASE
            WHEN bool_and((d.diagnosis_id IS NULL)) THEN ''::text
            ELSE func.html_div('eventinfo_tooltip'::text, array_agg(ARRAY[concat_ws(' '::text, d.diagnosis_code, d.diagnosis_name)] ORDER BY d.is_main_diagnosis DESC))
        END) AS eventinfo_tooltip,
    NULL::character varying AS icon_text
   FROM (patient_data.episode_of_care v
     LEFT JOIN patient_data.diagnosis d ON (((v.episode_of_care_id = d.episode_of_care_id) AND ((d.service_type)::text = 'episode of care'::text))))
  GROUP BY v.episode_of_care_id, v.unit_code, v.unit_name, v.resource_code, v.resource_name, v.text_content;


--
-- Name: v_lab_package_eventinfo_content _RETURN; Type: RULE; Schema: patient_data; Owner: -
--

CREATE OR REPLACE VIEW patient_data.v_lab_package_eventinfo_content AS
 SELECT 'lab_package'::text AS category,
    p.element_id,
    p.lab_package_id AS timeline_table_pk,
    func.html_div('eventinfo_main'::text, array_agg(ARRAY[concat(t.test, ': '), (t.result)::text, (t.unit)::text] ORDER BY t.test)) AS eventinfo_content,
    func.html_div('eventinfo_main'::text, array_agg(ARRAY[concat(t.test, ': '), (t.result)::text, (t.unit)::text] ORDER BY t.test)) AS eventinfo_tooltip,
    NULL::character varying AS icon_text
   FROM (patient_data.lab_package p
     JOIN patient_data.lab_test t ON ((p.lab_package_id = t.lab_package_id)))
  GROUP BY p.lab_package_id;


--
-- Name: v_medication_set_eventinfo_content _RETURN; Type: RULE; Schema: patient_data; Owner: -
--

CREATE OR REPLACE VIEW patient_data.v_medication_set_eventinfo_content AS
 SELECT 'medication_set'::text AS category,
    s.element_id,
    s.medication_set_id AS timeline_table_pk,
    concat(func.html_div('eventinfo_unit'::text, ARRAY[ARRAY[('Yksikkö:'::character varying)::text, (s.prescribing_unit_code)::text]]), func.html_div('eventinfo_main'::text, array_agg(ARRAY['resepti'::text, concat_ws(' '::text, m.atc_code, m.atc_name), concat(m.product_name, ' (', m.generic_name, ')'), (m.strength)::text, (m.dosage)::text]), headers => ARRAY['Tyyppi'::text, 'ATC'::text, 'Lääke'::text, 'Vahvuus'::text, 'Annostelu'::text])) AS eventinfo_content,
    func.html_div('eventinfo_tooltip'::text, (array_agg(ARRAY[m.product_name]))::text[]) AS eventinfo_tooltip,
    NULL::character varying AS icon_text
   FROM (patient_data.medication_set s
     JOIN patient_data.medication m ON ((s.medication_set_id = m.medication_set_id)))
  GROUP BY s.medication_set_id, s.prescribing_unit_code;


--
-- Name: v_pathology_eventinfo_content _RETURN; Type: RULE; Schema: patient_data; Owner: -
--

CREATE OR REPLACE VIEW patient_data.v_pathology_eventinfo_content AS
 WITH cte_pathology_answer AS (
         SELECT a_1.pathology_id,
            a_1.pathology_answer_id,
            a_1.order_number,
            a_1.answer_number,
            concat(func.html_div('eventinfo_unit'::text, ARRAY[ARRAY[('Lähettäjä: '::character varying)::text, (a_1.ordering_unit)::text], ARRAY[('Vastaanottaja: '::character varying)::text, (a_1.receiving_unit)::text]]), func.html_div('eventinfo_main'::text, ARRAY[ARRAY[('Pyyntö: '::character varying)::text, ((a_1.order_number)::character varying)::text, ('Vastaus: '::character varying)::text, ((a_1.answer_number)::character varying)::text]]),
                CASE
                    WHEN bool_and((d_1.pathology_diagnosis_id IS NULL)) THEN ''::text
                    ELSE func.html_div('eventinfo_main'::text, array_agg(DISTINCT ARRAY[concat_ws(' '::text, d_1.organ_prefix, d_1.organ, d_1.organ_suffix), ': '::text, concat_ws(' '::text, d_1.diagnosis, d_1.diagnosis_suffix)]))
                END,
                CASE
                    WHEN bool_and((t.pathology_table_data_id IS NULL)) THEN ''::text
                    ELSE func.html_div('eventinfo_main'::text, ARRAY[ARRAY['Taulukko: '::text, string_agg(DISTINCT (t.table_name)::text, ', '::text ORDER BY (t.table_name)::text)]])
                END, func.html_div('eventinfo_main'::text, (array_agg(DISTINCT ARRAY[t.question, t.result] ORDER BY ARRAY[t.question, t.result]))::text[]), func.html_div('eventinfo_text'::text, ARRAY[ARRAY['Esitiedot: '::text, a_1.anamnesis_text_content], ARRAY['Lausunto: '::text, a_1.statement_text_content]])) AS answer_eventinfo_content,
                CASE
                    WHEN bool_and((d_1.pathology_diagnosis_id IS NULL)) THEN NULL::text[]
                    ELSE array_agg(DISTINCT ARRAY[concat_ws(' '::text, d_1.organ_prefix, d_1.organ, d_1.organ_suffix), ': '::text, concat_ws(' '::text, d_1.diagnosis, d_1.diagnosis_suffix)])
                END AS answer_diagnoses,
                CASE
                    WHEN bool_and((d_1.pathology_diagnosis_id IS NULL)) THEN NULL::text[]
                    ELSE array_agg(DISTINCT ARRAY[concat_ws(' '::text, d_1.organ_prefix, d_1.organ, d_1.organ_suffix), ': '::text, concat_ws(' '::text, d_1.diagnosis, d_1.diagnosis_suffix)])
                END AS all_diagnoses
           FROM ((patient_data.pathology_answer a_1
             LEFT JOIN patient_data.pathology_diagnosis d_1 ON ((a_1.pathology_answer_id = d_1.pathology_answer_id)))
             LEFT JOIN patient_data.pathology_table_data t ON ((a_1.pathology_answer_id = t.pathology_answer_id)))
          GROUP BY a_1.pathology_id, a_1.pathology_answer_id, a_1.order_number, a_1.answer_number
        ), cte_diagnoses AS (
         SELECT a_1.pathology_id,
                CASE
                    WHEN bool_and((d_1.pathology_diagnosis_id IS NULL)) THEN ''::text
                    ELSE func.html_div('eventinfo_unit'::text, array_agg(DISTINCT ARRAY[concat_ws(' '::text, d_1.organ_prefix, d_1.organ, d_1.organ_suffix), ': '::text, concat_ws(' '::text, d_1.diagnosis, d_1.diagnosis_suffix)]))
                END AS diagnoses_tooltip
           FROM (patient_data.pathology_answer a_1
             LEFT JOIN patient_data.pathology_diagnosis d_1 ON ((a_1.pathology_answer_id = d_1.pathology_answer_id)))
          GROUP BY a_1.pathology_id
        )
 SELECT 'pathology'::text AS category,
    p.element_id,
    p.pathology_id AS timeline_table_pk,
    concat(func.html_div('eventinfo_main'::text, ARRAY[ARRAY[('Näytenumero: '::character varying)::text, (p.source_pk)::text]]), string_agg(a.answer_eventinfo_content, ''::text ORDER BY a.order_number, a.answer_number)) AS eventinfo_content,
    d.diagnoses_tooltip AS eventinfo_tooltip,
    NULL::character varying AS icon_text
   FROM ((patient_data.pathology p
     JOIN cte_pathology_answer a ON ((p.pathology_id = a.pathology_id)))
     LEFT JOIN cte_diagnoses d ON ((p.pathology_id = d.pathology_id)))
  GROUP BY p.pathology_id, d.diagnoses_tooltip;


--
-- Name: v_radiology_procedure_set_eventinfo_content _RETURN; Type: RULE; Schema: patient_data; Owner: -
--

CREATE OR REPLACE VIEW patient_data.v_radiology_procedure_set_eventinfo_content AS
 SELECT 'radiology_procedure_set'::text AS category,
    s.element_id,
    s.radiology_procedure_set_id AS timeline_table_pk,
    concat(func.html_div('eventinfo_unit'::text, ARRAY[ARRAY['Tilaaja: '::text, string_agg(DISTINCT (s.ordering_unit_code)::text, ', '::text)]]), func.html_div('eventinfo_main'::text, array_agg(ARRAY[concat_ws(' '::text, p.procedure_code, p.procedure_name)])),
        CASE
            WHEN (s.referral_text IS NULL) THEN ''::text
            ELSE func.html_div('eventinfo_text'::text, ARRAY[ARRAY['Lähete: '::text, s.referral_text], ARRAY['Lausunto: '::text, s.statement_text]])
        END) AS eventinfo_content,
    func.html_div('eventinfo_main'::text, array_agg(ARRAY[concat_ws(' '::text, p.procedure_code, p.procedure_name)])) AS eventinfo_tooltip,
    s.procedure_type AS icon_text
   FROM (patient_data.radiology_procedure_set s
     JOIN patient_data.radiology_procedure p ON ((s.radiology_procedure_set_id = p.radiology_procedure_set_id)))
  GROUP BY s.radiology_procedure_set_id, s.referral_text, s.statement_text;


--
-- Name: v_surgery_eventinfo_content _RETURN; Type: RULE; Schema: patient_data; Owner: -
--

CREATE OR REPLACE VIEW patient_data.v_surgery_eventinfo_content AS
 SELECT 'surgery'::text AS category,
    s.element_id,
    s.surgery_id AS timeline_table_pk,
    concat(func.html_div('eventinfo_unit'::text, ARRAY[ARRAY['Hoitava osasto: '::text, concat(s.treating_unit_code, ' ', s.treating_unit_name)]]), func.html_div('eventinfo_main'::text, (array_agg(ARRAY[sp.procedure_code, sp.procedure_name, (
        CASE
            WHEN ((sp.diagnosis_name)::text <> ''::text) THEN concat('(', sp.diagnosis_name, ')')
            ELSE NULL::text
        END)::character varying] ORDER BY sp.is_main_procedure DESC))::text[]),
        CASE
            WHEN bool_and((s.text_content IS NULL)) THEN ''::text
            ELSE func.html_div('eventinfo_text'::text, ARRAY[ARRAY[s.text_content]])
        END) AS eventinfo_content,
    concat(func.html_div('eventinfo_tooltip'::text, (array_agg(ARRAY[sp.procedure_code, sp.procedure_name] ORDER BY sp.is_main_procedure DESC))::text[])) AS eventinfo_tooltip,
    NULL::character varying AS icon_text
   FROM (patient_data.surgery s
     JOIN patient_data.surgery_procedure sp ON ((s.surgery_id = sp.surgery_id)))
  GROUP BY s.surgery_id, s.treating_unit_code, s.treating_unit_name, s.text_content;


--
-- Name: v_visit_eventinfo_content _RETURN; Type: RULE; Schema: patient_data; Owner: -
--

CREATE OR REPLACE VIEW patient_data.v_visit_eventinfo_content AS
 SELECT 'visit'::text AS category,
    v.element_id,
    v.visit_id AS timeline_table_pk,
    concat(func.html_div('eventinfo_unit'::text, ARRAY[ARRAY['Yksikkö: '::text, concat_ws(' '::text, v.unit_code, v.unit_name)], ARRAY['Resurssi: '::text, concat_ws(' '::text, v.resource_code, v.resource_name)], ARRAY[('Käyntityyppi: '::character varying)::text, (v.visit_type)::text]]),
        CASE
            WHEN bool_and((d.diagnosis_id IS NULL)) THEN ''::text
            ELSE func.html_div('eventinfo_tooltip'::text, array_agg(ARRAY[concat_ws(' '::text, d.diagnosis_code, d.diagnosis_name)] ORDER BY d.is_main_diagnosis DESC))
        END,
        CASE
            WHEN (v.text_content IS NULL) THEN ''::text
            ELSE func.html_div('eventinfo_text'::text, ARRAY[ARRAY[v.text_content]])
        END) AS eventinfo_content,
    concat(func.html_div('eventinfo_tooltip'::text, ARRAY[ARRAY[(v.unit_code)::text, (v.unit_name)::text]]),
        CASE
            WHEN bool_and((d.diagnosis_id IS NULL)) THEN ''::text
            ELSE func.html_div('eventinfo_tooltip'::text, array_agg(ARRAY[concat_ws(' '::text, d.diagnosis_code, d.diagnosis_name)] ORDER BY d.is_main_diagnosis DESC))
        END) AS eventinfo_tooltip,
    v.unit_code AS icon_text
   FROM (patient_data.visit v
     LEFT JOIN patient_data.diagnosis d ON (((v.visit_id = d.visit_id) AND ((d.service_type)::text = 'visit'::text))))
  GROUP BY v.visit_id, v.unit_code, v.unit_name, v.resource_code, v.resource_name, v.visit_type, v.text_content;


--
-- Name: form_field form_field_gui_element_type_trigger; Type: TRIGGER; Schema: wtf; Owner: -
--

CREATE TRIGGER form_field_gui_element_type_trigger BEFORE INSERT ON wtf.form_field FOR EACH ROW EXECUTE PROCEDURE wtf.set_default_form_field_gui_element_type();


--
-- Name: answer trigger_name; Type: TRIGGER; Schema: wtf; Owner: -
--

CREATE TRIGGER trigger_name BEFORE INSERT ON wtf.answer FOR EACH ROW EXECUTE PROCEDURE wtf.ignore_empty_answer();


--
-- Name: group_feature_access feature_group_feature_access_fk; Type: FK CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.group_feature_access
    ADD CONSTRAINT feature_group_feature_access_fk FOREIGN KEY (feature_id) REFERENCES base.feature(feature_id);


--
-- Name: group_membership group_group_membership_fk; Type: FK CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.group_membership
    ADD CONSTRAINT group_group_membership_fk FOREIGN KEY (group_id) REFERENCES base.user_group(group_id);


--
-- Name: app_user member_form_user_fk; Type: FK CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.app_user
    ADD CONSTRAINT member_form_user_fk FOREIGN KEY (app_user_id) REFERENCES base.member(member_id);


--
-- Name: user_group member_group_fk; Type: FK CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.user_group
    ADD CONSTRAINT member_group_fk FOREIGN KEY (group_id) REFERENCES base.member(member_id);


--
-- Name: group_membership member_group_membership_fk; Type: FK CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.group_membership
    ADD CONSTRAINT member_group_membership_fk FOREIGN KEY (member_id) REFERENCES base.member(member_id);


--
-- Name: group_feature_access user_group_group_feature_access_fk; Type: FK CONSTRAINT; Schema: base; Owner: -
--

ALTER TABLE ONLY base.group_feature_access
    ADD CONSTRAINT user_group_group_feature_access_fk FOREIGN KEY (group_id) REFERENCES base.user_group(group_id);


--
-- Name: chemotherapy_course chemotherapy_course_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.chemotherapy_course
    ADD CONSTRAINT chemotherapy_course_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: chemotherapy_cycle chemotherapy_cycle_chemotherapy_course_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.chemotherapy_cycle
    ADD CONSTRAINT chemotherapy_cycle_chemotherapy_course_id_fkey FOREIGN KEY (chemotherapy_course_id) REFERENCES patient_data.chemotherapy_course(chemotherapy_course_id) ON DELETE CASCADE;


--
-- Name: chemotherapy_dose chemotherapy_dose_chemotherapy_cycle_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.chemotherapy_dose
    ADD CONSTRAINT chemotherapy_dose_chemotherapy_cycle_id_fkey FOREIGN KEY (chemotherapy_cycle_id) REFERENCES patient_data.chemotherapy_cycle(chemotherapy_cycle_id) ON DELETE CASCADE;


--
-- Name: clinical_finding clinical_finding_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.clinical_finding
    ADD CONSTRAINT clinical_finding_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: diagnosis diagnosis_episode_of_care_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.diagnosis
    ADD CONSTRAINT diagnosis_episode_of_care_id_fkey FOREIGN KEY (episode_of_care_id) REFERENCES patient_data.episode_of_care(episode_of_care_id) ON DELETE CASCADE;


--
-- Name: diagnosis diagnosis_visit_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.diagnosis
    ADD CONSTRAINT diagnosis_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES patient_data.visit(visit_id) ON DELETE CASCADE;


--
-- Name: element_significance element_significance_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.element_significance
    ADD CONSTRAINT element_significance_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: element_significance element_significance_significance_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.element_significance
    ADD CONSTRAINT element_significance_significance_id_fkey FOREIGN KEY (significance_id) REFERENCES patient_data.significance(significance_id) ON DELETE RESTRICT;


--
-- Name: episode_of_care episode_of_care_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.episode_of_care
    ADD CONSTRAINT episode_of_care_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: lab_package lab_package_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.lab_package
    ADD CONSTRAINT lab_package_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: lab_test lab_test_lab_package_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.lab_test
    ADD CONSTRAINT lab_test_lab_package_id_fkey FOREIGN KEY (lab_package_id) REFERENCES patient_data.lab_package(lab_package_id) ON DELETE CASCADE;


--
-- Name: medication medication_medication_set_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.medication
    ADD CONSTRAINT medication_medication_set_id_fkey FOREIGN KEY (medication_set_id) REFERENCES patient_data.medication_set(medication_set_id) ON DELETE CASCADE;


--
-- Name: medication_set medication_set_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.medication_set
    ADD CONSTRAINT medication_set_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: pathology_answer pathology_answer_pathology_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.pathology_answer
    ADD CONSTRAINT pathology_answer_pathology_id_fkey FOREIGN KEY (pathology_id) REFERENCES patient_data.pathology(pathology_id) ON DELETE CASCADE;


--
-- Name: pathology_diagnosis pathology_diagnosis_pathology_answer_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.pathology_diagnosis
    ADD CONSTRAINT pathology_diagnosis_pathology_answer_id_fkey FOREIGN KEY (pathology_answer_id) REFERENCES patient_data.pathology_answer(pathology_answer_id) ON DELETE CASCADE;


--
-- Name: pathology pathology_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.pathology
    ADD CONSTRAINT pathology_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: pathology_examination pathology_examination_pathology_answer_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.pathology_examination
    ADD CONSTRAINT pathology_examination_pathology_answer_id_fkey FOREIGN KEY (pathology_answer_id) REFERENCES patient_data.pathology_answer(pathology_answer_id) ON DELETE CASCADE;


--
-- Name: pathology_table_data pathology_table_data_pathology_answer_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.pathology_table_data
    ADD CONSTRAINT pathology_table_data_pathology_answer_id_fkey FOREIGN KEY (pathology_answer_id) REFERENCES patient_data.pathology_answer(pathology_answer_id) ON DELETE CASCADE;


--
-- Name: radiology_procedure radiology_procedure_radiology_procedure_set_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.radiology_procedure
    ADD CONSTRAINT radiology_procedure_radiology_procedure_set_id_fkey FOREIGN KEY (radiology_procedure_set_id) REFERENCES patient_data.radiology_procedure_set(radiology_procedure_set_id) ON DELETE CASCADE;


--
-- Name: radiology_procedure_set radiology_procedure_set_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.radiology_procedure_set
    ADD CONSTRAINT radiology_procedure_set_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: radiotherapy radiotherapy_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.radiotherapy
    ADD CONSTRAINT radiotherapy_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: referral referral_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.referral
    ADD CONSTRAINT referral_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: surgery surgery_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.surgery
    ADD CONSTRAINT surgery_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: surgery_procedure surgery_procedure_surgery_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.surgery_procedure
    ADD CONSTRAINT surgery_procedure_surgery_id_fkey FOREIGN KEY (surgery_id) REFERENCES patient_data.surgery(surgery_id) ON DELETE CASCADE;


--
-- Name: timeline_element timeline_element_patient_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.timeline_element
    ADD CONSTRAINT timeline_element_patient_id_fkey FOREIGN KEY (person_id) REFERENCES base.person(person_id) ON DELETE CASCADE;


--
-- Name: visit visit_element_id_fkey; Type: FK CONSTRAINT; Schema: patient_data; Owner: -
--

ALTER TABLE ONLY patient_data.visit
    ADD CONSTRAINT visit_element_id_fkey FOREIGN KEY (element_id) REFERENCES patient_data.timeline_element(element_id) ON DELETE CASCADE;


--
-- Name: answer answer_set_answer_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.answer
    ADD CONSTRAINT answer_set_answer_fk FOREIGN KEY (answer_set_id) REFERENCES wtf.answer_set(answer_set_id);


--
-- Name: answer_set answer_set_answer_set_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.answer_set
    ADD CONSTRAINT answer_set_answer_set_fk FOREIGN KEY (replaced_by_answer_set_id) REFERENCES wtf.answer_set(answer_set_id);


--
-- Name: answer choice_answer_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.answer
    ADD CONSTRAINT choice_answer_fk FOREIGN KEY (choice_id) REFERENCES wtf.choice(choice_id);


--
-- Name: form_field_choice choice_form_field_choice_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field_choice
    ADD CONSTRAINT choice_form_field_choice_fk FOREIGN KEY (choice_id) REFERENCES wtf.choice(choice_id);


--
-- Name: component_hide component_component_hide_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.component_hide
    ADD CONSTRAINT component_component_hide_fk FOREIGN KEY (component_id) REFERENCES wtf.component(component_id);


--
-- Name: component_condition component_component_visibility_condition_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.component_condition
    ADD CONSTRAINT component_component_visibility_condition_fk FOREIGN KEY (conditional_component_id) REFERENCES wtf.component(component_id);


--
-- Name: component_condition component_component_visibility_condition_fk1; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.component_condition
    ADD CONSTRAINT component_component_visibility_condition_fk1 FOREIGN KEY (determining_component_id) REFERENCES wtf.component(component_id);


--
-- Name: synonym context_synonym_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.synonym
    ADD CONSTRAINT context_synonym_fk FOREIGN KEY (context_id) REFERENCES wtf.context(context_id);


--
-- Name: field data_type_field_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.field
    ADD CONSTRAINT data_type_field_fk FOREIGN KEY (data_type_id) REFERENCES wtf.data_type(data_type_id);


--
-- Name: field_filter field_field_filter_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.field_filter
    ADD CONSTRAINT field_field_filter_fk FOREIGN KEY (field_id) REFERENCES wtf.field(field_id);


--
-- Name: form_field field_form_field_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field
    ADD CONSTRAINT field_form_field_fk FOREIGN KEY (field_id) REFERENCES wtf.field(field_id);


--
-- Name: field field_type_field_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.field
    ADD CONSTRAINT field_type_field_fk FOREIGN KEY (field_type_id) REFERENCES wtf.field_type(field_type_id);


--
-- Name: field_filter filter_field_filter_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.field_filter
    ADD CONSTRAINT filter_field_filter_fk FOREIGN KEY (filter_id) REFERENCES wtf.filter(filter_id);


--
-- Name: answer_set form_answer_set_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.answer_set
    ADD CONSTRAINT form_answer_set_fk FOREIGN KEY (form_id) REFERENCES wtf.form(form_id);


--
-- Name: form_field_choice form_component_form_field_choice_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field_choice
    ADD CONSTRAINT form_component_form_field_choice_fk FOREIGN KEY (component_id) REFERENCES wtf.component(component_id);


--
-- Name: form_field form_component_form_field_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field
    ADD CONSTRAINT form_component_form_field_fk FOREIGN KEY (component_id) REFERENCES wtf.component(component_id);


--
-- Name: answer form_field_answer_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.answer
    ADD CONSTRAINT form_field_answer_fk FOREIGN KEY (form_field_id) REFERENCES wtf.form_field(form_field_id);


--
-- Name: form_field_choice form_field_form_field_choice_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field_choice
    ADD CONSTRAINT form_field_form_field_choice_fk FOREIGN KEY (form_field_id) REFERENCES wtf.form_field(form_field_id);


--
-- Name: form_field form_field_form_field_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field
    ADD CONSTRAINT form_field_form_field_fk FOREIGN KEY (parent_form_field_id) REFERENCES wtf.form_field(form_field_id);


--
-- Name: form_field form_form_field_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field
    ADD CONSTRAINT form_form_field_fk FOREIGN KEY (form_id) REFERENCES wtf.form(form_id);


--
-- Name: form form_form_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form
    ADD CONSTRAINT form_form_fk FOREIGN KEY (parent_form_id) REFERENCES wtf.form(form_id);


--
-- Name: group_form_access form_group_form_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.group_form_access
    ADD CONSTRAINT form_group_form_fk FOREIGN KEY (form_id) REFERENCES wtf.form(form_id);


--
-- Name: component_hide group_component_hide_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.component_hide
    ADD CONSTRAINT group_component_hide_fk FOREIGN KEY (group_id) REFERENCES base.user_group(group_id);


--
-- Name: form_field gui_element_type_form_field_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form_field
    ADD CONSTRAINT gui_element_type_form_field_fk FOREIGN KEY (gui_element_type_id) REFERENCES wtf.gui_element_type(gui_element_type_id);


--
-- Name: session patient_session_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.session
    ADD CONSTRAINT patient_session_fk FOREIGN KEY (person_id) REFERENCES base.person(person_id);


--
-- Name: answer_set session_answer_set_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.answer_set
    ADD CONSTRAINT session_answer_set_fk FOREIGN KEY (session_id) REFERENCES wtf.session(session_id);


--
-- Name: session session_app_user_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.session
    ADD CONSTRAINT session_app_user_fk FOREIGN KEY (app_user_id) REFERENCES base.app_user(app_user_id);


--
-- Name: session session_end_type_session_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.session
    ADD CONSTRAINT session_end_type_session_fk FOREIGN KEY (session_end_type_id) REFERENCES wtf.session_end_type(session_end_type_id);


--
-- Name: user_group_analytics_activity_status user_group_analytics_activity_status_user_group_id_fkey; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.user_group_analytics_activity_status
    ADD CONSTRAINT user_group_analytics_activity_status_user_group_id_fkey FOREIGN KEY (user_group_id) REFERENCES base.user_group(group_id);


--
-- Name: form user_group_form_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.form
    ADD CONSTRAINT user_group_form_fk FOREIGN KEY (owner_group_id) REFERENCES base.user_group(group_id);


--
-- Name: group_form_access user_group_group_form_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.group_form_access
    ADD CONSTRAINT user_group_group_form_fk FOREIGN KEY (group_id) REFERENCES base.user_group(group_id);


--
-- Name: session user_group_session_fk; Type: FK CONSTRAINT; Schema: wtf; Owner: -
--

ALTER TABLE ONLY wtf.session
    ADD CONSTRAINT user_group_session_fk FOREIGN KEY (group_id) REFERENCES base.user_group(group_id);


--
-- PostgreSQL database dump complete
--

