const LandTitle = artifacts.require("LandTitle");

contract("LandTitle", accounts => {
    let landTitle = null;
    const owner = accounts[0];
    const newOwner = accounts[1];
    let tokenId = null;
    const dataHash = "Qm123abc";
    const invalidTokenId = 9999; // An ID that has not been minted

    beforeEach(async () => {
        landTitle = await LandTitle.new({ from: owner });
        let result = await landTitle.registerTitle(dataHash, { from: owner });
        tokenId = result.logs[0].args.tokenId.toString();
    });

    it("Should register a new title", async () => {
        // let result = await landTitle.registerTitle(dataHash, { from: owner });
        // Get tokenId from the emitted event
        // tokenId = result.logs[0].args.tokenId.toString();

        assert.notEqual(tokenId, 0, "Token ID should not be 0");
    });

    it("Should get the correct title details", async () => {
        const returnedDataHash = await landTitle.getTitleDetails(tokenId, { from: owner });
        assert.equal(returnedDataHash, dataHash, "The returned data hash is incorrect");
    });

    it("Should verify title correctly", async () => {
        const isOwner = await landTitle.verifyTitle(tokenId, { from: owner });
        assert.equal(isOwner, true, "The owner should own the token");

        const isNotOwner = await landTitle.verifyTitle(tokenId, { from: newOwner });
        assert.equal(isNotOwner, false, "The non-owner should not own the token");
    });

    it("Should transfer title correctly", async () => {
        await landTitle.transferTitle(owner, newOwner, tokenId, { from: owner });

        const newOwnerOfToken = await landTitle.ownerOf(tokenId);
        assert.equal(newOwner, newOwnerOfToken, "New owner should now own the token");
    });

    // Test for non-existing token
    it("Should fail when trying to retrieve details of a non-existing token", async () => {
        try {
            await landTitle.getTitleDetails(invalidTokenId, { from: owner });
            assert.fail("Expected error not received");
        } catch (error) {
            const expectedError = "ERC721: queried token does not exist";
            assert(error.message.includes(expectedError), `Expected "${expectedError}", but got "${error.message}"`);
        }

    });

    it("Should fail when trying to verify a non-existing token", async () => {
        try {
            await landTitle.verifyTitle(invalidTokenId, { from: owner });
            assert.fail("Expected error not received");
        } catch (error) {
            const expectedError = "ERC721: queried token does not exist";
            assert(error.message.includes(expectedError), `Expected "${expectedError}", but got "${error.message}"`);
        }
    });

    it("Should fail when trying to transfer a non-existing token", async () => {
        try {
            await landTitle.transferTitle(owner, newOwner, invalidTokenId, { from: owner });
            assert.fail("Expected error not received");
        } catch (error) {
            const expectedError = "ERC721: queried token does not exist";
            assert(error.message.includes(expectedError), `Expected "${expectedError}", but got "${error.message}"`);
        }
    });

    // Test for non-owner transfer
    it("Should fail when trying to transfer a token by someone who is not the owner", async () => {
        try {
            await landTitle.transferTitle(newOwner, owner, tokenId, { from: newOwner });
            assert.fail("Expected error not received");
        } catch (error) {
            const expectedError = "ERC721: owner is not the owner";
            assert(error.message.includes(expectedError), `Expected "${expectedError}", but got "${error.message}"`);
        }
    });


});
