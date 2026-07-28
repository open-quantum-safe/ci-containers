## OQS CI-Containers

The **Open Quantum Safe (OQS) project** has the goal of developing and prototyping quantum-resistant cryptography. This repository contains Dockerfiles that establish the environments used for CI testing of the various OQS sub-projects.

### Changing an image

Every push to `main` republishes `:latest`, so the `LABEL version` in a Dockerfile is (currently) the only signal consumers get that what they pull has changed. **If you change anything in an image's build context, bump that image's `LABEL version`** to the next whole number; CI fails the pull request otherwise. Republishing under an already-released version could silently change what a downstream project builds against: anyone consuming the mutable `:latest` tag, rather than pinning the image by `@sha256:...` digest, picks the new image up without review.

Before anything is built, [`Pre-build checks`](.github/workflows/checks.yml) lints the Dockerfiles with [hadolint](https://github.com/hadolint/hadolint) (accepted rules are recorded, with reasons, in [`.hadolint.yaml`](.hadolint.yaml)), checks those versions, and runs `shellcheck`, `actionlint` and [`zizmor`](https://docs.zizmor.sh) over the scripts and workflows. Each image is then built and scanned with [Trivy](https://trivy.dev); a fixable critical vulnerability stops it being pushed.

It is recommended to run these tools locally before submitting a pull request, so you can fix any issues before CI runs.

### Adding an image

[`images.yml`](images.yml) contains the full set of this repository's images. The linting, version check, build, scan and push are all derived from it. **Adding a container is a new directory plus an entry in `images.yml`**. A directory holding a Dockerfile that is absent from `images.yml` is not built.

### License

This repository is licensed under the MIT License; see [LICENSE.txt](https://github.com/open-quantum-safe/testing/blob/master/LICENSE.txt) for details.

### Team

The Open Quantum Safe project is led by [Douglas Stebila](https://www.douglas.stebila.ca/research/) and [Michele Mosca](http://faculty.iqc.uwaterloo.ca/mmosca/) at the University of Waterloo.

### Contributors

- Michael Baentsch 
- Ben Davies (University of Waterloo)
- Shravan Mishra (University of Waterloo)
- Christian Paquin (Microsoft Research)
- Douglas Stebila (University of Waterloo)
- Goutam Tamvada (University of Waterloo)
- JT

### Support

Financial support for the development of Open Quantum Safe has been provided by Amazon Web Services and the Canadian Centre for Cyber Security.
We'd like to make a special acknowledgement to the companies who have dedicated programmer time to contribute source code to OQS, including Amazon Web Services, Cisco Systems, evolutionQ, IBM Research, and Microsoft Research.

Research projects which developed specific components of OQS have been supported by various research grants, including funding from the Natural Sciences and Engineering Research Council of Canada (NSERC); see the source papers for funding acknowledgments.
