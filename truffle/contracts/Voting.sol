// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
import "./Investment.sol";
import "./Campaign.sol";


contract Voting is Investment{

    struct Vote{
        uint c_id;
        address [] invAddress;
        uint votingNum;
        uint votedYes;
        uint percent;
        uint DL;
    }


    mapping(uint => Vote) public campaignExtend;
    mapping(uint => mapping(uint => Vote)) public milestoneExtend;
    mapping(uint => mapping(uint => Vote)) public nextMilestone;
    
  
    function campaign_extend(uint campign_id , bool value) public{
        require(checkAddress(campign_id, msg.sender));
        require(!c_findAddress(campign_id, msg.sender));//check if the sender did voted or not

        campaignExtend[campign_id].votingNum++;

        if(!C_countDown(campign_id)){
            if(value == true){// or msg.value == 0
                campaignExtend[campign_id].invAddress[campaignExtend[campign_id].votingNum] = msg.sender;
                campaignExtend[campign_id].votedYes++;
                campaignExtend[campign_id].percent =
                 (campaignExtend[campign_id].votedYes + campaignExtend[campign_id].votingNum ) /100;
            }
        }
    }


    function milestone_extend(uint campaign_id, uint milestone_id, bool value) public{
        require(checkAddress(campaign_id, msg.sender));
        require(!EM_findAddress(campaign_id, milestone_id, msg.sender));

        milestoneExtend[campaign_id][milestone_id].votingNum++;

        if(!EM_countDown(campaign_id, milestone_id)){
            if(value == true){// or msg.value == 0
                milestoneExtend[campaign_id][milestone_id].invAddress[milestoneExtend[campaign_id][milestone_id].votingNum] = msg.sender;
                milestoneExtend[campaign_id][milestone_id].votedYes++;
                milestoneExtend[campaign_id][milestone_id].percent =
                 (milestoneExtend[campaign_id][milestone_id].votedYes + milestoneExtend[campaign_id][milestone_id].votingNum ) /100;
            }
        }
    }

    function next_milestone(uint campaign_id, uint milestone_id, bool value) public{
        require(checkAddress(campaign_id, msg.sender));
        require(!NM_findAddress(campaign_id, milestone_id, msg.sender));

        nextMilestone[campaign_id][milestone_id].votingNum++;

        if(!NM_countDown(campaign_id, milestone_id)){
            if(value == true){// or msg.value == 0
                nextMilestone[campaign_id][milestone_id].invAddress[nextMilestone[campaign_id][milestone_id].votingNum] = msg.sender;
                nextMilestone[campaign_id][milestone_id].votedYes++;
                nextMilestone[campaign_id][milestone_id].percent =
                 (nextMilestone[campaign_id][milestone_id].votedYes + nextMilestone[campaign_id][milestone_id].votingNum ) /100;
            }
        }
        
    }

    function C_countDown(uint id) public returns(bool) {
            uint timeNow = block.timestamp;
            campaignExtend[id].DL = (5 *24 * 60 * 60) + timeNow;

            if(timeNow != campaignExtend[id].DL){
                timeNow = block.timestamp; 
                return false;
            }
            return true;
        }

    function EM_countDown(uint c_id, uint m_id) public returns(bool) {
            uint timeNow = block.timestamp;
            milestoneExtend[c_id][m_id].DL =(5 *24 * 60 * 60)  + timeNow;

            if(timeNow != milestoneExtend[c_id][m_id].DL){
                timeNow = block.timestamp;
                return false; 
            }
            return true;
    }

    function NM_countDown(uint c_id, uint m_id) public returns(bool) {
            uint timeNow = block.timestamp;
            nextMilestone[c_id][m_id].DL = (5 *24 * 60 * 60)  + timeNow;

            if(timeNow != nextMilestone[c_id][m_id].DL){
                timeNow = block.timestamp;
                return false; 
            }
            return true;
    }

    function c_findAddress(uint c_id, address sender) view public returns(bool){
        uint votersNum = campaignExtend[c_id].votingNum;

        for(uint i =0 ; i< votersNum; i++){
            if(campaignExtend[c_id].invAddress[i] == sender){
                return true;
            }
        }
        return false;
    } 

    function EM_findAddress(uint c_id, uint m_id, address sender) view public returns(bool){
        uint votersNum = milestoneExtend[c_id][m_id].votingNum;

        for(uint i =0 ; i< votersNum; i++){
            if(milestoneExtend[c_id][m_id].invAddress[i] == sender){
                return true;
            }
        }
        return false;
    } 

    function NM_findAddress(uint c_id, uint m_id, address sender) view public returns(bool){
        uint votersNum = nextMilestone[c_id][m_id].votingNum;

        for(uint i =0 ; i< votersNum; i++){
            if(nextMilestone[c_id][m_id].invAddress[i] == sender){
                return true;
            }
        }
        return false;
    } 

}

