apiVersion: v1
kind: Secret
metadata:
  name: mysql-credentials
  namespace: default
type: Opaque
data:
  mysql-root-password: ${mysql_root_password}
  mysql-database: ${mysql_database}
  mysql-user: ${mysql_username}
  mysql-password: ${mysql_password}
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: laravel-prod-ahm
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: ${mysql_root_password_decoded}
  MYSQL_DATABASE: ${mysql_database_decoded}
  MYSQL_USER: ${mysql_username_decoded}
  MYSQL_PASSWORD: ${mysql_password_decoded}
