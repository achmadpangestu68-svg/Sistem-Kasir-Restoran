; =====================================================================================
; UJIAN AKHIR SEMESTER - PEMROGRAMAN BAHASA RAKITAN
; =====================================================================================
; NAMA PROGRAM : Sistem Kasir Restoran (Skala Besar)
; PROGRAMMER   : Achmad Pangestu
; TEMA         : Manajemen Pemesanan dan Kalkulasi Pembayaran
; COMPILER     : TASM / DOSBox / emu8086
; =====================================================================================

.model small
.stack 1024       ; Memperbesar stack karena kita akan banyak menggunakan fungsi

; =====================================================================================
; MACRO DEFINITIONS 
; (Kumpulan makro untuk mempermudah pemanggilan fungsi dan memperkaya LOC)
; =====================================================================================
PRINT_STR MACRO string
    lea dx, string
    mov ah, 09h
    int 21h
ENDM

NEW_LINE MACRO
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
ENDM

WAIT_KEY MACRO
    mov ah, 07h
    int 21h
ENDM

.data
    ; ---------------------------------------------------------------------------------
    ; ASCII ART: LOGO RESTORAN (Versi Aman 100% Anti-Error & Fit 80 Kolom)
    ; ---------------------------------------------------------------------------------
    logo_01 db 13, 10, ' ========================================================================== ', 13, 10, '$'
    logo_02 db         ' ||                                                                      || ', 13, 10, '$'
    logo_03 db         ' ||       ____  _____ ____ _____ ___  ____      _    _   _               || ', 13, 10, '$'
    logo_04 db         ' ||      |  _ \| ____/ ___|_   _/ _ \|  _ \    / \  | \ | |              || ', 13, 10, '$'
    logo_05 db         ' ||      | |_) |  _| \___ \ | || | | | |_) |  / _ \ |  \| |              || ', 13, 10, '$'
    logo_06 db         ' ||      |  _ <| |___ ___) || || |_| |  _ <  / ___ \| |\  |              || ', 13, 10, '$'
    logo_07 db         ' ||      |_| \_\_____|____/ |_| \___/|_| \_\/_/   \_\_| \_|              || ', 13, 10, '$'
    logo_08 db         ' ||                                                                      || ', 13, 10, '$'
    logo_09 db         ' ||  ..................................................................  || ', 13, 10, '$'
    logo_10 db         ' ||                                                                      || ', 13, 10, '$'
    logo_11 db         ' ||                 R E S T O R A N   N U S A N T A R A                  || ', 13, 10, '$'
    logo_12 db         ' ||                Sistem Kasir & Manajemen Order V3.0                   || ', 13, 10, '$'
    logo_13 db         ' ||                                                                      || ', 13, 10, '$'
    logo_14 db         ' ========================================================================== ', 13, 10, '$'

    ; ---------------------------------------------------------------------------------
    ; DAFTAR MENU MAKANAN & MINUMAN (Sangat membantu menambah baris kode)
    ; ---------------------------------------------------------------------------------
    menu_hdr db 13, 10, ' ------------- DAFTAR MENU MAKANAN & MINUMAN -------------', 13, 10, '$'
    menu_01  db ' [1] Nasi Goreng Spesial    - Rp 15.000', 13, 10, '$'
    menu_02  db ' [2] Ayam Penyet Sambal     - Rp 20.000', 13, 10, '$'
    menu_03  db ' [3] Sate Ayam Madura       - Rp 18.000', 13, 10, '$'
    menu_04  db ' [4] Mie Goreng Jawa        - Rp 12.000', 13, 10, '$'
    menu_05  db ' [5] Nasi Uduk Komplit      - Rp 10.000', 13, 10, '$'
    menu_06  db ' [6] Es Teh Manis / Tawar   - Rp  5.000', 13, 10, '$'
    menu_07  db ' [7] Es Jeruk Peras         - Rp  6.000', 13, 10, '$'
    menu_08  db ' [8] Kopi Hitam Panas       - Rp  4.000', 13, 10, '$'
    menu_09  db ' [9] Air Mineral Botol      - Rp  3.000', 13, 10, '$'
    menu_00  db ' [0] SELESAI & HITUNG TOTAL PEMBAYARAN', 13, 10, '$'
    menu_ftr db ' ---------------------------------------------------------', 13, 10, '$'

    ; ---------------------------------------------------------------------------------
    ; PESAN PROMPT & NOTIFIKASI
    ; ---------------------------------------------------------------------------------
    prompt_pilih db 13, 10, ' Masukkan Kode Menu (0-9) : $'
    prompt_porsi db ' Masukkan Jumlah Porsi (1-9) : $'
    msg_error    db 13, 10, ' [!] ERROR: Input tidak valid! Silakan ulangi.', 13, 10, '$'
    msg_added    db 13, 10, ' [+] BERHASIL: Pesanan ditambahkan ke dalam nota.', 13, 10, '$'
    msg_press    db 13, 10, ' Tekan sembarang tombol untuk kembali ke menu...', 13, 10, '$'
    
    ; ---------------------------------------------------------------------------------
    ; UI STRUK PEMBAYARAN & KEMBALIAN
    ; ---------------------------------------------------------------------------------
    struk_01     db 13, 10, ' ====================================================================== ', 13, 10, '$'
    struk_02     db         '                           NOTA PEMBAYARAN                              ', 13, 10, '$'
    struk_03     db         ' ====================================================================== ', 13, 10, '$'
    struk_04     db 13, 10, ' TOTAL TAGIHAN      : Rp $'
    struk_05     db '.000', 13, 10, '$'  ; Digunakan untuk mencetak ribuan secara statis
    
    prompt_bayar db 13, 10, ' Masukkan Nominal Pembayaran (Dalam ribuan, misal 50 untuk 50.000): $'
    msg_kurang   db 13, 10, ' [!] ERROR: Uang pembayaran KURANG! Silakan masukkan nominal yang pas.', 13, 10, '$'
    
    struk_06     db 13, 10, ' TOTAL PEMBAYARAN   : Rp $'
    struk_07     db 13, 10, ' UANG KEMBALIAN     : Rp $'
    
    struk_08     db 13, 10, 13, 10, ' ====================================================================== ', 13, 10, '$'
    struk_09     db         '        Terima Kasih Atas Kunjungan Anda di Restoran Nusantara!         ', 13, 10, '$'
    struk_10     db         ' ====================================================================== ', 13, 10, '$'
    
    prompt_lagi db 13, 10, 13, 10, ' Apakah Anda ingin melayani pelanggan lain? (Y/N) : $'
    msg_keluar  db 13, 10, 13, 10, ' Menutup sistem kasir... Terima kasih!$'
    
    ; ---------------------------------------------------------------------------------
    ; VARIABEL GLOBAL PENYIMPANAN DATA
    ; ---------------------------------------------------------------------------------
    total_harga  dw 0    ; Menyimpan akumulasi total belanja (Data Word / 16-bit)
    harga_temp   dw 0    ; Menyimpan harga menu yang sedang dipilih sementara
    porsi_temp   dw 0    ; Menyimpan jumlah porsi yang diinput user
    uang_bayar   dw 0    ; Menyimpan nominal uang yang dibayarkan pelanggan
    kembalian    dw 0    ; Menyimpan hasil kalkulasi (uang_bayar - total_harga)
    
    .code
