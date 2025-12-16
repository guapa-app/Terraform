apiVersion: v1
kind: ConfigMap
metadata:
  name: laravel-config
  namespace: default
data:
  DB_CONNECTION: "mysql"
  DB_HOST: "mysql"
  DB_PORT: "3306"
  APP_ENV: "production"
  APP_DEBUG: "false"
  LOG_CHANNEL: "stack"
  CACHE_DRIVER: "file"
  QUEUE_CONNECTION: "database"
  SESSION_DRIVER: "file"
