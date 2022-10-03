// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity >=0.7.0 <0.9.0;

import "./Investment.sol";
import "./Voting.sol";

contract Campaign {

    Investment investment = new Investment();
    Voting voting = new Voting();
  /* Milestone */
    enum MState {
      created,
      undervote,
      inprogress,
      completed,
      rejected,
      failed
  }

  struct milestone {
    uint id;
    string name;
    uint fund;
    uint duration;
    MState state;
  }
  mapping(uint => mapping(uint =>  milestone)) public milestones;
  /* mapping(uint => uint ) numberOfmilestones; */

  
  /* Round State */
  enum RoundState {
    Inprogress,
    Success,
    Failed
  }

    /* Campaign State */
  enum CState {
    Inprogress,
    UnderVote,
    Close,
    Failed
  }

  enum Models {
    keep_it_all,
    all_or_nothing
  }

  struct campaign {
    uint id;
    address payable owner;
    uint capital;
    uint shares;
    uint starttime;
    uint deadline1;
    uint deadline2;
    uint minimumInvest;
    Models model;
    uint numberOfmilestones;
    uint currentMilestone;
    CState state;
  }

  mapping (uint => mapping(uint => RoundState)) Rounds;
  mapping (uint => uint) TotalRounds;
  mapping(uint => campaign) campaigns;
  uint campaignnumbers;
  



/* -------------------- from string to uint ---------------------------- */
  function st2num(string memory numString) public pure returns(uint) {
        uint  val=0;
        bytes   memory stringBytes = bytes(numString);
        for (uint  i =  0; i<stringBytes.length; i++) {
            uint exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
           uint jval = uval - uint(0x30);
   
           val +=  (uint(jval) * (10**(exp-1))); 
        }
      return val;
  }

/*-------------------- Transfer fund from contract wallet to owner wallet ---------------------- */
  function Transfer_money(uint campaign_id, uint milestone_id) public {
    uint fund = milestones[campaign_id][milestone_id].fund;
    address payable owner = campaigns[campaign_id].owner;
    owner.transfer(fund);
    investment.updateRemaining(campaign_id, fund);
    m_countDown(campaign_id, milestone_id);
  }

/* ----------------------------------- create campaign ------------------------------------ */
  function createcampaign(uint capital, uint shares, uint deadline1, uint deadline2, uint minimumInvest, uint numberOfmilestones, Models model, string[][] memory milestones) public {
      /* milestones[], */
      addMilestones(numberOfmilestones, milestones);
      uint now = block.timestamp;
      uint dL1 = (deadline1*24*60*60) + now;
      uint dL2 = (deadline2*24*60*60) + dL1;
      campaigns[campaignnumbers] = campaign(campaignnumbers, payable(msg.sender), capital, shares, now, dL1, dL2, minimumInvest, model, numberOfmilestones, 0, CState.Inprogress);
      Rounds[campaignnumbers][0] = RoundState.Inprogress;
      TotalRounds[campaignnumbers] = 0;
      campaignnumbers++;
     c_countDown(campaignnumbers-1, dL1);
  }

/* ----------------------------------- retrieve AllCampaigns ------------------------------------ */
  function RetrieveAll() public view returns (campaign[] memory) {
      campaign[] memory AllCampaigns = new campaign[](campaignnumbers);
        for(uint i=0; i<campaignnumbers; i++){
            campaign memory instance = campaigns[i];
            AllCampaigns[i] = instance;
        }
       return AllCampaigns;
  }
/* ----------------------------------- retrieve OneCampaign ------------------------------------ */
  function RetrieveOne(uint campaign_id) public view returns (campaign memory, bool) {
    bool isInvestor;
    if(investment.checkAddress(campaign_id, msg.sender)){
            isInvestor = true;
    }
    else{
            isInvestor = false;
    }
    return (campaigns[campaign_id], isInvestor);
      /* 1- check round state
         2- if under vote (check if this investor is voted or not)
         3- if success (check milestone state)
         4- if under vote (check if this investor is voted or not) */
  }
        

/* -----------------------------------add and retrieve Milestones------------------------------------ */
  function addMilestones(uint _numberOfmilestones, string[][] memory _milestones) public {
        for(uint i=0; i<_numberOfmilestones; i++) {
            uint fund = st2num(_milestones[i][1]);
            uint duration = st2num(_milestones[i][2]);
            milestones[campaignnumbers][i] = milestone(i, _milestones[i][0], fund, duration, MState.created);
        }
  }

  function RetrieveAllMilestones(uint campaign_id) public view returns (milestone[] memory) {
      uint _nom = campaigns[campaign_id].numberOfmilestones;
      milestone[] memory AllMilestones = new milestone[](_nom);
      for(uint i=0; i<_nom; i++) {
            AllMilestones[i] = milestones[campaign_id][i];
      }
       return AllMilestones;
  }

  function RetrieveOneMilestone(uint campaign_id, uint milestone_id) public view returns (milestone memory, bool) {
    bool isInvestor;
    if(investment.checkAddress(campaign_id, msg.sender)){
            isInvestor = true;
    }
    else{
            isInvestor = false;
    }
      return (milestones[campaign_id][milestone_id], isInvestor);
  }


/* -------------------------------- CountDown ------------------------------- */
  function c_countDown(uint campaign_id, uint DL) public {
    uint now = block.timestamp;
    while(now != DL ){
      now = block.timestamp;
    }
    C_deadline(campaign_id);
  }

  function m_countDown(uint campaign_id, uint milestone_id) public {
    milestones[campaign_id][milestone_id].state = MState.inprogress;
    uint now = block.timestamp;
    uint duration = milestones[campaign_id][milestone_id].duration;
    uint deadline = (duration*24*60*60) + now;

    while(now != deadline){
      now = block.timestamp;
    }

    MS_Deadline(campaign_id, milestone_id);
  }


/* ----------------------------------- Campaign Deadline (updated one) ------------------------------- */
     function C_deadline(uint campaign_id) public {
        /* ------ check total investment from investment contract ------ */
        uint c_capital = investment.retrieveFund(campaign_id);

        /* -------- finding the capital percentage -------- */
        uint total = (c_capital*100)/campaigns[campaign_id].capital;
        
        if(campaigns[campaign_id].capital == c_capital || campaigns[campaign_id].model == Models.keep_it_all && total >= 95){
          campaigns[campaign_id].state = CState.Close;
          if(TotalRounds[campaignnumbers] == 0){
              Rounds[campaignnumbers][0] = RoundState.Success;
              Transfer_money(campaign_id, 0);
           }

          else{
            Rounds[campaignnumbers][1] = RoundState.Success;
            Transfer_money(campaign_id, 0);
           }
        }
        else{
          if(TotalRounds[campaignnumbers] == 0){
              Rounds[campaignnumbers][0] = RoundState.Failed;
              campaigns[campaign_id].state = CState.UnderVote;
              bool result = voting.campaignExtend(campaign_id);

              if(result == true){
                TotalRounds[campaign_id] = 1;
                campaigns[campaign_id].state = CState.Inprogress;
                /* ----- Deadline2 ------ */
                uint deadline = campaigns[campaign_id].deadline2;
                uint now = block.timestamp;
                deadline = deadline + now;
                c_countDown(campaign_id, deadline);
              }
              else{
                investment.returnFund(campaign_id);
                campaigns[campaign_id].state = CState.Failed;
              }
           }

          else{
              investment.returnFund(campaign_id);
              campaigns[campaign_id].state = CState.Failed;
           }
        }
     }
     /* check collected fund
     if(completed or >95%){
          if( round 1){
            1-Round1.state= Success
            2-transfer fund
          }
          else if( round2 ){
            1-Round2.state = success
            2-transfer fund
          }
     }
     else{
          if( round1 ){
            1- Round1.state = failed
            2- voting
                - if true()
                   - TotalRounds[campaignnumbers] = 1;
                   - countdown;
                - if false()
                   -retrieve fund to investors;
          }
          else if(round 2){
            1-round2.state = failed
            2-retrieve fund to investors
          }
     } */

/* ----------------------------------- Milestone Deadline ------------------------------- */
  function MS_Deadline(uint campaign_id, uint milestone_id) public {

    /* if it's last milestone*/
    if((milestone_id+1) == campaigns[campaign_id].numberOfmilestones){
      campaigns[campaign_id].state = CState.Close;
    }

    else{

      if(milestones[campaign_id][milestone_id].state == MState.completed){
        uint next_MS = milestone_id+1;
        milestones[campaign_id][next_MS].state = MState.undervote;
        bool result = voting.nextMilestone(campaign_id, next_MS);
        if(result == true) {
            /* transfer next milestone fund */
            Transfer_money(campaign_id, milestone_id);
        }
        else {
           /* return fund 2 investors*/
            milestones[campaign_id][next_MS].state = MState.rejected;
           investment.returnFund(campaign_id);
        }
    }

    else {
      milestones[campaign_id][milestone_id].state = MState.failed;
      investment.returnFund(campaign_id);
    }
    }
    
  }

/* -------------------------------- update milestone state (complete) => (from frontend)------------------------------- */
  function ms_complete(uint campaign_id, uint milestone_id) public {
    milestones[campaign_id][milestone_id].state = MState.completed;
  }

/* -------------------------- Extend milestone => (from frontend) ---------------------------- */
  function ms_extend(uint campaign_id, uint milestone_id, uint _addT) public {
    milestones[campaign_id][milestone_id].state = MState.undervote;
      bool result = voting(campaign_id, milestone_id, _addT);
      if (result == true) {
          uint addT = (_addT*24*60*60);
          uint count = campaigns[campaign_id].numberOfmilestones;

          for(uint i = milestone_id; i < count; i++) {
            milestones[campaign_id][milestone_id].duration = (milestones[campaign_id][milestone_id].duration + addT);
          }
      }
      else if(result == false){
        milestones[campaign_id][milestone_id].state = MState.failed;
        investment.returnFund(campaign_id);

      }
  }













/* -------------------------- Update milestones funds (keep_it_all) ---------------------------- */
  function updateMilestonesFund(uint campaign_id) public {
      /* - 5% from every milestone fund  */
      uint count = campaigns[campaign_id].numberOfmilestones;
      for(uint i=0; i< count; i++){
          uint fund = milestones[campaign_id][i].fund;
          uint perc = (fund*5)/100;
          fund = fund - perc;
          milestones[campaign_id][i].fund = fund;
      }
  }

/* 2000, 20, 30, 40, 100, 2, [["first", "150", "20"],["second", "200", "30"]] */
}