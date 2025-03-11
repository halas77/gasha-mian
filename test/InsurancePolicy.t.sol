// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {InsurancePolicy, Policy, PolicyStatus} from "../src/InsurancePolicy.sol";

contract InsurancyPolicy is Test {
    InsurancePolicy policyContract;
    address owner;
    address user1;
    address user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x123);
        user2 = address(0x456);

        policyContract = new InsurancePolicy();
    }

    function testCreatePolicy() public {
        uint256 premium = 1 ether;
        uint256 coverage = 10 ether;
        uint256 duration = 30 days;

        policyContract.createPolicy(user1, premium, coverage, duration);

        Policy memory policyOne = policyContract.getPolicy(1);

        assertEq(policyOne.policyId, 1, "Policy ID should match");
        assertEq(policyOne.holder, user1, "Holder address should match");
        assertEq(policyOne.premium, premium, "Premium should be 1 ether");
        assertEq(
            policyOne.coverageAmount,
            coverage,
            "Coverage should be 10 ether"
        );
        assertEq(
            policyOne.startDate,
            block.timestamp,
            "Expiry should be in the future"
        );
        assertEq(
            uint(policyOne.status),
            uint(PolicyStatus.Active),
            "Status should be Active"
        );
    }

    function testUpdatePolicy() public {
        policyContract.createPolicy(user1, 1 ether, 10 ether, 30 days);

        policyContract.updatePolicy(1, PolicyStatus.Expired);

        Policy memory policyOne = policyContract.getPolicy(1);

        assertEq(
            uint8(policyOne.status),
            uint8(PolicyStatus.Expired),
            "Policy status must be the same."
        );
    }

    function testGetUserPolicies() public {
        policyContract.createPolicy(user1, 1 ether, 10 ether, 30 days);
        policyContract.createPolicy(user1, 2 ether, 20 ether, 60 days);

        uint256[] memory userPolicies = policyContract.getUserPolicies(user1);

        assertEq(userPolicies.length, 2, "User should have 2 policies.");
    }
}
