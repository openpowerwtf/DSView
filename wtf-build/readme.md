# Crosscompile for win64

* did not try including yet:  ```libsigrok4DSL``` and ```libsigrokdecode4DSL```

* build env, enter to shell

```
docker build dsview/. -t dsview
docker-compose run dsview
```

* in shell, build mxe and crosscompile dsview win64

```
./build_mxe.sh
./build_dsview_win64.sh
./export.sh
```
