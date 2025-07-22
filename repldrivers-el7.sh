#! /bin/bash
#
# be sure to update Replicate environment
#
# PATH="/opt/mssql-tools/bin:$PATH"
# LD_LIBRARY_PATH="/usr/lib/oracle/12.2/client64/lib:/opt/microsoft/msodbcsql17/lib64/:/usr/pgsql-12/lib:$LD_LIBRARY_PATH"


mysqlodbc=https://downloads.mysql.com/archives/get/p/10/file/mysql-connector-odbc-8.0.25-1.el7.x86_64.rpm
postgresyum=https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpmwg
databricks=https://databricks-bi-artifacts.s3.us-east-2.amazonaws.com/simbaspark-drivers/odbc/2.6.22/SimbaSparkODBC-2.6.22.1037-LinuxRPM-64bit.zip
snowflake_version=2.25.4
snowflake=https://sfc-repo.snowflakecomputing.com/odbc/linux/${snowflake_version}/snowflake-odbc-${snowflake_version}.x86_64.rpm

#disablerepo=--disablerepo="epel"

yum install wget unzip

yum -y update  ca-certificates
    yum -y install epel-release
    yum $disablerepo -y update
    yum $disablerepo -y install unixODBC
    mv /etc/odbcinst.ini /etc/odbcinst.ini.org
    touch /etc/odbcinst.ini

    # mysql
    echo "**** INSTALLING MYSQL DRIVERS ***"
    yum $disablerepo -y install mysql
    yum $disablerepo -y install $mysqlodbc

    # postgres
    echo "**** INSTALLING POSTGRES DRIVERS ***"
    yum $disablerepo -y install $postgresyum;  \
    yum $disablerepo -y install postgresql12
    yum $disablerepo -y install postgresql12-odbc
    {
       echo "" 
       echo "[PostgreSQL]" 
       echo "Description=ODBC for PostgeSQL target" 
       echo "Driver=/usr/pgsql-12/lib/psqlodbcw.so" 
       echo "Driver64=/usr/pgsql-12/lib/psqlodbcw.so" 
       echo "" 
       echo "[PostgreSQL Unicode(x64)]" 
       echo "Description=ODBC for PostgeSQL source" 
       echo "Driver=/usr/pgsql-12/lib/psqlodbcw.so" 
       echo "Driver64=/usr/pgsql-12/lib/psqlodbcw.so" 
       echo "" 
    } >> /etc/odbcinst.ini

    # SQL Server
    echo "**** INSTALLING SQL SERVER DRIVERS ***"
    curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo
    ACCEPT_EULA=Y yum $disablerepo -y install msodbcsql17
    # for bcp and sqlcmd 
    ACCEPT_EULA=Y yum $disablerepo -y install mssql-tools
    #ls  -la /opt/microsoft/msodbcsql/lib64/libmsodbc*
    #ln -s $(ls /opt/microsoft/msodbcsql/lib64/libmsodbcsql-13.1.so.*) /opt/microsoft/msodbcsql/lib64/libmsodbcsql-13.1.so.0.0

    # Snowflake
    echo "**** INSTALLING SNOWFLAKE DRIVERS ***"
    yum $disablerepo -y install $snowflake

    # Databricks
    echo "**** INSTALLING DATABRICKS DRIVERS ***"
    mkdir /tmp/databricks
    cd /tmp/databricks
    wget $databricks
    unzip Simba*.zip
    yum -y install simba*.rpm
    cd -
    rm -rf /tmp/databricks
    {
       echo "" 
       echo "[Simba Spark ODBC Driver]" 
       echo "Description=Simba Spark ODBC Driver (64-bit)" 
       echo "Driver=/opt/simba/spark/lib/64/libsparkodbc_sb64.so" 
       echo "" 
    } >> /etc/odbcinst.ini

    # clean up
    yum $disablerepo -y update
    yum clean all
    rm -rf /var/cache/yum

