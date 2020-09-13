#Compute Instances
resource "aws_instance" "jenkinsmaster" {
    ami = "ami-0b331d9b32ae9db2d"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
    key_name = "login"
    associate_public_ip_address = true
    subnet_id = aws_subnet.public-subnet-1.id
    tags = {
        Name = "Jenkins_Master"
    }

#Allow Terrform to connect via ssh
    connection {
        user = "ec2-user"
        type = "ssh"
        private_key = file(var.ssh_key)
        host = "self.public_ip"
        timeout = "2m"
    }
    
 #Copy the files to the Jenkins Master
 provisioner "file" {
        source      = "Files/jenkins-proxy"
        destination = "/tmp/jenkins-proxy"
    }

    provisioner "file" {
        source      = "Files/Dockerfile"
        destination = "/tmp/Dockerfile"
    }

    provisioner "file" {
        source      = "Files/jenkins-plugins"
        destination = "/tmp/jenkins-plugins"
    }

    provisioner "file" {
        source      = "Files/default-user.groovy"
        destination = "/tmp/default-user.groovy"
    }
    
 #Run all the commands 
    provisioner "remote-exec" {
        inline = [
        
        # steps to setup docker ce
            "apt update",
            "apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common",
            "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -",
            "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable\" ",
            "apt update",
            "apt-cache policy docker-ce",
            "apt -y install docker-ce",
            
 # Build jenkins image with default admin user
            "cd /tmp && docker build -t devsecops/jenkins .",
            
  # run newly built jenkins container on port 8080
            "docker run -d --name jenkins-server -p 8080:8080 devsecops/jenkins",

            # install remaining dependencies
            "apt -y install nginx",
            "apt -y install ufw",
            
            # setup debian firewall
            "ufw status verbose",
            "ufw default deny incoming",
            "ufw default allow outgoing",
            "ufw allow ssh",
            "ufw allow 22",
            "ufw allow 80",
            "yes | ufw enable",
            
            # update nginx configuration
            "rm -f /etc/nginx/sites-enabled/default",
            "cp -f /tmp/jenkins-proxy /etc/nginx/sites-enabled",
            "service nginx restart"        
        ]
    }
}