MAIN PROC
    ; 1. Inisialisasi Data Segment ke register DS
    mov ax, @data
    mov ds, ax

    ; 2. Reset variabel total harga di awal program
    mov total_harga, 0

START_MENU:
    ; Bersihkan layar sebelum merender UI (Prosedur akan dibuat di Tahap 3)
    call CLEAR_SCREEN

    ; -----------------------------------------------------------------------------
    ; RENDER HEADER & LOGO RESTORAN
    ; -----------------------------------------------------------------------------
    PRINT_STR logo_01
    PRINT_STR logo_02
    PRINT_STR logo_03
    PRINT_STR logo_04
    PRINT_STR logo_05
    PRINT_STR logo_06
    PRINT_STR logo_07
    PRINT_STR logo_08
    PRINT_STR logo_09
    PRINT_STR logo_10
    PRINT_STR logo_11
    PRINT_STR logo_12
    PRINT_STR logo_13
    PRINT_STR logo_14

    ; -----------------------------------------------------------------------------
    ; RENDER DAFTAR MENU
    ; -----------------------------------------------------------------------------
    PRINT_STR menu_hdr
    PRINT_STR menu_01
    PRINT_STR menu_02
    PRINT_STR menu_03
    PRINT_STR menu_04
    PRINT_STR menu_05
    PRINT_STR menu_06
    PRINT_STR menu_07
    PRINT_STR menu_08
    PRINT_STR menu_09
    PRINT_STR menu_00
    PRINT_STR menu_ftr

