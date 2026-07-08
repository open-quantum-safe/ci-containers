## OQS CI-Containers

The **Open Quantum Safe (OQS) project** has the goal of developing and prototyping quantum-resistant cryptography. This repository contains Dockerfiles that establish the environments used for CI testing of the various OQS sub-projects.

The images are published to Docker Hub under [`openquantumsafe`](https://hub.docker.com/u/openquantumsafe), e.g. `openquantumsafe/ci-ubuntu-latest`.

### Consuming these images

`:latest` (and any other version-less tag) is a **mutable** pointer: the image it resolves to can change at any time, so CI pinned to it runs whatever was pushed most recently, without review. We recommend pinning the immutable content digest instead:

```yaml
jobs:
  build:
    container:
      image: openquantumsafe/ci-ubuntu-latest@sha256:52c9f9c763619c6495b34948c03b613ef1300deba8e615a26ea603d5ab0cfc47
```

You can read the current digest of any published image with:

```console
$ docker buildx imagetools inspect openquantumsafe/ci-ubuntu-latest:latest --format '{{ .Manifest.Digest }}'
```

### Version-change notifications

This repository can open an issue on your project's repository whenever a new version of an image you depend on is published.

**How it works.** Each image's Dockerfile carries a `LABEL version="N"`. When a change to `main` bumps that label and the image is (re)published to Docker Hub, the [`Notify subscribers`](.github/workflows/notify.yml) workflow resolves the newly published multi-arch digest and opens an issue on every subscribed repository. Issues are posted by the [`oqs-bot`](https://github.com/oqs-bot) account and contain the new version, the `@sha256:...` digest to pin, and a link to verify it on Docker Hub.

**Subscribing.** Subscriptions are limited to repositories in the [`open-quantum-safe`](https://github.com/open-quantum-safe) organization. To subscribe, open a pull request adding your project to [`subscribers.yml`](subscribers.yml); once it is merged, you will receive an issue the next time one of your watched images is republished.

```yaml
subscribers:
  - repo: open-quantum-safe/oqs-provider   # open-quantum-safe repository that receives the issue
    images:                                 # images to watch (no "openquantumsafe/" prefix)
      - ci-ubuntu-latest
      - ci-ubuntu-jammy
      - ci-alpine-amd64
    mention:                                # optional: usernames to @-mention
      - baentsch
```

The watchable images are those this repository publishes: `ci-ubuntu-focal`, `ci-ubuntu-jammy`, `ci-ubuntu-latest`, and `ci-alpine-amd64`. A [validation workflow](.github/workflows/validate-subscribers.yml) checks your entry when you open the PR.

**Not part of `open-quantum-safe`?** This notifier is currently limited to the organization's own repositories. If there is demand to notify projects elsewhere, please open an issue or pull request to register your interest.

**For maintainers of this repository.** The default `GITHUB_TOKEN` cannot open issues on other repositories, so notifications run as the `oqs-bot` account, which is a member of the `open-quantum-safe` organization. Store a **fine-grained** personal access token for `oqs-bot` in the `NOTIFY_TOKEN` repository or organization secret, scoped to:

- **Resource owner:** `open-quantum-safe`
- **Repository access:** the subscriber repositories (or all organization repositories)
- **Permissions:** _Issues → Read and write_ — nothing else

An organization admin must approve the token, and fine-grained tokens expire (maximum one year), so it needs periodic rotation. If `NOTIFY_TOKEN` is unset the workflow skips notification without failing. Re-announce a specific image manually via the workflow's `workflow_dispatch` trigger.

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
