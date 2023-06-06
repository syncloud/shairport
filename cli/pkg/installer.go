package pkg

import (
	cp "github.com/otiai10/copy"
	"os"
	"path"
)

const (
	App       = "shareport"
	AppDir    = "/snap/shareport/current"
	DataDir   = "/var/snap/shareport/current"
	CommonDir = "/var/snap/shareport/common"
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
	err := i.UpdateConfigs()
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
	return cp.Copy(path.Join(AppDir, "config"), path.Join(DataDir, "config"))
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
