/*
 * Author: Özüm Eldoğan
 * Created at: 2016-12-20 15:35:03 +0300
 *
 */

SET client_min_messages = warning;

CREATE TYPE password;

CREATE OR REPLACE FUNCTION passwordin(pg_catalog.cstring) RETURNS password AS 'textin' LANGUAGE 'internal' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 1;
CREATE OR REPLACE FUNCTION passwordout(password) RETURNS pg_catalog.cstring AS 'textout' LANGUAGE 'internal' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 1;
CREATE OR REPLACE FUNCTION passwordrecv(pg_catalog.internal) RETURNS password AS 'textrecv' LANGUAGE 'internal' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 1;
CREATE OR REPLACE FUNCTION passwordsend(password) RETURNS bytea AS 'textsend' LANGUAGE 'internal' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 1;

CREATE TYPE password (
    LIKE       = text,
    INPUT      = passwordin,
    OUTPUT     = passwordout,
    RECEIVE    = passwordrecv,
    SEND       = passwordsend
);

-- crypt('entered password', pswhash)

/*************************************************************************
						  COMPARISON FUNCTIONS
**************************************************************************/
CREATE OR REPLACE FUNCTION password_eq (
    public.password,
    text
)
RETURNS boolean AS
$body$
BEGIN
	RETURN $1::text = crypt($2, $1::text);
END;
$body$
LANGUAGE 'plpgsql' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 2000;


CREATE OR REPLACE FUNCTION password_eq (
    text,
    public.password
)
RETURNS boolean AS
$body$
BEGIN
	RETURN $2::text = crypt($1, $2::text);
END;
$body$
LANGUAGE 'plpgsql' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 2000;


CREATE OR REPLACE FUNCTION password_ne (
    public.password,
    text
)
RETURNS boolean AS
$body$
BEGIN
	RETURN $1::text <> crypt($2, $1::text);
END;
$body$
LANGUAGE 'plpgsql' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 2000;


CREATE OR REPLACE FUNCTION password_ne (
    text,
    public.password
)
RETURNS boolean AS
$body$
BEGIN
	RETURN $2::text <> crypt($1, $2::text);
END;
$body$
LANGUAGE 'plpgsql' IMMUTABLE RETURNS NULL ON NULL INPUT SECURITY INVOKER COST 2000;

CREATE OPERATOR public.= (LEFTARG = public.password, RIGHTARG = text, COMMUTATOR = OPERATOR(public.=), NEGATOR = OPERATOR(public.<>), PROCEDURE = password_eq);
CREATE OPERATOR public.<> (LEFTARG = public.password, RIGHTARG = text, COMMUTATOR = OPERATOR(public.<>), NEGATOR = OPERATOR(public.=) ,PROCEDURE = password_ne);
CREATE OPERATOR public.= (LEFTARG = text, RIGHTARG = public.password, COMMUTATOR = OPERATOR(public.=), NEGATOR = OPERATOR(public.<>), PROCEDURE = password_eq);
CREATE OPERATOR public.<> (LEFTARG = text, RIGHTARG = public.password, COMMUTATOR = OPERATOR(public.<>), NEGATOR = OPERATOR(public.=) ,PROCEDURE = password_ne);

/*************************************************************************
						  TRIGGER FUNCTIONS
**************************************************************************/
CREATE OR REPLACE FUNCTION public.t_encrypt_password ()
RETURNS trigger AS
$body$
DECLARE
    v_iter_count    INTEGER := COALESCE(NULLIF(TG_ARGV[0], ''), '8');             -- Lets the user specify the iteration count. The higher the count, the more time it takes to hash the password.
BEGIN
    NEW.password = crypt(NEW.password::TEXT, gen_salt('bf', v_iter_count));
    RETURN NEW;
END
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 2000;