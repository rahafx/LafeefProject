// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
import "./Investment.sol";
import "./Campaign.sol";


contract Voting{

    struct Voter{
        address invAddress;
        bool voted;
    }

    struct result{
        uint c_id;
        uint votingResult;
        uint votedYes;
        uint votedNo;
    }

    Campaign campaigns = new Campaign();
    Investment investment = new Investment();
    mapping(uint => mapping(address => Voter)) public C_voters;
    mapping(uint => mapping(uint => mapping(address => Voter))) public M_voters;
    mapping(uint => result) C_result;
    mapping(uint => mapping(uint => result)) M_result;

    uint campaignnumbers = campaigns.campaignnumbers();
    uint investrsnumber;



    function campaign_extend(uint campign_id , uint value) public{
        getVoters(campign_id);
        require(!C_voters[campign_id][msg.sender].voted);

        if(value == 1){
            C_result[campign_id].votedYes++;
        }

        C_result[campign_id].votingResult++;
    }

    function milestone_extend(uint campaign_id, uint milestone_id, uint value) public{
        getVoters(campaign_id , milestone_id);
        require(!M_voters[campaign_id][milestone_id][msg.sender].voted);

        if(value == 1){
            M_result[campaign_id][milestone_id].votedYes++;
        }

        M_result[campaign_id][milestone_id].votingResult++;
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


    function c_countDown(uint campaign_id, uint DL) view public returns(bool) {
        uint timeNow = block.timestamp;
        uint finalResult = C_result[campaign_id].votingResult;

        while(timeNow != DL  || finalResult != investrsnumber){
            timeNow = block.timestamp;
        }

        return true;
    
    }

    function m_countDown(uint campaign_id, uint milestone_id, uint DL) view public returns(bool) {
        uint timeNow = block.timestamp;
        uint finalResult = M_result[campaign_id][milestone_id].votingResult;

        while(timeNow != DL  || finalResult != investrsnumber){
            timeNow = block.timestamp;
        }

        return true;
    
    }

}