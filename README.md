pg_datatype_password
====================

## Abstract

PostgreSQL data type for storing blowfish encrypted and salted passwords which can be queried against clear text.

## Description

This is a PostgreSQL extension which adds custom base data type called `password` and related operators. This module requires `pgcrypto` module.
 
User can transparently query encrypted passwords against clear password coming from web application etc. Every password is encryped using different
 salt, therefore even same passwords are represented with different encryped text. See [https://www.postgresql.org/docs/current/static/pgcrypto.html](pgcrypto documentation)

## Synopsis

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

## Contribution Needed !!!

It would be much better and elegant solution, if input function of `password` base type would directly encrypt given input and return encrypted result.
Then there would be no need the extra trigger. Module becomes much more transparent than it's current state.

Because of PostgreSQL's ctype input limitation for procedural languages, this function have to be written in C.
Please see [https://www.postgresql.org/docs/current/static/sql-createtype.html](PostgreSQL documentation)

PR for the input function is very welcome.

## What is included?

* `password` data type
* `=` and `<>` comparison operators to compare clear text with encrypted password.
* `t_encrypt_password` trigger

## Install

To build it, just do this:

    make
    make installcheck
    make install

If you encounter an error such as:

    "Makefile", line 8: Need an operator

You need to use GNU make, which may well be installed on your system as
`gmake`:

    gmake
    gmake install
    gmake installcheck

If you encounter an error such as:

    make: pg_config: Command not found

Be sure that you have `pg_config` installed and in your path. If you used a
package management system such as RPM to install PostgreSQL, be sure that the
`-devel` package is also installed. If necessary tell the build process where
to find it:

    env PG_CONFIG=/path/to/pg_config make && make installcheck && make install

And finally, if all that fails (and if you're on PostgreSQL 8.1 or lower, it
likely will), copy the entire distribution directory to the `contrib/`
subdirectory of the PostgreSQL source tree and try it there without
`pg_config`:

    env NO_PGXS=1 make && make installcheck && make install

If you encounter an error such as:

    ERROR:  must be owner of database regression

You need to run the test suite using a super user, such as the default
"postgres" super user:

    make installcheck PGUSER=postgres

Once pg_datatype_password is installed, you can add it to a database. If you're running
PostgreSQL 9.1.0 or greater, it's a simple as connecting to a database as a
super user and running:

    CREATE EXTENSION pg_datatype_password;

If you've upgraded your cluster to PostgreSQL 9.1 and already had pg_datatype_password
installed, you can upgrade it to a properly packaged extension with:

    CREATE EXTENSION pg_datatype_password FROM unpackaged;

For versions of PostgreSQL less than 9.1.0, you'll need to run the
installation script:

    psql -d mydb -f /path/to/pgsql/share/contrib/pg_datatype_password.sql

If you want to install pg_datatype_password and all of its supporting objects into a specific
schema, use the `PGOPTIONS` environment variable to specify the schema, like
so:

    PGOPTIONS=--search_path=extensions psql -d mydb -f pg_datatype_password.sql

Dependencies
------------
The `pg_datatype_password` requires `pgcrypto` module.

Copyright and License
---------------------

See LICENSE file. Copyright (c) 2016 Özüm Eldoğan.

