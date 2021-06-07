const { expect } = require('chai')



describe('ICO', function () {
  let ICO, ico, LokToken, loktoken, owner, dev, alice, bob
  //variables pour ERC20
  const TOTAL_SUPPLY = ethers.utils.parseEther('4000')

  //variables pour ICO
  const PRICE = 2

  let TIME_CURRENT

  beforeEach(async function () {
    //deployment de ERC20
    ;[dev, owner, alice, bob] = await ethers.getSigners()
    LokToken = await ethers.getContractFactory('LokToken')
    loktoken = await LokToken.connect(dev).deploy(TOTAL_SUPPLY, owner.address)
    await loktoken.deployed()

    //deployment de ICO
    ICO = await ethers.getContractFactory('ICO')
    ico = await ICO.connect(dev).deploy(loktoken.address, PRICE)
    await ico.deployed()
    TIME_CURRENT = Math.floor(Date.now() / 1000)
  })

  describe('Deployment', function () {
    it('Should have the right Token address', async function () {
      expect(await ico.tokenAddress()).to.equal(loktoken.address)
    })
    it('Should have the right token price', async function () {
      expect(await ico.tokenPrice()).to.equal(PRICE)
    })
  })

  describe('_buyToken', function () {
    beforeEach(async function () {
      await loktoken.connect(owner).approve(ico.address, TOTAL_SUPPLY)
  })
    it('Should emit event BoughtToken with args address buyer and uint256 amount of Tokens', async function () {
      expect(await ico.connect(alice).buyToken({value: ethers.utils.parseEther('2')}))
        .to.emit(ico, 'BoughtToken')
        .withArgs(alice.address, 1)
    })
    it('Should return the right balance of the buyer', async function () {
      await ico.connect(alice).buyToken({value: ethers.utils.parseEther('2')})
      expect(await loktoken.balanceOf(alice.address)).to.equal(1)
    })
    it('Should return the right balance of the token holder', async function () {
      await ico.connect(alice).buyToken({value: ethers.utils.parseEther('2')})
      expect(await loktoken.balanceOf(owner.address)).to.equal(TOTAL_SUPPLY.sub(1))
    })
    it('Should return the right amount of sold tokens', async function () {
      await ico.connect(alice).buyToken({value: ethers.utils.parseEther('2')})
      expect(await ico.connect(bob).alreadyBought()).to.equal(1)
    })
    it('Should revert due to unsufficient value', async function () {
      await expect(ico.connect(alice).buyToken({value: ethers.utils.parseEther('1')})).to.be.revertedWith("Sorry, this is not enough Ether (in weis) to buy one Token.")
    })
    it('Should revert because sale no longer ongoing', async function () {
      await ethers.provider.send('evm_increaseTime', [1210000])
      await ethers.provider.send('evm_mine')
      await expect(ico.connect(bob).buyToken({value: ethers.utils.parseEther('2')})).to.be.revertedWith("Sorry, the sale has ended already")
    })
  })

  describe('Withdraw', function () {
    beforeEach(async function () {
      await loktoken.connect(owner).approve(ico.address, TOTAL_SUPPLY)
      await ico.connect(alice).buyToken({value: ethers.utils.parseEther('2')})
      await ico.connect(bob).buyToken({value: ethers.utils.parseEther('2')})
  })
  it('Should credit the account of the owner', async function () {
    await ethers.provider.send('evm_increaseTime', [1210000])
    await ethers.provider.send('evm_mine')
    expect(await ico.connect(owner).withdraw()).to.emit(ico, 'Withdrawn').withArgs(owner.address, ethers.utils.parseEther('4'))
  })
  it('Should revert because sale has not ended', async function () {
    await expect(ico.connect(owner).withdraw()).to.be.revertedWith("Sorry, the sale has not ended yet.")
  })
  it('Should revert because only the token holder can withdraw', async function () {
    await ethers.provider.send('evm_increaseTime', [1210000])
    await ethers.provider.send('evm_mine')
    await expect(ico.connect(alice).withdraw()).to.be.revertedWith("Sorry you are not allowed to withdraw the content of this contract.")
  })
})

  describe('Getters', function () {
    beforeEach(async function () {
      await loktoken.connect(owner).approve(ico.address, TOTAL_SUPPLY)
    })
    it('Should return the name of the token', async function () {
      expect(await ico.connect(bob).name()).to.be.equal('LokToken')
    })
    it('Should return the symbol of the token', async function () {
      expect(await ico.connect(bob).symbol()).to.be.equal('LOK')
    })
    it('Should return the address of the token contract', async function () {
      expect(await ico.connect(bob).tokenAddress()).to.be.equal(loktoken.address)
    })
    it('Should return the price of the token', async function () {
      expect(await ico.connect(bob).tokenPrice()).to.be.equal(2)
    })
    it('Should return initial supply', async function () {
      expect(await ico.connect(bob).initialSupply()).to.be.equal(ethers.utils.parseEther('4000'))
    })
    it('Should return the amount of already bought tokens', async function () {
      await ico.connect(alice).buyToken({value: ethers.utils.parseEther('2')})
      await ico.connect(bob).buyToken({value: ethers.utils.parseEther('2')})
      expect(await ico.connect(bob).alreadyBought()).to.be.equal(2)
    })
    it('Should return the amount of left tokens for sale', async function () {
      await ico.connect(alice).buyToken({value: ethers.utils.parseEther('2')})
      await ico.connect(bob).buyToken({value: ethers.utils.parseEther('2')})
      expect(await ico.connect(bob).tokenForSale()).to.be.equal(ethers.utils.parseEther('4000').sub(2))
    })
  }) 
})
