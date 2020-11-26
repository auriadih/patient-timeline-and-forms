

-- insert user

SELECT base.insert_user('ATP','Auria', 'Tietopalvelu','foo@zzxxyy.com','foo');



-- join user to groups


SELECT base.join_user_to_group('foo@zzxxyy.com','Urologi');
SELECT base.join_user_to_group('foo@zzxxyy.com','Urologinen potilas');
SELECT base.join_user_to_group('foo@zzxxyy.com','Keuhkopotilas');
SELECT base.join_user_to_group('foo@zzxxyy.com','Keuhkolääkäri');
SELECT base.join_user_to_group('foo@zzxxyy.com','Infektiolääkäri');
SELECT base.join_user_to_group('foo@zzxxyy.com','Testaaja');



