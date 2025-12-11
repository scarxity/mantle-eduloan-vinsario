// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title EduLoan - Decentralized Student Loan System
/// @author [Nama Anda]
/// @notice Sistem pinjaman pendidikan terdesentralisasi di Mantle Network
/// @dev Challenge Final Mantle Co-Learning Camp

contract EduLoan {
    // ============================================
    // ENUMS & STRUCTS
    // ============================================

    enum LoanStatus {
        Pending,
        Approved,
        Active,
        Repaid,
        Defaulted,
        Rejected
    }

    struct Loan {
        uint256 loanId;
        address borrower;
        uint256 principalAmount;
        uint256 interestRate;
        uint256 totalAmount;
        uint256 amountRepaid;
        uint256 applicationTime;
        uint256 approvalTime;
        uint256 deadline;
        LoanStatus status;
        string purpose;
    }

    // ============================================
    // STATE VARIABLES
    // ============================================

    // TODO: Deklarasikan state variables
    // Hint: admin, loanCounter, constants, mappings
    address public admin;
    uint256 public loanCounter;
    uint256 public constant INTEREST_RATE = 500; // 5% dalam basis points
    uint256 public constant LOAN_DURATION = 365 days;
    uint256 public constant MIN_LOAN = 0.01 ether;
    uint256 public constant MAX_LOAN = 10 ether;

    mapping (uint256 => Loan) public loans;
    mapping (address => uint256[]) public borrowerLoans;

    // ============================================
    // EVENTS
    // ============================================

    // TODO: Deklarasikan semua events
    event LoanApplied(uint256 indexed loanId, address indexed borrower, uint256 amount, string purpose);
    event LoanApproved(uint256 indexed loanId, address indexed borrower, uint256 totalAmount);
    event LoanRejected(uint256 indexed loanId, address indexed borrower, string reason);
    event LoanDisbursed(uint256 indexed loanId, address indexed borrower, uint256 amount);
    event PaymentMade(uint256 indexed loanId, address indexed borrower, uint256 amount, uint256 remaining);
    event LoanRepaid(uint256 indexed loanId, address indexed borrower);
    event LoanDefaulted(uint256 indexed loanId, address indexed borrower);

    // ============================================
    // MODIFIERS
    // ============================================

    // TODO: Buat modifiers (onlyAdmin, onlyBorrower, dll)
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin allowed");
        _;
    }
    modifier onlyBorrower(uint256 _loanId){
        Loan storage loan = loans[_loanId];
        require(msg.sender == loan.borrower, "Only Borrower allowed");
        _;
    }
    modifier loanExists(uint256 _loanId){
        require(loans[_loanId].loanId != 0, "Loan doesn't exist");
        _;
    }
    modifier inStatus(uint256 _loanId, LoanStatus _status){
        require(loans[_loanId].status == _status, "Loan status invalid for this action");
        _;
    }

    // ============================================
    // CONSTRUCTOR
    // ============================================

    constructor() {
        // TODO: Set admin = msg.sender
        admin = msg.sender;
    }

    // ============================================
    // MAIN FUNCTIONS
    // ============================================

    /// @notice Mahasiswa mengajukan pinjaman
    /// @param _amount Jumlah pinjaman yang diajukan
    /// @param _purpose Tujuan pinjaman
    function applyLoan(uint256 _amount, string memory _purpose) public {
        // TODO: Implementasi
        // 1. Validasi amount (MIN_LOAN <= amount <= MAX_LOAN)
        // 2. Increment loanCounter
        // 3. Hitung total dengan bunga
        // 4. Buat Loan struct baru
        // 5. Simpan di mapping
        // 6. Tambahkan loanId ke borrowerLoans
        // 7. Emit event
        require(MIN_LOAN <= _amount, "Amount is invalid");
        require(_amount <= MAX_LOAN, "Amount is invalid");
        loanCounter++;
        uint256 total_amount = _amount + calculateInterest(_amount);
        loans[loanCounter] = Loan({
            loanId: loanCounter,
            borrower: msg.sender,
            principalAmount: _amount,
            interestRate: INTEREST_RATE,
            totalAmount: total_amount,
            amountRepaid: 0,
            applicationTime: block.timestamp,
            approvalTime: 0,
            deadline: 0, // Set deadlinenya ketika loan sudah dicairkan
            status: LoanStatus.Pending      ,
            purpose: _purpose
        });
        borrowerLoans[msg.sender].push(loanCounter);

        emit LoanApplied(loanCounter, msg.sender, _amount, _purpose);
    }

    /// @notice Admin menyetujui pinjaman
    /// @param _loanId ID pinjaman yang disetujui
    function approveLoan(uint256 _loanId) public onlyAdmin loanExists(_loanId) inStatus(_loanId, LoanStatus.Pending) {
        // TODO: Implementasi
        Loan storage loan = loans[_loanId];
        loan.approvalTime = block.timestamp;
        loan.status = LoanStatus.Approved;
        emit LoanApproved(_loanId, loan.borrower, loan.totalAmount);
    }

    /// @notice Admin menolak pinjaman
    /// @param _loanId ID pinjaman yang ditolak
    /// @param _reason Alasan penolakan
    function rejectLoan(uint256 _loanId, string memory _reason) public onlyAdmin loanExists(_loanId) inStatus(_loanId, LoanStatus.Pending) {
        // TODO: Implementasi
        Loan storage loan = loans[_loanId];
        loan.status = LoanStatus.Rejected;
        emit LoanRejected(_loanId, loan.borrower, _reason);
    }

    /// @notice Admin mencairkan dana pinjaman
    /// @param _loanId ID pinjaman yang dicairkan
    function disburseLoan(uint256 _loanId) public loanExists(_loanId) onlyBorrower(_loanId) inStatus(_loanId, LoanStatus.Approved) {
        // TODO: Implementasi
        // 1. Validasi status = Approved
        // 2. Validasi contract balance cukup
        // 3. Transfer dana ke borrower
        // 4. Set deadline
        // 5. Update status ke Active
        // 6. Emit event
        Loan storage loan = loans[_loanId];
        require(getContractBalance() >= loan.principalAmount, "Contract balance isn't enough");
        (bool success, ) = msg.sender.call{value: loan.principalAmount}("");
        require(success, "Disbursement failed");
        loan.deadline = block.timestamp + LOAN_DURATION;
        loan.status = LoanStatus.Active;

        emit LoanDisbursed(loan.loanId, loan.borrower, loan.principalAmount);
    }

    /// @notice Borrower membayar cicilan
    /// @param _loanId ID pinjaman
    function makePayment(uint256 _loanId) public payable loanExists(_loanId) inStatus(_loanId, LoanStatus.Active) {
        // TODO: Implementasi
        // 1. Validasi status = Active
        // 2. Validasi msg.value > 0
        // 3. Update amountRepaid
        // 4. Jika lunas, update status ke Repaid
        // 5. Emit event
        Loan storage loan = loans[_loanId];
        require(msg.value > 0, "The amount must be greater than 0");
        loan.amountRepaid += msg.value;
        if(loan.amountRepaid >= loan.totalAmount) {
            loan.status = LoanStatus.Repaid;
            emit LoanRepaid(loan.loanId, loan.borrower);
        }
        emit PaymentMade(loan.loanId, loan.borrower, msg.value, getRemainingAmount(_loanId));
    }

    /// @notice Cek apakah pinjaman sudah default
    /// @param _loanId ID pinjaman
    function checkDefault(uint256 _loanId) public loanExists(_loanId) {
        // TODO: Implementasi
        // Jika melewati deadline dan belum lunas, set status Defaulted
        Loan storage loan = loans[_loanId];
        if(loan.deadline > block.timestamp) {
            loan.status = LoanStatus.Defaulted;
            emit LoanDefaulted(loan.loanId, loan.borrower);
        }
    }

    // ============================================
    // VIEW FUNCTIONS
    // ============================================

    /// @notice Lihat detail pinjaman
    function getLoanDetails(uint256 _loanId) public view loanExists(_loanId) returns (Loan memory) {
        // TODO: Implementasi
        return loans[_loanId];
    }

    /// @notice Lihat semua pinjaman milik caller
    function getMyLoans() public view returns (uint256[] memory) {
        // TODO: Implementasi
        return borrowerLoans[msg.sender];
    }

    /// @notice Hitung bunga dari principal
    function calculateInterest(uint256 _principal) public pure returns (uint256) {
        // TODO: Implementasi
        // Formula: (_principal * INTEREST_RATE) / 10000
        return (_principal * INTEREST_RATE) / 10000;
    }

    /// @notice Lihat sisa yang harus dibayar
    function getRemainingAmount(uint256 _loanId) public view returns (uint256) {
        // TODO: Implementasi
        Loan storage loan = loans[_loanId];
        return loan.totalAmount - loan.amountRepaid;
    }

    /// @notice Lihat saldo contract
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // ============================================
    // ADMIN FUNCTIONS
    // ============================================

    /// @notice Admin deposit dana ke contract
    function depositFunds() public payable onlyAdmin {
        // TODO: Implementasi (onlyAdmin)
        require(msg.value > 0, "Deposit amount must be greater than 0");
    }

    /// @notice Admin withdraw dana dari contract
    function withdrawFunds(uint256 _amount) onlyAdmin public {
        // TODO: Implementasi (onlyAdmin)
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transaction failed");
    }
}