## Contents
- [get](#get)
    - [namespace](#namespace)
    - [pod](#pod)
- [images](#images)
- [run](#run)
    - [interactive](#interactive)
    - [tty](#tty)



## get
### namespace
To get all the namespace resources
```bash
$ kubectl get namespace
NAME                   STATUS   AGE
default                Active   9d
```

### pod
To get all the pod resources
```bash
$ kubectl get pods -n default
No resources found.
```
## images
To show all the images present
```bash
$ sudo docker images               
Password:
REPOSITORY                           TAG                        IMAGE ID            CREATED             SIZE
ubuntu                               latest                     4e5021d210f6        2 weeks ago         64.2MB
busybox                              latest                     83aa35aa1c79        3 weeks ago         1.22MB
```

## run
### interactive
>--interactive , -i	
>	
>Keep STDIN open even if not attached 
```bash
$ sudo docker run -i ubuntu:latest bash
pwd
/
exit

$
```
### tty
>--tty , -t	
>	
>Allocate a pseudo-TTY

You have to externally kill the container in this case
```bash
$ sudo docker run -t ubuntu:latest bash
root@b01ba82675f5:/# pwd
ls
exit
^C^C
root@b01ba82675f5:/# exit
```

When you combine -i and -t, you get a proper terminal like experience
```bash
$ sudo docker run -i -t ubuntu:latest bash
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
5bed26d33875: Pull complete
f11b29a9c730: Pull complete
930bda195c84: Pull complete
78bf9a5ad49e: Pull complete
Digest: sha256:bec5a2727be7fff3d308193cfde3491f8fba1a2ba392b7546b43a051853a341d
Status: Downloaded newer image for ubuntu:latest
root@e421090e426a:/#
```


## Test
test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test






