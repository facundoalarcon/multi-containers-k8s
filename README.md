## Docker commands for ruby
```
docker run -it -v $(pwd):/app ruby:2.4 sh
```
### Travis
#### github tokens
https://github.com/settings/tokens
```
gem install travis
travis login --com --github-token <token>
travis encrypt-file service-account.json -r facundoalarcon/multi-k8s --com
```
con esto creamos un archivo json encriptado basado en el json original
el original se borra y se deja solo el encriptado