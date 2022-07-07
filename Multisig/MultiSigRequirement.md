# MultiSigAudit

MULTISIG CONTRACT 

Use Case Of The Contract : 

This contract registers a group of users with a unique hash “ssid” and in each ssid there are defined number of owners for that ssid,one of  who can submit a transaction,each transaction is identified with a unique nonce.Upon submission of transaction all the other owners will be able to confirm the transaction.each ssid has a required number of confirmations that are needed so that the transaction is confirmed 

AddOwners: 

This takes ssid(string),owners(array of addresses) and minimum number of confirmations needed to confirm a transaction(uint).This sets the array of address as owners for the group with given Id and sets the minimum number of confirmations.

getOwners  can be used to see the new owners of the ssid and required mappings can be used for the purpose of checking the required confirmations


AddWhiteListers: 

This takes ssid(string),_Whitelisters(array of addresses).This set the array of address is WhiteListters for the group with given Id.

isWhitelisted can be used to see the new owners of the ssid and only owners of a ssid can add whitelisters



SubmitTransaction :

This takes ssid as input parameter and returns a transactionId(uint) that references this transaction

Only a owner of the ssid group can submit this transaction and onlywallet modifiers takes care of this part

A internal function addTransaction  is called here this also takes ssid as an input parameter and returns a transactionId(uint) that references this transaction.In addTransaction function the transactionId is set the transactionCount(private variable that keeps count of total no of transactions) it also sets two mappings txSsid(maps the transactionId with the corresponding ssid) and transactions(maps the transactionId with transaction struct)

Transaction struct is structure that stores the executed status of the transaction initially it is set to false in the submit transaction function


At the end of submit transaction the transaction the transaction is also confirmed meaning the one who submitted the transaction has also confirmed the transaction


ConfirmTranscation :

This takes transactionId as input parameter and confirms the transaction on behalf of msg.sender
For this function to work the following conditions should be met

1.The transaction should exists (transactionExists modifier will look after this part)
2.msg.sender should has access to confirm the transaction(ownerExists modifier will look after this part)
3.The transaction should not have been already confirmed by the msg.sender(notConfirmed modifier will look after this part)

This sets the confirmations mapping of transactionId and msg.sender to true

Confirmations mapping maps address and transactionId with boolean value its value is true when the address confirmed the transactionId else it's set to false 

At the end of confirmTransaction execute transaction is invoked 

ExecuteTransaction:

executeTransactions checks if the transactionId reaches the required number of confirmations (by calling isConfirmed function) and if its confirmed the transaction state is set to executed 
