# Database migration

In this task you will migrate the Drupal database to the new RDS database instance.

![Schema](./img/CLD_AWS_INFA.PNG)

## Task 01 - Securing current Drupal data

### [Get Bitnami MariaDb user's password](https://docs.bitnami.com/aws/faq/get-started/find-credentials/)

```bash
[INPUT]
cat /home/bitnami/bitnami_credentials

[OUTPUT]
Welcome to the Bitnami package for Drupal

******************************************************************************
The default username and password is 'user' and 'f474ZnV@dQuP'.
******************************************************************************

You can also use this password to access the databases and any other component the stack includes.

Please refer to https://docs.bitnami.com/ for more details.
```

### Get Database Name of Drupal

```bash
[INPUT]
// Malgré l'info du fichier credentials, le username n'est pas user mais root (testé)
mariadb -u root -p

show databases;

[OUTPUT]
+--------------------+
| Database           |
+--------------------+
| bitnami_drupal     |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
6 rows in set (0.003 sec)
```

### [Dump Drupal DataBases](https://mariadb.com/kb/en/mariadb-dump/)

```bash
[INPUT]
mariadb-dump -u root -p bitnami_drupal > /root/drupal_dump.sql

[OUTPUT]
root@ip-10-0-3-10:~# ls -l
total 5796
-rw-r--r-- 1 root root 5932861 Mar 21 13:39 drupal_dump.sql
```

### Create the new Data base on RDS

```sql
[INPUT]
CREATE DATABASE bitnami_drupal;

[OUTPUT]
Query OK, 1 row affected (0.000 sec)
```

### [Import dump in RDS db-instance](https://mariadb.com/kb/en/restoring-data-from-dump-files/)

Note : you can do this from the Drupal Instance. Do not forget to set the "-h" parameter.

```sql
[INPUT]
mariadb -h dbi-devopsteam03.cshki92s4w5p.eu-west-3.rds.amazonaws.com -u admin -p bitnami_drupal < /root/drupal_dump.sql

[OUTPUT]
// No output
Enter password: 
root@ip-10-0-3-10:~#
```

### [Get the current Drupal connection string parameters](https://www.drupal.org/docs/8/api/database-api/database-configuration)

```bash
[INPUT]
//help : same settings.php as before
cat /bitnami/drupal/sites/default/settings.php

[OUTPUT]
$databases['default']['default'] = array (
  'database' => 'bitnami_drupal',
  'username' => 'bn_drupal',
  'password' => '53eff0c6c299e47031365d73845eb0269aaf4b12ceb8a9ad15ed79351c51a847',
  'prefix' => '',
  'host' => '127.0.0.1',
  'port' => '3306',
  'isolation_level' => 'READ COMMITTED',
  'driver' => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
);
```

### Replace the current host with the RDS FQDN

```
//settings.php

$databases['default']['default'] = array (
  'database' => 'bitnami_drupal',
  'username' => 'bn_drupal',
  'password' => '53eff0c6c299e47031365d73845eb0269aaf4b12ceb8a9ad15ed79351c51a847',
  'prefix' => '',
  'host' => 'dbi-devopsteam03.cshki92s4w5p.eu-west-3.rds.amazonaws.com',
  'port' => '3306',
  'isolation_level' => 'READ COMMITTED',
  'driver' => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
);
```

### [Create the Drupal Users on RDS Data base](https://mariadb.com/kb/en/create-user/)

Note : only calls from both private subnets must be approved.
* [By Password](https://mariadb.com/kb/en/create-user/#identified-by-password)
* [Account Name](https://mariadb.com/kb/en/create-user/#account-names)
* [Network Mask](https://cric.grenoble.cnrs.fr/Administrateurs/Outils/CalculMasque/)

```sql
[INPUT]
CREATE USER bn_drupal@'10.0.3.0/255.255.255.240' IDENTIFIED BY '53eff0c6c299e47031365d73845eb0269aaf4b12ceb8a9ad15ed79351c51a847';

GRANT ALL PRIVILEGES ON bitnami_drupal.* TO 'bn_drupal'@'10.0.3.0/255.255.255.240';

//DO NOT FORGET TO FLUSH PRIVILEGES
```

```sql
//validation
[INPUT]
SHOW GRANTS for 'bn_drupal'@'10.0.3.0/255.255.255.240';

[OUTPUT]
+---------------------------------------------------------------------------------------------------------------------------------+
| Grants for bn_drupal@10.0.3.0/255.255.255.240                                                                                   |
+---------------------------------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `bn_drupal`@`10.0.3.0/255.255.255.240` IDENTIFIED BY PASSWORD '*5D39723506302B511B48F34C1BDEB7F32A9BC237' |
| GRANT ALL PRIVILEGES ON `bitnami_drupal`.* TO `bn_drupal`@`10.0.3.0/255.255.255.240`                                            |
+---------------------------------------------------------------------------------------------------------------------------------+
2 rows in set (0.000 sec)
+---------------------------------------------------------------------------------------------------------------------------
```

### Validate access (on the drupal instance)

```sql
[INPUT]
mysql -h dbi-devopsteam03.cshki92s4w5p.eu-west-3.rds.amazonaws.com -u bn_drupal -p

[INPUT]
show databases;

[OUTPUT]
+--------------------+
| Database           |
+--------------------+
| bitnami_drupal     |
| information_schema |
+--------------------+
2 rows in set (0.001 sec)
```

* Repeat the procedure to enable the instance on subnet 2 to also talk to your RDS instance.