// https://developer.algorand.org/docs/run-a-node/setup/install/#sync-node-network-using-fast-catchup
// global state
cancancel: uint64 // bool (0=false)
start: uint64 // unix timestamp
end: uint64 // unix timestamp // needs to be after now
beneficiary: byte[] // addr

// set env vars for terminal
export ALGORAND_DATA="$HOME/node/testnetdata"
export WALLET=2i2i
export CODE_DIR=./code
export TXNS_DIR=./txns
export SYSTEM_APPROVAL_FILE=$CODE_DIR/state_approval_program.teal
export SYSTEM_CLEAR_FILE=$CODE_DIR/state_clear_program.teal
export CREATOR=2I2IXTP67KSNJ5FQXHUJP5WZBX2JTFYEBVTBYFF3UUJ3SQKXSZ3QHZNNPY
export APP_ID=98699947
export APP_ACCOUNT=O5AJICLQUOJJS2GEFFBPZIAADIH3CWQUVMZ26OXQQ6BBASBAJ4DX5FWVCY
export ASA=91697272
export CANCANCEL=0
export END=1657155598
export NEW_END=
export BENEFICIARY=VHDMPEWDLWENHMRPH4MJBW6ADTFBRRRZ6UTZT7OXTTIPBUNK3RVKLBRK6A
export AMOUNT=100
export NEW_AMOUNT=

// start goal, create wallet and account
goal node start
goal node status
goal node end
goal wallet new $WALLET
goal account new -w $WALLET
goal clerk send -a 1000000 -f $CREATOR -t $A -w $WALLET

// create
goal app create --creator $CREATOR --approval-prog $SYSTEM_APPROVAL_FILE --clear-prog $SYSTEM_CLEAR_FILE --global-byteslices 1 --global-ints 3 --local-byteslices 0 --local-ints 0 --extra-pages 0 --on-completion OptIn -w $WALLET
goal app info --app-id $APP_ID

goal clerk send --amount 100000 --from $CREATOR --to $APP_ACCOUNT --wallet $WALLET

// init
goal clerk send --amount 101000 --from $CREATOR --to $APP_ACCOUNT --wallet $WALLET --out=$TXNS_DIR/init_send_algo.stxn
goal app call --app-id=$APP_ID --from $CREATOR --app-arg="str:init" --app-arg="int:$CANCANCEL" --app-arg="int:$END" --app-account="$BENEFICIARY" --foreign-asset $ASA --wallet $WALLET --out=$TXNS_DIR/init_call.stxn
goal asset send --amount $AMOUNT --assetid $ASA --from $CREATOR --to $APP_ACCOUNT --wallet $WALLET --out=$TXNS_DIR/init_send_asa.stxn
cat $TXNS_DIR/init_send_algo.stxn $TXNS_DIR/init_call.stxn $TXNS_DIR/init_send_asa.stxn > $TXNS_DIR/combinedtransactions.txn
goal clerk group --infile $TXNS_DIR/combinedtransactions.txn --outfile $TXNS_DIR/groupedtransactions.txn
goal clerk sign --infile $TXNS_DIR/groupedtransactions.txn --outfile $TXNS_DIR/init.stxn -w $WALLET
goal clerk rawsend --filename $TXNS_DIR/init.stxn

goal app call --app-id=$APP_ID --from $CREATOR --app-arg="str:init" --app-arg="int:$CANCANCEL" --app-arg="int:$END" --app-account="$BENEFICIARY" --foreign-asset $ASA --wallet $WALLET --out=$TXNS_DIR/init_call.stxn
goal asset send --amount $AMOUNT --assetid $ASA --from $CREATOR --to $APP_ACCOUNT --wallet $WALLET --out=$TXNS_DIR/init_send_asa.stxn
cat $TXNS_DIR/init_call.stxn $TXNS_DIR/init_send_asa.stxn > $TXNS_DIR/combinedtransactions.txn
goal clerk group --infile $TXNS_DIR/combinedtransactions.txn --outfile $TXNS_DIR/groupedtransactions.txn
goal clerk sign --infile $TXNS_DIR/groupedtransactions.txn --outfile $TXNS_DIR/init.stxn -w $WALLET
goal clerk rawsend --filename $TXNS_DIR/init.stxn

// withdraw
goal app call --app-id=$APP_ID --from $BENEFICIARY --app-arg="str:withdraw" --foreign-asset $ASA --wallet $WALLET --out=$TXNS_DIR/withdraw.stxn
goal app call --app-id=$APP_ID --from $CREATOR --app-arg="str:withdraw" --foreign-asset $ASA --wallet $WALLET --out=$TXNS_DIR/withdraw.stxn
goal clerk dryrun -t $TXNS_DIR/withdraw.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $SYSTEM_APPROVAL_FILE -d $TXNS_DIR/dryrun.json --group-index 0

// update
goal app call --app-id=APP_ID --from $CREATOR --app-arg="str:update" --app-arg="int:$NEW_END" --wallet $WALLET --out=$TXNS_DIR/update_call.stxn
goal asset send --amount $NEW_AMOUNT --assetid $ASA --from $CREATOR --to $APP_ACCOUNT --wallet $WALLET --out=$TXNS_DIR/update_send.stxn
cat $TXNS_DIR/update_call.stxn $TXNS_DIR/update_send.stxn > $TXNS_DIR/combinedtransactions.txn
goal clerk group --infile $TXNS_DIR/combinedtransactions.txn --outfile $TXNS_DIR/groupedtransactions.txn
goal clerk sign --infile $TXNS_DIR/groupedtransactions.txn --outfile $TXNS_DIR/update.stxn -w $WALLET
goal clerk rawsend --filename $TXNS_DIR/update.stxn

// debug
goal clerk dryrun -t $TXNS_DIR/init.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $SYSTEM_APPROVAL_FILE -d $TXNS_DIR/dryrun.json --group-index 0
// update - disabled in prod
goal app update --app-id=$APP_ID --from=$CREATOR --approval-prog $SYSTEM_APPROVAL_FILE --clear-prog $SYSTEM_CLEAR_FILE
