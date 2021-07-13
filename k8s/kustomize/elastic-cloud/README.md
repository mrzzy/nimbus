# Elasticsearch Users & Roles

Use [File Realm](https://www.elastic.co/guide/en/cloud-on-k8s/master/k8s-users-and-roles.html#k8s_file_realm)
to configure Users Credentials & Roles for Elasticsearch

> :warning: Ensure that the `filerealm/` directed is not commited.
> Instead the generated sealed secret is safe to commit.

## Creating a File Realm
Creating a File Realm

```sh
mkdir filerealm
touch filerealm/users filerealm/users_roles
```


## Add Users
Add Users & Roles via Elasticsearch Container to the File Realm

```sh
docker run \
    -v $(pwd)/filerealm:/usr/share/elasticsearch/config \
    docker.elastic.co/elasticsearch/elasticsearch:7.13.3 \
    bin/elasticsearch-users useradd myuser -p mypassword -r myrole
```

## Regenerate Sealed Secret
Regenerate Sealed Secrets with the Project Makefile:

```sh
make -C ../../../ $(pwd) all
```
