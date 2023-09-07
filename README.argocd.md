# README Argocd

```
kubectl create namespace argo
kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.4.10/install.yaml

# https://localhost:2746
scoop install argocd
```

Bind the service account to the role (in this case in the argo namespace):

```
kubectl create rolebinding jenkins --role=jenkins --serviceaccount=argo:jenkins
```

Token Creation

You now need to create a secret to hold your token:

```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: jenkins.service-account-token
  annotations:
    kubernetes.io/service-account.name: jenkins
type: kubernetes.io/service-account-token
EOF
```

Wait a few seconds:
```
ARGO_TOKEN="Bearer $(kubectl get secret jenkins.service-account-token -o=jsonpath='{.data.token}' | base64 --decode)"
echo $ARGO_TOKEN
Bearer ZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkltS...
```

## References
 
* https://argoproj.github.io/argo-workflows/access-token/#token-creation