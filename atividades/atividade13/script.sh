#!/usr/bin/env bash

# Correção: 2,0. Tudo OK!!!

if [ "$2" == '--debug' ]; then
  set -x
  set -v
fi

if [ -z "$1" ]; then
  echo "Foneça uma chave de acesso❗"
  exit 1
fi

echo "⏳ Criando servidor..."

KEY_PAIR=$1

VPC_ID="$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --output text --query Vpcs[0].VpcId)"

SUBNET_ID="$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --output text --query Subnets[0].SubnetId)"

# Verifica se já existe um grupo de segurança para a atividade13
SG_ID="$(aws ec2 describe-security-groups --filter 'Name=description,Values=Security group for atividade13' --query SecurityGroups[0].GroupId --output text)"

# Caso não haja, é criado um
if ! [[ "$SG_ID" =~ sg-.+ ]]; then
  SG_ID="$(aws ec2 create-security-group --group-name atividade13-sg --description 'Security group for atividade13' --vpc-id "$VPC_ID" --output text --query GroupId)"
  
  # Adicionando regra de acesso ao servidor web
  aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr "0.0.0.0/0"
  aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr "0.0.0.0/0"
fi

IMAGE_ID="$(aws ec2 describe-images --filters "Name=description,Values=Amazon Linux 2 Kernel 5.10 AMI 2.0.20211223.0 x86_64 HVM gp2" --output text --query Images[0].ImageId)"

INSTANCE_ID="$(aws ec2 run-instances --image-id "$IMAGE_ID" --count 1 --instance-type t2.micro --key-name "$KEY_PAIR" --security-group-ids "$SG_ID" --subnet-id "$SUBNET_ID" --user-data file://user-data.sh --output text --query Instances[0].InstanceId)"

# Esperando instancia iniciar
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID"

INSTANCE_PUBLIC_IP="$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicIp --output text)"

echo "Acesse http://$INSTANCE_PUBLIC_IP"

echo "Tecle Enter para desfazer as modificações ❗"
echo -n "⏳ Aguardando..."
read -r

aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"

if [ "$?" != 0 ]; then
  echo "⛔ Erro ao terminar instancia."
  exit 2
fi

echo "✅ Instancia finalizada."

aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"

aws ec2 delete-security-group --group-id "$SG_ID"

if [ "$?" != 0 ]; then
  echo "⛔ Erro ao deletar o grupo de segurança."
  exit 3
fi

echo "✅ Grupo de segurança apagado."
