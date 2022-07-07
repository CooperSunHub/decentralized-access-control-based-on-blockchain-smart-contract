// 测试Docker


测试流程

1. 生成公共Ganach-docker
2. 生成20个Truffle-docker, 并与Ganach链接
	- 每个Truffle在启动时, 查找Ganach生成的全部地址, 按顺序填入truffle-config.js
3. 前3个Truffle依次部署合约, 并发布交易修改链接合约地址


4. 设计脚本控制Truffle节点的行为



【启动】
1. 进入geth console 
docker exec -it id sh
find / -name "geth.ipc"
geth attach /root/.ethereum/geth.ipc

2. 复制文件
docker cp /private/tmp/contracts 80436ea9ec4d:/endpoint

【挖矿】
miner.start()
miner.getHashrate()


Public address of the key:   0x606Fe74Ac272f536674FfCc8c653744397ba5010
Path of the secret key file: /root/.ethereum/keystore/UTC--2022-05-14T16-08-49.138356263Z--606fe74ac272f536674ffcc8c653744397ba5010

【Coinbase】 8e3f
miner.setEtherbase("0x6E8601c90Bb45c18447d030b7f97B041C6497571")
miner.start(100)
miner.getHashrate()
personal.unlockAccount(eth.coinbase)

【web3.js合约问题】
geth控制台 部署合约问题，复制到geth控制台回车提示Cannot read property 'deploy' of undefined
https://learnblockchain.cn/question/1985
How To: Deploy Smart Contracts Onto The Ethereum Blockchain
https://medium.com/mercuryprotocol/dev-highlights-of-this-week-cb33e58c745f