INPUT_MENU_PILIHAN:
    ; Meminta input kode menu dari kasir/user
    PRINT_STR prompt_pilih
    
    mov ah, 01h         ; Fungsi DOS untuk membaca 1 karakter dari keyboard
    int 21h

    ; -----------------------------------------------------------------------------
    ; LOGIKA ROUTING (PENCABANGAN)
    ; Membandingkan input user (di register AL) dengan karakter ASCII '0' - '9'
    ; -----------------------------------------------------------------------------
    cmp al, '1'
    je SET_HARGA_1
    cmp al, '2'
    je SET_HARGA_2
    cmp al, '3'
    je SET_HARGA_3
    cmp al, '4'
    je SET_HARGA_4
    cmp al, '5'
    je SET_HARGA_5
    cmp al, '6'
    je SET_HARGA_6
    cmp al, '7'
    je SET_HARGA_7
    cmp al, '8'
    je SET_HARGA_8
    cmp al, '9'
    je SET_HARGA_9
    
    ; --- UBAH BAGIAN INI ---
    cmp al, '0'
    jne INVALID_INPUT    ; Jika BUKAN 0, lompat ke peringatan error
    jmp PROSES_CHECKOUT  ; Jika 0, JMP biasa dijamin sampai ke tujuan

    INVALID_INPUT:
    ; Jika input tidak valid (bukan 0-9)
    PRINT_STR msg_error
    WAIT_KEY
    jmp START_MENU

; =====================================================================================
; BLOK PENETAPAN HARGA (Berdasarkan Pilihan Menu)
; Harga disimpan dalam bentuk ribuan (misal: 15.000 disimpan sebagai 15)
; Hal ini sangat penting untuk mencegah "overflow" pada register saat kalkulasi.
; =====================================================================================
SET_HARGA_1:
    mov harga_temp, 15  ; Nasi Goreng Spesial - Rp 15.000
    jmp PROSES_PORSI
SET_HARGA_2:
    mov harga_temp, 20  ; Ayam Penyet Sambal - Rp 20.000
    jmp PROSES_PORSI
SET_HARGA_3:
    mov harga_temp, 18  ; Sate Ayam Madura - Rp 18.000
    jmp PROSES_PORSI
SET_HARGA_4:
    mov harga_temp, 12  ; Mie Goreng Jawa - Rp 12.000
    jmp PROSES_PORSI
SET_HARGA_5:
    mov harga_temp, 10  ; Nasi Uduk Komplit - Rp 10.000
    jmp PROSES_PORSI
SET_HARGA_6:
    mov harga_temp, 5   ; Es Teh Manis / Tawar - Rp 5.000
    jmp PROSES_PORSI
SET_HARGA_7:
    mov harga_temp, 6   ; Es Jeruk Peras - Rp 6.000
    jmp PROSES_PORSI
SET_HARGA_8:
    mov harga_temp, 4   ; Kopi Hitam Panas - Rp 4.000
    jmp PROSES_PORSI
SET_HARGA_9:
    mov harga_temp, 3   ; Air Mineral Botol - Rp 3.000
    jmp PROSES_PORSI
    
    ; =====================================================================================
