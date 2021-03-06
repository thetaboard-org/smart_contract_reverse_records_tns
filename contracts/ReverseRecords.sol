pragma solidity >=0.8.4;
pragma experimental ABIEncoderV2;

import "./Namehash.sol";
import './interfaces/ENS.sol';
import './ReverseRegistrar.sol';
import './interfaces/Resolver.sol';

contract ReverseRecords {
    ENS ens;
    ReverseRegistrar registrar;
    bytes32 private constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    /**
     * The `constructor` takes ENS registry address
     */
    constructor(ENS _ens) {
        ens = _ens;
        registrar = ReverseRegistrar(ens.owner(ADDR_REVERSE_NODE));
    }

    function node(address addr) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr)));
    }

    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
        addr;
        ret; // Stop warning us about unused variables
        assembly {
            let lookup := 0x3031323334353637383961626364656600000000000000000000000000000000

            for { let i := 40 } gt(i, 0) { } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }

    /**
     * Read only function to return ens name only if both forward and reverse resolution are set     *
     */
    function getNames(address[] calldata addresses, string memory extension) external view returns (string[] memory r) {
        r = new string[](addresses.length);
        for(uint i = 0; i < addresses.length; i++) {
            bytes32 nodeAddr = node(addresses[i]);
            address resolverAddress = ens.resolver(nodeAddr);
            if(resolverAddress != address(0x0)){
                Resolver resolver = Resolver(resolverAddress);
                string memory name = resolver.name(nodeAddr);
                if(bytes(name).length == 0 ){
                    continue;
                }
                string memory fullName = string(bytes.concat(bytes(name), ".", bytes(extension)));
                bytes32 namehash = Namehash.namehash(fullName);
                address forwardResolverAddress = ens.resolver(namehash);
                if(forwardResolverAddress != address(0x0)){
                    Resolver forwardResolver = Resolver(forwardResolverAddress);
                    address forwardAddress = forwardResolver.addr(namehash);
                    if(forwardAddress == addresses[i]){
                        r[i] = string(bytes.concat(bytes(name), ".", bytes(extension)));
                    }
                }
            }
        }
        return r;
    }
}