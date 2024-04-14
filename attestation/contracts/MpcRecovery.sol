// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { ISP } from "@ethsign/sign-protocol-evm/src/interfaces/ISP.sol";
import { Attestation } from "@ethsign/sign-protocol-evm/src/models/Attestation.sol";
import { DataLocation } from "@ethsign/sign-protocol-evm/src/models/DataLocation.sol";

contract MpcRecovery is Ownable {
    ISP public spInstance;
    uint64 public schemaId;

    mapping(address recipient => uint64 attestationId) private mpcAccountAttestations;

    constructor() Ownable(_msgSender()) { }

    function setSPInstance(address instance) external onlyOwner {
        spInstance = ISP(instance);
    }

    function setSchemaID(uint64 schemaId_) external onlyOwner {
        schemaId = schemaId_;
    }

    function claimMPCAccount(bytes32 _hash, bytes memory _signature) public view returns (bool) {
        address signer = ECDSA.recover(_hash, _signature);
        if(signer != msg.sender) {
            revert("Signature does not match message sender");
        } 

        return mpcAccountAttestations[signer] != 0;
    }


    function attestMPCAccount(address recipient, bytes memory data) external {
    
         bytes[] memory recipients = new bytes[](1);
            recipients[0] = abi.encode(recipient);

            Attestation memory a = Attestation({
                schemaId: schemaId,
                linkedAttestationId: 0,
                attestTimestamp: 0,
                revokeTimestamp: 0,
                attester: address(this),
                validUntil: 0,
                dataLocation: DataLocation.ONCHAIN,
                revoked: false,
                recipients: recipients,
                data: data 
            });

            uint64 attestationId = spInstance.attest(a, "", "", "");
            mpcAccountAttestations[recipient] = attestationId;
    }
}