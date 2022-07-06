# AlgoVesting
Smart contract to enforce a vesting schedule for withdrawing coins

Lock coins in a smart contract that are meant for someone else (an employee, a founder, an investor, a friend etc.) and that person can withdraw coins according to some schedule.  

The schedule could have second precision.  

## Example  
Imagine an employer that locks (budgets) coins for an employee in this smart contract and the employee can withdraw their salary whenever they want, but always only pro-rata, i.e. according to the time passed.  

Some companies pay their employees at the end of each month. This leaves all the risk with the employee (if the company goes bankrupt). If they payment were at the beginning of each month, all the risk would be with the company (if the employee does not show up). To decrease the risk, some companies pay weekly.  
In theory, the least risky would be to pay every second (or moment). This would be expensive in the old world. but with a smart contract, the employee can withdraw whenever they want, depending on how much time has already passed.  

Assume the company has deposited coins for 1 week (7\*24\*60\*60 secs). After an hour (60\*60 secs) the employee could withdraw 60\*60/(7\*24\*60\*60)=0.6% of the coins. They could wait and instead withdraw after 2 days (2\*24\*60\*60 secs) and get 29% of the coins.  
In case the employee stops working, the company can cancel the smart contract.  

This smart contract thus allows for the "fairest" possible compensation.

## Details

- works with any ASA

- `cancancel` - set by `creator`: allows `creator` to withdraw all coins, i.e. to cancel the vesting (use case `true`: imagine the vesting is for a salary of an employee and that employee quits / use case `false`: imagine the vesting is a founder of a project and the coins are guaranteed)

- `start` timestamp is immutable [epoch]

- `end` timestamp [epoch] ~ has to after now  ~ after `end`, `beneficiary` can withdraw all coins

- `withdraw` method always withdraws full eligible amount (pro-rata current timestamp vs `end`-`start`) ~ rate = coins / (end - start)

- `beneficiary` is set by the `creator` - a single account

- `beneficiary` has to send dApp txn fee (currently 0.001 ALGO) for `withdraw`

- `update` ~ change `end` ~ needs to be accompanied with coins such that withdraw rate does not worsen ~ new `end` has to be after old `end` and after now
