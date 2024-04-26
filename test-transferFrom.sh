#!/bin/bash
set -e

rpc="https://earpc.apothem.network/"

if [ -f .env ]; then
  export $(cat .env | sed '/^\s*#/d' | xargs)
fi

if [[ "${#key1}" != 66 ]]; then
  echo "Please set private key1 for address ${address1}: export key1=<PRIVATE_KEY>"
  exit 1
fi

if [[ "${#key1}" != 66 ]]; then
  echo "Please set private key2 for address ${address2}: export key2=<PRIVATE_KEY>"
  exit 2
fi

address1=$(cast wallet address --private-key ${key1})
address2=$(cast wallet address --private-key ${key2})
address3=${address3:-0x77Cb85AE0aE070DfC013BA1a5b3EE1CED4A059a7}
fiat_token=${fiat_token:-0xcCd3FCaE5f5f93D32480a67537c757a7f356fC56}

echo "rpc = ${rpc}"
echo "address1 = ${address1}"
echo "address2 = ${address2}"
echo "address3 = ${address3}"
echo "fiat_token = ${fiat_token}"
echo

# print balance before transfer
for address in ${address1} ${address2} ${address3}; do
  balance=$(cast call --rpc-url ${rpc} ${fiat_token} "balanceOf(address)(uint256)" ${address})
  echo "balanceOf(${address}) = ${balance}"
done
echo

# transfer 100000 from address1 to address2
amount=100000
echo "${address1} transfer ${amount} from ${address1} to ${address2}"
for address in ${address1} ${address2} ${address3}; do
  balance=$(cast call --rpc-url ${rpc} ${fiat_token} "balanceOf(address)(uint256)" ${address})
  echo "balanceOf(${address}) = ${balance}"
done

# print allowance before approve
allowance=$(cast call --rpc-url ${rpc} ${fiat_token} "allowance(address,address)(uint256)" ${address1} ${address2})
echo "old allowance(${address1}, ${address2}) = ${allowance}"
echo

# address1 approve address2 with allowance 100000
allowance=100000
echo "${address1} set allowance of ${address2} to ${allowance}"
cast send --legacy --rpc-url ${rpc} --private-key ${key1} ${fiat_token} "approve(address,uint256)" ${address2} ${allowance}

# print allowance after approve
echo
echo
allowance=$(cast call --rpc-url ${rpc} ${fiat_token} "allowance(address,address)(uint256)" ${address1} ${address2})
echo "new allowance(${address1}, ${address2}) = ${allowance}"
echo

# address2 transfer 10000 from address1 to address3
amount=10000
echo "${address1} transfer ${amount} from ${address1} to ${address3}"
cast send --legacy --rpc-url ${rpc} --private-key ${key2} ${fiat_token} "transferFrom(address,address,uint256)" ${address1} ${address3} ${amount}

# print balance after transfer
echo
echo
for address in ${address1} ${address2} ${address3}; do
  balance=$(cast call --rpc-url ${rpc} ${fiat_token} "balanceOf(address)(uint256)" ${address})
  echo "balanceOf(${address}) = ${balance}"
done
