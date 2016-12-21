/*
 * Author: Özüm Eldoğan
 * Created at: 2016-12-20 15:35:03 +0300
 *
 */


SET client_min_messages = warning;

BEGIN;

DROP FUNCTION public.t_encrypt_password();

DROP TYPE public.password CASCADE;

COMMIT;
