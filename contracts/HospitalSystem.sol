// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HospitalSystem {
    // Structs
    struct Hospital {
        uint256 hospitalId;
        string name;
        string password; // In real implementation, use proper authentication
        address hospitalAddress;
        bool isRegistered;
        uint256 timestamp;
    }

    struct Patient {
        uint256 patientId;
        string name;
        string password; // In real implementation, use proper authentication
        address patientAddress;
        string medicalHistory;
        bool isRegistered;
        uint256 timestamp;
    }

    struct Pharmacy {
        uint256 pharmacyId;
        string name;
        address pharmacyAddress;
        uint256 associatedHospitalId;
        bool isRegistered;
        uint256 timestamp;
    }

    // State variables
    mapping(uint256 => Hospital) public hospitals;
    mapping(uint256 => Patient) public patients;
    mapping(uint256 => Pharmacy) public pharmacies;
    mapping(address => uint256) public addressToHospitalId;
    mapping(address => uint256) public addressToPatientId;
    mapping(address => uint256) public addressToPharmacyId;

    uint256 private hospitalCounter;
    uint256 private patientCounter;
    uint256 private pharmacyCounter;

    // Events
    event HospitalRegistered(
        uint256 indexed hospitalId,
        string name,
        address hospitalAddress
    );
    event PatientRegistered(
        uint256 indexed patientId,
        string name,
        address patientAddress
    );
    event PharmacyRegistered(
        uint256 indexed pharmacyId,
        string name,
        address pharmacyAddress,
        uint256 hospitalId
    );
    event MedicalRecordCreated(
        uint256 indexed patientId,
        uint256 indexed hospitalId,
        string proofHash
    );
    event DataAccessed(
        uint256 indexed patientId,
        address indexed accessor,
        string accessType
    );

    // Modifiers
    modifier onlyRegisteredHospital() {
        require(
            hospitals[addressToHospitalId[msg.sender]].isRegistered,
            "Not a registered hospital"
        );
        _;
    }

    modifier onlyRegisteredPatient() {
        require(
            patients[addressToPatientId[msg.sender]].isRegistered,
            "Not a registered patient"
        );
        _;
    }

    // Hospital Registration
    function registerHospital(
        string memory _name,
        string memory _password
    ) public returns (uint256) {
        require(
            addressToHospitalId[msg.sender] == 0,
            "Hospital already registered"
        );

        hospitalCounter++;
        uint256 hospitalId = hospitalCounter;

        hospitals[hospitalId] = Hospital({
            hospitalId: hospitalId,
            name: _name,
            password: _password,
            hospitalAddress: msg.sender,
            isRegistered: true,
            timestamp: block.timestamp
        });

        addressToHospitalId[msg.sender] = hospitalId;

        emit HospitalRegistered(hospitalId, _name, msg.sender);
        return hospitalId;
    }

    // Patient Registration
    function registerPatient(
        string memory _name,
        string memory _password,
        string memory _medicalHistory
    ) public returns (uint256) {
        require(
            addressToPatientId[msg.sender] == 0,
            "Patient already registered"
        );

        patientCounter++;
        uint256 patientId = patientCounter;

        patients[patientId] = Patient({
            patientId: patientId,
            name: _name,
            password: _password,
            patientAddress: msg.sender,
            medicalHistory: _medicalHistory,
            isRegistered: true,
            timestamp: block.timestamp
        });

        addressToPatientId[msg.sender] = patientId;

        emit PatientRegistered(patientId, _name, msg.sender);
        return patientId;
    }

    // Pharmacy Registration
    function registerPharmacy(
        string memory _name,
        uint256 _hospitalId
    ) public returns (uint256) {
        require(
            addressToPharmacyId[msg.sender] == 0,
            "Pharmacy already registered"
        );
        require(hospitals[_hospitalId].isRegistered, "Hospital does not exist");

        pharmacyCounter++;
        uint256 pharmacyId = pharmacyCounter;

        pharmacies[pharmacyId] = Pharmacy({
            pharmacyId: pharmacyId,
            name: _name,
            pharmacyAddress: msg.sender,
            associatedHospitalId: _hospitalId,
            isRegistered: true,
            timestamp: block.timestamp
        });

        addressToPharmacyId[msg.sender] = pharmacyId;

        emit PharmacyRegistered(pharmacyId, _name, msg.sender, _hospitalId);
        return pharmacyId;
    }

    // Create Medical Record
    function createMedicalRecord(
        uint256 _patientId,
        string memory _proofHash
    ) public onlyRegisteredHospital {
        require(patients[_patientId].isRegistered, "Patient does not exist");

        uint256 hospitalId = addressToHospitalId[msg.sender];
        emit MedicalRecordCreated(_patientId, hospitalId, _proofHash);
        emit DataAccessed(_patientId, msg.sender, "Medical Record Creation");
    }

    // Access Patient Data
    function accessPatientData(uint256 _patientId) public {
        require(patients[_patientId].isRegistered, "Patient does not exist");
        require(
            msg.sender == patients[_patientId].patientAddress ||
                hospitals[addressToHospitalId[msg.sender]].isRegistered ||
                pharmacies[addressToPharmacyId[msg.sender]].isRegistered,
            "Unauthorized access"
        );

        emit DataAccessed(_patientId, msg.sender, "Data Access");
    }
}
