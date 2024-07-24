#! /bin/sh
#*************************************************************************** 
#*
#* File Name:         OM_mailer.sh
#*
#* File Title:        Order Acknowledgment and Ship Confirm Mailer
#*
#* Author:            Pär Lilja, Alcesys AB
#*
#* Version:           1.0
#*
#* Function:          Read from XX_HI3G_MAIL table, generate mail and send
#*
#* Parameters:        None
#*
#*
#* Change History:
#*
#* Version  Date       Author           Change Reference/Description
#* ======== ========== ================ ====================================================================================================================== 
#*   1.0    16-Oct-03  P Lilja          Initial create
#*   2.0    01-dec-05  P Lilja	        Adding new logistics interfaces
#*   3.0    03-oct-11  Raja Venkadesh   Modified the script to send mail to multiple recipients - TR 38086
#*   4.0    21-sep-12  Vani             Change electra mail id from bp
#*   5.0    22-Nov-12  Vani             Changed apps password  
#*   6.0    19-JUL-13  Sindhuja         Changed 'from' email address 
#*	 7.0	05-FEB-15  Jerric		    modified the script to set the environment and passwords dynamically and to send mails based on environment.
#*   8.0    28-MAR-15  Jerric			Modified the logic for sending mails to new logistic partner based on organization.
#*   9.0    01-JUL-15  Anupam			PBI2990 - Changed script to search for 'DENMARK' and 'SWEDEN' and send mail to corresponding Logistic Partner.
#*   9.1    04-SEP-15  Anupam			PBI2990 - Removed code to pick email address from spool file, added code to pick email address from sql query
#*                                               Removed unused comment sections and 'echo' messages
#*   10.0   12-DEC-17  Sinduja          BR-18920 Additional SIM - ErrorScenario1.2 - ERP validate EID before publishing the order to PSFT
#*   11.0   25-OCT-22  Tommy Barrud     Modified the sendmail command to set correct sender -f [email address]. This it make sender email verified.
#*   12.0   10-May-23  Anitha			ERP-491 Retrofit Impacted objects for OM - Replacing with R12.2 directory path.
#*   13.0   26-Sep-23  Karim Mabrouk    ERP-937 ERP upgrade Defect NR-Cron-001
#*   14.0   26-Sep-23  Himanshu G       ERP-426 Change ISL order completion error mail
#*   15.0   26-Jun-24  Neha             ERP-1096 Remove hostname hardcoding and refer from seperate HOST file
#*************************************************************************************************************************************************************
#-----------------------------------------------------------------------------    
# function send_mail
#-----------------------------------------------------------------------------  
send_mail()
{

# Clean up any earlier mail files

  if (test -f $textfile1) 
      then
      rm $textfile1
  fi
  if (test -f $textfile2) 
      then
      rm $textfile2
  fi

# mail_generate.sql Fetches database information and spools out a textfile
sqlplus ${APPSDB_UNAME}/${APPSDB_PWD} @$XXCUST_TOP/OM_mailer/mail_generate $header $type

# Remove Oracle's success messages
sed s#"PL/SQL procedure successfully completed."#" "# $textfile1 > $textfile2

# Check generated files for ERROR messages indicating an Oracle error. If so, send it to erpmail

NUMLOGONS=`cat $textfile2 | grep ERROR | wc -l`

if [ $NUMLOGONS -gt 0 ]
then
   type=99
fi

# Collect all interface error mails into one mail
if [ $type -eq 12 ]
then
   type=11
fi
if [ $type -eq 13 ]
then
   type=11
fi

if [ $type -eq 30 ]
then
   eposmail=$mail
fi

# Send all mail to patrick.pring@tre.se
# Remove this line if Order Acknowledge mail should be sent !!
#mail=patrick.pring@tre.se

#Added Version 15.0
source $XXCUST_TOP/admin/XX_HOST_DETAILS.sh

echo "prod host: " $PROD_HOSTNAME
echo "file host: " $HOSTNAME

if [ $HOSTNAME = $PROD_HOSTNAME]

#if [ $HOSTNAME = "x12873pzz" ] commented Version 15.0

then
mail=erp@tre.se
echo "Mail sent in PROD"                #Added Version 3.0
else
mail='sindhuja.balasubramanian@tre.se,meenakshi.arjunan@tre.se'
echo "Mail sent in Non-PROD"             #Added Version 3.0
fi

# Send right type of mail
case $type in
     1)
         # cat $textfile2 | mailx -s 'Order Acknowledgement' -r $from1 $mail
	  # mail -s 'Order Acknowledgement' $mail < $textfile2
	  $XXCUST_TOP/OM_mailer/add_mail_headers.sh $mail " " 'Order Acknowledgement' $textfile2 | sendmail -i -t
         ;;
     2)
         # cat $textfile2 | mailx -s 'Ship Confirm' $from2 $mail
	  # mail -s 'Ship Confirm' $mail < $textfile2
	  $XXCUST_TOP/OM_mailer/add_mail_headers.sh $mail " " 'Ship Confirm' $textfile2 | sendmail -i -t
         ;;
     3)
         # cat $textfile2 | mailx -s 'Ship Confirm' -r $from2 $mail
	  # mail -s 'Ship Confirm' $mail < $textfile2
	  $XXCUST_TOP/OM_mailer/add_mail_headers.sh $mail " " 'Ship Confirm' $textfile2 | sendmail -i -t
         ;;
     4)
         # cat $textfile2 | mailx -s 'Order Acknowledgement' -r $from3 $mail
	  # mail -s 'Order Acknowledgement' $mail < $textfile2
	  $XXCUST_TOP/OM_mailer/add_mail_headers.sh $mail " " 'Order Acknowledgement' $textfile2 | sendmail -i -t
         ;;
     5)
         # cat $textfile2 | mailx -s 'Ship Confirm' -r $from4 $mail
	  # mail -s 'Ship Confirm' $mail < $textfile2
	  $XXCUST_TOP/OM_mailer/add_mail_headers.sh $mail " " 'Ship Confirm' $textfile2 | sendmail -i -t
         ;;
     6)
         # cat $textfile2 | mailx -s 'Ship Confirm' -r $from4 $mail
	  # mail -s 'Ship Confirm' $mail < $textfile2
	  $XXCUST_TOP/OM_mailer/add_mail_headers.sh $mail " " 'Ship Confirm' $textfile2 | sendmail -i -t
         ;;
     11)
         # cat $textfile2 | mailx -s 'Interface Errors' -r $from4 $erpmail
	  # mail -s 'Interface Errors' $erpmail -r noreply@tre.se < $textfile1
	  $XXCUST_TOP/OM_mailer/add_mail_headers.sh $erpmail " " 'Interface Errors' $textfile1 | sendmail -i -t
         ;;
     30)
         # cat $textfile2 | mailx -s 'EPOS Interface Error' -r $from5 $eposmail
	  # mail -s 'EPOS Interface Error' $eposmail < $textfile2
	   $XXCUST_TOP/OM_mailer/add_mail_headers.sh $eposmail " " 'EPOS Interface Error' $textfile2 | sendmail -i -t
         ;;
     99)
         # cat $textfile2 | mailx -s 'Error in OM_mailer' -r $from5 $erpmail
	  # mail -s 'Error in OM_mailer' $erpmail < $textfile2
	   $XXCUST_TOP/OM_mailer/add_mail_headers.sh $erpmail " " 'Error in OM_mailer' $textfile2 | sendmail -i -t

