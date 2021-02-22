Deliver Oracle Database 18c Express Edition in Containers
Read here https://blogs.oracle.com/oraclemagazine/deliver-oracle-database-18c-express-edition-in-containers

-- clone repo
git clone https://github.com/oracle/docker-images.git

-- download installation binary
Download one zip file for xe edition from here: https://www.oracle.com/technical-resources/
Copy zip file to docker-images/OracleDatabase/SingleInstance/dockerfiles/18.4.0 folder

-- build image
./buildDockerImage.sh -v 18.4.0 -x

-- create a container
docker run --name dbmeta \
    -d \
    -p 51521:1521 \
    -p 55500:5500 \
    -e ORACLE_PWD=secure \
    -e ORACLE_CHARACTERSET=AL32UTF8 \
    oracle/database:18.4.0-xe


-- connect as sysdba
sqlplus sys/secure@dbmeta as sysdba

-- create user guest
CREATE USER guest identified by guest;

ALTER USER guest quota unlimited on users;

-- grant privs
GRANT create session TO guest;
GRANT create table TO guest;
GRANT create view TO guest;
GRANT create any trigger TO guest;
GRANT create any procedure TO guest;
GRANT create sequence TO guest;
GRANT create synonym TO guest;


Status : Failure -Test failed: no ocijdbc19 in java.library.path: [/Users/steinth6/Library/Java/Extensions, /Library/Java/Extensions, /Network/Library/Java/Extensions, /System/Library/Java/Extensions, /usr/lib/java, .]
