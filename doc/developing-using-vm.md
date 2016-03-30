# Developing using the VM

## Installing

NB: this assumes you are running on the GOV.UK virtual machine, not your host.

```bash
./install # git fetch from each dependency dir and bundle install
```

### Installing dependencies

Clone the following repositories:

* [imminence](https://github.com/alphagov/imminence)
* [asset-manager](https://github.com/alphagov/asset-manager)
* [govuk_content_api](https://github.com/alphagov/govuk_content_api)

Then run `bundle install` for each application.

## Running the application

Run using bowler on VM from cd /var/govuk/development:

```bash
bowl smartanswers
```

## Viewing a Smart Answer

To view a smart answer locally if running using bowler http://smartanswers.dev.gov.uk/register-a-birth

## Troubleshooting

### Ruby version error

Check the available versions of ruby by running:

```bash
rbenv versions
```

If the required version of ruby is not available in the list, your virtual machine may be out of date.

To update the GOV.UK virtual machine first pull the latest version of the [govuk-puppet](https://github.com/alphagov/govuk-puppet) repository, then run:

```bash
vagrant provision
```

### DNS cannot resolve host smartanswers.dev.gov.uk

The vagrant-dns plugin may be missing, or may not have installed correctly.

On your base machine, go to the [govuk-puppet](https://github.com/alphagov/govuk-puppet) repository and check the available vagrant plugins:

```bash
vagrant plugin list
```

If the vagrant-dns plugin exists, first uninstall it:

```bash
vagrant plugin uninstall vagrant-dns
```

Then install it again:

```bash
vagrant plugin install vagrant-dns
```

N.B. If the plugin was missing, you just need to follow the install step.

Finally, restart vagrant by running `vagrant halt` followed by `vagrant up`.
