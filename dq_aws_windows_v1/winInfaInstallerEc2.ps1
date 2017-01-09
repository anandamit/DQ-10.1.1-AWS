$env:USERNAME="Administrator"
$env:USERDOMAIN=$env:COMPUTERNAME
$env:JOIN_HOST_NAME="$env:COMPUTERNAME"
$env:DOMAIN_USER="$env:DOMAIN_USER_NAME"
$env:CLOUD_SUPPORT_ENABLE=1 

$domainpass=$args[0]
$dbpass = $args[1]
$repopass = $args[2]
$passKeyPhrase = $args[3]

C:\InfaEc2Scripts\generateTnsOra.ps1 $env:DB_SERVICENAME $env:DB_ADDRESS $env:DB_PORT 2>  C:\InfaServiceLog.log

$env:DB_ADDRESS=$env:DB_ADDRESS+":"+$env:DB_PORT

$env:METADATA_ACCESS_STRING="'jdbc:informatica:oracle://"+$env:DB_ADDRESS+";Servicename="+$env:DB_SERVICENAME+"'"

$env:MRS_DB_CUSTOM_STRING="jdbc:informatica:oracle://"+$env:DB_ADDRESS+";ServiceName="+$env:DB_SERVICENAME+";MaxPooledStatements=20;CatalogOptions=0;BatchPerformanceWorkaround=true"

$env:STAGE_CONN_NAME="STAGE"

$env:MRS_NAME="ModelRepositoryService"

$env:DIS_NAME="DataIntegrationService"

$env:CMS_NAME="ContentManagementService"

$env:DISHTTPPORT="8095"

$env:CMSHTTPPORT="8105"

C:\InfaEc2Scripts\modifyDBUsers.ps1 $env:DB_ADDRESS $env:DB_SERVICENAME $env:DB_UNAME $dbpass 2>  C:\InfaServiceLog.log

C:\InfaEc2Scripts\createDBUsers.bat 2> C:\InfaServiceLog.log

$USER_INSTALL_DIR="C:\Informatica\10.1.1"
$KEY_DEST_LOCATION="C:\Informatica\10.1.1\isp\config\keys"


$PROPERTYFILE="C:\infainstaller\SilentInput.properties"

