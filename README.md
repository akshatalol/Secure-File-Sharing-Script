# Secure-File-Sharing-Script
Cryptographic Digital Envelope- Bash Script

Implemented a cryptographic file sharing system with encryption, digital signature and digital envelope file functions into a bash script. Technologies: OpenSSL, PKI,  RSA. This is a cryptographic scheme that provides confidentiality, integrity and authenticity. An implementation of this Secure Group File sharing system enables a sender to encrypt and sign a file to be sent to an specified group of recipients (each of them should provide their public key to the sender). The receiver is able to decrypt the file and verify the sender’s signature.

Error handling: Printed to stderr
Encryption & Signature: ./crypto.sh -e receiver1.pub receiver2.pub receiver3.pub sender.priv <plaintext_file> <encrypted_file>
Decryption & Verification of Signature: ./crypto.sh -d receiver<#>.priv sender.pub <encrypted_file> <decrypted_file>

