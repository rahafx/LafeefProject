// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Investment {

    struct invest{
        mapping(uint => address) investors;
        mapping(uint => uint) funds;
        uint collected_fund;
        uint remaining;
        uint numberOfInvestors;
    }
    mapping(uint => invest) Investments;


/* --------------------- from investors to contract --------------------- */
    function deposit(uint campaign_id, uint fund) public payable {
        createinvest(campaign_id, msg.sender, fund);
    }
/* ------------------ from contract wallet to investors ----------------- */
    function Transfer_money(address payable investor, uint fund) public {
    investor.transfer(fund);
  }
/* ------------------- add and retrieve investments information ------------------------- */
    function createinvest(uint campaign_id, address investor, uint fund) public {
        uint count = Investments[campaign_id].numberOfInvestors;
        Investments[campaign_id].investors[count] = investor;
        Investments[campaign_id].funds[count] = fund;
        Investments[campaign_id].collected_fund += fund;
        Investments[campaign_id].remaining = Investments[campaign_id].collected_fund;
        Investments[campaign_id].numberOfInvestors++;
    }

    function retrieveInvestors(uint campaign_id) public view returns(uint, address[] memory, uint[] memory){
        uint count = Investments[campaign_id].numberOfInvestors;
        address[] memory investors;
        uint[] memory funds;
        for(uint i=0; i<count; i++){
            investors[i]=Investments[campaign_id].investors[i];
            funds[i]=Investments[campaign_id].funds[i];
        }
        return (count, investors, funds);
    }

    function retrieveFund(uint campaign_id) public view returns(uint){
        return Investments[campaign_id].collected_fund;

    }
    function updateRemaining(uint campaign_id, uint fund) public {
        Investments[campaign_id].remaining = Investments[campaign_id].remaining - fund;
    }
/*  --------------------- from contract to investors --------------------- */
    function returnFund(uint campaign_id) public payable {

        uint count = Investments[campaign_id].numberOfInvestors;
        uint capital = Investments[campaign_id].collected_fund;
        uint remaining = Investments[campaign_id].remaining;

        address investor;
        uint fund;
        uint share;
        uint value;
        for(uint i=0; i<count; i++){
            investor = Investments[campaign_id].investors[i];
            fund = Investments[campaign_id].funds[i];
            share = (fund*100)/capital;
            value = (remaining*share)/100;
        }
        Investments[campaign_id].remaining = 0;
    }

}