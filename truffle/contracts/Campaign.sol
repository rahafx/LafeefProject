// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity ^0.4.0;
import "./investment.sol";
import "./voting.sol";


contract Campaign {
  
  /* Milestone */
    enum MState {
    created,
    inprogress,
    completed
  }

  struct milestone {
    uint id;
    string name;
    string fund;
    MState state;
  }
  mapping(uint => mapping(uint =>  milestone)) public milestones;
  mapping(uint => uint ) numberOfmilestones;


  /* Campaign */
  enum CState { 
    Inprogress,
    Success, 
    Extend,
    Close
  }

  struct campaign {
    uint id;
    address owner;
    uint capital;
    uint shares;
    uint starttime;
    uint deadline1;
    uint deadline2;
    uint minimumInvest;
    CState state;
  }

  mapping(uint => campaign) campaigns;
  uint campaignnumbers;

  function createcampaign(uint capital, uint shares, uint deadline1, uint deadline2, uint minimumInvest, uint numberOfmilestones, string[][] memory milestones) public {
      /* milestones[], */
      addMilestones(numberOfmilestones, milestones);
      uint sT = block.timestamp;
      uint dL1 = (deadline1*24*60*60) + sT;
      uint dL2 = (deadline2*24*60*60) + dL1;
      campaigns[campaignnumbers] = campaign(campaignnumbers, msg.sender, capital, shares, sT, dL1, dL2, minimumInvest, CState.Inprogress);
      campaignnumbers++;
      c_countDown(campaignnumbers-1, dL1);
  }

  function addMilestones(uint _numberOfmilestones, string[][] memory _milestones) public {
        numberOfmilestones[campaignnumbers] = _numberOfmilestones;
        for(uint i=0; i<_numberOfmilestones; i++) {
          for(uint j=0; j<2; j++){
            milestones[campaignnumbers][i] = milestone(i, _milestones[i][j], _milestones[i][j], MState.created);
          }
        }
  }

  function RetrieveAllMilestones(uint campaign_id) public view returns (milestone[] memory) {
      uint _nom = numberOfmilestones[campaign_id];
      milestone[] memory AllMilestones = new milestone[](_nom);
      for(uint i=0; i<_nom; i++) {
            AllMilestones[i] = milestones[campaign_id][i];
      }
       return AllMilestones;
  }

  function RetrieveOneMilestone(uint campaign_id, uint milestone_id) public view returns (milestone memory) {
      return milestones[campaign_id][milestone_id];
  }

  function RetrieveAll() public view returns (campaign[] memory) {
      campaign[] memory AllCampaigns = new campaign[](campaignnumbers);
        for(uint i=0; i<campaignnumbers; i++){
            campaign memory instance = campaigns[i];
            AllCampaigns[i] = instance;
        }
       return AllCampaigns;
  }

  function RetrieveOne(uint campaign_id) public view returns (campaign memory) {
      return campaigns[campaign_id];
  }

  function c_countDown(uint campaign_id, uint DL) public {
    uint now = block.timestamp;
    while(now != DL){
      now = block.timestamp ;
    }
    deadline1(campaign_id);
  }

  function deadline1(uint campaign_id) public {
    /* checkcapital from investment contract */
    uint c_capital = getInvest(campaign_id); 

    /*if success*/
    if (campaigns[campaign_id].capital == c_capital){
      Transfer_money();
    }

    /*if faild*/
    else {
      /* call campaign voting from voting contract */
    }
  }

  function Transfer_money(uint fund) public {
  } 

}