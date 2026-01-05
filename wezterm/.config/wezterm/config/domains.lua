local platform = require('utils.platform')

local options = {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   ssh_domains = {},

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = {},
}

if platform.is_win then
   options.ssh_domains = {
      {
         name = 'ssh:wsl',
         remote_address = 'localhost',
         multiplexing = 'None',
         default_prog = { 'fish', '-l' },
         assume_shell = 'Posix',
      },
   }

   options.wsl_domains = {
      {
         name = 'wsl:debian-zsh',
         distribution = 'Debian',
         username = 'karna',
         default_cwd = '/home/karna',
         default_prog = { 'zsh', '-l' },
      },
      {
         name = 'wsl:debian-bash',
         distribution = 'Debian',
         username = 'karna',
         default_cwd = '/home/karna',
         default_prog = { 'bash', '-l' },
      },
   }
end

return options