esac

}

#-----------------------------------------------------------------------------    
# function get_mail_id
#-----------------------------------------------------------------------------  

get_mail_id()
{

 #if [ $HOSTNAME = "x12873pzz" ]  commented version 15.0
 
 if [ $HOSTNAME = $PROD_HOSTNAME]  #added version 15.0
 
 then 
 
elsmail1=$(sqlplus -S ${APPSDB_UNAME}/${APPSDB_PWD} <<EOF
set heading off;
set feedback off;
SELECT meaning
        FROM fnd_lookup_values flv, fnd_lookup_types flt
       WHERE flt.lookup_type = flv.lookup_type
         AND flv.lookup_type = 'XXHI3G_LOGISTIC_MAILID_LOOKUPS'
         AND flv.lookup_code = 'BSTAR_MAIL'
         AND flv.enabled_flag = 'Y'
         AND flv.LANGUAGE = USERENV ('LANG')
         AND NVL (flv.end_date_active, SYSDATE) >= SYSDATE;
 
exit;
EOF
)
echo "end of if"

elsmail2=$(sqlplus -S ${APPSDB_UNAME}/${APPSDB_PWD} <<EOF
set heading off;
set feedback off;
SELECT meaning
        FROM fnd_lookup_values flv, fnd_lookup_types flt
       WHERE flt.lookup_type = flv.lookup_type
         AND flv.lookup_type = 'XXHI3G_LOGISTIC_MAILID_LOOKUPS'
         AND flv.lookup_code = 'IMM_MAIL'
         AND flv.enabled_flag = 'Y'
         AND flv.LANGUAGE = USERENV ('LANG')
         AND NVL (flv.end_date_active, SYSDATE) >= SYSDATE;
 
exit;
EOF
)

erpmail=$(sqlplus -S ${APPSDB_UNAME}/${APPSDB_PWD} <<EOF
set heading off;
set feedback off;
SELECT meaning
        FROM fnd_lookup_values flv, fnd_lookup_types flt
       WHERE flt.lookup_type = flv.lookup_type
         AND flv.lookup_type = 'XXHI3G_MAILID_LOOKUPS'
         AND flv.lookup_code = 'ERP_OPS'
         AND flv.enabled_flag = 'Y'
         AND flv.LANGUAGE = USERENV('LANG')
         AND NVL(flv.end_date_active, SYSDATE) >= SYSDATE;
 
exit;
EOF
) 
#SWEDEN RECIPIENT 14.0
elsmail3=$(sqlplus -S ${APPSDB_UNAME}/${APPSDB_PWD} <<EOF
set heading off;
set feedback off;
SELECT meaning
        FROM fnd_lookup_values flv, fnd_lookup_types flt
       WHERE flt.lookup_type = flv.lookup_type
         AND flv.lookup_type = 'XXHI3G_LOGISTIC_MAILID_LOOKUPS'
         AND flv.lookup_code = 'BSTAR_MAIL'
         AND flv.enabled_flag = 'Y'
         AND flv.LANGUAGE = USERENV ('LANG')
         AND NVL (flv.end_date_active, SYSDATE) >= SYSDATE;
 
exit;
EOF
)
#DENMARK RECIPIENT 14.0
elsmail4=$(sqlplus -S ${APPSDB_UNAME}/${APPSDB_PWD} <<EOF
set heading off;
set feedback off;
SELECT meaning
        FROM fnd_lookup_values flv, fnd_lookup_types flt
       WHERE flt.lookup_type = flv.lookup_type
         AND flv.lookup_type = 'XXHI3G_LOGISTIC_MAILID_LOOKUPS'
         AND flv.lookup_code = 'IMM_MAIL'
         AND flv.enabled_flag = 'Y'
         AND flv.LANGUAGE = USERENV ('LANG')
         AND NVL (flv.end_date_active, SYSDATE) >= SYSDATE;
 
exit;
EOF
)

 else 
elsmail1=$(sqlplus -S ${APPSDB_UNAME}/${APPSDB_PWD} <<EOF
set heading off;
set feedback off;
SELECT meaning
        FROM fnd_lookup_values flv, fnd_lookup_types flt
       WHERE flt.lookup_type = flv.lookup_type
         AND flv.lookup_type = 'XXHI3G_LOGISTIC_MAILID_LOOKUPS'
         AND flv.lookup_code = 'TEST_FOR_ALL'
         AND flv.enabled_flag = 'Y'
         AND flv.LANGUAGE = USERENV ('LANG')
         AND NVL (flv.end_date_active, SYSDATE) >= SYSDATE;
 
exit;
EOF
)

elsmail2=$(sqlplus -S ${APPSDB_UNAME}/${APPSDB_PWD} <<EOF
set heading off;
set feedback off;
SELECT meaning
        FROM fnd_lookup_values flv, fnd_lookup_types flt
       WHERE flt.lookup_type = flv.lookup_type
         AND flv.lookup_type = 'XXHI3G_LOGISTIC_MAILID_LOOKUPS'
         AND flv.lookup_code = 'TESTING'
         AND flv.enabled_flag = 'Y'
         AND flv.LANGUAGE = USERENV ('LANG')
         AND NVL (flv.end_date_active, SYSDATE) >= SYSDATE;
 
exit;
EOF
)

erpmail=$(sqlplus -S ${APPSDB_UNAME}/${APPSDB_PWD} <<EOF
set heading off;
set feedback off;
SELECT meaning
        FROM fnd_lookup_values flv, fnd_lookup_types flt
       WHERE flt.lookup_type = flv.lookup_type
         AND flv.lookup_type = 'XXHI3G_LOGISTIC_MAILID_LOOKUPS'
         AND flv.lookup_code = 'TESTING'
         AND flv.enabled_flag = 'Y'
         AND flv.LANGUAGE = USERENV ('LANG')
         AND NVL (flv.end_date_active, SYSDATE) >= SYSDATE;
 
exit;
EOF
) 

ISLmailDK=$(sqlplus -S ${APPSDB_UNAME}/${APPSDB_PWD} <<EOF
set heading off;
set feedback off;
SELECT meaning
        FROM fnd_lookup_values flv, fnd_lookup_types flt
       WHERE flt.lookup_type = flv.lookup_type
         AND flv.lookup_type = 'XXHI3G_LOGISTIC_MAILID_LOOKUPS'
         AND flv.lookup_code = 'ISL_ORDER_MAIL_DK'
         AND flv.enabled_flag = 'Y'
         AND flv.LANGUAGE = USERENV ('LANG')
         AND NVL (flv.end_date_active, SYSDATE) >= SYSDATE;
 
exit;
EOF
) 

ISLmailSE=$(sqlplus -S ${APPSDB_UNAME}/${APPSDB_PWD} <<EOF
set heading off;
set feedback off;
SELECT meaning
        FROM fnd_lookup_values flv, fnd_lookup_types flt
       WHERE flt.lookup_type = flv.lookup_type
         AND flv.lookup_type = 'XXHI3G_LOGISTIC_MAILID_LOOKUPS'
         AND flv.lookup_code = 'ISL_ORDER_MAIL_SE'
         AND flv.enabled_flag = 'Y'
         AND flv.LANGUAGE = USERENV ('LANG')
         AND NVL (flv.end_date_active, SYSDATE) >= SYSDATE;
 
exit;
EOF
) 


 
 fi 

}

