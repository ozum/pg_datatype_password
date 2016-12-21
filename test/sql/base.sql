\set ECHO 0
BEGIN;
\i sql/pg_datatype_password.sql
\set ECHO all

-- You should write your tests

SELECT pg_datatype_password('foo', 'bar');

SELECT 'foo' #? 'bar' AS arrowop;

CREATE TABLE ab (
    a_field pg_datatype_password
);

INSERT INTO ab VALUES('foo' #? 'bar');
SELECT (a_field).a, (a_field).b FROM ab;

SELECT (pg_datatype_password('foo', 'bar')).a;
SELECT (pg_datatype_password('foo', 'bar')).b;

SELECT ('foo' #? 'bar').a;
SELECT ('foo' #? 'bar').b;

ROLLBACK;
