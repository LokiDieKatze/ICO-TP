const { expect } = require('chai')


describe('LokToken', function () {
  let LokToken, loktoken, owner, dev, alice, bob
  const TOTAL_SUPPLY = ethers.utils.parseEther('500000000000')
  const NAME = 'LokToken'
  const SYMBOL = 'LOK'

  beforeEach(async function () {
    ;[dev, owner, alice, bob] = await ethers.getSigners()
    LokToken = await ethers.getContractFactory('LokToken')
    loktoken = await LokToken.connect(dev).deploy(TOTAL_SUPPLY, owner.address)
    await loktoken.deployed()
  })

  describe('Deployment', function () {
    it('Should have name LokToken', async function () {
      expect(await loktoken.name()).to.equal(NAME)
    })
    it('Should have symbol LOK', async function () {
      expect(await loktoken.symbol()).to.equal(SYMBOL)
    })
    it('Should mint total supply to owner', async function () {
      expect(await loktoken.balanceOf(owner.address)).to.equal(TOTAL_SUPPLY)
    })
  })
})
