# Mac mini 헤드리스 서버 설정

맥미니를 모니터 없이 24시간 켜두고 맥북에서 SSH·화면 공유·Herdr로 쓰기 위한 설정.
`install.sh`에는 포함하지 않는다(서버 전용). 맥미니에서 dotfiles 설치 후 한 번만 실행한다.

## 적용

```sh
# 1. 잠자기 금지, 정전 후 자동 시작, OS 자동 설치(무단 재부팅) 끔, 자동 로그인 등록
sudo ./mac-mini/always-on.sh
# 자동 로그인 비밀번호 저장(SACSetAutoLoginPassword)이 실패하면
# System Settings > Users & Groups > Automatically log in as 에서 직접 등록한다.

# 2. Herdr 서버를 로그인 시 자동 기동, 5분마다 재확인
sed "s#\$HOME#$HOME#g" mac-mini/dev.herdr.server.plist > ~/Library/LaunchAgents/dev.herdr.server.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.herdr.server.plist
```

`herdr server`를 직접 띄우면 detached daemon 표시가 없어 맥북 사이드바 점검이 "stopped"로 실패한다.
그래서 Herdr가 내부적으로 쓰는 `herdr remote-client-bridge`(stdin 닫힘)로 띄운다.

## 수동 항목

- System Settings > General > Sharing: Screen Sharing, Remote Login 켬. Remote Management는 켜지 않는다(켜면 Screen Sharing이 꺼짐).
- Tailscale 설치·로그인 후 로그인 항목에 등록. 관리 콘솔에서 맥미니 노드의 key expiry를 끈다.
- 유선 랜 권장. Wi-Fi는 재부팅 뒤 로그인 전에 붙지 않을 수 있다.
- 맥북 `~/.ssh/config`: `mini`(Tailscale IP), `mini-lan`(effy.local), `ForwardAgent yes`.
- 맥북 WARP는 Zero Trust 디바이스 프로필에서 `100.64.0.0/10`을 제외해야 Tailscale 경로가 산다.
