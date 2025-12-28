{inputs, ...}: {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;

    settings = {
      appLauncher = {
        customLaunchPrefix = "";
        customLaunchPrefixEnabled = false;
        enableClipPreview = true;
        enableClipboardHistory = true;
        pinnedExecs = [];
        position = "center";
        showCategories = true;
        sortByMostUsed =
          true;
        terminalCommand = "kitty -e";
        useApp2Unit = false;
        viewMode = "list";
      };
      audio = {
        cavaFrameRate = 30;
        externalMixer = "pwvucontrol || pavucontrol";
        mprisBlacklist = [];
        preferredPlayer = "";
        visualizerQuality = "low";
        visualizerType = "mirrored";
        volumeOverdrive = false;
        volumeStep = 5;
      };
      bar = {
        capsuleOpacity = 0.75;
        density = "default";
        exclusive = true;
        floating = false;
        marginHorizontal = 0;
        marginVertical = 1;
        monitors = [
        ];
        outerCorners = true;
        position = "left";
        showCapsule = true;
        showOutline = false;
        transparent = false;
        widgets = {
          center = [
            {
              displayMode = "alwaysHide";
              id = "Microphone";
            }
            {
              colorName = "primary";
              hideWhenIdle =
                false;
              id = "AudioVisualizer";
              width = 200;
            }
            {
              displayMode = "alwaysShow";
              id = "Volume";
            }
          ];
          left = [
            {
              characterCount = 1;
              colorizeIcons = false;
              enableScrollWheel = true;
              followFocusedScreen = false;
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "index+name";
              showApplications = false;
              showLabelsOnlyWhenOccupied = false;
            }
            {
              hideMode = "hidden";
              hideWhenIdle = false;
              id = "MediaMini";
              maxWidth = 145;
              scrollingMode = "hover";
              showAlbumArt = true;
              showArtistFirst = true;
              showProgressRing =
                true;
              showVisualizer = false;
              useFixedWidth = false;
              visualizerType = "linear";
            }
          ];
          right = [
            {
              blacklist = [];
              colorizeIcons = true;
              drawerEnabled = false;
              hidePassive = true;
              id = "Tray";
              pinned = [
              ];
            }
            {
              diskPath = "/nix";
              id = "SystemMonitor";
              showCpuTemp = false;
              showCpuUsage = true;
              showDiskUsage =
                false;
              showGpuTemp = false;
              showMemoryAsPercent = true;
              showMemoryUsage = true;
              showNetworkStats =
                false;
              usePrimaryColor = false;
            }
            {
              displayMode = "onhover";
              id = "Bluetooth";
            }
            {
              displayMode = "onhover";
              id = "WiFi";
            }
            {
              deviceNativePath = "BAT0";
              displayMode = "alwaysHide";
              id = "Battery";
              showNoctaliaPerformance = true;
              showPowerProfiles = true;
              warningThreshold = 30;
            }
            {
              customFont = "";
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm ss";
              id = "Clock";
              useCustomFont = false;
              usePrimaryColor = true;
            }
          ];
        };
      };
      brightness = {
        brightnessStep = 5;
        enableDdcSupport = true;
        enforceMinimum = true;
      };
      calendar = {
        cards = [
          {
            enabled = true;
            id = "calendar-header-card";
          }
          {
            enabled =
              true;
            id = "calendar-month-card";
          }
          {
            enabled = true;
            id = "timer-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
        ];
      };
      colorSchemes = {
        darkMode = true;
        generateTemplatesForPredefined = true;
        manualSunrise = "06:30";
        manualSunset = "18:30";
        matugenSchemeType = "scheme-tonal-spot";
        predefinedScheme = "Kanagawa";
        schedulingMode = "off";
        useWallpaperColors = false;
      };
      controlCenter = {
        cards = [
          {
            enabled = true;
            id = "profile-card";
          }
          {
            enabled = true;
            id = "shortcuts-card";
          }
          {
            enabled = true;
            id = "audio-card";
          }
          {
            enabled =
              true;
            id = "brightness-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
          {
            enabled = true;
            id = "media-sysmon-card";
          }
        ];
        position = "close_to_bar_button";
        shortcuts = {
          left = [{id = "WiFi";} {id = "Bluetooth";} {id = "KeepAwake";} {id = "Notifications";}];
          right = [{id = "NightLight";} {id = "DarkMode";} {id = "WallpaperSelector";}];
        };
      };
      desktopWidgets = {
        editMode = false;
        enabled = true;
        monitorWidgets = [
          {
            name = "DP-1";
            widgets = [
              {
                id = "Weather";
                showBackground = true;
                x = 78.4688;
                y =
                  691.602;
              }
            ];
          }
        ];
      };
      dock = {
        backgroundOpacity = 1;
        colorizeIcons = false;
        deadOpacity = 0.6;
        displayMode = "auto_hide";
        enabled = false;
        floatingRatio = 1;
        inactiveIndicators = false;
        monitors = [];
        onlySameOutput =
          true;
        pinnedApps = [];
        pinnedStatic = false;
        size = 2;
      };
      general = {
        allowPanelsOnScreenWithoutBar = true;
        animationDisabled = false;
        animationSpeed = 1;
        avatarImage = "/home/danieln/pictures/avatar-neu.jpg";
        boxRadiusRatio = 1;
        compactLockScreen = false;
        dimmerOpacity = 0;
        enableShadows = true;
        forceBlackScreenCorners =
          true;
        iRadiusRatio = 1;
        language = "en";
        lockOnSuspend = true;
        radiusRatio = 1;
        scaleRatio = 1;
        screenRadiusRatio = 0.5;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        showHibernateOnLockScreen = false;
        showScreenCorners = true;
        showSessionButtonsOnLockScreen = false;
      };
      hooks = {
        darkModeChange = "";
        enabled = false;
        wallpaperChange = "";
      };
      location = {
        analogClockInCalendar = false;
        firstDayOfWeek = 1;
        name = "Stuttgart,\n          Germany";
        showCalendarEvents = true;
        showCalendarWeather =
          true;
        showWeekNumberInCalendar = true;
        use12hourFormat = false;
        useFahrenheit = false;
        weatherEnabled = true;
        weatherShowEffects = true;
      };
      network = {wifiEnabled = true;};
      nightLight = {
        autoSchedule = true;
        dayTemp = "6500";
        enabled = true;
        forced = false;
        manualSunrise = "06:30";
        manualSunset = "18:30";
        nightTemp = "4000";
      };
      notifications = {
        backgroundOpacity = 1;
        criticalUrgencyDuration = 15;
        enableKeyboardLayoutToast = true;
        enabled =
          true;
        location = "top";
        lowUrgencyDuration = 5;
        monitors = [];
        normalUrgencyDuration = 10;
        overlayLayer = true;
        respectExpireTimeout = false;
        sounds = {
          criticalSoundFile = "";
          enabled = false;
          excludedApps = "discord,firefox,chrome,chromium,edge";
          lowSoundFile = "";
          normalSoundFile = "";
          separateSounds = false;
          volume = 0.5;
        };
      };
      osd = {
        autoHideMs = 3000;
        backgroundOpacity = 1;
        enabled = true;
        enabledTypes = [
          1
          2
          4
          0
        ];
        location = "bottom";
        monitors = [];
        overlayLayer = true;
      };
      screenRecorder = {
        audioCodec = "opus";
        audioSource = "default_output";
        colorRange = "limited";
        directory = "/home/danieln/Videos";
        frameRate = 60;
        quality = "very_high";
        showCursor = true;
        videoCodec = "h264";
        videoSource = "portal";
      };
      sessionMenu = {
        countdownDuration = 3000;
        enableCountdown = true;
        position = "center";
        powerOptions = [
          {
            action = "lock";
            command = "";
            countdownEnabled = true;
            enabled = true;
          }
          {
            action = "suspend";
            command = "";
            countdownEnabled =
              true;
            enabled = true;
          }
          {
            action = "hibernate";
            command = "";
            countdownEnabled = true;
            enabled = false;
          }
          {
            action = "reboot";
            command = "";
            countdownEnabled = true;
            enabled = true;
          }
          {
            action = "logout";
            command = "";
            countdownEnabled = true;
            enabled = false;
          }
          {
            action = "shutdown";
            command = "";
            countdownEnabled =
              true;
            enabled = true;
          }
        ];
        showHeader = true;
      };
      settingsVersion = 31;
      systemMonitor = {
        cpuCriticalThreshold = 90;
        cpuPollingInterval = 3000;
        cpuWarningThreshold = 80;
        criticalColor = "";
        diskCriticalThreshold = 90;
        diskPollingInterval = 3000;
        diskWarningThreshold = 80;
        enableNvidiaGpu = false;
        gpuCriticalThreshold = 90;
        gpuPollingInterval = 3000;
        gpuWarningThreshold = 80;
        memCriticalThreshold = 90;
        memPollingInterval = 3000;
        memWarningThreshold = 80;
        networkPollingInterval = 3000;
        tempCriticalThreshold = 100;
        tempPollingInterval = 3000;
        tempWarningThreshold = 80;
        useCustomColors = false;
        warningColor = "";
      };
      templates = {
        alacritty = false;
        cava = true;
        code = false;
        discord = false;
        emacs = false;
        enableUserTemplates = false;
        foot = false;
        fuzzel = false;
        ghostty = true;
        gtk = true;
        kcolorscheme = true;
        kitty = true;
        niri = true;
        pywalfox = false;
        qt = true;
        spicetify = false;
        telegram = false;
        vicinae = false;
        walker = false;
        wezterm =
          false;
        yazi = false;
        zed = false;
      };
      ui = {
        fontDefault = "Iosevka";
        fontDefaultScale = 1;
        fontFixed = "monospace";
        fontFixedScale = 1;
        panelBackgroundOpacity = 0.7;
        panelsAttachedToBar = true;
        settingsPanelMode = "centered";
        tooltipsEnabled = true;
      };
      wallpaper = {
        directory = "/home/danieln/Pictures/Wallpapers";
        enableMultiMonitorDirectories = false;
        enabled = true;
        fillColor = "#000000";
        fillMode = "crop";
        hideWallpaperFilenames = true;
        monitorDirectories = [];
        overviewEnabled = false;
        panelPosition = "center";
        randomEnabled = false;
        randomIntervalSec = 300;
        recursiveSearch = false;
        setWallpaperOnAllMonitors = true;
        transitionDuration = 1500;
        transitionEdgeSmoothness = 0.03;
        transitionType = "random";
        useWallhaven = true;
        wallhavenCategories = "100";
        wallhavenOrder = "desc";
        wallhavenPurity = "100";
        wallhavenQuery = "nix";
        wallhavenResolutionHeight = "";
        wallhavenResolutionMode = "atleast";
        wallhavenResolutionWidth = "";
        wallhavenSorting = "views";
      };
    };
  };
}
