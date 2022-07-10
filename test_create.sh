export CREATE_APP_ID=99099422
export CREATE_APP_ACCOUNT=QZDPW4KE356TLAGDJGPCUCU75GIAKYFLGRX3OOOWRQVY5QZTAS23VNDQSI
export USER=BURN3MK23BN3DDV2JVYBL7VYIPBUFCKXQWK5W5ECG5FJMG2QNSGODQBGI4
export AMOUNT=23
export CANCANCEL=0
export END=1657472894
export BENEFICIARY=FYMC4AQVEVEP4ZJ4G6KRBF5T7O3EJZIISDA2QP4XU2RXGQAGSU6KYILLE4

goal asset send --amount 0 --assetid 92125658 --from $USER --to $USER --wallet $WALLET
goal asset send --amount 100000 --assetid 92125658 --from $CREATOR --to $USER --wallet $WALLET

// create
goal app create --creator $CREATOR --approval-prog $CREATE_APPROVAL_FILE --clear-prog $SYSTEM_CLEAR_FILE --global-byteslices 0 --global-ints 0 --local-byteslices 0 --local-ints 0 --on-completion OptIn -w $WALLET
goal app info --app-id $CREATE_APP_ID

// run
goal clerk send --amount 741500 --from $USER --to $CREATE_APP_ACCOUNT --out=$TXNS_DIR/create_send_algo.stxn
goal app call --app-id=$CREATE_APP_ID --from $USER --app-arg="str:optin" --foreign-asset $ASA --out=$TXNS_DIR/create_optin.stxn
goal asset send --amount $AMOUNT --assetid $ASA --from $USER --to $CREATE_APP_ACCOUNT --out=$TXNS_DIR/create_send_asa.stxn
goal app call --app-id=$CREATE_APP_ID --from $USER --app-arg="str:create" --app-arg="int:$CANCANCEL" --app-arg="int:$END" --app-account="$BENEFICIARY" --foreign-asset $ASA --out=$TXNS_DIR/create_call.stxn
cat $TXNS_DIR/create_send_algo.stxn $TXNS_DIR/create_optin.stxn $TXNS_DIR/create_send_asa.stxn $TXNS_DIR/create_call.stxn > $TXNS_DIR/combinedtransactions.txn
goal clerk group --infile $TXNS_DIR/combinedtransactions.txn --outfile $TXNS_DIR/groupedtransactions.txn
goal clerk sign --infile $TXNS_DIR/groupedtransactions.txn --outfile $TXNS_DIR/create.stxn
goal clerk rawsend --filename $TXNS_DIR/create.stxn

// debug
goal clerk dryrun -t $TXNS_DIR/create.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $CREATE_APPROVAL_FILE -d $TXNS_DIR/dryrun.json --group-index 3
goal clerk send --amount 2202000 --from $CREATOR --to $CREATE_APP_ACCOUNT
goal app update --app-id=$CREATE_APP_ID --from=$CREATOR --approval-prog $CREATE_APPROVAL_FILE --clear-prog $SYSTEM_CLEAR_FILE





goal asset send --amount $AMOUNT --assetid $ASA --from $USER --to $CREATE_APP_ACCOUNT
goal app create --creator $CREATOR --approval-prog $CREATE_APPROVAL_FILE --clear-prog $SYSTEM_CLEAR_FILE --global-byteslices 0 --global-ints 0 --local-byteslices 0 --local-ints 0 --on-completion OptIn -w $WALLET
goal clerk send --amount 1000000 --from $CREATOR --to $CREATE_APP_ACCOUNT
# goal app call --app-id=$CREATE_APP_ID --from $USER --foreign-app 99024788
goal app call --app-id=$CREATE_APP_ID --from $USER --foreign-asset $ASA