/*
 * Author: Özüm Eldoğan
 * Created at: 2016-12-20 15:35:03 +0300
 *
 */


SET client_min_messages = warning;


-- Sometimes it is common to use special operators to
-- work with your new created type, you can create
-- one like the command bellow if it is applicable
-- to your case


CREATE TYPE password;



CREATE OR REPLACE FUNCTION passwordin(pg_catalog.cstring, oid, integer) RETURNS password AS 'varcharin' LANGUAGE 'internal' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 1;
CREATE OR REPLACE FUNCTION passwordout(password) RETURNS pg_catalog.cstring AS 'varcharout' LANGUAGE 'internal' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 1;
CREATE OR REPLACE FUNCTION passwordrecv(pg_catalog.internal, oid, integer) RETURNS password AS 'varcharin' LANGUAGE 'internal' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 1;
CREATE OR REPLACE FUNCTION passwordsend(password) RETURNS bytea AS 'varcharout' LANGUAGE 'internal' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 1;





CREATE TYPE password (
    LIKE       = varchar,
    INPUT      = passwordin,
    OUTPUT     = passwordout,
    RECEIVE    = passwordrecv,
    SEND       = passwordsend
);


CREATE OR REPLACE FUNCTION deneme(pg_catalog.cstring) RETURNS password AS 'textin' LANGUAGE 'internal' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 1;
CREATE OR REPLACE FUNCTION passwordin2 (
    varchar
)
RETURNS password AS
$body$
BEGIN
    RETURN deneme(crypt($1, gen_salt('bf', 8))::pg_catalog.cstring);
END;
$body$
LANGUAGE 'plpgsql' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 500;


-- crypt('entered password', pswhash)

/*************************************************************************
						  COMPARISON FUNCTIONS
**************************************************************************/
CREATE OR REPLACE FUNCTION password_eq (
    public.password,
    varchar
)
RETURNS boolean AS
$body$
BEGIN
	RETURN $1::varchar = crypt($2, $1::varchar);
END;
$body$
LANGUAGE 'plpgsql' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 500;


CREATE OR REPLACE FUNCTION password_eq (
    varchar,
    public.password
)
RETURNS boolean AS
$body$
BEGIN
	RETURN $2::varchar = crypt($1, $2::varchar);
END;
$body$
LANGUAGE 'plpgsql' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 500;


CREATE OR REPLACE FUNCTION password_ne (
    public.password,
    varchar
)
RETURNS boolean AS
$body$
BEGIN
	RETURN $1::varchar <> crypt($2, $1::varchar);
END;
$body$
LANGUAGE 'plpgsql' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 500;


CREATE OR REPLACE FUNCTION password_ne (
    varchar,
    public.password
)
RETURNS boolean AS
$body$
BEGIN
	RETURN $2::varchar <> crypt($1, $2::varchar);
END;
$body$
LANGUAGE 'plpgsql' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 500;

CREATE OPERATOR public.= (LEFTARG = public.password, RIGHTARG = varchar, COMMUTATOR = OPERATOR(public.=), NEGATOR = OPERATOR(public.<>), PROCEDURE = password_eq);
CREATE OPERATOR public.<> (LEFTARG = public.password, RIGHTARG = varchar, COMMUTATOR = OPERATOR(public.<>), NEGATOR = OPERATOR(public.=) ,PROCEDURE = password_ne);
CREATE OPERATOR public.= (LEFTARG = varchar, RIGHTARG = public.password, COMMUTATOR = OPERATOR(public.=), NEGATOR = OPERATOR(public.<>), PROCEDURE = password_eq);
CREATE OPERATOR public.<> (LEFTARG = varchar, RIGHTARG = public.password, COMMUTATOR = OPERATOR(public.<>), NEGATOR = OPERATOR(public.=) ,PROCEDURE = password_ne);

/*************************************************************************
						  TRIGGER FUNCTIONS
**************************************************************************/
CREATE OR REPLACE FUNCTION public.t_encrypt_password ()
RETURNS trigger AS
$body$
DECLARE
    v_column        TEXT    := COALESCE(NULLIF(TG_ARGV[0], ''), 'password');    -- Column name which stores password.
    v_iter_count    INTEGER := COALESCE(NULLIF(TG_ARGV[1], ''), 6);             -- Lets the user specify the iteration count. The higher the count, the more time it takes to hash the password.
    v_clear         TEXT;
BEGIN

     --EXECUTE FROMAT('SELECT $1.%I', v_column) INTO v_clear USING


     --char_length()





     NEW.password := crypt(NEW.password, gen_salt('bf'));
     RETURN NEW;
END
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 500;


/*************************************************************************
						  CONVERSION FUNCTIONS
**************************************************************************/


CREATE OR REPLACE FUNCTION "password"(
    varchar
)
RETURNS password AS
$body$
BEGIN
    RETURN crypt($1, gen_salt('bf', 8));
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 2;

CREATE OR REPLACE FUNCTION "password"(
    text
)
RETURNS password AS
$body$
BEGIN
    RETURN crypt($1, gen_salt('bf', 8));
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 2;

CREATE CAST (text AS password) WITH FUNCTION "password"(text) AS IMPLICIT;
--CREATE CAST (varchar AS password) WITH FUNCTION "password"(varchar) AS IMPLICIT;
CREATE CAST (password AS varchar) WITHOUT FUNCTION AS IMPLICIT;