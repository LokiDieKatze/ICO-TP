const { expect } = require('chai')

describe('Calculator', function () {
let Calculator, calculator, LokToken, loktoken, owner, dev, alice, bob
  //variables pour ERC20
  const TOTAL_SUPPLY = ethers.utils.parseEther('4000')

  beforeEach(async function () {
    //deployment de ERC20
    ;[dev, owner, alice, bob] = await ethers.getSigners()
    LokToken = await ethers.getContractFactory('LokToken')
    loktoken = await LokToken.connect(dev).deploy(TOTAL_SUPPLY, owner.address)
    await loktoken.deployed()

    //deployment de Calculator
    Calculator = await ethers.getContractFactory('Calculator')
    calculator = await Calculator.connect(dev).deploy(loktoken.address)
    await calculator.deployed()
  })


  describe('Deployment', function () {
    it('Should be deployed with the right erc20 address.', async function () {
      expect(await calculator.tokenAddress()).to.equal(loktoken.address)
    })
  })


  describe('Add', function () {
      beforeEach(async function () {
      await loktoken.connect(owner).transfer(alice.address, 10)
  })
    it('Should emit the event Operated with the right args', async function () {
      await loktoken.connect(alice).approve(calculator.address, 1)
      expect(await calculator.connect(alice).add(100, 1)).to.emit(calculator, 'Operated').withArgs(alice.address, 100, '+', 1, 101)
    })
    it('Should revert the transaction because of non approval', async function () {
      await expect( calculator.connect(alice).add(100, 1)).to.be.reverted
    })
    it('Revert the call of function due to unsufficient funds', async function () {
      await loktoken.connect(bob).approve(calculator.address, 1)
      await expect(calculator.connect(bob).add(0,9)).to.be.revertedWith("Calculator: This operation costs 1 Loktoken, please credit your account.")
    })
    it('Should return the right result to the operation', async function () {
      await loktoken.connect(owner).transfer(bob.address, 10)
      await loktoken.connect(bob).approve(calculator.address, 1)
      expect(await calculator.connect(bob).add(0,9)).to.emit(calculator, 'Operated').withArgs(bob.address, 0, '+', 9, 9)
  })
  it('Should return the right token balance', async function () {
    await loktoken.connect(alice).approve(calculator.address, 1)
    await calculator.connect(alice).add(18,3)
    expect(await loktoken.balanceOf(alice.address)).to.equal(9)
  })
})

  describe('Sub', function () {
      beforeEach(async function () {
      await loktoken.connect(owner).transfer(bob.address, 100)
  })
    it('Should emit the event Operated with the right args', async function () {
      await loktoken.connect(bob).approve(calculator.address, 1)
      expect(await calculator.connect(bob).sub(100, 98)).to.emit(calculator, 'Operated').withArgs(bob.address, 100, '-', 98, 2)
    })
    it('Should revert the transaction because of non approval', async function () {
      await expect( calculator.connect(bob).sub(1, 1)).to.be.reverted
    })
    it('Revert the call of function due to unsufficient funds', async function () {
      await loktoken.connect(alice).approve(calculator.address, 1)
      await expect(calculator.connect(alice).sub(0,9)).to.be.revertedWith("Calculator: This operation costs 1 Loktoken, please credit your account.")
    })
    it('Should return the right result to the operation', async function () {
      await loktoken.connect(owner).transfer(bob.address, 10)
      await loktoken.connect(bob).approve(calculator.address, 1)
      expect(await calculator.connect(bob).sub(2,1)).to.emit(calculator, 'Operated').withArgs(bob.address, 2, '-', 1, 1)
  })
  it('Should return the right token balance', async function () {
    await loktoken.connect(bob).approve(calculator.address, 3)
    await calculator.connect(bob).sub(18,3)
    await calculator.connect(bob).sub(18,3)
    await calculator.connect(bob).sub(18,3)
    expect(await loktoken.balanceOf(bob.address)).to.equal(97)
  })
})

  describe('Mul', function () {
      beforeEach(async function () {
      await loktoken.connect(owner).transfer(bob.address, 3)
      await loktoken.connect(owner).transfer(alice.address, 1)
  })
    it('Should emit the event Operated with the right args', async function () {
      await loktoken.connect(bob).approve(calculator.address, 1)
      expect(await calculator.connect(bob).mul(10, 98)).to.emit(calculator, 'Operated').withArgs(bob.address, 10, '*', 98, 980)
    })
    it('Should revert the transaction because of non approval', async function () {
      await expect( calculator.connect(bob).mul(1, 1)).to.be.reverted
    })
    it('Revert the call of function due to unsufficient funds', async function () {
      await loktoken.connect(alice).approve(calculator.address, 1)
      await calculator.connect(alice).mul(18,3)
      await expect(calculator.connect(alice).mul(0,9)).to.be.revertedWith("Calculator: This operation costs 1 Loktoken, please credit your account.")
    })
    it('Should return the right result to the operation', async function () {
      await loktoken.connect(owner).transfer(alice.address, 1)
      await loktoken.connect(alice).approve(calculator.address, 1)
      expect(await calculator.connect(alice).mul(2,1)).to.emit(calculator, 'Operated').withArgs(alice.address, 2, '*', 1, 2)
  })
  it('Should return the right token balance', async function () {
    await loktoken.connect(bob).approve(calculator.address, 3)
    await calculator.connect(bob).mul(18,3)
    await calculator.connect(bob).mul(18,3)
    await calculator.connect(bob).mul(18,3)
    expect(await loktoken.balanceOf(bob.address)).to.equal(0)
  })
})

  describe('Div', function () {
    beforeEach(async function () {
      await loktoken.connect(owner).transfer(bob.address, 3)
      await loktoken.connect(owner).transfer(alice.address, 2)
    })
    it('Should return the event Operated with the right arguments', async function () {
      await loktoken.connect(bob).approve(calculator.address, 1)
      expect(await calculator.connect(bob).div(10, 1)).to.emit(calculator, 'Operated').withArgs(bob.address, 10, '/', 1, 10)
    })
    it('Should revert if trying to divide by 0.', async function () {
      await loktoken.connect(alice).approve(calculator.address, 1)
      await expect(calculator.connect(alice).div(9,0)).to.be.revertedWith("Calculator: impossible to divide by 0.")
    })
    it('Should revert the call of function due to unsufficient funds', async function () {
      await loktoken.connect(alice).approve(calculator.address, 2)
      await calculator.connect(alice).div(18,2)
      await calculator.connect(alice).div(18,6)
      await expect(calculator.connect(alice).div(0,9)).to.be.reverted
})
})

describe('Modulo', function () {
    beforeEach(async function () {
      await loktoken.connect(owner).transfer(bob.address, 5)
      await loktoken.connect(owner).transfer(alice.address, 2)
    })
    it('Should return the event Operated with the right arguments', async function () {
      await loktoken.connect(bob).approve(calculator.address, 1)
      expect(await calculator.connect(bob).modulo(89, 8)).to.emit(calculator, 'Operated').withArgs(bob.address, 89, '%', 8, 1)
    })
    it('Should revert if trying to divide by 0.', async function () {
      await loktoken.connect(alice).approve(calculator.address, 1)
      await expect(calculator.connect(alice).modulo(9,0)).to.be.revertedWith("Calculator: impossible to operate modulo 0.")
    })
    it('Should revert the call of function due to unsufficient funds', async function () {
      await loktoken.connect(alice).approve(calculator.address, 3)
      await calculator.connect(alice).modulo(18,2)
      await calculator.connect(alice).modulo(18,6)
      await expect(calculator.connect(alice).div(0,9)).to.be.revertedWith("Calculator: This operation costs 1 Loktoken, please credit your account.")
})
})
})
