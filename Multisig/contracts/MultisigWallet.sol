//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
contract MultiSigWallet {
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Executed(uint indexed transactionId);
    event RequirementChange(uint required,string ssid);
    uint constant public MAX_OWNER_COUNT = 5;
    mapping (uint => Transaction) public transactions;
    mapping(uint => string) public txSsid;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => mapping(string => bool)) public isOwner;
    mapping (address => mapping(string => bool)) public isWhiteListed;
    mapping (string => address[]) public ssidOwners;
    mapping (string => address[]) public whiteListers;
    mapping (string => uint) public required;
    uint public transactionCount;
    address public creator;
    struct Transaction {
        bool executed;
    }
    /*
     *  Modifiers
     */
    modifier onlyWallet(string memory ssid) {
        require(isOwner[msg.sender][ssid],"sender is not owner of ssid");
        _;
    }
    modifier onlyCreator()
    {
        require(msg.sender==creator,"sender is not creator");
        _;
    }
    modifier accessToConfirm(uint256 transactionId) {
        require(transactionId<transactionCount,"transaction doesnt exist");
        require(isOwner[msg.sender][txSsid[transactionId]],"doesnt have access to confirm");
        _;
    }
   
    modifier notConfirmed(uint transactionId) {
        require(!confirmations[transactionId][msg.sender],"sender already confirmed transaction");
        _;
    }
    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed,"transaction executed");
        _;
    }
    modifier transactionExists(uint transactionId) {
        require(transactionId<transactionCount,"transaction doesn't exists");
        _;
    }
    modifier validRequirement(string memory _ssid,uint _required) {
        require( _required <= ssidOwners[_ssid].length,"quorum exceeds no of owners");
        require( _required != 0,"zero quorum");
        _;
    }
    modifier addOwnerRequirement(uint newOwnersCount,uint _required)
    {
        require( newOwnersCount <= MAX_OWNER_COUNT,"Exceeds max count");
        require( _required <= newOwnersCount,"quorum exceeds no of owners");
        require( _required != 0,"zero quorum");
        _;
    }
    constructor()
        {
        creator=msg.sender;
    }
    function addOwners(address [] memory _owners,string memory _ssid,uint _required)
        public
        onlyCreator
       addOwnerRequirement(_owners.length,_required)
    {
         for (uint i=0; i<_owners.length; i++) {
            require(_owners[i] != address(0),"null address cant be added");
            isOwner[_owners[i]][_ssid]= true;
        }
        ssidOwners[_ssid]=_owners;
        required[_ssid] = _required;
        emit RequirementChange(_required, _ssid);
    }
    function addWhitelisters(address [] memory _whiteListers,string memory _ssid)
    public
    onlyWallet(_ssid)
    {
        for (uint i=0; i<_whiteListers.length; i++) {
            require(_whiteListers[i] != address(0),"null address cant be added");
            isWhiteListed[_whiteListers[i]][_ssid]= true;
        }
        whiteListers[_ssid]=_whiteListers;
    }
    function changeRequirement(uint _required,string memory ssid)
        public
        onlyWallet(ssid)
        validRequirement(ssid, _required)
    {
        required[ssid] = _required;
        emit RequirementChange(_required,ssid);
    }
    function submitTransaction(string memory ssid)
        public
        onlyWallet(ssid)
        returns (uint transactionId)
    {
        transactionId = addTransaction(ssid);
        confirmTransaction(transactionId);
    }
    function confirmTransaction(uint transactionId)
        public
        accessToConfirm(transactionId)
        notConfirmed(transactionId)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }
    function executeTransaction(uint transactionId)
        internal
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed=true;
            emit Executed(transactionId);
        }
    }
    function isConfirmed(uint transactionId)
        public
        view
        returns (bool )
    {
        uint count = 0;
        string memory ssid=txSsid[transactionId];
        address [] memory owners=ssidOwners[ssid];
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required[ssid])
                return true;
        }
        return false;
    }
    function addTransaction(string memory ssid)
        internal
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        txSsid[transactionId]=ssid;
        transactions[transactionId] = Transaction({
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }
    function getConfirmationCount(uint transactionId)
        public
        view
        returns (uint count)
    {
        string memory ssid=txSsid[transactionId];
        address [] memory owners = ssidOwners[ssid];
        for (uint i=0; i<owners.length; i++)
           {if (confirmations[transactionId][owners[i]])
                count += 1;
           }
    }
    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint count)
    {
        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;
    }
    function getOwners(string memory ssid)
        public
        view
        returns (address[] memory)
    {
        return ssidOwners[ssid];
    }

    function getWhiteListers(string memory ssid)
        public
        view
        returns (address[] memory)
    {
        return whiteListers[ssid];
    }
    function getConfirmations(uint transactionId)
        public
        view
        transactionExists(transactionId)
        returns (address[] memory _confirmations)
    {
        string memory ssid=txSsid[transactionId];
        address [] memory owners=ssidOwners[ssid];
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }
}