#-----------------------------------------------------------------------------    
# function send_if_error_mail
#-----------------------------------------------------------------------------  


send_if_error_mail()
{


for i in `cat $FTPCOM` 

do      
	 # Clean up any earlier mail files

	if (test -f $textfile1) 
	      then
	      rm $textfile1
	fi

	if (test -f $textfile2) 
	      then
	      rm $textfile2
	fi

 echo "FTPCOM call"
# mail_generate.sql Fetches database information and spools out a textfile


	sqlplus ${APPSDB_UNAME}/${APPSDB_PWD} @$XXCUST_TOP/OM_mailer/if_mail_generate $i

# Remove Oracle's success messages

	sed s#"PL/SQL procedure successfully completed."#" "# $textfile1 > $textfile2

	NUMROWS=`cat $textfile2 | grep Interface | wc -l`
	#Added for 9.0...start
	NUMROWS_SE=`cat $textfile2 | grep SWEDEN | wc -l`
	NUMROWS_DK=`cat $textfile2 | grep DENMARK | wc -l`
	NUMROWS_DK_ERP=`cat $textfile2 | grep 'DENMARK ERP Error' | wc -l`
	NUMROWS_SK_ERP=`cat $textfile2 | grep 'SWEDEN ERP Error' | wc -l`
	sed -i 's/ERP Error//' $textfile2
	echo $textfile2
	echo $NUMROWS_SE
	echo $NUMROWS_DK
	echo $NUMROWS_DK_ERP
	echo $NUMROWS_SK_ERP
	 echo "if_mail_generate call4"
	#Added for 9.0...End	

	if [ $NUMROWS -gt 0 ]
	then
 echo "INTERFACE ERROR LOOP call"
	#commented for 9.0 .. start
           #if [ $i == 'INVENTORY_TRX' ]
           #then
                 # mail -s $i' Errors' -c $erpmail $elsmail < $textfile2
		   #$XXCUST_TOP/OM_mailer/add_mail_headers.sh $elsmail1 $erpmail $i' Errors' $textfile2 | sendmail -i -t
    #commented for 9.0 .. end

    #added for 9.0 .. start 

		if [ $i == 'INVENTORY_TRX_SE' ]
           then
                 # mail -s $i' Errors' -c $erpmail $elsmail < $textfile2
				 
				 if [ $NUMROWS_SE -gt 0 ]
	                then
		 # removed for v.11 	 
		 # $XXCUST_TOP/OM_mailer/add_mail_headers.sh $elsmail1 $erpmail $i' Errors' $textfile2 | sendmail -i -t
		 
		 # Added for v.11	
		   $XXCUST_TOP/OM_mailer/add_mail_headers.sh $elsmail1 $erpmail $i' Errors' $textfile2 | sendmail -ferp@tre.se -i -t
	             fi
	
	   elif [ $i == 'INVENTORY_TRX_DK' ]
           then
                 # mail -s $i' Errors' -c $erpmail $elsmail < $textfile2
				 if [ $NUMROWS_DK -gt 0 ]
	                then
		
		 # removed for v.11 	 
		 # $XXCUST_TOP/OM_mailer/add_mail_headers.sh $elsmail1 $erpmail $i' Errors' $textfile2 | sendmail -i -t
		 
		 # Added for v.11		
		   $XXCUST_TOP/OM_mailer/add_mail_headers.sh $elsmail2 $erpmail $i' Errors' $textfile2 | sendmail -ferp@tre.se -i -t
	             fi
    #added for 9.0 .. end	
    #added for 10.0 .. start 

		elif [ $i == 'XX_EID_MISSING_SE' ]
           then
                 # mail -s $i' Errors' -c $erpmail $elsmail < $textfile2
				 
		 # removed for v.11 	 
		 # $XXCUST_TOP/OM_mailer/add_mail_headers.sh $elsmail1 $erpmail $i' Errors' $textfile2 | sendmail -i -t
		 
		 # Added for v.11
		   $XXCUST_TOP/OM_mailer/add_mail_headers.sh $elsmail1 $erpmail $i' Errors' $textfile2 | sendmail -ferp@tre.se -i -t
	           	
	   elif [ $i == 'XX_EID_MISSING_DK' ]
           then
                 # mail -s $i' Errors' -c $erpmail $elsmail < $textfile2
		 
		 # removed for v.11 	 
		 # $XXCUST_TOP/OM_mailer/add_mail_headers.sh $elsmail1 $erpmail $i' Errors' $textfile2 | sendmail -i -t
		 
		 # Added for v.11
		   $XXCUST_TOP/OM_mailer/add_mail_headers.sh $elsmail2 $erpmail $i' Errors' $textfile2 | sendmail -ferp@tre.se -i -t
	         
		 #added for	 14.0
		elif [ $i == 'XX_ISL_ORDER_COMPLETION_DK' ]
           then
		     $XXCUST_TOP/OM_mailer/add_mail_headers_isl.sh $ISLmailDK " " $i' Errors' "text/html" $textfile2 | sendmail -ferp@tre.se -i -t
							   
		elif [ $i == 'XX_ISL_ORDER_COMPLETION_DK_ERP' ] 
            then
					 		
					    $XXCUST_TOP/OM_mailer/add_mail_headers_isl.sh $ISLmailDK " " $i' Errors' "text/html" $textfile2 | sendmail -ferp@tre.se -i -t
						
		elif [ $i == 'XX_ISL_ORDER_COMPLETION_SE' ]
            then 
					 		
					    $XXCUST_TOP/OM_mailer/add_mail_headers_isl.sh $ISLmailSE " " $i' Errors' "text/html" $textfile2 | sendmail -ferp@tre.se -i -t
						
		elif [ $i == 'XX_ISL_ORDER_COMPLETION_SE_ERP' ] 
            then
					 		
					    $XXCUST_TOP/OM_mailer/add_mail_headers_isl.sh $ISLmailSE " " $i' Errors' "text/html" $textfile2 | sendmail -ferp@tre.se -i -t
 		   
		else		 
    #added for 10.0 .. end
           
		 # cat $textfile2 | mailx -s  $i' Errors' -r $from5 $erpmail
		 # mail -s $i' Errors' $erpmail < $textfile2

		 # removed for v.11 	 
		 # $XXCUST_TOP/OM_mailer/add_mail_headers.sh $elsmail1 $erpmail $i' Errors' $textfile2 | sendmail -i -t
		 
		 # Added for v.11
		 $XXCUST_TOP/OM_mailer/add_mail_headers.sh $erpmail " " $i' Errors' $textfile2 | sendmail -ferp@tre.se -i -t
		 
        fi
	fi

done 

}




