@ECHO OFF

cd /D e:\WBTlogs

e:\sftp\psftp projec0712\sftpuser@sftp.webtrends.com -pw PM1temppa$$ -bc -b "e:\sftp\ftpscript.txt"

e:\sftp\7z e *.gz -y

EXIT