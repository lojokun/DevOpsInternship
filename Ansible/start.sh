vagrant ssh master -c "ssh-keygen -t rsa -b 4096 -N '' -f '/home/vagrant/.ssh/id_rsa'"
vagrant plugin install vagrant-scp
vagrant scp master:/home/vagrant/.ssh/id_rsa.pub .
vagrant scp id_rsa.pub webapp:/home/vagrant
vagrant ssh webapp -c "cat id_rsa.pub >> .ssh/authorized_keys && rm id_rsa.pub"
vagrant scp id_rsa.pub db:/home/vagrant
vagrant ssh db -c "cat id_rsa.pub >> .ssh/authorized_keys && rm id_rsa.pub"
rm id_rsa.pub
#vagrant ssh master -c "ansible-playbook /home/vagrant/ansible/playbook_dbs.yml -u vagrant"
#vagrant ssh master -c "ansible-playbook /home/vagrant/ansible/playbook_webapps.yml -u vagrant"
echo DONE
