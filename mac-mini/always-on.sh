#!/bin/bash
# 맥미니 상시 가동(헤드리스 서버) 설정. sudo로 실행한다.
set -euo pipefail
if [[ $EUID -ne 0 ]]; then
  echo "sudo로 실행하세요: sudo $0" >&2
  exit 1
fi
USER_NAME="${SUDO_USER:?SUDO_USER가 비어 있음}"

echo "==> 잠자기 금지, 정전 후 자동 시작, 네트워크 깨우기"
pmset -a sleep 0 disksleep 0 displaysleep 0 womp 1 autorestart 1 lowpowermode 0 powernap 0

echo "==> macOS 업데이트 자동 설치(무단 재부팅) 끄기. 다운로드·보안 응답은 유지"
defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool false
defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true
defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true

echo "==> 자동 로그인: $USER_NAME (재부팅 후 Herdr 등 유저 프로세스가 올라오게)"
if fdesetup status | grep -q "On"; then
  echo "FileVault가 켜져 있어 자동 로그인을 건너뜁니다." >&2
else
  read -rs -p "$USER_NAME 로그인 비밀번호: " PW; echo
  sysadminctl -autologin set -userName "$USER_NAME" -password "$PW"
  unset PW
fi

echo "==> 결과"
pmset -g | grep -E "^ *(sleep|disksleep|displaysleep|womp|autorestart|lowpowermode|powernap)"
echo "autoLoginUser: $(defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null || echo 없음)"
echo "AutomaticallyInstallMacOSUpdates: $(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates)"
