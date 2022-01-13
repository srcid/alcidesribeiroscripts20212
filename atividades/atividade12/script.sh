#!/usr/bin/env -S bash -xv
# Correção: 4,0. Tudo OK!!!

if [ -z "$1" ]; then
  echo "Foneça uma chave de acesso❗"
  exit 1
fi

echo "⏳ Criando servidor..."

KEY_PAIR=$1

VPC_ID="$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --output text --query Vpcs[0].VpcId)"

SUBNET_ID="$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --output text --query Subnets[0].SubnetId)"

# Verifica se já existe um grupo de segurança para o NGINX
SG_ID="$(aws ec2 describe-security-groups --filter 'Name=description,Values=Security group for NGINX' --query SecurityGroups[0].GroupId --output text)"

# Caso não haja, é criado um
if [ "$SG_ID" == 'None' ]; then
  SG_ID="$(aws ec2 create-security-group --group-name nginx-sg --description 'Security group for NGINX' --vpc-id "$VPC_ID" --output text --query GroupId)"
  
  # Adicionando regra de acesso ao servidor web
  aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr "0.0.0.0/0"
  aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr "0.0.0.0/0"
fi

IMAGE_ID="$(aws ec2 describe-images --filters "Name=description,Values=Amazon Linux 2 Kernel 5.10 AMI 2.0.20211223.0 x86_64 HVM gp2" --output text --query Images[0].ImageId)"

INSTANCE_ID="$(aws ec2 run-instances --image-id "$IMAGE_ID" --count 1 --instance-type t2.micro --key-name "$KEY_PAIR" --security-group-ids "$SG_ID" --subnet-id "$SUBNET_ID" --user-data "$(cat user-data.sh)" --output text --query Instances[0].InstanceId)"

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
