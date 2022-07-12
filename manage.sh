// https://developer.algorand.org/docs/run-a-node/setup/install/#sync-node-network-using-fast-catchup
// chrome://inspect/#devices
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
export APP_ID=99094778
export APP_ACCOUNT=FZWAB6CXAXWN7NPSY6PUEPQGJUKZJ33NX6UDKQGLTEJZRRRXWI6SS66RKI
export ASA=92125658
export CANCANCEL=0
export END=1657155598
export NEW_END=16576492130
export BENEFICIARY=FYMC4AQVEVEP4ZJ4G6KRBF5T7O3EJZIISDA2QP4XU2RXGQAGSU6KYILLE4
export AMOUNT=100
export NEW_AMOUNT=40000

export APP_ID=99369510

// start goal, create wallet and account
goal node start
goal node status
goal node end
goal wallet new $WALLET
goal account new -w $WALLET
goal clerk send -a 1000000 -f $CREATOR -t $A -w $WALLET

// withdraw
goal clerk send --amount 1000 --from $BENEFICIARY --to $APP_ACCOUNT --out=$TXNS_DIR/withdraw_algo.stxn -w $WALLET
goal app call --app-id=$APP_ID --from $BENEFICIARY --app-arg="str:withdraw" --foreign-asset=$ASA --out=$TXNS_DIR/withdraw_call.stxn -w $WALLET
cat $TXNS_DIR/withdraw_algo.stxn $TXNS_DIR/withdraw_call.stxn > $TXNS_DIR/combinedtransactions.txn
goal clerk group --infile $TXNS_DIR/combinedtransactions.txn --outfile $TXNS_DIR/groupedtransactions.txn
goal clerk sign --infile $TXNS_DIR/groupedtransactions.txn --outfile $TXNS_DIR/withdraw.stxn
goal clerk rawsend --filename $TXNS_DIR/withdraw.stxn

// update
goal app call --app-id=$APP_ID --from $CREATOR --app-arg="str:update" --app-arg="int:$NEW_END" --foreign-asset=$ASA --wallet $WALLET --out=$TXNS_DIR/update_call.stxn
goal asset send --amount $NEW_AMOUNT --assetid $ASA --from $CREATOR --to $APP_ACCOUNT --wallet $WALLET --out=$TXNS_DIR/update_send.stxn
cat $TXNS_DIR/update_call.stxn $TXNS_DIR/update_send.stxn > $TXNS_DIR/combinedtransactions.txn
goal clerk group --infile $TXNS_DIR/combinedtransactions.txn --outfile $TXNS_DIR/groupedtransactions.txn
goal clerk sign --infile $TXNS_DIR/groupedtransactions.txn --outfile $TXNS_DIR/update.stxn -w $WALLET
goal clerk rawsend --filename $TXNS_DIR/update.stxn

// cancel
goal app call --app-id=$APP_ID --from $CREATOR --app-arg="str:cancel" --wallet $WALLET

// debug
goal clerk send --amount 100000 --from $CREATOR --to $APP_ACCOUNT --wallet $WALLET
goal clerk dryrun -t $TXNS_DIR/init.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $SYSTEM_APPROVAL_FILE -d $TXNS_DIR/dryrun.json --group-index 0
// update - disabled in prod
goal app update --app-id=$APP_ID --from=$CREATOR --approval-prog $SYSTEM_APPROVAL_FILE --clear-prog $SYSTEM_CLEAR_FILE