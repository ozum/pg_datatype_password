pg_datatype_password
====================

Abstract
--------

PostgreSQL data type for storing blowfish encrypted and salted passwords which can be queried against clear text.

Synopsis
--------

On CLI:

    $ make install
    
On SQL: 
 
```SQL
CREATE EXTENSION pgcrypto;
CREATE EXTENSION pg_datatype_password;
    
    
CREATE TABLE app_user (
    id SERIAL,
    password password,
    CONSTRAINT pkey PRIMARY KEY(id)
);
 
CREATE TRIGGER encrypt_password BEFORE INSERT OR UPDATE OF password 
    ON app_user FOR EACH ROW 
    EXECUTE PROCEDURE t_encrypt_password();

-- Password is inserted as encrypted because of trigger.
INSERT INTO app_user (password) VALUES ('MySecret');
INSERT INTO app_user (password) VALUES ('MySecret');
```

```SQL
SELECT * FROM app_user;
```

id    | password
------|---------------
1     | $2a$08$uTmBdGeSABWFM.scyi3DB.d0G.9Lmof6j06dc.PTdkiS4AeyoCjGu
2     | $2a$08$oTyyV8VlUMXWmWPsUbuzNOHZImN3FB79dNZkgjxaDH8/gWCU8/Jli


```SQL
-- Test with clear password such as coming from web application.
-- See two passwords encrypted differently even they were same as clear text, because every password is created with different salt.
SELECT * FROM app_user WHERE id = 1 AND password = 'MySecret';  

```

id    | password
------|---------------
1     | $2a$08$uTmBdGeSABWFM.scyi3DB.d0G.9Lmof6j06dc.PTdkiS4AeyoCjGu
2     | $2a$08$oTyyV8VlUMXWmWPsUbuzNOHZImN3FB79dNZkgjxaDH8/gWCU8/Jli

```SQL
-- Cannot be tested with encrypted password.
SELECT * FROM app_user WHERE id = 1 AND password = '$2a$08$uTmBdGeSABWFM.scyi3DB.d0G.9Lmof6j06dc.PTdkiS4AeyoCjGu';  
```

id    | password
------|---------------
      | 

Description
-----------

This is a PostgreSQL extension which adds custom base data type called `password` and related operators. This module requires `pgcrypto` module.
 
User can transparently query encrypted passwords against clear password coming from web application etc. Every password is encryped using different
 salt, therefore even same passwords are represented with different encryped text. See [https://www.postgresql.org/docs/current/static/pgcrypto.html](pgcrypto documentation)


Support
-------

[https://github.com/ozum/pg_datatype_password/issues](GitHub Issues)

Author
------

[https://github.com/ozum](Özüm Eldoğan)

Copyright and License
---------------------

Copyright (c) 2016 Özüm Eldoğan.

