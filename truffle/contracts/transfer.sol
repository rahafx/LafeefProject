
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract transfer{

/* ---------------- from investors to contract ---------------- */
    function deposit() public payable {}


/*  --------------------- from contract to owner --------------------- */
/* milestone fund */
    function sendFund(address payable _to) public payable {
        uint x = address(this).balance-5;
        _to.transfer(x);
    }

/* -------------------- from contract to investors ------------------- */
/* investors[] */
    function returnFund() public payable {
    }

    function get() public view returns (uint) {
        return address(this).balance;
    }
}