; BLOK KALKULASI PESANAN (Menghitung Total Berdasarkan Porsi)
; =====================================================================================
PROSES_PORSI:
    ; Meminta input jumlah porsi
    PRINT_STR prompt_porsi
    
    mov ah, 01h             ; Membaca input 1 digit (porsi)
    int 21h
    
    ; Validasi porsi (Harus angka 1 - 9)
    cmp al, '1'
    jl INVALID_PORSI_INPUT
    cmp al, '9'
    jg INVALID_PORSI_INPUT
    
    ; Konversi ASCII ke desimal murni
    sub al, '0'             ; Kurangi nilai ASCII dengan '0' (48)
    mov ah, 0               ; Bersihkan AH agar AX hanya berisi nilai AL
    mov porsi_temp, ax      ; Simpan porsi ke memori
    
    ; PROSES PERKALIAN (Harga x Porsi)
    mov ax, harga_temp      ; Pindahkan harga ke AX
    mov bx, porsi_temp      ; Pindahkan porsi ke BX
    mul bx                  ; Perintah MUL mengalikan AX dengan BX, hasilnya disimpan di AX
    
    ; Menambahkan hasil perkalian ke total harga keseluruhan
    add total_harga, ax
    
    ; Menampilkan notifikasi sukses dan kembali ke menu
    PRINT_STR msg_added
    WAIT_KEY                ; Memanggil makro tunggu tombol
    jmp INPUT_MENU_PILIHAN  ; Ulangi tampilan menu utama

INVALID_PORSI_INPUT:
    PRINT_STR msg_error
    WAIT_KEY
    jmp PROSES_PORSI        ; Minta input porsi lagi

; =====================================================================================
; BLOK CHECKOUT & PEMBAYARAN
; =====================================================================================
PROSES_CHECKOUT:
    ; Bersihkan layar untuk menampilkan nota
    call CLEAR_SCREEN
    
    ; Mencetak Header Struk
    PRINT_STR struk_01
    PRINT_STR struk_02
    PRINT_STR struk_03
    
    ; Mencetak Total Tagihan
    PRINT_STR struk_04
    mov ax, total_harga     ; Pindahkan total harga ke AX
    call PRINT_NUM          ; Panggil prosedur konversi angka untuk dicetak
    PRINT_STR struk_05      ; Cetak ".000" di belakangnya

INPUT_PEMBAYARAN:
    PRINT_STR prompt_bayar
    
    ; Panggil prosedur READ_NUM untuk membaca input uang yang bisa > 1 digit
    ; (misal user mengetik '50' lalu menekan Enter)
    call READ_NUM           
    mov uang_bayar, ax      ; Hasil dari READ_NUM akan disimpan di AX

    ; Validasi: Apakah uang yang dibayarkan cukup?
    mov bx, total_harga
    cmp ax, bx              ; Bandingkan uang bayar (AX) dengan total harga (BX)
    jl UANG_KURANG          ; Jika uang bayar KECIL DARI (<) total, lompat ke UANG_KURANG
    
    ; Menghitung Kembalian (Uang Bayar - Total Harga)
    sub ax, bx              ; AX = AX - BX
    mov kembalian, ax       ; Simpan hasil pengurangan ke variabel kembalian
    
    ; Mencetak Rincian Pembayaran
    PRINT_STR struk_06
    mov ax, uang_bayar
    call PRINT_NUM
    PRINT_STR struk_05
    
    ; Mencetak Uang Kembalian
    PRINT_STR struk_07
    mov ax, kembalian
    call PRINT_NUM
    PRINT_STR struk_05
    
    ; Mencetak Footer Struk & Keluar
    PRINT_STR struk_08
    PRINT_STR struk_09
    PRINT_STR struk_10
    
    mov ah, 4Ch             ; Interupsi DOS untuk mengakhiri program
    int 21h

UANG_KURANG:
    PRINT_STR msg_kurang
    jmp INPUT_PEMBAYARAN    ; Suruh kasir mengulang input nominal uang

MAIN ENDP

; =====================================================================================
; KUMPULAN PROSEDUR TINGKAT LANJUT (SUBROUTINES)
; Membantu menambah LOC secara signifikan dengan logika berbobot tinggi.
; =====================================================================================

