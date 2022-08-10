Write-Host "Prüfe Administrator-Rechte"
if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "Skript hat bereits Administrator-Rechte."
}
else {
  # Starte das skript neu, als Administrator.
  Write-Host "Evaluate rights..."
  $process = New-Object System.Diagnostics.ProcessStartInfo "powershell"
  $process.Arguments = $myInvocation.MyCommand.Definition;
  $process.Verb = "runas";
  [System.Diagnostics.Process]::Start($process)
  exit
}

function test-cmd($command) {
  return Get-Command $command -errorAction SilentlyContinue
}

# install choco
Write-Host "Prüfe, ob choco installiert ist..."
if (!(test-cmd "choco")) {
  Write-Host "choco is not installed. Installing now..." -ForegroundColor Yellow
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  irm https://community.chocolatey.org/install.ps1 | iex
  choco feature enable -n=allowGlobalConfirmation
}

# install git
Write-Host "Prüfe, ob git installiert ist..."
if (!(test-cmd "git")) {
  Write-Host "git is not installed. Installing now..." -ForegroundColor Yellow
  choco install git
}

# install pyhton
Write-Host "Prüfe, ob python installiert ist..."
if (!(test-cmd "python")) {
  Write-Host "python and pip are not installed. Installing now..." -ForegroundColor Yellow
  choco install python.install
  python -m ensurepip
}

# install make
Write-Host "Prüfe, ob make installiert ist..."
if (!(test-cmd "make")) {
  Write-Host "make is not installed. Installing now..." -ForegroundColor Yellow
  choco install gnuwin32-coreutils.install
}

# install pdflatex
Write-Host "Prüfe, ob pdflatex installiert ist..."
if (!(test-cmd "pdflatex")) {
  Write-Host "pdflatex not found. Installing MikTex now..." -ForegroundColor Yellow
  choco install miktex.install \ThisUser
  Write-Host "Remember to update MikTex dependencies!" -ForegroundColor Yellow
}

# install pandoc
Write-Host "Prüfe, ob pandoc installiert ist..."
if (!(test-cmd "pandoc")) {
  Write-Host "pandoc not found. Installing pandoc and extensions now..." -ForegroundColor Yellow
  choco install pandoc pandoc-crossref
  pip install pandoc-include --user

  Write-Host "Installing pandoc-acro now to ~/apps..."
  if (!(test-path ~/apps)) { mkdir -p ~/apps }
  pushd ~/apps
  git clone https://github.com/kprussing/pandoc-acro.git
  pushd pandoc-acro
  python setup.py install
  popd
  popd
}

if (!(choco find --local rsvg-convert)) {
  Write-Host "libvirt.dll (SVG support) not found. Installing now..." -ForegroundColor Yellow
  choco install rsvg-convert
}