// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title EntewardProjects - A contract for managing projects as NFTs for the Ente Ward Dapp.
/// @notice This contract allows the creation and management of projects represented as non-transferable NFTs.
/// @dev The contract inherits from OpenZeppelin's ERC721 and Ownable libraries, and disables token transfer and approvals.
contract EntewardProjects is ERC721, Ownable {
	/// @notice Tracks the next token ID to be minted.
	uint256 private _nextTokenId;

	/// @notice Represents the possible statuses for a project.
	enum ProjectStatus {
		Upcoming,
		Ongoing,
		Completed,
		Cancelled
	}

	/// @notice Struct that holds metadata and status of a project.
	/// @dev Projects are associated with IPFS URIs and status.
	struct ProjectDetails {
		string proposalURI; // URI to project proposal details (stored on IPFS).
		string reportURI; // URI to project report (used if project is Completed or Cancelled, stored on IPFS).
		ProjectStatus status; // Current status of the project.
	}

	/// @notice Maps token ID to project details.
	mapping(uint256 => ProjectDetails) private _projectDetails;

	/// @notice Emitted when a new project is minted.
	/// @param tokenId The ID of the newly minted project token.
	/// @param proposalURI The IPFS URI of the project proposal.
	event ProjectMinted(uint256 indexed tokenId, string proposalURI);

	/// @notice Emitted when a project's status is updated.
	/// @param tokenId The ID of the project.
	/// @param newStatus The new status of the project.
	/// @param reportURI The IPFS URI of the project report (used for Completed or Cancelled status).
	event ProjectStatusUpdated(
		uint256 indexed tokenId,
		ProjectStatus newStatus,
		string reportURI
	);

	/// @notice Constructor sets the initial owner of the contract.
	/// @param initialOwner The address to set as the initial owner.
	constructor(
		address initialOwner
	) ERC721("EnteWardProjects", "EWP") Ownable(initialOwner) {}

	/// @notice Modifier to ensure the project can only be edited if it exists and is not completed or cancelled.
	/// @param tokenId The ID of the token representing the project.
	modifier editable(uint256 tokenId) {
		require(_exists(tokenId), "ERC721: token does not exist");
		require(
			_projectDetails[tokenId].status != ProjectStatus.Completed &&
				_projectDetails[tokenId].status != ProjectStatus.Cancelled,
			"Project cannot be edited after it is completed or cancelled"
		);
		_;
	}

	/// @notice Creates a new project as a non-transferable NFT.
	/// @dev Mints a new project token with the initial status set to `Upcoming`.
	/// @param proposalURI The IPFS URI of the project's proposal.
	function mint(string memory proposalURI) public onlyOwner {
		require(bytes(proposalURI).length > 0, "Proposal URI cannot be empty");
		uint256 tokenId = _nextTokenId++;
		_safeMint(owner(), tokenId);
		_projectDetails[tokenId] = ProjectDetails({
			proposalURI: proposalURI,
			reportURI: "",
			status: ProjectStatus.Upcoming
		});

		emit ProjectMinted(tokenId, proposalURI);
	}

	/// @notice Updates the status of a project.
	/// @dev The function requires a report URI when setting the project to `Completed` or `Cancelled`.
	/// @param tokenId The ID of the project to update.
	/// @param newStatus The new status of the project.
	/// @param reportURI The IPFS URI of the project report (mandatory for `Completed` or `Cancelled` statuses).
	function updateStatus(
		uint256 tokenId,
		ProjectStatus newStatus,
		string memory reportURI
	) public onlyOwner editable(tokenId) {
		require(
			newStatus != ProjectStatus.Upcoming,
			"New status must be ongoing, completed or cancelled"
		);
		require(
			newStatus == ProjectStatus.Ongoing || bytes(reportURI).length > 0,
			"Report URI required to mark project as completed or cancelled"
		);

		_projectDetails[tokenId].status = newStatus;
		if (
			newStatus == ProjectStatus.Completed ||
			newStatus == ProjectStatus.Cancelled
		) {
			_projectDetails[tokenId].reportURI = reportURI;
		}

		emit ProjectStatusUpdated(tokenId, newStatus, reportURI);
	}

	/// @notice Disables token transfers by overriding the internal _transfer function.
	/// @dev This ensures that project NFTs are non-transferable.
	/// @param from The address from which the token would be transferred.
	/// @param to The address to which the token would be transferred.
	/// @param tokenId The ID of the token to be transferred.
	function _transfer(
		address from,
		address to,
		uint256 tokenId
	) internal pure override {
		require(false, "Token transfers are disabled");
	}

	/// @notice Disables approvals by overriding the internal _approve function.
	/// @dev Prevents token approvals, ensuring non-transferability.
	/// @param to The address to approve the token for.
	/// @param tokenId The ID of the token for which approval is being set.
	function _approve(address to, uint256 tokenId) internal pure override {
		require(false, "Token approvals are disabled");
	}

	/// @notice Disables setting approval for all tokens.
	/// @dev Prevents setting operator approvals for all tokens.
	/// @param operator The address to approve as an operator.
	/// @param approved Whether the operator is approved or not.
	function setApprovalForAll(
		address operator,
		bool approved
	) public pure override {
		require(false, "Approval for all is disabled");
	}

	/// @notice Disables approving a specific token.
	/// @dev Prevents approval for individual tokens.
	/// @param to The address to approve for the specific token.
	/// @param tokenId The ID of the token for which approval is being set.
	function approve(address to, uint256 tokenId) public pure override {
		require(false, "Token approvals are disabled");
	}
}
