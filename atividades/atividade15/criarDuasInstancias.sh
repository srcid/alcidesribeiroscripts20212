#!/usr/bin/env bash
# Correção: 2,0
if [ "$4" == '--debug' ]; then
  set -x
  set -v
fi

if [ -z "$1" ]; then
  echo "Foneça uma chave de acesso❗"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Foneça o nome de usuário para o banco de dados❗"
  exit 2
fi

if [ -z "$3" ]; then
  echo "Foneça uma senha para o banco de dados❗"
  exit 3
fi

echo "⏳ Recuperando ip da dessa máquina..."
HOST_IP=$(curl -4 -s https://checkip.amazonaws.com)

if [ "$?" != "0" ]; then
  echo "Não foi possível recuperar seu IP público."
  exit 4
fi

KEY_PAIR="$1"
DB_USER="$2"
DB_USER_PASSWD="$3"

VPC_ID="$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --output text --query Vpcs[0].VpcId)"

SUBNET_ID="$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --output text --query Subnets[0].SubnetId)"

SG_ID="$(aws ec2 create-security-group --group-name atividade15-sg --description 'Security group for atividade15' --vpc-id "$VPC_ID" --output text --query GroupId)"

aws ec2 wait security-group-exists --group-ids "$SG_ID"

aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr "0.0.0.0/0"
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr "$HOST_IP/32"
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 3306 --source-group "$SG_ID"

IMAGE_ID="$(aws ec2 describe-images --filters "Name=description,Values=Amazon Linux 2 Kernel 5.10 AMI 2.0.20211223.0 x86_64 HVM gp2" --output text --query Images[0].ImageId)"

echo "⏳ Criando servidor de banco de dados..."
INSTANCE_ID_DB="$(aws ec2 run-instances --image-id "$IMAGE_ID" --count 1 --instance-type t2.micro --key-name "$KEY_PAIR" --security-group-ids "$SG_ID" --subnet-id "$SUBNET_ID" --user-data "$(echo '
#!/usr/bin/env bash

yum install mariadb-server -y

systemctl enable mariadb.service --now

mysql -u root <<\eof

create database scripts;

GRANT ALL PRIVILEGES ON scripts.* TO '"'"$DB_USER"'"'@'"'"%"'"' IDENTIFIED BY '"'"$DB_USER_PASSWD"'"';

quit

\eof
')" --output text --query Instances[0].InstanceId)"

# Esperando instancia iniciar
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID_DB"
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID_DB"

echo '🏃 A instância de banco de dados está em estado "running"'

DB_PRIVATE_IP="$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID_DB" --query Reservations[0].Instances[0].PrivateIpAddress --output text)"

echo "⏳ Criando servidor de aplicação..."
INSTANCE_ID=$(aws ec2 run-instances --image-id "$IMAGE_ID" --count 1 --instance-type t2.micro --key-name "$KEY_PAIR" --security-group-ids "$SG_ID" --subnet-id "$SUBNET_ID"  --user-data "$(echo '
#!/usr/bin/env bash

yum install mariadb -y

mysql --user='$DB_USER' --password='$DB_USER_PASSWD' --database=scripts --host='$DB_PRIVATE_IP' <<\eof

create table teste (
    atividade int primary key
);

insert into teste values (1),(2);

quit

\eof
')" --output text --query Instances[0].InstanceId)

# Esperando instancia iniciar
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID"

echo '🏃 A instância de aplicação está em estado "running"'

INSTANCE_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query Reservations[0].Instances[0].PublicIpAddress --output text)

echo "👉 IP privado do banco de dados: $DB_PRIVATE_IP"
echo "👉 IP públic da aplicação: $INSTANCE_PUBLIC_IP"

echo "⚠ Tecle Enter para desfazer as modificações❗"
echo -n "⏳ Aguardando..."
read -r

echo "☠ Removendo instancias..."
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" "$INSTANCE_ID_DB"

if [ "$?" != "0" ]
then
  echo "⛔ Erro ao terminar instancia."
  exit 5
fi

aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" "$INSTANCE_ID_DB"

echo "✅ Instancias finalizadas."

echo "☠ Removendo grupo de segurança"

aws ec2 delete-security-group --group-id "$SG_ID"

if [ "$?" != "0" ]
then
  echo "⛔ Erro ao deletar o grupo de segurança."
  exit 6
fi

echo "✅ Grupo de segurança apagado."
