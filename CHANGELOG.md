# Changelog

## [1.1.5](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/compare/v1.1.4...v1.1.5) (2023-04-24)


### Bug Fixes

* Actually use twiddle-wakka operator for provider dependencies everywhere ([220f6f1](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/220f6f15ba46af86cfd04bb4e90eccde24f1046c))

## [1.1.4](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/compare/v1.1.3...v1.1.4) (2023-04-24)


### Bug Fixes

* Remove .terraform.lock.hcl ([e9ab4f4](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/e9ab4f45340f3a93641a45731750357430c2313d))

## [1.1.3](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/compare/v1.1.2...v1.1.3) (2023-04-24)


### Bug Fixes

* Use twiddle-wakka operator for provider dependencies to pin only by major version ([e7ef922](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/e7ef92229303d4f8dd4dbdf85cd2dbaac35c7c32))

## [1.1.2](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/compare/v1.1.1...v1.1.2) (2023-03-24)


### Bug Fixes

* Use host network,pid and ipc ([69a76a4](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/69a76a4f9721656be30435998e75d8d7d8e757e7))
* vsphere vm guest hostname ([ca5fce9](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/ca5fce9b6cdad48f3f0fcb7688167a8f5c330feb))

## [1.1.1](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/compare/v1.1.0...v1.1.1) (2023-03-01)


### Bug Fixes

* Units should not be mandatory ([dcbd2d4](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/dcbd2d476d7ce94d7f4c335e43524aec147e8490))

## [1.1.0](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/compare/v1.0.0...v1.1.0) (2023-02-15)


### Features

* Add user unit module ([9b8ac7b](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/9b8ac7b2934bc52497eb8bafaa29eacc078ffdc7))

## 1.0.0 (2023-02-09)


### Features

* Add and use directory parents module ([dd7ad94](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/dd7ad945fdda508bfb33625854118706561f815c))
* Add authorized_keys module ([f96470f](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/f96470fc2bb4c45ed709a4c9913e9790a09162a2))
* Add basic terraform structure ([6efb63e](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/6efb63e43c522e1377a67c28b2c82337b71c552d))
* Add KVM based example for testing ([98786b3](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/98786b307db438bb48e1c7ded8271f5c13d097ee))
* Add open-vm-tools for VMware support as service ([d94a4b8](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/d94a4b8dcfaed1d61c48b18016a6c7d08622412b))
* Add pod related modules ([aa5112d](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/aa5112d637f015c1fc8583e0819427aea8972725))
* Add ssh make target ([1e3942b](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/1e3942bb6fba4e37d0d8052bda8acfd29edfd43a))
* Add user variable but still default to core user ([de8ba58](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/de8ba58a5922207c23e1d8315f15ca8adfcd5608))
* Allow pods to be run as specific user ([288bffb](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/288bffb795e74a5182c171ecf0e560d5cf9e0661))
* Change name of pod to comply with naming rules of pod module ([1098638](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/1098638507d54a9ab0c3cd79766c2e8825f946e1))
* Integrate submodules in main module, add global user and group configuration ([8240fed](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/8240fed9a79c9872f74e8d3f05fad498d613116f))
* Make directory parents module input optional ([de4fedd](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/de4feddf6f0671b330abf0cd7dcf9faf93a08249))
* Pass global user to authorized keys module ([bb482ae](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/bb482aeb0cae6c2280001ff78e0450e11a4f3033))
* Remove default to root user ([0212b63](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/0212b635d3869fdda8ec35891230596e9acd1f77))
* Remove podman module ([3382042](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/33820426684fcdd9a46d2d1b57dc38df16ebff9e))
* Remove yaml validation ([cf79d83](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/cf79d8396fe3663133d51ce2a488d54bc7d518b4))
* Take a list of certificates in the ca module ([d7cdac8](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/d7cdac80e792dc8fec29462bb931dfb8b9a7a244))
* Update inputs of pod module ([914baaf](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/914baaf0aabc67f0bd5a2cf9310df9ed026a0e2b))
* Use pod module in node-exporter ([778becf](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/778becf60d10523dc3eb0b5a8a77500e07f73d8c))
* Use proper escaping in pod module ([38b2a51](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/38b2a51fecd9338d2342ce31e09053d5021104b2))


### Bug Fixes

* Actually use the given username in authorized_keys ([0d64251](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/0d64251ac05620a600f59feb3cd9784d75561a66))
* Ensure pod services wait for the network to be online ([65cd301](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/65cd30139c205dbb2a3f180d602b1e90800d96c6))
* Ensure user services are actually started on boot ([7be1c22](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/7be1c22bc20494ef65d503c9f827e981e63a2b8d))
* Explicitly persist container volumes ([b4e3cae](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/b4e3caec1ae915aa9e59edc5a4dbc948bba9310e))
* Remove default to root user from pod-user-module ([c6f5a1e](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/c6f5a1ee884e5116f552e98e5ddce0c41a9957ce))
* Trim and validate for trailing slashes in paths ([5837f84](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/5837f84275e1225652a1b99b83f2e0d37168728d))
* Use ignition snippets instead of terraform merge ([11be1fe](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/11be1fe2e2456dd7f11853afd72b0d3084a2d20d))
* Use proper indentations ([4da982b](https://gitlab.breuni.de/itops/terraform-modules/terraform-module-ignition-blueprints/commit/4da982bc05d8fe16db916e18347666c5a4bc2ef1))