#-----------------------------------------------------------------------------  
#-----------------------------------------------------------------------------  
# Start of Script
#-----------------------------------------------------------------------------  
#-----------------------------------------------------------------------------  

#. /opt/oracle/applprd2/apps/apps_st/appl/xxcust/12.0.0/OM_mailer/OM_mailer.env		#Commented as part of 12.0
#. /opt/oracle/applprd2/apps/apps_st/appl/xxcust/12.0.0/admin/get_db_cred.env		#Commented as part of 12.0

													   
#. /$XXCUST_TOP/OM_mailer/OM_mailer.env				#Added as part of 12.0 # commented as part of 13.0


GPG_KEY="SIGN"
BAD_FILE_STATUS=0
LOAD_STATUS=1

# load all the secrets, including GPG_SIGN_PASSWORD and APPS_PW
.$XXCUST_TOP/admin/xx_secrets2.sh

gpg --batch --yes -u $GPG_KEY --passphrase $GPG_SIGN_PASSWORD -o /$XXCUST_TOP/admin/get_db_cred.env -d /$XXCUST_TOP/admin/get_db_cred.env.gpg

. /opt/ebs122/EBSapps.env run						# added as part of 13.0
. /$XXCUST_TOP/admin/get_db_cred.env					#Added as part of 12.0

