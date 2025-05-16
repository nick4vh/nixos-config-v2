# nixos-config/modules/home-manager/nick/shells.nix
{ pkgs, config, lib, ... }:

let
  # Standard-Shell auswählen: "zsh" oder "fish"
  defaultShellChoice = "zsh";

  # Aliase, die in beiden Shells verfügbar sein sollen
  commonAliases = {
    ls = "${pkgs.eza}/bin/eza --git --icons --color=always --group-directories-first"; # Moderner ls mit eza
    ll = "${pkgs.eza}/bin/eza -l --git --icons --color=always --group-directories-first";
    la = "${pkgs.eza}/bin/eza -la --git --icons --color=always --group-directories-first";
    l = "${pkgs.eza}/bin/eza -lbGF --git --icons --color=always --group-directories-first"; # Eine Zeile pro Eintrag
    lt = "${pkgs.eza}/bin/eza --tree --level=2 --git --icons --color=always";
    cat = "${pkgs.bat}/bin/bat -p --theme=Catppuccin-mocha"; # Cat mit bat und Theme

    # NixOS und Home Manager Befehle
    # Die Variablen FLAKE_TARGET und FLAKE_HOSTNAME werden in default.nix (home.sessionVariables) gesetzt
    # basierend auf den Werten, die vom Flake übergeben werden.
    nrs = "sudo nixos-rebuild switch --flake ~/nixos-config#${config.home.sessionVariables.FLAKE_TARGET or "host1-kde"}";
    nrb = "sudo nixos-rebuild boot --flake ~/nixos-config#${config.home.sessionVariables.FLAKE_TARGET or "host1-kde"}";
    nrt = "sudo nixos-rebuild test --flake ~/nixos-config#${config.home.sessionVariables.FLAKE_TARGET or "host1-kde"}";
    hms = "home-manager switch --flake ~/nixos-config#nick@${config.home.sessionVariables.FLAKE_HOSTNAME or "host1"}";
    hmg = "home-manager generations -u nick@${config.home.sessionVariables.FLAKE_HOSTNAME or "host1"}";

    # Git Aliase
    ga = "git add";
    gc = "git commit -m";
    gs = "git status";
    gp = "git push";
    gl = "git log --graph --oneline --decorate --all";
    gd = "git diff";

    # Weitere nützliche Aliase
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    update-grub = "sudo grub-mkconfig -o /boot/grub/grub.cfg"; # Falls manuell GRUB aktualisiert werden muss
  };
in
{
  programs.zsh = {
    enable = (defaultShellChoice == "zsh");
    enableAutosuggestions = true; # Verwendet zsh-autosuggestions
    enableCompletion = true;      # Aktiviert das Zsh-Completion-System
    # syntaxHighlighting.enable = true; # Verwendet zsh-syntax-highlighting
    # Die Pakete dafür (zsh-autosuggestions, zsh-syntax-highlighting) werden in packages.nix hinzugefügt

    shellAliases = commonAliases // {
      # Zsh-spezifische Aliase hier
    };

    # Oh My Zsh (optional, viele bevorzugen schlankere Setups mit Plugin-Managern)
    # ohMyZsh = {
    #   enable = true;
    #   plugins = [ "git" "sudo" "docker" ];
    #   theme = "agnoster"; # Oder ein anderes Theme
    # };

    # Empfehlung: Zinit, Antigen oder manuelles Sourcing für Plugins
    # Hier ein Beispiel für manuelles Sourcing der via nixpkgs installierten Plugins:
    initExtra = ''
      # Starship Prompt
      if command -v starship &> /dev/null; then
        eval "$(starship init zsh)"
      fi

      # Direnv (falls verwendet und nicht schon global aktiviert)
      if command -v direnv &> /dev/null; then
        eval "$(direnv hook zsh)"
      fi

      # Zsh Syntax Highlighting (falls nicht über HM Option aktiviert)
      if [ -f "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
        source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      fi
      ZSH_HIGHLIGHT_STYLES[path]=underline

      # Zsh Autosuggestions (falls nicht über HM Option aktiviert)
      if [ -f "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
        source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
      fi
      # Optional: Farbe der Autosuggestions anpassen
      # ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=gray'

      # Zsh Completions (falls nicht über HM Option aktiviert)
      if [ -f "${pkgs.zsh-completions}/share/zsh-completions/zsh-completions.plugin.zsh" ]; then
          fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
      fi

      # FZF keybindings and fuzzy completion
      # Needs fzf to be installed (added in packages.nix)
      source ${pkgs.fzf}/shell/key-bindings.zsh
      source ${pkgs.fzf}/shell/completion.zsh

      # History settings
      HISTFILE=~/.zsh_history
      HISTSIZE=10000
      SAVEHIST=10000
      setopt appendhistory sharehistory incappendhistory extendedglob
    '';
    # history = { # Alternative Konfiguration für History
    #   size = 10000;
    #   path = "${config.xdg.dataHome}/zsh/history";
    #   share = true; # Share history between sessions
    # };
  };

  programs.fish = {
    enable = (defaultShellChoice == "fish");
    shellAliases = commonAliases // {
      # Fish-spezifische Aliase hier
    };

    # Plugins über Fisher (oder andere Manager wie Oh My Fish, Fundle)
    # Fisher wird oft bevorzugt, da es leichtgewichtig ist.
    # `fisher` muss als Paket in `home.packages` hinzugefügt werden.
    # plugins = [
    #   { name = "PatrickF1/fzf.fish"; src = pkgs.fetchFromGitHub { owner = "PatrickF1"; repo = "fzf.fish"; rev = "v9.0"; sha256 = "sha256-hash-hier"; }; }
    #   { name = "jethrokuan/z"; src = pkgs.fetchFromGitHub { owner = "jethrokuan"; repo = "z"; rev = "master"; sha256 = "sha256-hash-hier"; }; }
    #   # Weitere Plugins...
    # ];

    interactiveShellInit = ''
      # Starship Prompt
      if command -v starship &> /dev/null
        starship init fish | source
      end

      # Direnv (falls verwendet)
      if command -v direnv &> /dev/null
        direnv hook fish | source
      end

      # fzf keybindings (falls fzf installiert ist)
      if command -v fzf &> /dev/null
        fzf_key_bindings
      end

      # Deaktiviert die Begrüßungsnachricht von Fish
      set -g fish_greeting

      # Weitere Fish-spezifische Konfigurationen
      # set -U FZF_LEGACY_KEYBINDINGS 0 # Use new fzf bindings
    '';
  };

  # fzf Konfiguration (gilt für beide Shells, wenn fzf verwendet wird)
  programs.fzf = {
    enable = true;
    enableZshIntegration = (defaultShellChoice == "zsh");
    enableFishIntegration = (defaultShellChoice == "fish");
    defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git"; # Standardbefehl für fzf
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
    # Keybindings werden oft von den Shell-Integrationen (zsh/fish) bereitgestellt.
  };
}
