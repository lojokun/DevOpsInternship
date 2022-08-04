# DevOpsInternship
I decided to post everything I learned during the DevOpsInternship at Coera. 

The first thing I worked with was Vagrant, a tool for automating the deployment of Virtual Machines. We chose an app available on github at https://github.com/LukePeters/User-Login-System-Tutorial, which is a simple User Login System built with Flask for the frontend and MongoDB for the backend. The idea was to automate the deployment of this specific app on two different Virtual Machines.

After that, I started working with Dockers. I did the same thing, deploying the app in two different dockers. The next step was running this webapp inside Dockers that run inside VMs. This implementation you can find inside the folder DockerInVM.

Then I worked with Ansible, which is a tool that makes automation and maintaining applications on bigger infrastructures easy. Here I created three VMs with Vagrant, one being the master one which is used to control the other two, one being responsible for the webapp, the other one being responsible for the database. I then ran the playbooks from the master and the webapp starts working.

The last thing I learned so far is Terraform, which is a tool that automates the infrastructure. I used Terraform to create two dockers that run the same app, and now I'm working on running the same webapp inside two VMs that run on a cloud provider called Azure.
