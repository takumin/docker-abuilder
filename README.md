# docker-abuilder
Alpine Linux Running Abuild Container

# running
```bash
 $ docker run --rm -i -t -v ~/.abuild:/abuild -v $(pwd):/apkbuild takumi/abuilder:edge sh -c 'su-exec abuilder abuild -r || sh'
```
