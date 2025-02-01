# 第4章: Playbookを作成する

## 4.1: Playbookの作成と実行

プレイブックを使って、Ansibleで実行するタスクを記述します。この例では、`httpd`をインストールするタスクを作成します。

### Playbookの作成

```yaml
---
- name: Install and start httpd
  hosts: test
  become: true
  tasks:
    - name: Install httpd
      yum:
        name: httpd
        state: present
    - name: Start httpd
      service:
        name: httpd
        state: started