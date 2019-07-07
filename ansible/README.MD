**Importante:**
1) vagrant ssh into ansible_slave.
2) sudo vim /etc/ssh/sshd_config and uncomment PasswordAuthentication on for the first time. 
3) sudo systemctl restart sshd
3) ssh-copy-id master <enter password>
4) Re-disable PasswordAuthentication off
5) exit and vagrant ssh ansible_slave.
6) ansible all -i hosts -u vagrant -m ping

