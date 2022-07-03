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
