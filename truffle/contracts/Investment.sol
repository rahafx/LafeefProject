// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Investment {

    struct invest{
        mapping(uint => address payable) investors;
        mapping(uint => uint) funds;
        uint collected_fund;
        uint remaining;
        uint numberOfInvestors;
    }
    mapping(uint => invest) public allInvestments;


/* --------------------- from investors to contract --------------------- */
    function deposit(uint campaign_id, uint fund) public payable {
        /* ------------ check if capital is collected or if campaign is under vote -------------- */
        createinvest(campaign_id, payable(msg.sender), fund);
    }
/* ------------------ from contract wallet to investors(delete) ----------------- */
    function Transfer_money(address payable investor, uint fund) public {
        investor.transfer(fund);
  }
/* ------------------- add and retrieve investments information ------------------------- */
    function createinvest(uint campaign_id, address payable investor, uint fund) public {
        uint count = allInvestments[campaign_id].numberOfInvestors;
        allInvestments[campaign_id].investors[count] = investor;
        allInvestments[campaign_id].funds[count] = fund;
        allInvestments[campaign_id].collected_fund += fund;
        allInvestments[campaign_id].remaining = allInvestments[campaign_id].collected_fund;
        allInvestments[campaign_id].numberOfInvestors++;
    }

/* -------------------- retrieve invosters information in voting contract------------------*/
    function retrieveInvestors(uint campaign_id) public view returns(uint, address[] memory, uint[] memory){
        uint count = allInvestments[campaign_id].numberOfInvestors;
        address[] memory investors;
        uint[] memory funds;
        for(uint i=0; i<count; i++){
            investors[i]=allInvestments[campaign_id].investors[i];
            funds[i]=allInvestments[campaign_id].funds[i];
        }
        return (count, investors, funds);
    }

/* -------------------------- check if address exists ---------------------- */
function checkAddress(uint campaign_id, address investor) public view returns (bool){
    uint count = allInvestments[campaign_id].numberOfInvestors;
    for(uint i=0; i<count; i++){
            if(allInvestments[campaign_id].investors[i] == investor){
                return true;
            }
        }
    return false;
}

/* ---------------------- return collected fund --------------------------*/
    function retrieveFund(uint campaign_id) public view returns(uint){
        return allInvestments[campaign_id].collected_fund;

    }

/* ----------------------- Subtract milestone fund from remaining ------------*/
    function updateRemaining(uint campaign_id, uint fund) public {
        allInvestments[campaign_id].remaining = allInvestments[campaign_id].remaining - fund;
    }

/*  --------------------- from contract to investors --------------------- */
    function returnFund(uint campaign_id) public payable {

        uint count = allInvestments[campaign_id].numberOfInvestors;
        uint capital = allInvestments[campaign_id].collected_fund;
        uint remaining = allInvestments[campaign_id].remaining;

        address payable investor;
        uint fund;
        uint share;
        uint value;
        for(uint i=0; i<count; i++){
            investor = allInvestments[campaign_id].investors[i];
            fund = allInvestments[campaign_id].funds[i];
            share = (fund*100)/capital;
            value = (remaining*share)/100;
            Transfer_money(investor, value);
        }
        allInvestments[campaign_id].remaining = 0;
    }

}