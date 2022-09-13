// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
import "./Investment.sol";
import "./Campaign.sol";


contract Voting{

    struct Voter{
        address invAddress;
        bool voted;
    }

    Campaign campaigns = new Campaign();
    Investment investment = new Investment();
    mapping(uint => mapping(address => Voter)) public C_voters;
    mapping(uint => mapping(uint => mapping(address => Voter))) public M_voters;
    uint campaignnumbers = campaigns.campaignnumbers();
    uint investrsnumber;


    function campaign_extend(uint campign_id , uint value) public returns(bool){
        uint voteYes;
        bool result;
        getVoters(campign_id);
        require(!C_voters[campign_id][msg.sender].voted);
        if(value == 1){
            voteYes++;
            if(voteYes > (investrsnumber/2)){
                result= true;
            }
        }else{
            // error or a message with not completed yet
        }

        return result;
    }

    function milestone_extend(uint campaign_id, uint milestone_id, uint value) public returns(bool){
        uint voteYes;
        bool result;
        getVoters(campaign_id , milestone_id);
        require(!M_voters[campaign_id][milestone_id][msg.sender].voted);
        if(value == 1){
            voteYes++;
            if(voteYes > (investrsnumber/2)){
                result= true;
            }
        }else{
            // error or a message with not completed yet
        }

        return result;
    }

    function next_milestone(uint campaign_id, uint milestone_id) public returns(string memory){

    }



    function getVoters(uint campaign_id) public{
        uint count; address[] memory investors; uint[] memory funds;
        (count , investors, funds) = investment.retrieveInvestors(campaign_id);
        investrsnumber = count;

        for(uint i=0 ; i<investrsnumber ; i++){
            C_voters[campaign_id][investors[i]] = Voter(investors[i] , false);
        }

    }

    function getVoters(uint campaign_id, uint milestone_id) public{
        uint count; address[] memory investors; uint[] memory funds;
        (count , investors, funds) = investment.retrieveInvestors(campaign_id);
        investrsnumber = count;

        for(uint i=0 ; i<investrsnumber ; i++){
            M_voters[campaign_id][milestone_id][investors[i]] = Voter(investors[i] , false);
        }

    }




    // struct Choice{
    //     uint extend;
    //     uint close;
    // }

    // struct Voter{
    //     address invAddress;
    //     bool voted;
    // }

    // mapping(uint => Choice) public choices;
    // mapping(address => Voter) public Voters;

    // uint votersNum;
    // uint result;

    // function createCampaign(uint campaign_id) public{
    //     choices[campaign_id] = Choice(0,0);
    // }

    // function CampaignVoting(uint campaign_id, uint value) public returns(uint){
    //     require(!Voters[msg.sender].voted);
    //     votersNum++;

    //     if(value == 0){
    //         choices[campaign_id].extend++;
    //         if(votersNum > result && choices[campaign_id].extend > choices[campaign_id].close ){
    //             result = 0;
    //         }
    //     }else if(value == 1){
    //         choices[campaign_id].close++;
    //         if(votersNum > result && choices[campaign_id].close > choices[campaign_id].extend ){
    //             result = 1;
    //         }
    //     }else{
    //         //error
    //     }

    // }

    // function getVoters(address [] invAddress , uint invnumber) public {
    //     for(uint i; i<invnumber ; i++){
    //         Voters[invAddress[i]] = Voter(invAddress[i],false);
    //     }
    //     result = invnumber/2;
    // }

}