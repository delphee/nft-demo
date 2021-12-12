from scripts.helpful_scripts import (
    get_account,
    OPENSEA_URL,
    get_contract,
    fund_with_link,
)
from brownie import AdvancedCollectible, network, config


def deploy_and_create():
    account = get_account()
    advanced_collectible = AdvancedCollectible.deploy(
        get_contract("vrf_coordinator"),
        get_contract("link_token"),
        config["networks"][network.show_active()]["key_hash"],
        config["networks"][network.show_active()]["fee"],
        {"from": account},
    )
    fund_with_link(
        advanced_collectible.address
    )  # , account, get_contract("link_token"), amount=Web3.toWei(0.1, "ether"))
    create_tx = advanced_collectible.createCollectible({"from": account})
    create_tx.wait(1)
    print("New token has been created!")
    return advanced_collectible, create_tx


def main():
    deploy_and_create()
