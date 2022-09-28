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
    mapping(uint => result) C_result;
    mapping(uint => mapping(uint => mapping(address => Voter))) public NM_voters;
    mapping(uint => mapping(uint => mapping(address => Voter))) public EM_voters;
    mapping(uint => mapping(uint => result)) EM_result;
    mapping(uint => mapping(uint => result)) NM_result;

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


    function milestone_voting(uint campaign_id, uint milestone_id, uint votingValue, uint milestoneValue , uint DL) public{
            while(m_countDown(campaign_id, milestone_id, DL)){
                if(milestoneValue == 0){
                    require(!EM_voters[campaign_id][milestone_id][msg.sender].voted);

                    if(votingValue == 1){
                        EM_result[campaign_id][milestone_id].votedYes;
                    }

                    EM_result[campaign_id][milestone_id].votingResult++;
                    EM_voters[campaign_id][milestone_id][msg.sender].voted = true;

                }else if(milestoneValue == 1){
                    require(!NM_voters[campaign_id][milestone_id][msg.sender].voted);

                    if(votingValue == 1){
                        NM_result[campaign_id][milestone_id].votedYes++;
                    }

                    NM_result[campaign_id][milestone_id].votingResult++;
                    NM_voters[campaign_id][milestone_id][msg.sender].voted = true;
                }

        }
        
        
    }


    function getVoters(uint campaign_id) public{
        uint count; address[] memory investors; uint[] memory funds;
        (count , investors, funds) = investment.retrieveInvestors(campaign_id);
        investrsnumber = count;

        for(uint i=0 ; i<investrsnumber ; i++){
            C_voters[campaign_id][investors[i]] = Voter(investors[i] , false);
        }

    }

    function getVoters(uint campaign_id, uint milestone_id , uint value) public{
        uint count; address[] memory investors; uint[] memory funds;
        (count , investors, funds) = investment.retrieveInvestors(campaign_id);
        investrsnumber = count;
        if(value == 0 ){
            for(uint i=0 ; i<investrsnumber ; i++){
                EM_voters[campaign_id][milestone_id][investors[i]] = Voter(investors[i] , false);
         }

        }else if(value == 1 ){
            for(uint i=0 ; i<investrsnumber ; i++){
                NM_voters[campaign_id][milestone_id][investors[i]] = Voter(investors[i] , false);
         }

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
        uint finalResultNM = NM_result[campaign_id][milestone_id].votingResult;
        uint finalResultEM = EM_result[campaign_id][milestone_id].votingResult;

        while(timeNow != DL  || finalResultNM != investrsnumber || finalResultEM != investrsnumber){
            timeNow = block.timestamp;
        }

        return true;
    
    }

    function startMilestoneVoting(uint campaign_id, uint milestone_id , uint value, uint DL) public returns(bool){
        getVoters(campaign_id , milestone_id, value);

        return m_countDown(campaign_id,milestone_id,DL);
    }

    function startCampaignVoting(uint campaign_id, uint DL) public returns(bool){
        getVoters(campaign_id);

        return c_countDown( campaign_id,  DL);
    }


}



