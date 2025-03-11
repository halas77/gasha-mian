// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract InsurancePolicy is Ownable {
    uint256 private nextPolicyId;

    ///////////////
    //// ENUMS ////
    ///////////////

    enum PolicyStatus {
        Active,
        Expired,
        Canceled
    }

    /////////////////
    //// Structs ////
    /////////////////

    struct Policy {
        uint256 policyId;
        address holder;
        uint256 premium;
        uint256 coverageAmount;
        uint256 startDate;
        uint256 endDate;
        PolicyStatus status;
    }

    ////////////////
    //// Errors ////
    ////////////////

    error InsurancePolicy__InvalidAddress();
    error InsurancePolicy__InvalidParameter();
    error InsurancePolicy__PolicyNotExsit();

    //////////////////
    //// Mappings ////
    //////////////////

    mapping(uint256 => Policy) public policies;
    mapping(address => uint256[]) public userPolicies;

    ///////////////////
    //// Modifiers ////
    ///////////////////

    modifier onlyValidAddress(address _holder) {
        if (_holder == address(0)) {
            revert InsurancePolicy__InvalidAddress();
        }

        _;
    }

    modifier IsPolicyExist(uint256 _policyId) {
        if (policies[_policyId].policyId == 0) {
            revert InsurancePolicy__PolicyNotExsit();
        }
        _;
    }

    /////////////////////
    //// Constructor ////
    /////////////////////

    constructor() Ownable(msg.sender) {
        nextPolicyId = 1;
    }

    ////////////////////////////
    //// External Functions ////
    ////////////////////////////

    function createPolicy(
        address _holder,
        uint256 _premium,
        uint256 _coverageAmount,
        uint256 _duration
    ) external onlyValidAddress(_holder) {
        if (_premium < 0 || _coverageAmount < 0 || _duration < 0) {
            revert InsurancePolicy__InvalidParameter();
        }

        uint256 policyId = nextPolicyId;
        nextPolicyId++;

        policies[policyId] = Policy({
            policyId: policyId,
            holder: _holder,
            premium: _premium,
            coverageAmount: _coverageAmount,
            startDate: block.timestamp,
            endDate: block.timestamp + (_duration * 1 days),
            status: PolicyStatus.Active
        });

        userPolicies[_holder].push(policyId);
    }

    function updatePolicy(
        uint256 _policyId,
        PolicyStatus _status
    ) external IsPolicyExist(_policyId) onlyOwner {
        policies[_policyId].status = _status;
    }

    function getPolicy(
        uint256 _policyId
    ) external view IsPolicyExist(_policyId) returns (Policy memory) {
        return policies[_policyId];
    }

    function getUserPolicies(
        address _holder
    ) external view onlyValidAddress(_holder) returns (uint256[] memory) {
        return userPolicies[_holder];
    }
}
