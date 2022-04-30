const {network}  = require("hardhat")

async function moveTime(amount) {
    console.log("Moving blocks");
    amount =await network.provider.send("evm_increaseTime", [amount])
    console.log(`Moved forward in time ${amount} secods`)
}

module.exports = {
    moveTime,
}