(gc $PROPERTYFILE | %{$_ -replace '^CREATE_DOMAIN=.*$',"CREATE_DOMAIN=$env:CREATE_DOMAIN"  `
`
-replace '^JOIN_DOMAIN=.*$',"JOIN_DOMAIN=$env:JOIN_DOMAIN"  `
`
-replace '^CLOUD_SUPPORT_ENABLE=.*$',"CLOUD_SUPPORT_ENABLE=$env:CLOUD_SUPPORT_ENABLE"  `
`
-replace '^ENABLE_USAGE_COLLECTION=.*$',"ENABLE_USAGE_COLLECTION=1"  `
`
-replace '^USER_INSTALL_DIR=.*$',"USER_INSTALL_DIR=$USER_INSTALL_DIR"  `
`
-replace '^KEY_DEST_LOCATION=.*$',"KEY_DEST_LOCATION=$KEY_DEST_LOCATION"  `
`
-replace '^PASS_PHRASE_PASSWD=.*$',"PASS_PHRASE_PASSWD=$passKeyPhrase"  `
`
-replace '^SERVES_AS_GATEWAY=.*$',"SERVES_AS_GATEWAY=$env:SERVES_AS_GATEWAY" `
`
-replace '^DB_TYPE=.*$',"DB_TYPE=$env:DB_TYPE" `
`
-replace '^DB_UNAME=.*$',"DB_UNAME=$env:DB_UNAME" `
`
-replace '^DB_SERVICENAME=.*$',"DB_SERVICENAME=$env:DB_SERVICENAME" `
`
-replace '^DB_ADDRESS=.*$',"DB_ADDRESS=$env:DB_ADDRESS" `
`
-replace '^DOMAIN_NAME=.*$',"DOMAIN_NAME=$env:DOMAIN_NAME" `
`
-replace '^NODE_NAME=.*$',"NODE_NAME=$env:NODE_NAME" `
`
-replace '^DOMAIN_PORT=.*$',"DOMAIN_PORT=6005" `
`
-replace '^JOIN_NODE_NAME=.*$',"JOIN_NODE_NAME=$env:JOIN_NODE_NAME" `
`
-replace '^JOIN_HOST_NAME=.*$',"JOIN_HOST_NAME=$env:JOIN_HOST_NAME" `
`
-replace '^JOIN_DOMAIN_PORT=.*$',"JOIN_DOMAIN_PORT=6005" `
`
-replace '^DOMAIN_USER=.*$',"DOMAIN_USER=$env:DOMAIN_USER" `
`
-replace '^DOMAIN_HOST_NAME=.*$',"DOMAIN_HOST_NAME=$env:DOMAIN_HOST_NAME" `
`
-replace '^DOMAIN_PSSWD=.*$',"DOMAIN_PSSWD=$domainpass" `
`
-replace '^DOMAIN_CNFRM_PSSWD=.*$',"DOMAIN_CNFRM_PSSWD=$domainpass" `
`
-replace '^DB_PASSWD=.*$',"DB_PASSWD=$dbpass" `
`
-replace '^CREATE_SERVICES=.*$',"CREATE_SERVICES=0" `
`
-replace '^MRS_DB_TYPE=.*$',"MRS_DB_TYPE=Oracle" `
`
-replace '^MRS_DB_UNAME=.*$',"MRS_DB_UNAME=dqmrsdb" `
`
-replace '^MRS_DB_PASSWD=.*$',"MRS_DB_PASSWD=dqmrsdb" `
`
-replace '^MRS_DB_CUSTOM_STRING_SELECTION=.*$',"MRS_DB_CUSTOM_STRING_SELECTION=1" `
`
-replace '^MRS_DB_CUSTOM_STRING=.*$',"MRS_DB_CUSTOM_STRING=$env:MRS_DB_CUSTOM_STRING" `
`
-replace '^MRS_SERVICE_NAME=.*$',"MRS_SERVICE_NAME=$env:MRS_NAME" `
`
-replace '^DIS_SERVICE_NAME=.*$',"DIS_SERVICE_NAME=$env:DIS_NAME" `
`
-replace '^DIS_PROTOCOL_TYPE=.*$',"DIS_PROTOCOL_TYPE=http" `
`
-replace '^DIS_HTTP_PORT=.*$',"DIS_HTTP_PORT=8095" ` 

}) | sc $PROPERTYFILE
cd C:\infainstaller

C:\infainstaller\silentInstall.bat | Out-Null

function createDQServices() {

    ac  C:\InfaServiceLog.log "Create STAGE connection"
    ($out = C:\Informatica\10.1.1\isp\bin\infacmd createConnection -dn $env:DOMAIN_NAME -un $env:DOMAIN_USER -pd $domainpass -cn $env:STAGE_CONN_NAME -cid $env:STAGE_CONN_NAME -ct Oracle -cun dqcmsdb -cpd dqcmsdb -o CodePage='UTF-8' DataAccessConnectString=''$env:DB_SERVICENAME'' MetadataAccessConnectString='"'$env:METADATA_ACCESS_STRING''"" ) | Out-Null
    ac C:\InfaServiceLog.log $out

    ac  C:\InfaServiceLog.log "Create MRS"
    ($out = C:\Informatica\10.1.1\isp\bin\infacmd mrs createService -dn $env:DOMAIN_NAME -nn $env:NODE_NAME -un $env:DOMAIN_USER -pd $domainpass -sn $env:MRS_NAME -du dqmrsdb -dp dqmrsdb -dl $env:MRS_DB_CUSTOM_STRING -dt Oracle ) | Out-Null
    ac C:\InfaServiceLog.log $out

    ac  C:\InfaServiceLog.log "Create DIS"
    ($out = C:\Informatica\10.1.1\isp\bin\infacmd dis createService -dn $env:DOMAIN_NAME -nn $env:NODE_NAME -un $env:DOMAIN_USER -pd $domainpass -sn $env:DIS_NAME -rs $env:MRS_NAME -rsun $env:DOMAIN_USER -rspd $domainpass -HttpPort $env:DISHTTPPORT ) | Out-Null
    ac C:\InfaServiceLog.log $out

    ac  C:\InfaServiceLog.log "Create CMS"
    ($out = C:\Informatica\10.1.1\isp\bin\infacmd cms createService -dn $env:DOMAIN_NAME -nn $env:NODE_NAME -un $env:DOMAIN_USER -pd $domainpass -sn $env:CMS_NAME -ds $env:DIS_NAME -rs $env:MRS_NAME -rsu $env:USERNAME -rsp $domainpass -rdl STAGE -HttpPort $env:CMSHTTPPORT ) | Out-Null
	ac C:\InfaServiceLog.log $out

    if ($env:ADD_LICENSE_CONDITION -eq 1) {

        ac  C:\InfaServiceLog.log "Creating License"		
		($out = C:\Informatica\10.1.1\isp\bin\infacmd addlicense -dn $env:DOMAIN_NAME -un $env:DOMAIN_USER -pd $domainpass -ln License -lf C:\Informatica\10.1.1\License.key ) | Out-Null 
        ac C:\InfaServiceLog.log $out

        ac  C:\InfaServiceLog.log "Assigning License"
        ($out = C:\Informatica\10.1.1\isp\bin\infacmd assignLicense -dn $env:DOMAIN_NAME -un $env:DOMAIN_USER -pd $domainpass -ln License -sn $env:MRS_NAME $env:DIS_NAME $env:CMS_NAME ) | Out-Null 
        ac C:\InfaServiceLog.log $out
        
        ac  C:\InfaServiceLog.log "Removing License key file"
		rm  C:\Informatica\10.1.1\License.key
		ac C:\InfaServiceLog.log $out
	}
}

createDQServices