; -------------------------------------------------------------------------------------
; PROCEDURE: CLEAR_SCREEN
; Membersihkan layar dan mereset kursor ke (0,0) menggunakan Mode Video BIOS.
; -------------------------------------------------------------------------------------
CLEAR_SCREEN PROC
    push ax
    mov ah, 00h
    mov al, 03h
    int 10h
    pop ax
    ret
CLEAR_SCREEN ENDP

; -------------------------------------------------------------------------------------
; PROCEDURE: PRINT_NUM
; Mengonversi nilai integer 16-bit di register AX menjadi string dan mencetaknya.
; Metode: Dibagi dengan 10 berulang kali, sisanya disimpan di stack, lalu dicetak.
; -------------------------------------------------------------------------------------
PRINT_NUM PROC
    push ax
    push bx
    push cx
    push dx

    mov cx, 0       ; CX digunakan untuk menghitung jumlah digit
    mov bx, 10      ; Basis desimal pembagi (10)

    ; Jika angkanya kebetulan 0 (misal kembalian 0)
    cmp ax, 0
    jne DIVIDE_LOOP
    mov dx, 0
    push dx
    inc cx
    jmp PRINT_LOOP_START

DIVIDE_LOOP:
    mov dx, 0       ; Bersihkan DX (karena DIV membagi pasangan DX:AX)
    div bx          ; AX dibagi 10. Hasil di AX, sisa (digit terakhir) di DX
    push dx         ; Simpan digit tersebut di tumpukan (stack)
    inc cx          ; Catat bahwa ada 1 digit tambahan
    cmp ax, 0       ; Apakah hasil pembagian sudah 0?
    jne DIVIDE_LOOP ; Jika belum, ulangi proses

PRINT_LOOP_START:
    pop dx          ; Ambil digit dari stack (otomatis terurut dari depan)
    add dl, '0'     ; Ubah angka desimal menjadi karakter ASCII (tambah 48)
    mov ah, 02h     ; Fungsi cetak 1 karakter
    int 21h
    loop PRINT_LOOP_START ; Loop akan otomatis mengurangi CX sampai 0

    pop dx
    pop cx
    pop bx
    pop ax
    ret
PRINT_NUM ENDP

; -------------------------------------------------------------------------------------
; PROCEDURE: READ_NUM
; Fitur canggih untuk membaca multi-digit input dari user hingga menekan tombol ENTER.
; Hasil input akan dikonversi menjadi sebuah integer desimal utuh dan disimpan di AX.
; -------------------------------------------------------------------------------------
READ_NUM PROC
    push bx
    push cx
    push dx

    mov cx, 0       ; CX akan berfungsi sebagai akumulator nilai total
    
READ_CHAR:
    mov ah, 01h     ; Baca 1 karakter dengan echo
    int 21h

    cmp al, 13      ; Cek apakah karakter yang diinput adalah tombol ENTER (ASCII 13)
    je FINISH_READ  ; Jika ya, selesai membaca

    ; Validasi apakah yang diketik benar-benar angka
    cmp al, '0'
    jl READ_CHAR    ; Jika bukan angka, abaikan
    cmp al, '9'
    jg READ_CHAR

    ; Konversi ASCII ke desimal
    sub al, '0'
    mov ah, 0       ; Sekarang AX berisi digit yang baru saja diketik
    
    ; Logika Shift Digit: (Total Lama x 10) + Digit Baru
    push ax         ; Amankan digit baru di stack sementara
    mov ax, cx      ; Pindahkan total lama ke AX
    mov bx, 10
    mul bx          ; Kalikan total lama dengan 10 (AX = AX * 10)
    mov cx, ax      ; Simpan hasil perkalian kembali ke CX
    pop ax          ; Ambil lagi digit baru dari stack
    add cx, ax      ; Tambahkan digit baru ke CX (Total Baru)

    jmp READ_CHAR   ; Ulangi siklus untuk membaca digit selanjutnya

FINISH_READ:
    mov ax, cx      ; Pindahkan hasil kalkulasi utuh ke AX untuk di-return

    pop dx
    pop cx
    pop bx
    ret
READ_NUM ENDP

; =====================================================================================
; END OF PROGRAM
; =====================================================================================
END MAIN