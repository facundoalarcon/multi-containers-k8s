## Git Commands
```
git init
git remote add origin <url>
git add .
git commit -m 'comment'
git push -u origin master
```
### change repo
```
git remote -v
git remote remove origin
git remote add origin <url>
```
### show sha
id/sha from the las change
```
git rev-parse HEAD
```
### logs
id/sha from each change
```
git log
```
### revert changes
```
git checkout <sha>
```
