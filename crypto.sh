#!/bin/bash

if [ $1 == "-e" ]; then
	if [ $# == 7 ]; then
		echo "Encryption mode selected"
		if [[ ! -f $6 ]]; then
			echo "ERROR lolayekar.a File does not exist" 1>&2
			exit
		fi
#generating session key
		openssl rand -hex 32 >> session.key
		echo "Generated Session Key"

#Encrypt plaintext with session key
		openssl enc -aes-256-cbc -pbkdf2 -kfile session.key -in $6 -out ciphertext.enc
		echo "Encrypted plaintext file with the session key"

#Encrypt session key with public keys
		openssl rsautl -encrypt -inkey $2 -pubin -in session.key -out encrypt_1.enc
		openssl rsautl -encrypt -inkey $3 -pubin -in session.key -out encrypt_2.enc
		openssl rsautl -encrypt -inkey $4 -pubin -in session.key -out encrypt_3.enc
		echo "Encrypted session key with public keys"

#Sign the encrypted file 
		openssl dgst -sha256 -sign sender.priv -out sign ciphertext.enc
		echo "Signed encrypted file"

#Zip files
		zip $7 ciphertext.enc encrypt_1.enc encrypt_2.enc encrypt_3.enc sign
		echo "Zipped the files"
#clean up
		rm session.key
		rm ciphertext.enc
		rm encrypt_1.enc
		rm encrypt_2.enc
		rm encrypt_3.enc
		rm sign

	else
		echo "ERROR lolayekar.a Please provide 7 arguments as follows: ./crypto.sh -e receiver1.pub receiver2.pub receiver3.pub sender.priv <plaintext_file> <encryptedzip_file>" 1>&2
	fi

elif [ $1 == "-d" ]; then
	if [ $# == 5 ]; then
		
		echo "Decryption mode selected"

#Unzip files
		if [[ ! -f $4 ]]; then
			echo "ERROR lolayekar.a File does not exist" 1>&2
			exit
		fi
		if unzip "$4"; then
			echo "Unzipped file"
		else
			echo "ERROR lolayekar.a Unable to unzip file, please try again" 1>&2
		fi

#Verify Signature
		if [[ -f ciphertext.enc && -f sign ]]; then
			openssl dgst -sha256 -verify $3 -signature sign ciphertext.enc 
			echo "Signature Verified"
		else
			echo "ERROR lolayekar.a Zip file does not contain ciphertext file" 1>&2
		fi
#Decrypt session key with private key
		if [ -f encrypt_1.enc ]; then
			for i in 1 2 3
			do
				openssl rsautl -decrypt -inkey $2 -in encrypt_$i.enc -out decrypted.enc 2>STDERR.txt
				if [ $? == 0 ]; then
					echo "Decrypted Session key"
					break
				else
					echo "ERROR lolayekar.a Moving into next iteration" 2>STDERR.txt
					continue
				fi
			
			done
#Decrypt file with session key
			openssl enc -d -aes-256-cbc -pbkdf2 -kfile decrypted.enc -in ciphertext.enc -out $5
			rm ciphertext.enc
			rm decrypted.enc
			rm encrypt_1.enc
			rm encrypt_2.enc
			rm encrypt_3.enc
			rm sign
		else
			echo "ERROR lolayekar.a Zip file does not contain encrypted session key files" 1>&2
		fi
	
	else
		echo "ERROR lolayekar.a Please provide 5 arguments as follows: ./crypto.sh -d receiver<#>.priv sender.pub <encrypted_file> <decrypted_file>" 1>&2
	fi
else
#error handling for any other mode
	echo "ERROR lolayekar.a Please select -e or -d for encryption and decryption respectively" 1>&2

fi