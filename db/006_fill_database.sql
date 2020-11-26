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
-- Data for Name: member; Type: TABLE DATA; Schema: base; Owner: -
--

INSERT INTO base.member VALUES (1, 'group', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.member VALUES (2, 'group', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.member VALUES (3, 'group', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.member VALUES (4, 'group', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.member VALUES (5, 'group', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.member VALUES (6, 'group', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.member VALUES (7, 'group', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.member VALUES (174, 'group', '2020-01-21 08:49:03.562808', NULL);


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: base; Owner: -
--



--
-- Data for Name: feature; Type: TABLE DATA; Schema: base; Owner: -
--

INSERT INTO base.feature VALUES (3, 'confirmation_page', '2019-01-18 10:41:51.195161', NULL);
INSERT INTO base.feature VALUES (4, 'filled_form_list', '2019-01-18 10:41:51.195161', NULL);
INSERT INTO base.feature VALUES (1, 'timeline', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.feature VALUES (2, 'demographics', '2019-01-14 09:30:51.639612', NULL);


--
-- Data for Name: user_group; Type: TABLE DATA; Schema: base; Owner: -
--

INSERT INTO base.user_group VALUES (1, 'Lääkäri', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.user_group VALUES (2, 'Potilas', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.user_group VALUES (3, 'Urologi', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.user_group VALUES (4, 'Keuhkolääkäri', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.user_group VALUES (5, 'Urologinen potilas', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.user_group VALUES (6, 'Keuhkopotilas', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.user_group VALUES (7, 'Testaaja', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO base.user_group VALUES (174, 'Infektiolääkäri', '2020-01-21 08:49:03.562808', NULL);


--
-- Data for Name: group_feature_access; Type: TABLE DATA; Schema: base; Owner: -
--

INSERT INTO base.group_feature_access VALUES (1, 1, '2019-01-13 14:40:33.047785');
INSERT INTO base.group_feature_access VALUES (1, 2, '2019-01-14 09:32:19.309966');
INSERT INTO base.group_feature_access VALUES (2, 3, '2019-01-18 10:45:38.547614');
INSERT INTO base.group_feature_access VALUES (2, 4, '2019-01-18 10:45:38.547614');
INSERT INTO base.group_feature_access VALUES (7, 1, '2020-05-13 11:17:53.855088');
INSERT INTO base.group_feature_access VALUES (7, 2, '2020-05-13 11:17:53.855088');
INSERT INTO base.group_feature_access VALUES (7, 3, '2020-05-13 11:17:53.855088');
INSERT INTO base.group_feature_access VALUES (7, 4, '2020-05-13 11:17:53.855088');


--
-- Data for Name: group_membership; Type: TABLE DATA; Schema: base; Owner: -
--

INSERT INTO base.group_membership VALUES (174, 1, '2020-01-21 08:49:03.562808', NULL, true, '2020-01-21 08:49:03.562808', NULL);
INSERT INTO base.group_membership VALUES (3, 1, '2019-01-13 14:40:33.047785', NULL, true, '2019-01-13 14:40:33.047785', '2020-11-26 05:17:07.508052');
INSERT INTO base.group_membership VALUES (4, 1, '2019-01-13 14:40:33.047785', NULL, true, '2019-01-13 14:40:33.047785', '2020-11-26 05:17:07.508052');
INSERT INTO base.group_membership VALUES (5, 2, '2019-01-13 14:40:33.047785', NULL, true, '2019-01-13 14:40:33.047785', '2020-11-26 05:17:07.508052');
INSERT INTO base.group_membership VALUES (6, 2, '2019-01-13 14:40:33.047785', NULL, true, '2019-01-13 14:40:33.047785', '2020-11-26 05:17:07.508052');


--
-- Data for Name: parameters; Type: TABLE DATA; Schema: base; Owner: -
--



--
-- Data for Name: person; Type: TABLE DATA; Schema: base; Owner: -
--



--
-- Data for Name: cdc_time; Type: TABLE DATA; Schema: mining; Owner: -
--



--
-- Data for Name: epic_scoring; Type: TABLE DATA; Schema: mining; Owner: -
--

INSERT INTO mining.epic_scoring VALUES ('{1}', 'Incontinence', 4);
INSERT INTO mining.epic_scoring VALUES ('{2}', 'Incontinence', 4);
INSERT INTO mining.epic_scoring VALUES ('{3}', 'Incontinence', 4);
INSERT INTO mining.epic_scoring VALUES ('{4,1}', 'Incontinence', 4);
INSERT INTO mining.epic_scoring VALUES ('{4,2}', 'Urinary irritative/obstructive', 4);
INSERT INTO mining.epic_scoring VALUES ('{4,3}', 'Urinary irritative/obstructive', 4);
INSERT INTO mining.epic_scoring VALUES ('{4,4}', 'Urinary irritative/obstructive', 4);
INSERT INTO mining.epic_scoring VALUES ('{4,5}', 'Urinary irritative/obstructive', 4);
INSERT INTO mining.epic_scoring VALUES ('{6,1}', 'Bowel', 5);
INSERT INTO mining.epic_scoring VALUES ('{6,2}', 'Bowel', 5);
INSERT INTO mining.epic_scoring VALUES ('{6,3}', 'Bowel', 5);
INSERT INTO mining.epic_scoring VALUES ('{6,4}', 'Bowel', 5);
INSERT INTO mining.epic_scoring VALUES ('{6,5}', 'Bowel', 5);
INSERT INTO mining.epic_scoring VALUES ('{7}', 'Bowel', 5);
INSERT INTO mining.epic_scoring VALUES ('{8,1}', 'Sexual', 5);
INSERT INTO mining.epic_scoring VALUES ('{8,2}', 'Sexual', 5);
INSERT INTO mining.epic_scoring VALUES ('{9}', 'Sexual', 5);
INSERT INTO mining.epic_scoring VALUES ('{10}', 'Sexual', 5);
INSERT INTO mining.epic_scoring VALUES ('{11}', 'Sexual', 5);
INSERT INTO mining.epic_scoring VALUES ('{12}', 'Sexual', 5);
INSERT INTO mining.epic_scoring VALUES ('{13,1}', 'Hormonal', 4);
INSERT INTO mining.epic_scoring VALUES ('{13,2}', 'Hormonal', 4);
INSERT INTO mining.epic_scoring VALUES ('{13,3}', 'Hormonal', 4);
INSERT INTO mining.epic_scoring VALUES ('{13,4}', 'Hormonal', 4);
INSERT INTO mining.epic_scoring VALUES ('{13,5}', 'Hormonal', 4);


--
-- Data for Name: cdc_time; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: timeline_element; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: chemotherapy_course; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: chemotherapy_cycle; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: chemotherapy_dose; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: clinical_finding; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: episode_of_care; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: visit; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: diagnosis; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: significance; Type: TABLE DATA; Schema: patient_data; Owner: -
--

INSERT INTO patient_data.significance VALUES (1, 'Keskeinen', 1);
INSERT INTO patient_data.significance VALUES (2, 'Kiinnostava', 2);
INSERT INTO patient_data.significance VALUES (3, 'Muu', 3);


--
-- Data for Name: element_significance; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: help_page; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: lab_package; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: lab_test; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: medication_set; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: medication; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: pathology; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: pathology_answer; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: pathology_diagnosis; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: pathology_examination; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: pathology_table_data; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: radiology_procedure_set; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: radiology_procedure; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: radiotherapy; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: referral; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: surgery; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: surgery_procedure; Type: TABLE DATA; Schema: patient_data; Owner: -
--



--
-- Data for Name: form; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.form VALUES (1, 'Urologian laaturekisteri', NULL, NULL, '2019-01-13 14:40:33.172325', NULL, 3, 1, true, NULL, '2019-01-13 14:40:33.172325', NULL, NULL);
INSERT INTO wtf.form VALUES (2, 'Urologian potilaslomakkeet', NULL, NULL, '2019-01-13 14:40:33.172325', NULL, 5, 1, true, NULL, '2019-01-13 14:40:33.172325', NULL, NULL);
INSERT INTO wtf.form VALUES (3, 'Eturauhassyöpä', NULL, NULL, '2019-01-13 14:40:33.172325', NULL, 3, 1, true, 1, '2019-01-13 14:40:33.172325', NULL, NULL);
INSERT INTO wtf.form VALUES (10, 'Hoito', NULL, NULL, '2019-01-13 14:40:33.172325', NULL, 3, 3, false, 3, '2019-01-13 14:40:33.172325', NULL, NULL);
INSERT INTO wtf.form VALUES (11, 'Kotiutus', NULL, NULL, '2019-01-13 14:40:33.172325', NULL, 3, 4, false, 3, '2019-01-13 14:40:33.172325', NULL, NULL);
INSERT INTO wtf.form VALUES (12, 'Seuranta 3kk', NULL, NULL, '2019-01-13 14:40:33.172325', NULL, 3, 5, false, 3, '2019-01-13 14:40:33.172325', NULL, NULL);
INSERT INTO wtf.form VALUES (13, 'Seuranta', NULL, NULL, '2019-01-13 14:40:33.172325', NULL, 3, 6, true, 3, '2019-01-13 14:40:33.172325', NULL, NULL);
INSERT INTO wtf.form VALUES (14, 'EPIC', 'Tämä kysely on tehty mittaamaan eturauhassyöpää sairastavien elämänlaatua. Oikean tuloksen saamiseksi on tärkeää, että vastaat kaikkiin kysymyksiin rehellisesti etkä jätä mitään kohtaa väliin. Muista että vastauksesi tähän kyselyyn, kuten kaikki potilastiedot, ovat täysin luottamuksellisia.', 'Kiitos!', '2019-01-13 14:40:33.543027', NULL, 5, 2, true, 2, '2019-01-13 14:40:33.543027', NULL, true);
INSERT INTO wtf.form VALUES (8, 'Tutkimus', NULL, NULL, '2019-01-13 14:40:33.172325', NULL, 3, 1, true, 3, '2019-01-13 14:40:33.172325', NULL, NULL);
INSERT INTO wtf.form VALUES (9, 'Hoitoneuvottelu', NULL, NULL, '2019-01-13 14:40:33.172325', NULL, 3, 2, true, 3, '2019-01-13 14:40:33.172325', NULL, NULL);


--
-- Data for Name: session_end_type; Type: TABLE DATA; Schema: wtf; Owner: -
--



--
-- Data for Name: session; Type: TABLE DATA; Schema: wtf; Owner: -
--



--
-- Data for Name: answer_set; Type: TABLE DATA; Schema: wtf; Owner: -
--



--
-- Data for Name: choice; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.choice VALUES (1, 'TX', 'Kasvainta ei voida määrittää.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (5, 'T1c', 'Kasvain on todettu (esim. suurentuneen PSA-arvon vuoksi tehdyssä) neulabiopsiassa.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (6, 'T2', 'Kasvain on rajoittunut eturauhaseen.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (10, 'T3', 'Kasvain tunkeutuu eturauhaskapselin läpi.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (13, 'T4', 'Kasvain on fiksoitunut tai tunkeutuu muihin lähielimiin kuin rakkularauhasiin: virtsarakon kaulaan, ulompaan sulkijalihakseen, peräsuoleen, lantiopohjan lihaksiin tai lantion seinämään.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (14, 'kyllä', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (15, 'ei', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (16, '0', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (17, '1', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (18, '2', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (19, '3', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (20, '4', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (21, '5', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (22, 'Ei komplikaatioita', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (23, 'Gradus I', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (24, 'Gradus II', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (25, 'Gradus IIIa', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (26, 'Gradus IIIb', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (27, 'Gradus IVa', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (28, 'Gradus IVb', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (29, 'Gradus V', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (30, 'Infektio', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (31, 'Retentio', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (32, 'Hematuria', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (34, 'NX', 'Alueellisia imusolmukkeita ei voida määrittää.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (35, 'N0', 'Alueellisia imusolmuke-etäpesäkkeitä ei ole.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (36, 'N1', 'Alueellisia imusolmuke-etäpesäkkeitä on.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (37, 'MX', 'Etäpesäkkeitä ei voida määrittää.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (38, 'M0', 'Etäpesäkkeitä ei ole.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (39, 'M1', 'Etäpesäkkeitä on.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (40, 'M1a', 'Etäpesäkkeitä on myös muissa kuin alueellisissa imusolmukkeissa.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (41, 'M1b', 'Etäpesäkkeitä on luissa.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (42, 'M1c', 'Etäpesäkkeitä on muissa elimissä.', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (43, 'Aktiiviseuranta', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (44, 'Passiiviseuranta', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (45, 'Radikaali prostatektomia', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (46, 'Sädehoito + liitännäishormonihoito', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (47, 'Sädehoito, ei liitännäishormonihoitoa', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (48, 'Hormonihoito, jatkuva', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (49, 'Hormonihoito, intermittoiva', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (66, 'Primaarihoito', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (67, 'Salvage-prostatektomia', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (68, 'Ei hermojen säästöä', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (69, 'Intrafaskiaalinen', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (70, 'Interfaskiaalinen', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (71, 'Ekstrafaskiaalinen', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (72, 'Remissio', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (73, 'Ei saavutettua remissiota (PSA jäänyt koholle)', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (74, 'Relapsi', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (75, 'Biokemiallinen relapsi', 'PSA noussut yli rajaarvon 0,2 \u03bcl/l laskettuaan ensin sen alle', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (76, 'Imusolmukemetastaasi', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (77, 'Luustometastaasi', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (78, 'Muu metastaasi', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (79, 'Kastraatioresistentti tauti', 'Kastraatioresistantti tauti:<br>testosteroni kastraatiotasolla (<1.7 nmol/l), SEKÄ<br>biokemallinen progressio (PSA >2 \u03bcl/l ja kolme nousevaa arvoa yli nadir-arvon), TAI<br>radiologinen progressio (kaksi tai useampia luustomuutoksia tai uusi pehmytkudosmetastaasi)', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (80, 'Potilas menehtynyt tautiin', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (81, 'Potilas menehtynyt muuhun syyhyn', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (82, 'Seuranta ei muutu', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (83, 'Seuranta loppuu', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (84, 'Seuranta siirtyy Mobiili-PSA:han', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (85, 'Seuranta siirtyy avoterveydenhuoltoon', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (86, 'Seuranta siirtyy muuhun erikoissairaanhoidon yksikköön', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (87, 'Useammin kuin kerran vuorokaudessa', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (88, 'Noin kerran päivässä', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (89, 'Useammin kuin kerran viikossa', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (90, 'Noin kerran viikossa', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (91, 'Ei pidätyskykyä', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (92, 'Tiputtelua toistuvasti', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (93, 'Tiputtelua toisinaan', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (94, 'Täydellinen pidätyskyky', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (95, 'En yhtään', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (96, 'Yhden vuorokaudessa', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (97, 'Kaksi vuorokaudessa', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (98, 'Kolme tai useampia vuorokaudessa', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (99, 'Ei ongelmaa', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (100, 'Hyvin pieni ongelma', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (101, 'Pieni ongelma', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (102, 'Kohtalainen ongelma', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (103, 'Suuri ongelma', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (104, 'Hyvin huonosta olemattomaan', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (105, 'Huono', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (106, 'Kohtalainen', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (107, 'Hyvä', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (108, 'Erittäin hyvä', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (109, 'Ei erektioita', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (110, 'Riittämättömän jäykkä mihinkään seksuaaliseen toimintaan', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (111, 'Riittävän jäykkä itsetyydytykseen ja esileikkiin', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (112, 'Riittävän jäykkä yhdyntään', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (113, 'En saanut erektiota KOSKAAN, kun halusin', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (114, 'Sain erektion ALLE PUOLESSA niistä kerroista, kun halusin', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (115, 'Sain erektion NOIN PUOLESSA niistä kerroista, kun halusin', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (50, 'Lääkäri 1', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (51, 'Lääkäri 2', NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.choice VALUES (116, 'Sain erektion YLI PUOLESSA niistä kerroista, kun halusin', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (117, 'Sain erektion AINA, kun halusin', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (118, 'Erittäin huono', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (119, 'Vähän', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (120, 'Melko paljon', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (121, 'Hyvin paljon', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (122, 'Kyllä', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (123, 'Ei', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (124, 'En ole kokeillut', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (125, 'Kokeilin, mutta ei auttanut', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (126, 'Auttoi, mutta en käytä nyt', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (127, 'Auttoi ja käytän joskus', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (128, 'Auttoi ja käytän aina', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.choice VALUES (174, 'Harvoin tai ei koskaan', NULL, '2019-01-16 19:08:55.004238', NULL);
INSERT INTO wtf.choice VALUES (178, 'Luustokartta', NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.choice VALUES (179, 'Vartalon TT', NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.choice VALUES (180, 'Vartalon SPECT-TT', NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.choice VALUES (181, 'Vartalon MRI', NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.choice VALUES (182, 'PSMA-PET', NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.choice VALUES (183, 'Aste 0', NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.choice VALUES (184, 'Aste 1', NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.choice VALUES (185, 'Aste 2', NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.choice VALUES (186, 'Aste 3', NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.choice VALUES (187, 'Aste 4', NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.choice VALUES (188, 'T2a', 'Kasvain on rajoittunut yhteen lohkoon (alle 50 % lohkosta).', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.choice VALUES (189, 'T2b', 'Kasvain on rajoittunut yhteen lohkoon (yli 50 % lohkosta).', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.choice VALUES (190, 'T2c', 'Kasvain on rajoittunut molempiin lohkoihin.', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.choice VALUES (191, 'T3a', 'Kasvain on kasvanut toispuolisesti tai molemminpuolisesti kapselin läpi.', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.choice VALUES (192, 'T3b', 'Kasvain tunkeutuu rakkularauhaseen.', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.choice VALUES (193, 'T2', NULL, '2019-06-24 15:55:55.075099', NULL);


--
-- Data for Name: component; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.component VALUES (1, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (2, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (3, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (4, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (5, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (9, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (10, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (14, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (17, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (18, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (19, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (20, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (21, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (22, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (23, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (24, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (25, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (26, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (27, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (28, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (29, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (30, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (31, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (32, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (33, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (34, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (35, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (36, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (37, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (38, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (39, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (40, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (41, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (42, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (43, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (44, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (46, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (47, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (48, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (49, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (50, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (51, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (52, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (53, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (54, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (55, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (56, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (57, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (58, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (59, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (60, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (61, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (62, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (63, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (64, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (65, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (66, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (67, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (68, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (69, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (70, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (71, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (75, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (76, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (80, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (83, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (84, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (85, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (86, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (87, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (88, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (89, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (90, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (91, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (92, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (93, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (94, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (95, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (96, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (97, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (98, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (99, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (100, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (101, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (102, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (103, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (104, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (105, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (106, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (107, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (122, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (123, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (127, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (128, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (132, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (135, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (136, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (137, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (138, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (139, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (140, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (141, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (142, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (143, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (144, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (145, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (146, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (147, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (148, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (149, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (150, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (151, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (152, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (153, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (154, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (155, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (156, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (157, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (158, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (159, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (160, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (161, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (162, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (163, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (164, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (166, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (167, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (168, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (169, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (170, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (171, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (172, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (173, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (174, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (175, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (176, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (177, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (178, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (179, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (180, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (181, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (182, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (183, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (184, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (185, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (186, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (187, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (188, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (189, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (190, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (191, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (192, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (193, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (194, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (195, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (196, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (197, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (198, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (199, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (200, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (201, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (202, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (203, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (204, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (205, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (206, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (207, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (208, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (209, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (210, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (211, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (212, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (213, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (214, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (215, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (216, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (217, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (218, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (219, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (220, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (221, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (222, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (223, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (224, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (225, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (226, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (227, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (228, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (229, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (230, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (231, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (232, 'form_field', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (233, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (234, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (235, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (236, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (237, 'form_field_choice', '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.component VALUES (238, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (239, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (240, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (241, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (242, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (243, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (244, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (245, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (246, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (247, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (248, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (249, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (250, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (251, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (252, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (253, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (254, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (255, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (256, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (257, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (258, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (259, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (260, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (261, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (262, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (263, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (264, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (265, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (266, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (267, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (268, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (269, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (270, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (271, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (272, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (273, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (274, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (275, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (276, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (277, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (278, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (279, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (280, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (281, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (282, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (283, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (284, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (285, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (286, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (287, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (288, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (289, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (290, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (291, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (292, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (293, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (294, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (295, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (296, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (297, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (298, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (299, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (300, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (301, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (302, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (303, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (304, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (305, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (306, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (307, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (308, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (309, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (310, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (311, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (312, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (313, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (314, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (315, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (316, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (317, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (318, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (319, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (320, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (321, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (322, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (323, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (324, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (325, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (326, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (327, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (328, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (329, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (330, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (331, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (332, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (333, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (334, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (335, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (336, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (337, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (338, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (339, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (340, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (341, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (342, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (343, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (344, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (345, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (346, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (347, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (348, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (349, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (350, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (351, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (352, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (353, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (354, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (355, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (356, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (357, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (358, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (359, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (360, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (361, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (362, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (363, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (364, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (365, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (366, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (367, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (368, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (369, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (370, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (371, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (372, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (373, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (374, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (375, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (376, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (377, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (378, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (379, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (380, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (381, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (382, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (383, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (384, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (385, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (386, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (387, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (388, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (389, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (390, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (391, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (392, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (393, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (394, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (395, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (396, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (397, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (398, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (399, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (400, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (401, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (402, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (403, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (404, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (405, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (406, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (407, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (408, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (409, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (410, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (411, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (412, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (413, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (414, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (415, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (416, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (417, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (418, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (419, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (420, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (421, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (422, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (423, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (424, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (425, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (426, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (427, 'form_field', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (428, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (429, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (430, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (431, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (432, 'form_field_choice', '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.component VALUES (548, 'form_field_choice', '2019-01-16 19:08:55.004238', NULL);
INSERT INTO wtf.component VALUES (553, 'form_field', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (554, 'form_field_choice', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (555, 'form_field_choice', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (556, 'form_field_choice', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (557, 'form_field_choice', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (558, 'form_field_choice', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (559, 'form_field', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (560, 'form_field_choice', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (561, 'form_field_choice', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (562, 'form_field_choice', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (563, 'form_field_choice', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (564, 'form_field_choice', '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.component VALUES (565, 'form_field', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (566, 'form_field_choice', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (567, 'form_field_choice', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (568, 'form_field', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (569, 'form_field_choice', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (570, 'form_field_choice', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (571, 'form_field', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (572, 'form_field_choice', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (573, 'form_field_choice', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (574, 'form_field_choice', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (575, 'form_field_choice', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (576, 'form_field_choice', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (577, 'form_field_choice', '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.component VALUES (578, 'form_field', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (579, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (580, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (581, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (582, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (583, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (584, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (585, 'form_field', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (586, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (587, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (588, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (589, 'form_field', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (590, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (591, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (592, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (593, 'form_field', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (594, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (595, 'form_field_choice', '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.component VALUES (596, 'form_field', '2019-06-24 15:55:55.075099', NULL);
INSERT INTO wtf.component VALUES (597, 'form_field', '2019-06-24 15:55:55.075099', NULL);
INSERT INTO wtf.component VALUES (598, 'form_field_choice', '2019-06-24 15:55:55.075099', NULL);


--
-- Data for Name: data_type; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.data_type VALUES (1, 'int', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.data_type VALUES (2, 'char', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.data_type VALUES (3, 'boolean', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.data_type VALUES (4, 'double', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.data_type VALUES (5, 'date', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.data_type VALUES (7, 'text', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.data_type VALUES (8, 'datetime', '2019-10-18 15:12:27.639493', NULL);
INSERT INTO wtf.data_type VALUES (6, 'time', '2019-01-13 14:40:33.047785', NULL);


--
-- Data for Name: field_type; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.field_type VALUES (1, 'monivalinta_yksi_vastaus', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.field_type VALUES (2, 'monivalinta_monta_vastausta', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.field_type VALUES (3, 'vapaa_teksti', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.field_type VALUES (4, 'ei_vastausta', '2019-01-13 14:40:33.047785', NULL);


--
-- Data for Name: field; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.field VALUES (1, 'Tutkimuspäivä', NULL, 3, 5, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (2, 'PSA (mg/l)', NULL, 3, 4, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (5, 'MRI edeltävästi?', NULL, 1, 3, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (6, 'MRI tehty TYKSissä?', NULL, 1, 3, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (7, 'PI-RADS?', 'Prostate Imaging Reporting and Data Sytem:<br>PIRADS 1: very low (clinically significant cancer is highly unlikely to be present)<br>PIRADS 2: low (clinically significant cancer is unlikely to be present)<br>PIRADS 3: intermediate (the presence of clinically significant cancer is equivocal)<br>PIRADS 4: high (clinically significant cancer is likely to be present)<br>PIRADS 5: very high (clinically significant cancer is highly likely to be present)', 1, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (8, 'Systemaattisten biopsioiden määrä oikealta', NULL, 3, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (9, 'Systemaattisten biopsioiden määrä vasemmalta', NULL, 3, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (10, 'MRI:n perusteella kohdennettujen biopsioiden määrä', NULL, 3, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (11, 'Hoitoneuvottelupäivä', NULL, 3, 5, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (12, 'Biopsiakomplikaatioita?', NULL, 1, 3, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (13, 'Kontakti terveydenhuoltoon', NULL, 1, 3, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (14, 'Sairaalahoitoa', NULL, 1, 3, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (16, 'Komplikaatiotyyppi', NULL, 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (17, 'Syöpä?', NULL, 1, 3, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (18, 'Biopsian Gleason-luokat', NULL, 4, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (19, 'Yleisin', NULL, 1, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (20, 'Toiseksi yleisin', NULL, 1, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (21, 'Syövän osuus biopsioista (%)', NULL, 3, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (24, 'Hoitosuunnitelma', NULL, 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (25, 'Hoidon päivämäärä', NULL, 3, 5, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (26, 'Leikkaava lääkäri', NULL, 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (27, 'Leikkausindikaatio', NULL, 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (28, 'Imusolmukkeiden poisto', NULL, 1, 3, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (29, 'Hermojen säästö, oikea puoli', NULL, 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (30, 'Hermojen säästö, vasen puoli', NULL, 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (31, 'Vuodon määrä ml', NULL, 3, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (33, 'Kotiutuspäivä', NULL, 3, 5, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (34, 'Seurantapäivä (3kk)', NULL, 3, 5, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (35, 'Leikkauksen Gleason-luokat', NULL, 4, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (36, 'Kirurginen marginaali (mm)', NULL, 3, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (37, 'Kasvu kapselin ulkopuolelle', NULL, 1, 3, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (38, 'Kasvu rakkularauhasiin', NULL, 1, 3, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (39, 'Imusolmuke-etäpesäkkeitä', NULL, 1, 3, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (40, 'Metastaattisten imusolmukkeiden lkm', NULL, 3, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (41, 'Tutkittujen imusolmukkeiden lkm', NULL, 3, 1, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (42, 'Tautitilanne', NULL, 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (43, 'Tautitilanteen muutoksen tarkenne', 'Biokemiallinen relapsi: PSA noussut yli rajaarvon 0,2 \u03bcl/l laskettuaan ensin sen alle.<br>Kastraatioresistantti tauti:<br>testosteroni kastraatiotasolla (<1.7 nmol/l), SEKÄ<br>biokemallinen progressio (PSA >2 \u03bcl/l ja kolme nousevaa arvoa yli nadir-arvon), TAI<br>radiologinen progressio (kaksi tai useampia luustomuutoksia tai uusi pehmytkudosmetastaasi)', 2, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (44, 'Seurantapäivä', NULL, 3, 5, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (45, 'Seurannan muutos', NULL, 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (46, 'Kuinka usein sinulla on ollut virtsankarkailua viimeisten 4 viikon aikana?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (47, 'Mikä seuraavista kuvaa parhaiten virtsanpidätyskykyäsi viimeisten 4 viikon aikana?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (3, 'Prostatan koko (cm3)', 'Koko kuutiosenttimetreissä väliltä 0-200', 3, 4, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (48, 'Kuinka monta suojaa tai vaippaa vuorokaudessa käytit viimeisten 4 viikon aikana?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (49, 'Kuinka suurina ongelmina olet kokenut seuraavat asiat viimeisten 4 viikon aikana?', NULL, 4, NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (50, 'Tiputtelu tai virtsankarkailu', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (51, 'Kipu tai kirvely virtsatessa', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (52, 'Verenvuoto virtsatessa', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (53, 'Heikko virtsasuihku tai virtsarakon epätäydellinen tyhjeneminen', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (54, 'Tiheä virtsaamistarve päivän aikana', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (55, 'Kuinka suurena ongelmana kaikkiaan olet kokenut virtsaamisen viimeisten 4 viikon aikana?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (56, 'Kuinka suurina ongelmina olet kokenut seuraavat asiat?', NULL, 4, NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (57, 'Äkillinen ulostamistarve', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (58, 'Tihentynyt ulostamistarve', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (59, 'Ulosteenkarkailu', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (60, 'Verta ulosteessa', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (61, 'Vatsan, lantion tai peräsuolen kipu', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (62, 'Kuinka suurena ongelmana kaikkiaan olet kokenut suolentoimintasi viimeisten 4 viikon aikana?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (63, 'Millaiseksi arvioit seuraavat asiat viimeisten 4 viikon aikana?', NULL, 4, NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (64, 'Kykysi saada erektio?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (65, 'Kykysi saada orgasmi (laukeaminen)?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (66, 'Millaiseksi kuvailisit erektioittesi tavanomaisen LAADUN viimeisten 4 viikon aikana?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (67, 'Millaiseksi kuvailisit erektioittesi TIHEYDEN viimeisten 4 viikon aikana?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (68, 'Millaiseksi arvioisit kaikkiaan seksuaalisen toimintakykysi viimeisten 4 viikon aikana?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (69, 'Kuinka suurena ongelmana kaikkiaan olet kokenut seksuaalisen toimintakykysi tai sen puutteen viimeisten 4 viikon aikana?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (70, 'Kuinka suurina ongelmina olet kokenut seuraavat asiat viimeisten 4 viikon aikana?', NULL, 4, NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (71, 'Kuumat aallot', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (72, 'Rintojen arkuus tai kasvu', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (73, 'Masentuneisuus', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (74, 'Vetämättömyys', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (75, 'Painonmuutos', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (76, 'Missä määrit olit kiinnostunut seksistä viimeisten 4 viikon aikana?', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (77, 'Oletko käyttänyt lääkkeitä tai laitteita parantamaan erektiotasi?', NULL, 1, 3, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (78, 'Ilmoita kunkin lääkkeen tai laitteen osalta,oletko kokeillut tai käytätkö sitä tällä hetkellä parantamaan erektiotasi.', NULL, 4, NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (79, 'Tabletti (kuten Viagra)', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (80, 'Virtsaputken sisäinen puikko (kuten Muse)', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (81, 'Siittimen pistoshoito (kuten Caverject)', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (82, 'Tyhjiöpumppu (kuten ErecAid)', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (83, 'Muu', NULL, 1, 2, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.field VALUES (111, 'Levinneisyystutkimukset', NULL, 2, 2, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.field VALUES (113, 'Jos prebiopsia-MRI:tä ei tehty, tehtiinkö preoperatiivinen MRI?', NULL, 1, 3, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.field VALUES (23, 'M-luokka', '<div class="field_description"><table>
				<tr><th>M&#8209;luokka</th><th>Kuvaus</th></tr>
				<tr><td>MX</td><td>Etäpesäkkeitä ei voida määrittää.</td></tr>
				<tr><td>M0</td><td>Etäpesäkkeitä ei ole.</td></tr>
				<tr><td>M1</td><td>Etäpesäkkeitä on.</td></tr>
				<tr><td>M1a</td><td>Etäpesäkkeitä on myös muissa kuin alueellisissa imusolmukkeissa.</td></tr>
				<tr><td>M1b</td><td>Etäpesäkkeitä on luissa.</td></tr>
				<tr><td>M1c</td><td>Etäpesäkkeitä on muissa elimissä.</td></tr>
				</table></div>', 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (114, 'pT-luokka', '<table>
				<tr><th>pT-luokka</th><th>Kuvaus</th></tr>
				<tr><td>T2a</td><td>Kasvain on rajoittunut yhteen lohkoon (alle 50 % lohkosta).</td></tr>
				<tr><td>T2b</td><td>Kasvain on rajoittunut yhteen lohkoon (yli 50 % lohkosta).</td></tr>
				<tr><td>T2c</td><td>Kasvain on rajoittunut molempiin lohkoihin.</td></tr>
				<tr><td>T3a</td><td>Kasvain on kasvanut toispuolisesti tai molemminpuolisesti kapselin läpi.</td></tr>
				<tr><td>T3b</td><td>Kasvain tunkeutuu rakkularauhaseen.</td></tr>
				<tr><td>T4</td><td>Kasvain on fiksoitunut tai tunkeutuu muihin lähielimiin kuin rakkularauhasiin: virtsarakon kaulaan, ulompaan sulkijalihakseen, peräsuoleen, lantiopohjan lihaksiin tai lantion seinämään.</td></tr>
				</table>', 1, 2, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.field VALUES (115, 'pN-luokka', '<table>
				<tr><th>N-luokka</th><th>Kuvaus</th></tr>
				<tr><td>NX</td><td>Alueellisia imusolmukkeita ei voida määrittää.</td></tr>
				<tr><td>N0</td><td>Alueellisia imusolmuke-etäpesäkkeitä ei ole.</td></tr>
				<tr><td>N1</td><td>Alueellisia imusolmuke-etäpesäkkeitä on.</td></tr>
				</table>', 1, 2, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.field VALUES (116, 'Kolmanneksi yleisin', NULL, 1, 1, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.field VALUES (117, 'Perineuraalinen invaasio', NULL, 1, 3, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.field VALUES (112, 'ECOG', '<div class="field_description"><table>
					<tr><th>ECOG-aste</th><th>Kuvaus</th></tr>
					<tr><td>Aste 0</td><td>Potilas pystyy kaikkeen normaaliin toimintaan rajoituksetta.</td></tr>
					<tr><td>Aste 1</td><td>Potilas on oireinen, ei pysty raskaisiin fyysisiin ponnistuksiin, on liikkuva, kykenee kevyeen työhön tai toimintaan.</td></tr>
					<tr><td>Aste 2</td><td>Potilas on liikkuva ja pystyy hoitamaan itsensä. Ei pysty mihinkään työhön. Viettää osan mutta alle 50% valveillaoloajasta vuoteessa.</td></tr>
					<tr><td>Aste 3</td><td>Potilas pystyy vain rajoitetusti hoitamaan itseänsä ja on vuoteessa yli 50% valveillaoloajasta.</td></tr>
					<tr><td>Aste 4</td><td>Täysin vuodepotilas. Ei pysty lainkaan hoitamaan itseänsä.</td></tr>
					</table></div>', 1, 2, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.field VALUES (4, 'cT-luokka', '<div class="field_description"><table>
				<tr><th>cT&#8209;luokka</th><th>Kuvaus</th></tr>
				<tr><td>TX</td><td>Kasvainta ei voida määrittää.</td></tr>
				<tr><td>T1</td><td>Kasvain ei ole palpoitavissa eikä visualisoitavissa.</td></tr>
				<tr><td>T1a</td><td>Kasvain on histologinen sattumalöydös. Alle 5 % poistetusta kudoksesta on kasvainta.</td></tr>
				<tr><td>T1b</td><td>Kasvain on todettu (esim. suurentuneen PSA-arvon vuoksi tehdyssä) neulabiopsiassa.</td></tr>
				<tr><td>T2</td><td>Kasvain on rajoittunut eturauhaseen.</td></tr>
				<tr><td>T2a</td><td>Kasvain on rajoittunut yhteen lohkoon (alle 50 % lohkosta).</td></tr>
				<tr><td>T2b</td><td>Kasvain on rajoittunut yhteen lohkoon (yli 50 % lohkosta).</td></tr>
				<tr><td>T2c</td><td>Kasvain on rajoittunut molempiin lohkoihin.</td></tr>
				<tr><td>T3</td><td>Kasvain tunkeutuu eturauhaskapselin läpi.</td></tr>
				<tr><td>T3a</td><td>Kasvain on kasvanut toispuolisesti tai molemminpuolisesti kapselin läpi.</td></tr>
				<tr><td>T3b</td><td>Kasvain tunkeutuu rakkularauhaseen.</td></tr>
				<tr><td>T4</td><td>Kasvain on fiksoitunut tai tunkeutuu muihin lähielimiin kuin rakkularauhasiin: virtsarakon kaulaan, ulompaan sulkijalihakseen, peräsuoleen, lantiopohjan lihaksiin tai lantion seinämään.</td></tr>
				</table></div>', 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (22, 'N-luokka', '<div class="field_description"><table>
				<tr><th>N&#8209;luokka</th><th>Kuvaus</th></tr>
				<tr><td>NX</td><td>Alueellisia imusolmukkeita ei voida määrittää.</td></tr>
				<tr><td>N0</td><td>Alueellisia imusolmuke-etäpesäkkeitä ei ole.</td></tr>
				<tr><td>N1</td><td>Alueellisia imusolmuke-etäpesäkkeitä on.</td></tr>
				</table></div>', 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (15, 'Clavien-luokka', '<div class="field_description"><table>
<tr><th>Gradus</th><th>Kuvaus</th></tr>
<tr><td>Gradus&nbsp;I</td><td>Mikä tahansa poikkeama normaalista toipumisesta joka johtaa johonkin intervention.
Lääkityksistä  kipulääkkeet, pahoinvointilääkkeet, nestehoito. Myös mm. haavan ylimääräinen hoito, suunnittelematon fysioterapia, ylimääräiset kontrollit jne.</td></tr>
<tr><td>Gradus&nbsp;II</td><td>Merkittävämpi konservatiivinen hoito, edellistä raskaampi lääkitys, verensiirrot, parenteraalinen nesteytys.</td></tr>
<tr><td>Gradus&nbsp;IIIa</td><td>Kirurginen toimenpide ilman yleisanestesiaa.</td></tr>
<tr><td>Gradus&nbsp;IIIb</td><td>Kirurginen toimenpide yleisanestesiassa.</td></tr>
<tr><td>Gradus&nbsp;IVa</td><td>Henkeä uhkaava komplikaatio: Tehostettu hoito/tehohoito, yhden elinryhmän toimintahäiriö, esim. akuutti munuaisten vajaatoiminta, sydäninfarkti, aivotapahtuma.</td></tr>
<tr><td>Gradus&nbsp;IVb</td><td>Henkeä uhkaava komplikaatio: Monen elinryhmän toimintahäiriö.</td></tr>
<tr><td>Gradus&nbsp;V</td><td>Kuolema.</td></tr>
</table></div>', 1, 2, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.field VALUES (118, 'Leikkauksen alkuhetki', NULL, 3, 6, '2019-06-24 15:55:55.075099', NULL);
INSERT INTO wtf.field VALUES (119, 'Leikkauksen loppuhetki', NULL, 3, 6, '2019-06-24 15:55:55.075099', NULL);


--
-- Data for Name: gui_element_type; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.gui_element_type VALUES (1, 'text_field', 'vertical', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.gui_element_type VALUES (2, 'text_area', 'vertical', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.gui_element_type VALUES (3, 'radio_button', 'vertical', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.gui_element_type VALUES (4, 'radio_button', 'horizontal', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.gui_element_type VALUES (5, 'select_field', 'vertical', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.gui_element_type VALUES (6, 'checkbox', 'vertical', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.gui_element_type VALUES (7, 'checkbox', 'horizontal', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.gui_element_type VALUES (8, 'calendar', 'vertical', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.gui_element_type VALUES (9, 'file_chooser', 'vertical', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.gui_element_type VALUES (10, 'hidden', 'vertical', '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.gui_element_type VALUES (11, 'timestamp', 'horizontal', '2019-06-24 15:55:55.075099', NULL);
INSERT INTO wtf.gui_element_type VALUES (12, 'datetime', 'vertical', '2019-10-18 15:12:27.639493', NULL);


--
-- Data for Name: form_field; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.form_field VALUES (1, 8, 1, 1, 1, NULL, false, NULL, true, 8, '2019-01-13 14:40:33.172325', NULL, true, 1);
INSERT INTO wtf.form_field VALUES (132, 10, 118, 596, 3, NULL, false, NULL, true, 11, '2019-06-24 15:55:55.075099', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (133, 10, 119, 597, 4, NULL, false, NULL, true, 11, '2019-06-24 15:55:55.075099', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (5, 8, 5, 18, 5, NULL, false, NULL, true, 4, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (6, 8, 6, 21, 6, NULL, false, NULL, true, 4, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (7, 8, 7, 24, 7, NULL, false, NULL, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (58, 14, 46, 238, 1, '1.', false, NULL, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (59, 14, 47, 243, 2, '2.', false, NULL, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (60, 14, 48, 248, 3, '3.', false, NULL, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (61, 14, 49, 253, 4, '4.', false, NULL, true, 10, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (62, 14, 50, 254, 1, 'a.', false, 61, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (63, 14, 51, 260, 2, 'b.', false, 61, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (64, 14, 52, 266, 3, 'c.', false, 61, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (65, 14, 53, 272, 4, 'd.', false, 61, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (2, 8, 2, 2, 2, NULL, false, NULL, true, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (3, 8, 3, 3, 3, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (4, 8, 4, 4, 4, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (8, 8, 8, 31, 8, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (9, 8, 9, 32, 9, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (10, 8, 10, 33, 10, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (66, 14, 54, 278, 5, 'e.', false, 61, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (67, 14, 55, 284, 5, '5.', false, NULL, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (68, 14, 56, 290, 6, '6.', false, NULL, true, 10, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (69, 14, 57, 291, 1, 'a.', false, 68, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (70, 14, 58, 297, 2, 'b.', false, 68, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (71, 14, 59, 303, 3, 'c.', false, 68, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (72, 14, 60, 309, 4, 'd.', false, 68, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (73, 14, 61, 315, 5, 'e.', false, 68, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (74, 14, 62, 321, 7, '7.', false, NULL, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (75, 14, 63, 327, 8, '8.', false, NULL, true, 10, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (76, 14, 64, 328, 1, 'a.', false, 75, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (77, 14, 65, 334, 2, 'b.', false, 75, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (78, 14, 66, 340, 9, '9.', false, NULL, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (79, 14, 67, 345, 10, '10.', false, NULL, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (80, 14, 68, 351, 11, '11.', false, NULL, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (81, 14, 69, 357, 12, '12.', false, NULL, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (82, 14, 70, 363, 13, '13.', false, NULL, true, 10, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (83, 14, 71, 364, 1, 'a.', false, 82, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (84, 14, 72, 370, 2, 'b.', false, 82, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (85, 14, 73, 376, 3, 'c.', false, 82, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (86, 14, 74, 382, 4, 'd.', false, 82, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (87, 14, 75, 388, 5, 'e.', false, 82, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (88, 14, 76, 394, 14, '14.', false, NULL, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (89, 14, 77, 399, 15, '15.', false, NULL, true, 4, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (90, 14, 78, 402, 16, '16.', false, NULL, true, 10, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (91, 14, 79, 403, 1, 'a.', false, 90, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (92, 14, 80, 409, 2, 'b.', false, 90, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (93, 14, 81, 415, 3, 'c.', false, 90, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (94, 14, 82, 421, 4, 'd.', false, 90, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (95, 14, 83, 427, 5, 'e.', false, 90, true, 3, '2019-01-13 14:40:33.543027', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (11, 9, 11, 34, 1, NULL, false, NULL, true, 8, '2019-01-13 14:40:33.172325', NULL, true, 1);
INSERT INTO wtf.form_field VALUES (27, 10, 25, 104, 1, NULL, false, NULL, true, 8, '2019-01-13 14:40:33.172325', NULL, true, 1);
INSERT INTO wtf.form_field VALUES (39, 11, 33, 166, 1, NULL, false, NULL, true, 8, '2019-01-13 14:40:33.172325', NULL, true, 1);
INSERT INTO wtf.form_field VALUES (41, 12, 34, 176, 1, NULL, false, NULL, true, 8, '2019-01-13 14:40:33.172325', NULL, true, 1);
INSERT INTO wtf.form_field VALUES (54, 13, 44, 219, 1, NULL, false, NULL, true, 8, '2019-01-13 14:40:33.172325', NULL, true, 1);
INSERT INTO wtf.form_field VALUES (29, 10, 4, 122, 5, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (30, 10, 22, 136, 6, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (31, 10, 23, 140, 7, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (32, 10, 3, 147, 8, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (35, 10, 29, 154, 14, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (36, 10, 30, 159, 15, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (12, 9, 12, 35, 2, NULL, false, NULL, true, 4, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (13, 9, 13, 38, 3, NULL, false, NULL, true, 4, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (14, 9, 14, 41, 4, NULL, false, NULL, true, 4, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (15, 9, 15, 44, 5, NULL, false, NULL, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (16, 9, 16, 53, 6, NULL, false, NULL, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (17, 9, 17, 57, 7, NULL, false, NULL, true, 4, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (21, 9, 21, 69, 9, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (22, 9, 4, 70, 10, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (23, 9, 22, 84, 11, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (24, 9, 23, 88, 12, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (25, 9, 3, 95, 13, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (26, 9, 24, 96, 14, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (28, 10, 26, 105, 2, NULL, false, NULL, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (40, 11, 15, 167, 2, NULL, false, NULL, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (55, 13, 42, 220, 2, NULL, false, NULL, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (123, 9, 111, 553, 15, NULL, false, NULL, true, 6, '2019-05-27 16:21:56.793058', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (124, 9, 112, 559, 16, NULL, false, NULL, true, 5, '2019-05-27 16:21:56.793058', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (57, 13, 45, 232, 4, NULL, false, NULL, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (18, 9, 18, 60, 8, NULL, false, NULL, true, 10, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (56, 13, 43, 224, 3, NULL, false, NULL, true, 6, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (45, 12, 36, 186, 5, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (46, 12, 37, 187, 6, NULL, false, NULL, false, 4, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (47, 12, 38, 190, 7, NULL, false, NULL, false, 4, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (19, 9, 19, 61, 1, NULL, false, 18, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (20, 9, 20, 65, 2, NULL, false, 18, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (42, 12, 35, 177, 2, NULL, false, NULL, true, 10, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (43, 12, 19, 178, 1, NULL, false, 42, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (44, 12, 20, 182, 2, NULL, false, 42, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (128, 12, 114, 578, 3, NULL, false, NULL, false, 5, '2019-05-27 16:22:44.140455', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (129, 12, 115, 585, 4, NULL, false, NULL, false, 5, '2019-05-27 16:22:44.140455', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (48, 12, 39, 193, 9, NULL, false, NULL, false, 4, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (49, 12, 40, 196, 10, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (50, 12, 41, 197, 11, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (51, 12, 15, 198, 12, NULL, false, NULL, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (52, 12, 42, 207, 13, NULL, false, NULL, true, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (53, 12, 43, 211, 14, NULL, false, NULL, true, 6, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (131, 12, 117, 593, 8, NULL, false, NULL, true, 4, '2019-05-27 16:22:44.140455', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (130, 12, 116, 589, 3, NULL, false, 42, true, 5, '2019-05-27 16:22:44.140455', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (33, 10, 27, 148, 12, NULL, false, NULL, false, 5, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (34, 10, 28, 151, 13, NULL, false, NULL, false, 4, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (37, 10, 31, 164, 16, NULL, false, NULL, false, 1, '2019-01-13 14:40:33.172325', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (125, 10, 113, 565, 9, NULL, false, NULL, true, 4, '2019-05-27 16:22:21.895825', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (126, 10, 6, 568, 10, NULL, false, NULL, true, 4, '2019-05-27 16:22:21.895825', NULL, false, 1);
INSERT INTO wtf.form_field VALUES (127, 10, 7, 571, 11, NULL, false, NULL, true, 5, '2019-05-27 16:22:21.895825', NULL, false, 1);


--
-- Data for Name: answer; Type: TABLE DATA; Schema: wtf; Owner: -
--



--
-- Data for Name: component_condition; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.component_condition VALUES (21, 19, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (24, 19, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (33, 19, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (38, 37, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (41, 37, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (44, 37, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (53, 37, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (60, 59, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (61, 59, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (65, 59, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (69, 59, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (70, 59, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (84, 59, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (88, 59, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (95, 59, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (96, 59, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (105, 99, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (148, 99, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (151, 99, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (177, 99, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (178, 99, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (182, 99, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (186, 99, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (187, 99, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (190, 99, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (193, 152, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (197, 152, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (196, 195, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (211, 210, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (224, 223, false, '2019-01-13 14:40:33.435796', NULL);
INSERT INTO wtf.component_condition VALUES (553, 59, false, '2019-05-27 16:22:07.750445', NULL);
INSERT INTO wtf.component_condition VALUES (559, 59, false, '2019-05-27 16:22:07.750445', NULL);
INSERT INTO wtf.component_condition VALUES (568, 566, false, '2019-05-27 16:22:32.727084', NULL);
INSERT INTO wtf.component_condition VALUES (571, 566, false, '2019-05-27 16:22:32.727084', NULL);
INSERT INTO wtf.component_condition VALUES (565, 99, false, '2019-05-27 16:22:54.671273', NULL);
INSERT INTO wtf.component_condition VALUES (589, 99, false, '2019-05-27 16:22:54.671273', NULL);
INSERT INTO wtf.component_condition VALUES (578, 99, false, '2019-05-27 16:22:54.671273', NULL);
INSERT INTO wtf.component_condition VALUES (585, 99, false, '2019-05-27 16:22:54.671273', NULL);
INSERT INTO wtf.component_condition VALUES (593, 99, false, '2019-05-27 16:22:54.671273', NULL);
INSERT INTO wtf.component_condition VALUES (596, 99, false, '2019-06-24 15:55:55.075099', NULL);
INSERT INTO wtf.component_condition VALUES (597, 99, false, '2019-06-24 15:55:55.075099', NULL);


--
-- Data for Name: component_hide; Type: TABLE DATA; Schema: wtf; Owner: -
--



--
-- Data for Name: context; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.context VALUES (1, 'analytics');


--
-- Data for Name: filter; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.filter VALUES (1, 'email', '.*@.*\..*', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2019-01-13 14:40:33.047785', NULL);
INSERT INTO wtf.filter VALUES (2, 'prostatan_koko', NULL, 0, 200, NULL, NULL, NULL, NULL, NULL, NULL, '2019-01-13 14:40:33.047785', NULL);


--
-- Data for Name: field_filter; Type: TABLE DATA; Schema: wtf; Owner: -
--



--
-- Data for Name: form_field_choice; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.form_field_choice VALUES (1, 4, 5, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (5, 4, 9, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (6, 4, 10, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (10, 4, 14, 10, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (13, 4, 17, 13, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 5, 19, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 5, 20, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 6, 22, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 6, 23, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (16, 7, 25, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (17, 7, 26, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (18, 7, 27, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (19, 7, 28, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (20, 7, 29, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (21, 7, 30, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 12, 36, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 12, 37, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 13, 39, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 13, 40, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 14, 42, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 14, 43, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (23, 15, 46, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (24, 15, 47, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (25, 15, 48, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (26, 15, 49, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (27, 15, 50, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (28, 15, 51, 7, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (29, 15, 52, 8, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (30, 16, 54, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (31, 16, 55, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (32, 16, 56, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 17, 58, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 17, 59, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (19, 19, 62, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (20, 19, 63, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (21, 19, 64, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (19, 20, 66, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (20, 20, 67, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (21, 20, 68, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (1, 22, 71, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (5, 22, 75, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (6, 22, 76, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (10, 22, 80, 10, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (13, 22, 83, 13, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (34, 23, 85, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (35, 23, 86, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (36, 23, 87, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (37, 24, 89, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (38, 24, 90, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (39, 24, 91, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (40, 24, 92, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (41, 24, 93, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (42, 24, 94, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (43, 26, 97, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (44, 26, 98, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (45, 26, 99, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (46, 26, 100, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (47, 26, 101, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (48, 26, 102, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (49, 26, 103, 7, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (50, 28, 106, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (51, 28, 107, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (1, 29, 123, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (5, 29, 127, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (6, 29, 128, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (10, 29, 132, 10, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (13, 29, 135, 13, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (34, 30, 137, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (35, 30, 138, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (36, 30, 139, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (37, 31, 141, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (38, 31, 142, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (39, 31, 143, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (40, 31, 144, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (41, 31, 145, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (42, 31, 146, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (66, 33, 149, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (67, 33, 150, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 34, 152, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 34, 153, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (68, 35, 155, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (69, 35, 156, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (70, 35, 157, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (71, 35, 158, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (68, 36, 160, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (69, 36, 161, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (70, 36, 162, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (71, 36, 163, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (22, 40, 168, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (23, 40, 169, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (24, 40, 170, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (25, 40, 171, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (26, 40, 172, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (27, 40, 173, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (28, 40, 174, 7, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (29, 40, 175, 8, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (19, 43, 179, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (20, 43, 180, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (21, 43, 181, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (19, 44, 183, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (20, 44, 184, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (21, 44, 185, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 46, 188, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 46, 189, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 47, 191, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 47, 192, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 48, 194, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 48, 195, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (22, 51, 199, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (23, 51, 200, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (24, 51, 201, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (25, 51, 202, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (26, 51, 203, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (27, 51, 204, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (28, 51, 205, 7, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (29, 51, 206, 8, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (72, 52, 208, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (73, 52, 209, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (74, 52, 210, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (75, 53, 212, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (76, 53, 213, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (77, 53, 214, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (78, 53, 215, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (79, 53, 216, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (80, 53, 217, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (81, 53, 218, 7, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (72, 55, 221, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (73, 55, 222, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (74, 55, 223, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (75, 56, 225, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (76, 56, 226, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (77, 56, 227, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (78, 56, 228, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (79, 56, 229, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (80, 56, 230, 6, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (81, 56, 231, 7, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (82, 57, 233, 1, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (83, 57, 234, 2, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (84, 57, 235, 3, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (85, 57, 236, 4, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (86, 57, 237, 5, NULL, NULL, '2019-01-13 14:40:33.172325', NULL);
INSERT INTO wtf.form_field_choice VALUES (91, 59, 244, 1, '1:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (92, 59, 245, 2, '2:', 33, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (93, 59, 246, 3, '3:', 67, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (94, 59, 247, 4, '4:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (95, 60, 249, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (96, 60, 250, 2, '1:', 67, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (97, 60, 251, 3, '2:', 33, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (98, 60, 252, 4, '3:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 62, 255, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 62, 256, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 62, 257, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 62, 258, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 62, 259, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 63, 261, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 63, 262, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 63, 263, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 63, 264, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 64, 267, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 69, 292, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 69, 293, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 69, 294, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 70, 298, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 70, 299, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 70, 300, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 71, 304, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 67, 285, 1, '1:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (95, 88, 395, 1, '0:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (119, 88, 396, 2, '1:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (120, 88, 397, 3, '2:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (121, 88, 398, 4, '3:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (122, 89, 400, 1, '1:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (123, 89, 401, 2, '2:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (124, 91, 404, 1, '0:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (125, 91, 405, 2, '1:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (126, 91, 406, 3, '2:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (127, 91, 407, 4, '3:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (128, 91, 408, 5, '4:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (124, 92, 410, 1, '0:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (125, 92, 411, 2, '1:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (126, 92, 412, 3, '2:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (127, 92, 413, 4, '3:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (128, 92, 414, 5, '4:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (124, 93, 416, 1, '0:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (125, 93, 417, 2, '1:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (126, 93, 418, 3, '2:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (127, 93, 419, 4, '3:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (128, 93, 420, 5, '4:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (124, 94, 422, 1, '0:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (125, 94, 423, 2, '1:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (126, 94, 424, 3, '2:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (127, 94, 425, 4, '3:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (128, 94, 426, 5, '4:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (124, 95, 428, 1, '0:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (125, 95, 429, 2, '1:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (126, 95, 430, 3, '2:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (127, 95, 431, 4, '3:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (128, 95, 432, 5, '4:', NULL, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (104, 76, 329, 1, '1:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (105, 76, 330, 2, '2:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (106, 76, 331, 3, '3:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (107, 76, 332, 4, '4:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (108, 76, 333, 5, '5:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (104, 77, 335, 1, '1:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (105, 77, 336, 2, '2:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (106, 77, 337, 3, '3:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (107, 77, 338, 4, '4:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (108, 77, 339, 5, '5:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (113, 79, 346, 1, '1:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (114, 79, 347, 2, '2:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (115, 79, 348, 3, '3:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (116, 79, 349, 4, '4:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (117, 79, 350, 5, '5:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (118, 80, 352, 1, '1:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (105, 80, 353, 2, '2:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (106, 80, 354, 3, '3:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (107, 80, 355, 4, '4:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (108, 80, 356, 5, '5:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (109, 78, 341, 1, '1:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (110, 78, 342, 2, '2:', 33, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (87, 58, 239, 1, '1:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (88, 58, 240, 2, '2:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (89, 58, 241, 3, '3:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (90, 58, 242, 4, '4:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (174, 58, 548, 5, '5:', 100, '2019-01-16 19:08:55.004238', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 63, 265, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 64, 268, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 64, 269, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 64, 270, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 64, 271, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 65, 273, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 69, 295, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 69, 296, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 70, 301, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 70, 302, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 71, 305, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (111, 78, 343, 3, '3:', 67, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (112, 78, 344, 4, '4:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 65, 274, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 65, 275, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 65, 276, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 65, 277, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 66, 279, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 66, 280, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 66, 281, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 66, 282, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 66, 283, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 71, 306, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 71, 307, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 71, 308, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 72, 310, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 72, 311, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 72, 312, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 72, 313, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 72, 314, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 73, 316, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 73, 317, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 73, 318, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 73, 319, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 73, 320, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 83, 365, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 83, 366, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 83, 367, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 83, 368, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 83, 369, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 84, 371, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 84, 372, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 84, 373, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 84, 374, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 84, 375, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 85, 377, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 85, 378, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 85, 379, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 85, 380, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 85, 381, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 86, 383, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 86, 384, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 86, 385, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 86, 386, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 86, 387, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 87, 389, 1, '0:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 87, 390, 2, '1:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 87, 391, 3, '2:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 87, 392, 4, '3:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 87, 393, 5, '4:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 67, 286, 2, '2:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 67, 287, 3, '3:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 67, 288, 4, '4:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 67, 289, 5, '5:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 74, 322, 1, '1:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 74, 323, 2, '2:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 74, 324, 3, '3:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 74, 325, 4, '4:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 74, 326, 5, '5:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (99, 81, 358, 1, '1:', 100, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (100, 81, 359, 2, '2:', 75, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (101, 81, 360, 3, '3:', 50, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (102, 81, 361, 4, '4:', 25, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (103, 81, 362, 5, '5:', 0, '2019-01-13 14:40:33.543027', NULL);
INSERT INTO wtf.form_field_choice VALUES (178, 123, 554, 1, NULL, NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.form_field_choice VALUES (179, 123, 555, 2, NULL, NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.form_field_choice VALUES (180, 123, 556, 3, NULL, NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.form_field_choice VALUES (181, 123, 557, 4, NULL, NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.form_field_choice VALUES (182, 123, 558, 5, NULL, NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.form_field_choice VALUES (183, 124, 560, 1, NULL, NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.form_field_choice VALUES (184, 124, 561, 2, NULL, NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.form_field_choice VALUES (185, 124, 562, 3, NULL, NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.form_field_choice VALUES (186, 124, 563, 4, NULL, NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.form_field_choice VALUES (187, 124, 564, 5, NULL, NULL, '2019-05-27 16:21:56.793058', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 125, 566, 1, NULL, NULL, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 125, 567, 2, NULL, NULL, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 126, 569, 1, NULL, NULL, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 126, 570, 2, NULL, NULL, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.form_field_choice VALUES (16, 127, 572, 1, NULL, NULL, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.form_field_choice VALUES (17, 127, 573, 2, NULL, NULL, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.form_field_choice VALUES (18, 127, 574, 3, NULL, NULL, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.form_field_choice VALUES (19, 127, 575, 4, NULL, NULL, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.form_field_choice VALUES (20, 127, 576, 5, NULL, NULL, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.form_field_choice VALUES (21, 127, 577, 6, NULL, NULL, '2019-05-27 16:22:21.895825', NULL);
INSERT INTO wtf.form_field_choice VALUES (188, 128, 579, 7, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (189, 128, 580, 8, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (190, 128, 581, 9, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (191, 128, 582, 11, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (192, 128, 583, 12, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (13, 128, 584, 13, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (34, 129, 586, 1, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (35, 129, 587, 2, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (36, 129, 588, 3, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (19, 130, 590, 1, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (20, 130, 591, 2, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (21, 130, 592, 3, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (15, 131, 594, 1, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (14, 131, 595, 2, NULL, NULL, '2019-05-27 16:22:44.140455', NULL);
INSERT INTO wtf.form_field_choice VALUES (193, 128, 598, 1, NULL, NULL, '2019-06-24 15:55:55.075099', NULL);


--
-- Data for Name: group_form_access; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.group_form_access VALUES (1, 1, true, false, false, '2019-04-14 20:26:18.314635', NULL, true, '2019-04-14 20:26:18.314635', NULL);
INSERT INTO wtf.group_form_access VALUES (14, 3, true, false, false, '2019-04-14 20:26:18.314635', NULL, true, '2019-04-14 20:26:18.314635', NULL);
INSERT INTO wtf.group_form_access VALUES (1, 3, true, true, true, '2019-04-14 20:26:18.314635', NULL, true, '2019-04-14 20:26:18.314635', '2020-06-11 10:25:23.4226');
INSERT INTO wtf.group_form_access VALUES (2, 5, false, true, false, '2019-04-14 20:26:18.314635', NULL, true, '2019-04-14 20:26:18.314635', '2020-10-09 08:54:22.850672');


--
-- Data for Name: synonym; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.synonym VALUES (1, 1, 'uro_laatu', 'form', 1);
INSERT INTO wtf.synonym VALUES (2, 1, 'uro_pot', 'form', 2);
INSERT INTO wtf.synonym VALUES (3, 1, 'c61', 'form', 3);
INSERT INTO wtf.synonym VALUES (8, 1, 'tutkimus_pvm', 'component', 1);
INSERT INTO wtf.synonym VALUES (9, 1, 'psa', 'component', 2);
INSERT INTO wtf.synonym VALUES (10, 1, 'mri_tyksissa', 'component', 21);
INSERT INTO wtf.synonym VALUES (11, 1, 'syst_biopsiat_oikea', 'component', 31);
INSERT INTO wtf.synonym VALUES (12, 1, 'syst_biopsiat_vasen', 'component', 32);
INSERT INTO wtf.synonym VALUES (13, 1, 'mri_biopsioiden_maara', 'component', 33);
INSERT INTO wtf.synonym VALUES (14, 1, 'hoitoneuvottelu_pvm', 'component', 34);
INSERT INTO wtf.synonym VALUES (15, 1, 'biopsia_kompl', 'component', 35);
INSERT INTO wtf.synonym VALUES (16, 1, 'kompl_terv_huolto', 'component', 38);
INSERT INTO wtf.synonym VALUES (17, 1, 'kompl_sairaalahoito', 'component', 41);
INSERT INTO wtf.synonym VALUES (18, 1, 'clavien', 'component', 44);
INSERT INTO wtf.synonym VALUES (19, 1, 'komplikaatiotyyppi', 'component', 53);
INSERT INTO wtf.synonym VALUES (20, 1, 'biopsia_gleason', 'component', 60);
INSERT INTO wtf.synonym VALUES (21, 1, 'biops_syovan_osuus', 'component', 69);
INSERT INTO wtf.synonym VALUES (22, 1, 'hoito_pvm', 'component', 104);
INSERT INTO wtf.synonym VALUES (23, 1, 'leikk_laakari', 'component', 105);
INSERT INTO wtf.synonym VALUES (24, 1, 'hermojen_saasto_oikea', 'component', 154);
INSERT INTO wtf.synonym VALUES (25, 1, 'hermojen_saasto_vasen', 'component', 159);
INSERT INTO wtf.synonym VALUES (26, 1, 'vuoto_ml', 'component', 164);
INSERT INTO wtf.synonym VALUES (27, 1, 'clavien', 'component', 167);
INSERT INTO wtf.synonym VALUES (28, 1, 'seuranta_3kk_pvm', 'component', 176);
INSERT INTO wtf.synonym VALUES (29, 1, 'leikk_gleason', 'component', 177);
INSERT INTO wtf.synonym VALUES (30, 1, 'kir_marg_mm', 'component', 186);
INSERT INTO wtf.synonym VALUES (31, 1, 'metast_node', 'component', 193);
INSERT INTO wtf.synonym VALUES (32, 1, 'metast_node_lkm', 'component', 196);
INSERT INTO wtf.synonym VALUES (33, 1, 'tutk_node_lkm', 'component', 197);
INSERT INTO wtf.synonym VALUES (34, 1, 'clavien', 'component', 198);
INSERT INTO wtf.synonym VALUES (35, 1, 'tautitilanne', 'component', 207);
INSERT INTO wtf.synonym VALUES (36, 1, 'tauti_muutos_tarkenne', 'component', 211);
INSERT INTO wtf.synonym VALUES (37, 1, 'seuranta_pvm', 'component', 219);
INSERT INTO wtf.synonym VALUES (38, 1, 'tautitilanne', 'component', 220);
INSERT INTO wtf.synonym VALUES (39, 1, 'tauti_muutos_tarkenne', 'component', 224);
INSERT INTO wtf.synonym VALUES (40, 1, 'karkailu_4vko', 'component', 238);
INSERT INTO wtf.synonym VALUES (41, 1, 'virtsanpidatyskyky_4vko', 'component', 243);
INSERT INTO wtf.synonym VALUES (42, 1, 'vaipat_maara', 'component', 248);
INSERT INTO wtf.synonym VALUES (43, 1, 'ongelma_4vko', 'component', 253);
INSERT INTO wtf.synonym VALUES (44, 1, 'tiputtelu', 'component', 254);
INSERT INTO wtf.synonym VALUES (45, 1, 'kipu_virtsatessa', 'component', 260);
INSERT INTO wtf.synonym VALUES (46, 1, 'verivirtsaisuus', 'component', 266);
INSERT INTO wtf.synonym VALUES (47, 1, 'heikko_suihku_tai_tyhjeneminen', 'component', 272);
INSERT INTO wtf.synonym VALUES (48, 1, 'tihea_virtsaamistarve_paivalla', 'component', 278);
INSERT INTO wtf.synonym VALUES (49, 1, 'virtsa_ongelma_4vko', 'component', 284);
INSERT INTO wtf.synonym VALUES (50, 1, 'ongelma', 'component', 290);
INSERT INTO wtf.synonym VALUES (51, 1, 'akill_ulostamistarve', 'component', 291);
INSERT INTO wtf.synonym VALUES (52, 1, 'tihea_ulostustarve', 'component', 297);
INSERT INTO wtf.synonym VALUES (53, 1, 'veriuloste', 'component', 309);
INSERT INTO wtf.synonym VALUES (54, 1, 'lantio_kipu', 'component', 315);
INSERT INTO wtf.synonym VALUES (55, 1, 'suoli_ongelma_4vko', 'component', 321);
INSERT INTO wtf.synonym VALUES (56, 1, 'arvio_4vko', 'component', 327);
INSERT INTO wtf.synonym VALUES (57, 1, 'erektiokyky', 'component', 328);
INSERT INTO wtf.synonym VALUES (58, 1, 'orgasmikyky', 'component', 334);
INSERT INTO wtf.synonym VALUES (59, 1, 'erektio_laatu_4vko', 'component', 340);
INSERT INTO wtf.synonym VALUES (60, 1, 'erektio_tiheys_4vko', 'component', 345);
INSERT INTO wtf.synonym VALUES (61, 1, 'seks_kyky_4vko', 'component', 351);
INSERT INTO wtf.synonym VALUES (62, 1, 'seks_toiminta_ongelma_4vko', 'component', 357);
INSERT INTO wtf.synonym VALUES (63, 1, 'ongelma_4vko', 'component', 363);
INSERT INTO wtf.synonym VALUES (64, 1, 'rinnat', 'component', 370);
INSERT INTO wtf.synonym VALUES (65, 1, 'seks_kiinnostus_4vko', 'component', 394);
INSERT INTO wtf.synonym VALUES (66, 1, 'erektio_apuvalineet', 'component', 399);
INSERT INTO wtf.synonym VALUES (67, 1, 'apuvaline', 'component', 402);
INSERT INTO wtf.synonym VALUES (68, 1, 'tabletti', 'component', 403);
INSERT INTO wtf.synonym VALUES (69, 1, 'puikko', 'component', 409);
INSERT INTO wtf.synonym VALUES (70, 1, 'pistoshoito', 'component', 415);
INSERT INTO wtf.synonym VALUES (71, 1, 'tyhjiopumppu', 'component', 421);
INSERT INTO wtf.synonym VALUES (72, 1, 'muu', 'component', 427);
INSERT INTO wtf.synonym VALUES (97, 1, 'levinn_tutk', 'component', 553);
INSERT INTO wtf.synonym VALUES (98, 1, 'preop_mri', 'component', 565);
INSERT INTO wtf.synonym VALUES (99, 1, 'preop_mri_tyksissa', 'component', 568);
INSERT INTO wtf.synonym VALUES (100, 1, 'preop_pi-rads', 'component', 571);
INSERT INTO wtf.synonym VALUES (101, 1, 'pt_luokka', 'component', 578);
INSERT INTO wtf.synonym VALUES (102, 1, 'leikk_alkuhetki', 'component', 596);
INSERT INTO wtf.synonym VALUES (103, 1, 'leikk_loppuhetki', 'component', 597);


--
-- Data for Name: user_group_analytics_activity_status; Type: TABLE DATA; Schema: wtf; Owner: -
--

INSERT INTO wtf.user_group_analytics_activity_status VALUES (3, true);
INSERT INTO wtf.user_group_analytics_activity_status VALUES (5, true);


--
-- Name: feature__seq; Type: SEQUENCE SET; Schema: base; Owner: -
--

SELECT pg_catalog.setval('base.feature__seq', 4, true);


--
-- Name: member_seq; Type: SEQUENCE SET; Schema: base; Owner: -
--

SELECT pg_catalog.setval('base.member_seq', 177, true);


--
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: base; Owner: -
--

SELECT pg_catalog.setval('base.person_id_seq', 1, false);


--
-- Name: cdc_time_cdc_time_id_seq; Type: SEQUENCE SET; Schema: mining; Owner: -
--

SELECT pg_catalog.setval('mining.cdc_time_cdc_time_id_seq', 1, true);


--
-- Name: cdc_time_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.cdc_time_id_seq', 1, false);


--
-- Name: chemotherapy_course_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.chemotherapy_course_id_seq', 1, false);


--
-- Name: chemotherapy_cycle_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.chemotherapy_cycle_id_seq', 1, false);


--
-- Name: chemotherapy_dose_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.chemotherapy_dose_id_seq', 1, false);


--
-- Name: clinical_finding_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.clinical_finding_id_seq', 1, false);


--
-- Name: diagnosis_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.diagnosis_id_seq', 1, false);


--
-- Name: episode_of_care_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.episode_of_care_id_seq', 1, false);


--
-- Name: lab_package_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.lab_package_id_seq', 1, false);


--
-- Name: lab_test_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.lab_test_id_seq', 1, false);


--
-- Name: medication_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.medication_id_seq', 1, false);


--
-- Name: medication_set_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.medication_set_id_seq', 1, false);


--
-- Name: pathology_answer_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.pathology_answer_id_seq', 1, false);


--
-- Name: pathology_diagnosis_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.pathology_diagnosis_id_seq', 1, false);


--
-- Name: pathology_examination_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.pathology_examination_id_seq', 1, false);


--
-- Name: pathology_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.pathology_id_seq', 1, false);


--
-- Name: pathology_table_data_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.pathology_table_data_id_seq', 1, false);


--
-- Name: radiology_procedure_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.radiology_procedure_id_seq', 1, false);


--
-- Name: radiology_procedure_set_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.radiology_procedure_set_id_seq', 1, false);


--
-- Name: radiotherapy_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.radiotherapy_id_seq', 1, false);


--
-- Name: referral_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.referral_id_seq', 1, false);


--
-- Name: surgery_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.surgery_id_seq', 1, false);


--
-- Name: surgery_procedure_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.surgery_procedure_id_seq', 1, false);


--
-- Name: timeline_element_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.timeline_element_id_seq', 1, false);


--
-- Name: visit_id_seq; Type: SEQUENCE SET; Schema: patient_data; Owner: -
--

SELECT pg_catalog.setval('patient_data.visit_id_seq', 1, false);


--
-- Name: answer_seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.answer_seq', 238907, true);


--
-- Name: answer_set__seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.answer_set__seq', 35613, true);


--
-- Name: choice_seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.choice_seq', 260, true);


--
-- Name: component_seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.component_seq', 993, true);


--
-- Name: context__seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.context__seq', 5, true);


--
-- Name: data_type_seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.data_type_seq', 8, true);


--
-- Name: field_seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.field_seq', 181, true);


--
-- Name: field_type_seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.field_type_seq', 4, true);


--
-- Name: filter_seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.filter_seq', 2, true);


--
-- Name: form_field__seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.form_field__seq', 256, true);


--
-- Name: form_seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.form_seq', 36, true);


--
-- Name: gui_element_type__seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.gui_element_type__seq', 12, true);


--
-- Name: session_end_type_seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.session_end_type_seq', 1, false);


--
-- Name: session_seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.session_seq', 16936, true);


--
-- Name: synonym__seq; Type: SEQUENCE SET; Schema: wtf; Owner: -
--

SELECT pg_catalog.setval('wtf.synonym__seq', 153, true);


--
-- PostgreSQL database dump complete
--

