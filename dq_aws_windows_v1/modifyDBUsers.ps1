$DBADDR=$args[0]
$DBSN=$args[1]
$DBUN=$args[2]
$DBPW=$args[3]

$DBFILE="C:\InfaEc2Scripts\createDBUsers.bat"

(gc $DBFILE | %{$_ -replace '<DBADDR>',"$DBADDR"  `
`
-replace '<DBSN>',"$DBSN"  `
`
-replace '<DBUN>',"$DBUN"  `
`
-replace '<DBPW>',"$DBPW"  `

}) | sc $DBFILE
