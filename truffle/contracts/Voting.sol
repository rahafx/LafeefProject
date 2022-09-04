// SPDX-License-Identifier: MIT

pragma solidity ^0.4.0;
//import "./investment.sol";
import "./Campaign.sol";


contract Voting{

    struct Choice{
        uint extend;
        uint close;
    }

    struct Voter{
        address invAddress;
        bool voted;
    }

    mapping(uint => Choice) public choices;
    mapping(address => Voter) public Voters;

    uint votersNum;
    uint result;

    function createCampaign(uint campaign_id) public{
        choices[campaign_id] = Choice(0,0);
    }

    function CampaignVoting(uint campaign_id, uint value) public returns(uint){
        require(!Voters[msg.sender].voted);
        votersNum++;

        if(value == 0){
            choices[campaign_id].extend++;
            if(votersNum > result && choices[campaign_id].extend > choices[campaign_id].close ){
                result = 0;
            }
        }else if(value == 1){
            choices[campaign_id].close++;
            if(votersNum > result && choices[campaign_id].close > choices[campaign_id].extend ){
                result = 1;
            }
        }else{
            //error
        }

    }

    function getVoters(address [] invAddress , uint invnumber) public {
        for(uint i; i<invnumber ; i++){
            Voters[invAddress[i]] = Voter(invAddress[i],false);
        }
        result = invnumber/2;
    }

}
