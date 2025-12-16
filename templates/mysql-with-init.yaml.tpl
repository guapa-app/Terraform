---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: oci-bv
  resources:
    requests:
      storage: ${mysql_storage_size}
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: default
spec:
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
  clusterIP: None
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: default
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      initContainers:
      - name: download-sql-dump
        image: ghcr.io/oracle/oci-cli:latest
        command:
        - sh
        - -c
        - |
          echo "Downloading SQL dump from OCI Object Storage..."
          oci os object get \
            --namespace auto \
            --bucket-name ${sql_bucket_name} \
            --name ${sql_file_name} \
            --file /docker-entrypoint-initdb.d/${sql_file_name} \
            --region ${oci_region}
          
          if [ -f /docker-entrypoint-initdb.d/${sql_file_name} ]; then
            echo "SQL dump downloaded successfully"
            ls -lh /docker-entrypoint-initdb.d/
          else
            echo "Failed to download SQL dump"
            exit 1
          fi
        volumeMounts:
        - name: init-scripts
          mountPath: /docker-entrypoint-initdb.d
        env:
        - name: OCI_CLI_AUTH
          value: "instance_principal"
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
          name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: mysql-root-password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: mysql-database
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: mysql-user
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: mysql-password
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
        - name: init-scripts
          mountPath: /docker-entrypoint-initdb.d
        resources:
          requests:
            cpu: "500m"
            memory: "1Gi"
          limits:
            cpu: "1000m"
            memory: "2Gi"
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
      - name: init-scripts
        emptyDir: {}
