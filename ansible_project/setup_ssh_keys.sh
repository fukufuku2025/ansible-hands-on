#!/bin/sh

# 設定
ANSIBLE_CONTAINER="ansible"
WEB_CONTAINERS=("web1" "web2")
ANSIBLE_USER="ansible"
SSH_KEY_PATH="/home/${ANSIBLE_USER}/.ssh/id_rsa"

# 1. Ansibleコンテナ内でSSH鍵を作成
echo "[INFO] Ansibleコンテナ内でSSH鍵を作成します..."
docker exec -it ${ANSIBLE_CONTAINER} sh -c "mkdir -p /home/${ANSIBLE_USER}/.ssh && ssh-keygen -t rsa -b 2048 -f ${SSH_KEY_PATH} -N '' && chown -R ${ANSIBLE_USER}:${ANSIBLE_USER} /home/${ANSIBLE_USER}/.ssh"

# 2. 各 Web コンテナで `ansible` ユーザーを作成し、SSHサーバーをセットアップ
for CONTAINER in "${WEB_CONTAINERS[@]}"; do
    echo "[INFO] ${CONTAINER} に SSHサーバーをインストールし、${ANSIBLE_USER} ユーザーを作成します..."
    docker exec -it ${CONTAINER} sh -c "
        apk add --no-cache openssh sudo &&
        adduser -D ${ANSIBLE_USER} &&
        passwd -u ${ANSIBLE_USER} &&
        mkdir -p /home/${ANSIBLE_USER}/.ssh &&
        chmod 700 /home/${ANSIBLE_USER}/.ssh &&
        chown -R ${ANSIBLE_USER}:${ANSIBLE_USER} /home/${ANSIBLE_USER}/.ssh &&
        echo '${ANSIBLE_USER} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers &&
        echo 'PermitRootLogin no' >> /etc/ssh/sshd_config &&
        echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config &&
        echo 'AllowUsers ${ANSIBLE_USER}' >> /etc/ssh/sshd_config &&
        rc-update add sshd &&
        rc-service sshd start"
done

# 3. SSH鍵を Ansible コンテナから各 Web コンテナの `ansible` ユーザーにコピー
for CONTAINER in "${WEB_CONTAINERS[@]}"; do
    echo "[INFO] ${CONTAINER} にSSH鍵をコピーします..."
    docker exec -it ${ANSIBLE_CONTAINER} sh -c "
        ssh-keyscan -H ${CONTAINER} >> /home/${ANSIBLE_USER}/.ssh/known_hosts &&
        cat ${SSH_KEY_PATH}.pub | ssh ${ANSIBLE_USER}@${CONTAINER} 'cat >> /home/${ANSIBLE_USER}/.ssh/authorized_keys' &&
        ssh ${ANSIBLE_USER}@${CONTAINER} 'chmod 600 /home/${ANSIBLE_USER}/.ssh/authorized_keys &&
        chown ${ANSIBLE_USER}:${ANSIBLE_USER} /home/${ANSIBLE_USER}/.ssh/authorized_keys'"
done

echo "[INFO] SSH鍵のセットアップが完了しました！"
