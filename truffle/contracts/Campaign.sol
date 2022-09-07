// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity >=0.7.0 <0.9.0;

/* import "./Investment.sol"; */

contract Campaign {
  
  /* Milestone */
    enum MState {
    created,
    inprogress,
    extend,
    completed
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
    Close,
    Failed
  }

  enum Models{
    keep_it_all, /*if >= 95% */
    all_or_nothing
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
    Models model;
    uint numberOfmilestones;
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
    /* transfer fund from contract wallet to owner wallet*/
    
    /* m_countDown(campaign_id, milestone_id); */
  }


/*-------------------- Return fund 2 investors ---------------------- */
  function retrievrFund() public{
     /* retriveAllInvestors(campaign_id);  from investment contract */
  }



/* -----------------------------------create and retrieve Campaign------------------------------------ */
  function createcampaign(uint capital, uint shares, uint deadline1, uint deadline2, uint minimumInvest, uint numberOfmilestones, Models model, string[][] memory milestones) public {
      /* milestones[], */
      addMilestones(numberOfmilestones, milestones);
      uint now = block.timestamp;
      uint dL1 = (deadline1*24*60*60) + now;
      uint dL2 = (deadline2*24*60*60) + dL1;
      campaigns[campaignnumbers] = campaign(campaignnumbers, msg.sender, capital, shares, now, dL1, dL2, minimumInvest, model, numberOfmilestones, CState.Inprogress);
      Rounds[campaignnumbers][0] = RoundState.Inprogress;
      TotalRounds[campaignnumbers] = 0;
      campaignnumbers++;
     /* c_countDown(campaignnumbers-1, dL1); */
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

  function RetrieveOneMilestone(uint campaign_id, uint milestone_id) public view returns (milestone memory) {
      return milestones[campaign_id][milestone_id];
  }


/*-------------------------------- CountDown ------------------------------- */
  function c_countDown(uint campaign_id, uint DL) public {
    uint now = block.timestamp;
    while(now != DL ){
      now = block.timestamp;
    }
    C_deadline1(campaign_id);
  }

  function m_countDown(uint campaign_id, uint milestone_id) public {
    milestones[campaign_id][milestone_id].state = MState.inprogress;
    uint now = block.timestamp ;
    uint duration = milestones[campaign_id][milestone_id].duration;
    uint deadline = (duration*24*60*60) + now;

    while(now != deadline){
      now = block.timestamp;
    }

    MS_Deadline(campaign_id, milestone_id);
  }


/* ----------------------------------- Campaign Deadline ------------------------------- */
  function C_deadline1(uint campaign_id) public {
     /* ------ check total investment from investment contract ------ */
    uint c_capital = 1500;

      /* -------- finding the capital percentage -------- */
    uint total = (c_capital*100)/campaigns[campaign_id].capital;

    if (campaigns[campaign_id].capital == c_capital) {  /* Transfer_money(campaign_id, 0); */
        Rounds[campaignnumbers][0] = RoundState.Success;
        m_countDown(campaign_id, 0);
    }

    else if (campaigns[campaign_id].model == Models.keep_it_all && total >= 95){  /* Transfer_money(campaign_id, 0); */
        Rounds[campaignnumbers][0] = RoundState.Success;
        updateMilestonesFund(campaign_id);
        m_countDown(campaign_id, 0);
    }

    else {  /* call campaign voting from voting contract */
        Rounds[campaignnumbers][0] = RoundState.Failed;

        if(TotalRounds[campaignnumbers] == 0){

          TotalRounds[campaignnumbers] = 1;
          string memory result = ""; /* voting(campain_id, deadline2); */

          if(keccak256(bytes(result)) == keccak256(bytes("extend"))){
            Rounds[campaignnumbers][1] = RoundState.Inprogress;
            c_countDown(campaign_id, (campaigns[campaign_id].deadline2));
          }
          else {
            Rounds[campaignnumbers][1] = RoundState.Failed;
            campaigns[campaign_id].state = CState.Failed;
            /* transfer money from contracts to investors */
          }
        }
    }
  }

/* ----------------------------------- Milestone Deadline ------------------------------- */
  function MS_Deadline(uint campaign_id, uint milestone_id) public {
    /* if it's last milestone close campaign */
    bool result; /*voting(campaign_id, milestone_id, milestones[campaign_id][milestone_id].state) */

    if(result == true){
     /* transfer next milestone fund */
    }
    else {
     /* return fund 2 investors*/
    }
  }

/* -------------------------------- update milestone state (complete or extend) ------------------------------- */
  function updateState(uint campaign_id, uint milestone_id, MState _state) public {
      /* if it's not updated to complete or extend it will be closed */
    milestones[campaign_id][milestone_id].state = _state;
  }

/* -------------------------- Extend milestone ---------------------------- */
  function extendMS(uint campaign_id, uint milestone_id, uint _addT) public {
      bool result = voting(campaign_id, milestone_id, _addT);

      if (result == true) {
          milestones[campaign_id][milestone_id].state = MState.extend;
          uint addT = (_addT*24*60*60);
          uint count = campaigns[campaign_id].numberOfmilestones;

          for(uint i = milestone_id; i < count; i++) {
            milestones[campaign_id][milestone_id].duration = (milestones[campaign_id][milestone_id].duration + addT);
          }
      }
  }


/* -------------------------- Update milestones funds keep_it_all  ---------------------------- */
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