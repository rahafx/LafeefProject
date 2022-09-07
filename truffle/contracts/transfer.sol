
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract transfer{

/* ---------------- from investors to contract ---------------- */
    function deposit() public payable {}


/*  --------------------- from contract to owner --------------------- */
/* milestone fund */
    function send(address payable _to) public payable {
        _to.transfer(msg.value);
    }

/* -------------------- from contract to investors ------------------- */
/* investors[] */
   function returnFund() public payable {
   }
   
    function get() public view returns (uint) {
        return address(this).balance;
    }
}
