# EduLoan - Mantle Co-Learning Camp Challenge

## Author
- Nama: Vinsario Shentana
- GitHub: scarxity
- Wallet: 0xFAE609FF366495f8bF18B5B20eb36C286b6AA9D1

## Contract Address (Mantle Sepolia)
`0x7eB83e3981C04e623b75e1Db7E7160da03E6d306`

## Features Implemented
- [x] Apply Loan
- [x] Approve/Reject Loan
- [x] Disburse Loan
- [x] Make Payment
- [x] Check Default
- [x] Bonus: LoanStatus Enum for Rejected Loan

## Screenshots
<img width="363" height="707" alt="image" src="https://github.com/user-attachments/assets/710d742f-b83d-45b6-93ff-b88fb7de1e82" />
<img width="1615" height="663" alt="approve-loan" src="https://github.com/user-attachments/assets/2039b3dc-125a-4aa6-a6fa-382357c144cd" />
<img width="1605" height="710" alt="apply-loan" src="https://github.com/user-attachments/assets/aad14f13-7ed1-4dae-90e1-2755381183e6" />
<img width="1619" height="679" alt="payment" src="https://github.com/user-attachments/assets/24ea6a03-6e5b-48d7-b059-dd7c3248d11c" />


## How to Test
1. Deploy contract di Mantle Sepolia
2. Admin deposit funds
3. User apply loan
4. Admin approve loan
5. Admin disburse loan
6. User make payment

## Lessons Learned
Berikut adalah hal yang saya pelajari dari challenge ini.
1. Enum adalah tipe data yang berguna untuk membatasi pilihan sesuai dengan konteks yang kita inginkan, contohnya pada LoanStatus.
2. Data types seperti string, uint, mapping, serta struct.
3. Penerapan access modifier.
4. Fungsi payable untuk mengirim sejumlah coin/token
5. Implementasi modifier yang memudahkan pengecekan fungsi sehingga kode dapat menerapkan prinsip DRY (Don't Repeat Yourself)
6. Event yang di-emit agar bisa di-index di aplikasi web.
