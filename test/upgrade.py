import pytest
from subprocess import check_output
from syncloudlib.integration.hosts import add_host_alias
from syncloudlib.integration.installer import local_install, wait_for_installer

TMP_DIR = '/tmp/syncloud'


def settle(device):
    device.run_ssh('snap wait system seed.loaded', retries=100, throw=False)
    device.run_ssh('snap set system refresh.hold=2099-01-01T00:00:00Z', retries=20, throw=False)
    device.run_ssh('snap abort --last=auto-refresh', throw=False)
    device.run_ssh('snap watch --last=auto-refresh', throw=False)


@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir):
    def module_teardown():
        device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)
        device.run_ssh('journalctl | tail -2000 > {0}/refresh.journalctl.log'.format(TMP_DIR), throw=False)
        device.scp_from_device('{0}/*'.format(TMP_DIR), artifact_dir, throw=False)
        check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)

    request.addfinalizer(module_teardown)


def test_start(module_setup, app, device_host, domain, device):
    add_host_alias(app, device_host, domain)
    device.activated()
    settle(device)
    device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)


def test_install(device, app, app_archive_path, device_host, device_session, device_password, domain):
    device.run_ssh('snap remove {0}'.format(app), throw=False)
    local_install(device_host, device_password, app_archive_path)
    wait_for_installer(device_session, domain)


def test_refresh(app_archive_path, device_host, device_session, device_password, domain):
    local_install(device_host, device_password, app_archive_path)
    wait_for_installer(device_session, domain)


def test_storage_change_event(device):
    device.run_ssh('snap run shairport.storage-change')
