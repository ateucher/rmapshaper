```
docker build --tag deb-test .
docker run -d -p 8787:8787 -e PASSWORD=hello deb-test:latest
```

Go to localhost:8787 and log in with rstudio/hello. In terminal in Rstudio:

```
git clone https://github.com/ateucher/rmapshaper.git
```

Then open the `rmapshaper.Rproj` and run checks etc.
