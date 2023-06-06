local name = "shairport";
local go = "1.20.4";
local version = "4.2";

local build(arch, dind) = [{
    kind: "pipeline",
    type: "docker",
    name: arch,
    platform: {
        os: "linux",
        arch: arch
    },
    steps: [
        {
            name: "version",
            image: "debian:buster-slim",
            commands: [
                "echo $DRONE_BUILD_NUMBER > version"
            ]
        },
        {
            name: "shairport",
            image: "docker:" + dind,
            commands: [
                "./shairport/build.sh " + version
            ],
            volumes: [
                {
                    name: "dockersock",
                    path: "/var/run"
                }
            ]
        },
        {
            name: "cli",
            image: "golang:" + go,
            commands: [
                "cd cli",
                "go build -ldflags '-linkmode external -extldflags -static' -o ../build/snap/meta/hooks/install ./cmd/install",
                "go build -ldflags '-linkmode external -extldflags -static' -o ../build/snap/meta/hooks/configure ./cmd/configure",
                "go build -ldflags '-linkmode external -extldflags -static' -o ../build/snap/meta/hooks/pre-refresh ./cmd/pre-refresh",
                "go build -ldflags '-linkmode external -extldflags -static' -o ../build/snap/meta/hooks/post-refresh ./cmd/post-refresh",
                "go build -ldflags '-linkmode external -extldflags -static' -o ../build/snap/bin/cli ./cmd/cli",
            ]
        },
        {
            name: "package",
            image: "debian:buster-slim",
            commands: [
                "VERSION=$(cat version)",
                "./package.sh " + name + " $VERSION "
            ]
        },
        {
            name: "test-integration",
            image: "python:3.8-slim-buster",
            commands: [
              "APP_ARCHIVE_PATH=$(realpath $(cat package.name))",
              "cd test",
              "./deps.sh",
              "py.test -x -s test.py --distro=buster --domain=buster.com --app-archive-path=$APP_ARCHIVE_PATH --device-host=" + name + ".buster.com --app=" + name + " --arch=" + arch
            ]
        },
	{
        name: "test-upgrade",
        image: "python:3.8-slim-buster",
        commands: [
          "APP_ARCHIVE_PATH=$(realpath $(cat package.name))",
          "cd test",
          "./deps.sh",
          "py.test -x -s upgrade.py --distro=buster --ui-mode=desktop --domain=buster.com --app-archive-path=$APP_ARCHIVE_PATH --device-host=" + name + ".buster.com --app=" + name,
        ]
    },
        {
            name: "upload",
        image: "debian:buster-slim",
        environment: {
            AWS_ACCESS_KEY_ID: {
                from_secret: "AWS_ACCESS_KEY_ID"
            },
            AWS_SECRET_ACCESS_KEY: {
                from_secret: "AWS_SECRET_ACCESS_KEY"
            }
        },
        commands: [
          "PACKAGE=$(cat package.name)",
          "apt update && apt install -y wget",
          "wget https://github.com/syncloud/snapd/releases/download/1/syncloud-release-" + arch,
          "chmod +x syncloud-release-*",
          "./syncloud-release-* publish -f $PACKAGE -b $DRONE_BRANCH"
         ],
        when: {
            branch: ["stable", "master"],
            event: [ "push" ]
        }
        }] + [
        {
            name: "artifact",
            image: "appleboy/drone-scp:1.6.4",
            settings: {
                host: {
                    from_secret: "artifact_host"
                },
                username: "artifact",
                key: {
                    from_secret: "artifact_key"
                },
                timeout: "2m",
                command_timeout: "2m",
                target: "/home/artifact/repo/" + name + "/${DRONE_BUILD_NUMBER}-" + arch,
                source: "artifact/*",
		             strip_components: 1
            },
            when: {
              status: [ "failure", "success" ],
              event: [ "push" ]
            }
        }
    ],
     trigger: {
       event: [
         "push",
         "pull_request"
       ]
     },
    services: [
        {
            name: "docker",
            image: "docker:" + dind,
            privileged: true,
            volumes: [
                {
                    name: "dockersock",
                    path: "/var/run"
                }
            ]
        },
        {
            name: name + ".buster.com",
            image: "syncloud/platform-buster-" + arch + ":22.02",
            privileged: true,
            volumes: [
                {
                    name: "dbus",
                    path: "/var/run/dbus"
                },
                {
                    name: "dev",
                    path: "/dev"
                }
            ]
        }
    ],
    volumes: [
        {
            name: "dbus",
            host: {
                path: "/var/run/dbus"
            }
        },
        {
            name: "dev",
            host: {
                path: "/dev"
            }
        },
        {
            name: "shm",
            temp: {}
        },
        {
            name: "dockersock",
            temp: {}
        },
        {
            name: "videos",
            temp: {}
        },
      ]
},
 {
      kind: "pipeline",
      type: "docker",
      name: "promote-" + arch,
      platform: {
          os: "linux",
          arch: arch
      },
      steps: [
      {
              name: "promote",
              image: "debian:buster-slim",
              environment: {
                  AWS_ACCESS_KEY_ID: {
                      from_secret: "AWS_ACCESS_KEY_ID"
                  },
                  AWS_SECRET_ACCESS_KEY: {
                      from_secret: "AWS_SECRET_ACCESS_KEY"
                  }
              },
              commands: [
                "apt update && apt install -y wget",
                "wget https://github.com/syncloud/snapd/releases/download/1/syncloud-release-" + arch + " -O release --progress=dot:giga",
                "chmod +x release",
                "./release promote -n " + name + " -a $(dpkg --print-architecture)"
              ]
        }
       ],
       trigger: {
        event: [
          "promote"
        ]
      }
  }];

build("amd64", "20.10.21-dind") +
build("arm64", "19.03.8-dind") +
build("arm", "19.03.8-dind")
