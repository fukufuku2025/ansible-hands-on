# 第4章: Playbookを作成する

## 4.1: Playbookの作成と実行

プレイブックを使って、Ansibleで実行するタスクを記述します。この例では、`httpd`をインストールするタスクをroleで定義したのでそれを呼ぶように記載します。

### Playbookの作成

```yaml
- name: Deploy Apache Server
  hosts: all
  become: yes
  roles:
    - httpd
