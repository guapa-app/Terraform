---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: laravel-app
  namespace: default
spec:
  replicas: ${replicas_min}
  selector:
    matchLabels:
      app: laravel
  template:
    metadata:
      labels:
        app: laravel
    spec:
      imagePullSecrets:
      - name: ocirsecret
      
      # Init container to copy Laravel files
      initContainers:
      - name: copy-app
        image: me-riyadh-1.ocir.io/ax45nhirzfe7/guapa:fpm-prod
        command: ['sh', '-c', 'cp -r /var/www/html/. /app-data/']
        volumeMounts:
        - name: app-data
          #mountPath: /app-data
      
      containers:
      # Nginx container
      - name: nginx
        image: me-riyadh-1.ocir.io/ax45nhirzfe7/guapa:nginx-prod
        imagePullPolicy: Always
        ports:
        - containerPort: 80
          name: http
        volumeMounts:
        - name: app-data
          mountPath: /var/www/html
          readOnly: true
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"
      
      # PHP-FPM Laravel container
      - name: php-fpm
        image: me-riyadh-1.ocir.io/ax45nhirzfe7/guapa:fpm-prod
        imagePullPolicy: Always
        env:
        - name: DB_CONNECTION
          value: "mysql"
        - name: DB_HOST
          value: "10.20.30.90"
        - name: DB_PORT
          value: "3306"
        - name: DB_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: mysql-database
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: mysql-user
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: mysql-password
        - name: APP_ENV
          value: "production"
        - name: APP_DEBUG
          value: "false"
        volumeMounts:
        - name: app-data
          mountPath: /var/www/html
        - name: laravel-storage
          mountPath: /var/www/html/storage/app/public
        resources:
          requests:
            cpu: "200m"
            memory: "512Mi"
          limits:
            cpu: "500m"
            memory: "1Gi"
      
      volumes:
      - name: app-data
        emptyDir: {}
      - name: laravel-storage
        persistentVolumeClaim:
          claimName: laravel-storage-pvc

---
apiVersion: v1
kind: Service
metadata:
  name: laravel-service
  namespace: default
spec:
  type: LoadBalancer
  selector:
    app: laravel
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: laravel-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: laravel-app
  minReplicas: ${replicas_min}
  maxReplicas: ${replicas_max}
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
