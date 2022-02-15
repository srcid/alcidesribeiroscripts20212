#!/usr/bin/env bash

KEY_PAIR="$1"
DB_USER="$2"
DB_USER_PASSWD="$3"
HOST_IP=$(curl -4 -s https://checkip.amazonaws.com)

VPC_ID="$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --output text --query Vpcs[0].VpcId)"
SUBNET_ID="$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --output text --query Subnets[0].SubnetId)"

SG_ID="$(aws ec2 create-security-group --group-name atividade17-sg --description 'Security group for atividade17' --vpc-id "$VPC_ID" --output text --query GroupId)"
aws ec2 wait security-group-exists --group-ids "$SG_ID"

aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr "0.0.0.0/0" > /dev/null
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr "$HOST_IP/32" > /dev/null
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 3306 --source-group "$SG_ID" > /dev/null

aws rds create-db-instance --db-name wordpress --db-instance-identifier database-wp --allocated-storage 20 --db-instance-class db.t3.medium --engine mariadb --engine-version 10.5.13 --master-username $DB_USER --master-user-password $DB_USER_PASSWD --vpc-security-group-ids $SG_ID --no-storage-encrypted --no-deletion-protection --no-publicly-accessible --no-multi-az > /dev/null

aws rds wait db-instance-available --db-instance-identifier database-wp

DB_ENDPOINT="$(aws rds describe-db-instances --db-instance-identifier database-wp --query 'DBInstances[0].Endpoint.Address' --output text)"

USER_AGENT='#!/usr/bin/env bash

yum update -y
amazon-linux-extras install -y mariadb10.5
amazon-linux-extras install -y php7.2
yum install httpd -y

curl -s https://br.wordpress.org/wordpress-5.9-pt_BR.tar.gz --output wp.tar.gz

tar -zxf wp.tar.gz

cp wordpress/wp-config-sample.php wordpress/wp-config.php

salt=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sed -r '"'"'s/$/\\n/g'"'"' | tr -d '"'"'\n'"'"')

cat <<EOF > edit.sed
23 s/.+/define( '"'DB_NAME'"', '"'wordpress'"' );/g
26 s/.+/define( '"'DB_USER'"', '"'$DB_USER'"' );/g
29 s/.+/define( '"'DB_PASSWORD'"', '"'$DB_USER_PASSWD'"' );/g
32 s/.+/define( '"'DB_HOST'"', '"'$DB_ENDPOINT'"' );/g
53,60 d
52 a $salt
EOF

sed -i -r -f edit.sed wordpress/wp-config.php

rsync -r wordpress/ /var/www/html/

sed -i '"'"'151 s/AllowOverride None/AllowOverride All/'"'"' /etc/httpd/conf/httpd.conf

systemctl enable httpd.service
systemctl start httpd.service
'

IMAGE_ID="$(aws ec2 describe-images --filters "Name=description,Values=Amazon Linux 2 Kernel 5.10 AMI 2.0.20211223.0 x86_64 HVM gp2" --output text --query Images[0].ImageId)"

INSTANCE_ID=$(aws ec2 run-instances --image-id "$IMAGE_ID" --count 1 --instance-type t2.micro --key-name "$KEY_PAIR" --security-group-ids "$SG_ID" --subnet-id "$SUBNET_ID"  --user-data "$USER_AGENT" --output text --query Instances[0].InstanceId)

aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID"

echo '🏃 A instância de aplicação está em estado "running"'

INSTANCE_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query Reservations[0].Instances[0].PublicIpAddress --output text)

echo "👉 IP públic da aplicação: $INSTANCE_PUBLIC_IP"

echo "⚠ Tecle Enter para desfazer as modificações❗"
echo -n "⏳ Aguardando..."
read -r

aws rds delete-db-instance --db-instance-identifier database-wp > /dev/null
aws rds wait db-instance-deleted --db-instance-identifier database-wp
echo "✅ Banco de dados apagado."

aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" > /dev/null
aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"
echo "✅ Instância terminada."

aws ec2 delete-security-group --group-id "$SG_ID" > /dev/null
echo "✅ Grupo de segurança apagado."