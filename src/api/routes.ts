//动态路由

export const getAsyncRoutes = () => {
  return [{
    path: "/page/QuickSettings",
    meta: {
      title: "快速设置",
      icon: "mingcute:settings-2-line",
      rank: 1//菜单排序
    },
    children: [
      {
        path: "/page/QuickSettings/index",
        name: "QuickSettings",
        meta: {
          title: "快速设置",
          roles: ["admin"]
        }
      },
      {
        path: "/page/QuickSettings/DataPlan",
        name: "DataPlan",
        meta: {
          title: "流量管理",
          roles: ["admin"]
        }
      },
      {
        path: "/page/QuickSettings/VPN",
        name: "VPN",
        meta: {
          title: "VPN设置",
          roles: ["admin"]
        }
      },
      {
        path: "/page/QuickSettings/APN",
        name: "APN",
        meta: {
          title: "APN设置",
          roles: ["admin"]
        }
      },
      {
        path: "/page/QuickSettings/iframe",
        name: "Yiframe",
        meta: {
          showLink: false,
          title: "外部URL",
          roles: ["admin"]
        }
      }
    ]
  }, {
    path: "/page/connect/sms",
    meta: {
      title: "短信列表",
      icon: "wpf:message-outline",
      rank: 2//菜单排序
    },
    children: [
      {
        path: "/page/connect/sms",
        name: "sms",
        meta: {
          title: "短信列表",
          roles: ["admin"]
        }
      }
    ]
  }, {
    path: "/page/connect",
    meta: {
      title: "WIFI设置",
      icon: "material-symbols:wifi-proxy-rounded",
      rank: 3//菜单排序
    },
    children: [
      {
        path: "/page/connect/list",
        name: "connect",
        meta: {
          title: "连接列表",
          roles: ["admin"]
        }
      },
      {
        path: "/page/connect/index",
        name: "AdvancedSetting",
        meta: {
          title: "Wi-Fi 性能设置",
          roles: ["admin"]
        }
      },
      {
        path: "/page/connect/route",
        name: "route",
        meta: {
          title: "Wi-Fi 路由设置",
          roles: ["admin"]
        }
      },
      {
        path: "/page/connect/WifiBand",
        name: "WifiBand",
        meta: {
          title: "Wi-Fi 频段设置",
          roles: ["admin"]
        }
      }
    ]
  }, {
    path: "/page/AdvancedSetting",
    meta: {
      title: "高级设置",
      icon: "icon-park-twotone:setting-web",
      rank: 4//菜单排序
    },
    children: [
      {
        path: "/page/AdvancedSetting/SimSwitch",
        name: "SimSwitch",
        meta: {
          title: "SIM卡选择",
          roles: ["admin"]
        }
      },
      {
        path: "/page/AdvancedSetting/AT",
        name: "AT",
        meta: {
          title: "AT命令",
          roles: ["admin"]
        }
      },
      {
        path: "/page/AdvancedSetting/Other",
        name: "Other",
        meta: {
          title: "其他设置",
          roles: ["admin"]
        }
      },
      {
        path: "/page/AdvancedSetting/Band",
        name: "Band",
        meta: {
          title: "频段选择",
          roles: ["admin"]
        }
      },
      {
        path: "/page/AdvancedSetting/DDNS",
        name: "DDNS",
        meta: {
          title: "DDNS设置",
          roles: ["admin"]
        }
      },
      {
        path: "/page/AdvancedSetting/TR069",
        name: "TR069",
        meta: {
          title: "TR069设置",
          roles: ["admin"]
        }
      }
    ]
  }];
};
