# Herdr

`config.toml`과 `plugins/worktree-hunk/`를 이 저장소에서 관리한다.
`~/.config/herdr`에는 심볼릭 링크를 만들기 때문에 이 맥에서 설정을 수정하면 저장소에도 반영된다.

## 새 맥에서 복원

저장소 루트에서 `./install.sh`를 실행한다. Brewfile의 Herdr·Hunk·Python 설치와
Herdr 설정 연결·플러그인 등록을 포함한다.
이미 의존성이 설치돼 있다면 `./herdr/install.sh`만 실행해도 된다.
기존 설정은 연결 전에 같은 디렉터리의 `.herdr-backup.*` 아래로 백업한다.
Herdr 0.9.5 이상을 사용한다.

## 워크트리 동작

Git 워크트리를 생성하거나 열면 `hunk diff --watch` 탭을 추가한다.
기존 `hunk diff` 탭이 있으면 중복 생성하지 않으며, 현재 작업 탭의 포커스를 유지한다.

기기 전용 워크플로가 필요하면 `~/.config/herdr/private-plugins/worktree-hunk/`에
동일한 플러그인 ID의 로컬 구현을 둔다. 설치 스크립트는 이 경로의 manifest가 있으면 우선 등록한다.
이 디렉터리는 Git으로 동기화되지 않으므로 새 맥에서는 따로 복원해야 한다.
기존 개인 플러그인에 `cleanup.py`가 있으면 설치 시 `hooks/cleanup.py`로 연결한다.
`bootstrap.py`가 있으면 `hooks/bootstrap.py`로 연결하며, Melting 워크트리는
`bun install`과 `bun run db:local:start`로 준비한다. 기존 DB는 초기화하지 않는다.
DB 정리는 별도 프로세스로 실행해 삭제 훅이 기다리지 않는다. 결과와 오류는
`~/.local/state/herdr/plugins/local.worktree-hunk/*.cleanup.log`에 남고,
실패하면 checkout 등록과 setup 완료 기록을 유지한다. 일반 diff 플러그인에는 DB 삭제 훅을 추가하지 않는다.

Herdr 세션, 터미널 내용과 런타임 상태는 이 저장소에 포함하지 않는다.

## 검증

```sh
bash -n install.sh herdr/install.sh
python3 -m unittest discover -s herdr/tests -v
```

테스트는 Herdr CLI를 모의 처리한다. 실제 화면 동작과 새 맥 전체 설치는 별도 확인이 필요하다.
