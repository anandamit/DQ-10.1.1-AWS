PATH=C:\Informatica\10.1.1\java\jre\bin;%PATH%
cd C:\InfaEc2Scripts
java -cp C:\InfaEc2Scripts\OracleUtility.jar;C:\InfaEc2Scripts\com.informatica.datadirect-dworacle-5.1.4_C1.jar dbutil/OracleUtility jdbc:informatica:oracle://<DBADDR>;Servicename=<DBSN> <DBUN> <DBPW> dqmrsdb/dqmrsdb dqcmsdb/dqcmsdb