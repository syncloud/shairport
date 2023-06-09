package pkg

import (
	cp "github.com/otiai10/copy"
	"os"
	"path"
)

const (
	App       = "shairport"
	AppDir    = "/snap/shairport/current"
	DataDir   = "/var/snap/shairport/current"
	CommonDir = "/var/snap/shairport/common"
)

type Installer struct {
	NewVersionFile     string
	CurrentVersionFile string
}

func New() *Installer {
	return &Installer{
		NewVersionFile:     path.Join(AppDir, "version"),
		CurrentVersionFile: path.Join(DataDir, "version"),
	}
}

func (i *Installer) Install() error {
	err := CreateUser(App)
	if err != nil {
		return err
	}
	err = i.AddToUserGroups()
	if err != nil {
		return err
	}
	err = i.UpdateConfigs()
	if err != nil {
		return err
	}

	err = os.Mkdir(path.Join(CommonDir, "log"), 0755)
	if err != nil {
		return err
	}

	err = i.FixPermissions()
	if err != nil {
		return err
	}
	return nil
}

func (i *Installer) Configure() error {
	return i.UpdateVersion()
}

func (i *Installer) PreRefresh() error {
	return nil
}

func (i *Installer) PostRefresh() error {
	err := i.AddToUserGroups()
	if err != nil {
		return err
	}
	err = i.UpdateConfigs()
	if err != nil {
		return err
	}

	err = i.ClearVersion()
	if err != nil {
		return err
	}

	err = i.FixPermissions()
	if err != nil {
		return err
	}
	return nil

}

func (i *Installer) ClearVersion() error {
	return os.RemoveAll(i.CurrentVersionFile)
}

func (i *Installer) UpdateVersion() error {
	return cp.Copy(i.NewVersionFile, i.CurrentVersionFile)
}

func (i *Installer) UpdateConfigs() error {
	err := cp.Copy(path.Join(AppDir, "config"), path.Join(DataDir, "config"))
	if err != nil {
		return err
	}
	err = cp.Copy(path.Join(AppDir, "config", "shairport-dbus.conf"), path.Join("/etc/dbus-1/system.d", "shairport-dbus.conf"))
	if err != nil {
		return err
	}
	alsaConfDir := "/usr/share/alsa"
	if _, err := os.Stat(alsaConfDir); os.IsNotExist(err) {
		err = cp.Copy(path.Join(AppDir, "/shairport/usr/share/alsa"), alsaConfDir)
		if err != nil {
			return err
		}
	}
	return nil

}

func (i *Installer) FixPermissions() error {
	err := Chown(DataDir, App)
	if err != nil {
		return err
	}
	err = Chown(CommonDir, App)
	if err != nil {
		return err
	}
	return nil
}

func (i *Installer) AddToUserGroups() error {
	err := AddUserToGroup(App, "audio")
	if err != nil {
		return err
	}
	return nil
}