#rm $XXCUST_TOP/admin/get_db_cred_test.env

echo "End"

textfile1=$XXCUST_TOP/OM_mailer/mail_text.log
textfile2=$XXCUST_TOP/OM_mailer/mail_text2.log
FTPCOM=$XXCUST_TOP/OM_mailer/INT_EXCP_TYPE_COM.txt

from1=3.order.acknowledgement@tre.se
from2=3.shipping.notification@tre.se
from3=3.orderbekræftelse@3.dk
from4=3.forsendelsesbekræftelse@3.dk
from5=interface.exceptions@tre.se

 echo "get_mail_id call"

get_mail_id
 echo "send_if_error_mail call"
send_if_error_mail


# Script get_header fetches (and deletes) any mail that are in the send queue table XX_HI3G_MAIL
# Loop through all mails to be sent and generate them and send them
sqlplus -s ${APPSDB_UNAME}/${APPSDB_PWD} @$XXCUST_TOP/OM_mailer/get_header | while read RESULT_LINE
do

# Parse the Result into variables
remainder1=${RESULT_LINE%* *}
remainder2=${RESULT_LINE#* *}
header=${remainder1%* *} 
type=${remainder1#* *}
mail=${remainder2#* *}

# Check for null lines and sucess messages
   if [ "$RESULT_LINE" != "" ]; then
      if [ "$RESULT_LINE" != "PL/SQL procedure successfully completed." ]; then
     
	  # send_mail
	  echo "end of send_mail comment"
	  
      fi
   fi
done
