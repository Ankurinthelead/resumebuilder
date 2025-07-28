// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ResumeBuilder {
    struct Resume {
        string name;
        string email;
        string skills;
        string experience;
        string education;
        uint256 timestamp;
        bool isActive;
    }
    
    mapping(address => Resume) public resumes;
    mapping(address => bool) public hasResume;
    address[] public resumeOwners;
    
    event ResumeCreated(address indexed owner, string name, uint256 timestamp);
    event ResumeUpdated(address indexed owner, uint256 timestamp);
    event ResumeDeactivated(address indexed owner, uint256 timestamp);
    
    modifier onlyResumeOwner() {
        require(hasResume[msg.sender], "You don't have a resume");
        require(resumes[msg.sender].isActive, "Your resume is deactivated");
        _;
    }
    
    // Function 1: Create a new resume
    function createResume(
        string memory _name,
        string memory _email,
        string memory _skills,
        string memory _experience,
        string memory _education
    ) public {
        require(!hasResume[msg.sender], "Resume already exists");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_email).length > 0, "Email cannot be empty");
        
        resumes[msg.sender] = Resume({
            name: _name,
            email: _email,
            skills: _skills,
            experience: _experience,
            education: _education,
            timestamp: block.timestamp,
            isActive: true
        });
        
        hasResume[msg.sender] = true;
        resumeOwners.push(msg.sender);
        
        emit ResumeCreated(msg.sender, _name, block.timestamp);
    }
    
    // Function 2: Update existing resume
    function updateResume(
        string memory _name,
        string memory _email,
        string memory _skills,
        string memory _experience,
        string memory _education
    ) public onlyResumeOwner {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_email).length > 0, "Email cannot be empty");
        
        Resume storage resume = resumes[msg.sender];
        resume.name = _name;
        resume.email = _email;
        resume.skills = _skills;
        resume.experience = _experience;
        resume.education = _education;
        resume.timestamp = block.timestamp;
        
        emit ResumeUpdated(msg.sender, block.timestamp);
    }
    
    // Function 3: Get resume by address
    function getResume(address _owner) public view returns (
        string memory name,
        string memory email,
        string memory skills,
        string memory experience,
        string memory education,
        uint256 timestamp,
        bool isActive
    ) {
        require(hasResume[_owner], "Resume doesn't exist");
        Resume memory resume = resumes[_owner];
        return (
            resume.name,
            resume.email,
            resume.skills,
            resume.experience,
            resume.education,
            resume.timestamp,
            resume.isActive
        );
    }
    
    // Function 4: Get your own resume
    function getMyResume() public view onlyResumeOwner returns (
        string memory name,
        string memory email,
        string memory skills,
        string memory experience,
        string memory education,
        uint256 timestamp
    ) {
        Resume memory resume = resumes[msg.sender];
        return (
            resume.name,
            resume.email,
            resume.skills,
            resume.experience,
            resume.education,
            resume.timestamp
        );
    }
    
    // Function 5: Deactivate resume (soft delete)
    function deactivateResume() public onlyResumeOwner {
        resumes[msg.sender].isActive = false;
        emit ResumeDeactivated(msg.sender, block.timestamp);
    }
    
    // Function 6: Get total number of active resumes
    function getTotalActiveResumes() public view returns (uint256) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < resumeOwners.length; i++) {
            if (resumes[resumeOwners[i]].isActive) {
                activeCount++;
            }
        }
        return activeCount;
    }
}
