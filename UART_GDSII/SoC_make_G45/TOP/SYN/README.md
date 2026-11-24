# SYN — UART_GDSII Genus 45nm MMMC 논리 합성

본 폴더는 Cadence Genus 22.17을 사용하여 자작 UART RTL(`uart_top`)을 **단독 칩(`uart_pad`)** 및 **내부 코어 블록(`uart_no_pad`)** 두 가지 MMMC 조건으로 합성한 스크립트, 제약 조건 및 최종 리포트를 정리한다.

---

## 1. 실험 입력 구성 (`uart_pad` vs `uart_no_pad`)

| 항목 | `uart_pad` (단독 칩) | `uart_no_pad` (코어 블록) |
|---|---|---|
| 실행 스크립트 | `uart_run_synthesis` → `script/uart_45nm_mmmc.tcl` | `uart_run_block_synthesis` → `uart_no_pad/uart_45nm_block_mmmc.tcl` |
| RTL 매크로 | `-define USE_IO_PAD` (RX `PADDI`, TX `PADDO` 포함) | 매크로 미정의 (순수 코어 로직만 합성) |
| MMMC 뷰 파일 | `cons/uart_top.mmmc.view` | `uart_no_pad/uart_top_block.mmmc.view` |
| SDC 제약 파일 | `cons/uart_top_mmmc.sdc` | `uart_no_pad/uart_top_block_mmmc.sdc` |
| 타겟 클록 (`UART_CLK`) | `10.0 ns` (`100 MHz`) | `10.0 ns` (`100 MHz`) |
| `o_uart_txd` 출력 부하 | **`1.0 pF`** (외부 칩 핀 구동) | **`0.01 pF`** (내부 블록 배선 부하) |
| 기타 출력 부하 | `0.01 pF` | `0.01 pF` |
| 출력 디렉토리 | `uart_mapped/`, `uart_report/` | `uart_block_mapped/`, `uart_block_report/` |

### MMMC 분석 뷰 (공통)
- **`UART_SS_WORST`**: `slow_vdd1v0` + `pads_SS` (`0.9 V`, `125 ℃`) — Setup 분석
- **`UART_FF_BEST`**: `fast_vdd1v0` + `pads_FF` (`1.1 V`, `0 ℃`) — Setup / Hold 분석

---

## 2. 실행 순서

1. `TOP/SYN/`에서 `./uart_run_synthesis` (`uart_pad`) 또는 `./uart_run_block_synthesis` (`uart_no_pad`) 실행.
2. `read_mmmc` → `read_hdl` → `elaborate uart_top` → `init_design` 수행.
3. `syn_generic` → `syn_map` → `syn_opt` 순차 수행 및 코너별 타이밍/QoR 리포트 출력.
4. `uart_top_syn_final.v`, `uart_top_ss_syn_final.sdc`, `uart_top_ff_syn_final.sdc`, 코너별 SDF 출력.
5. *(참고: `uart_pad` 전용)* PnR 입력 시 `PNR/uart_pad/uart_add_pad`의 전원 패드 16개(각 변 `PADVDDIOR`/`PADVDD`/`PADVSS`/`PADVSSIOR`)를 결합한다.

---

## 3. 합성 결과 비교 (실제 `19_uart_top_SYN_qor.rpt` 기준)

| 지표 | `uart_pad` (`uart_report/`) | `uart_no_pad` (`uart_block_report/`) | 비고 |
|---|---:|---:|---|
| `UART_SS_WORST` Critical Slack | **`+7,079.6 ps` (`+7.080 ns`)** | **`+7,079.6 ps` (`+7.080 ns`)** | Violating `0` |
| `UART_FF_BEST` Critical Slack | **`+9,295.5 ps` (`+9.296 ns`)** | **`+9,295.5 ps` (`+9.296 ns`)** | Violating `0` |
| Leaf Instance Count | **`832`** (Seq `339`, Comb `493`) | **`827`** (Seq `339`, Comb `488`) | 패드 2개 및 관련 버퍼 차이 |
| Cell Area (`㎛²`) | **`32,651.604`** | **`3,847.500`** | RX/TX IO PAD 2개 = `28,800 ㎛²` |

### 부가 트러블슈팅 (`uart_no_pad` 재합성 배경)
- 초기에 `o_uart_txd`에 단독 칩용 `1.0 pF` 부하가 남아 있어 PAD가 없는 코어 블록 PnR 2단계(`PlaceOpt`)에서 `max_cap`/`max_tran` 1건 위반이 발생하였다.
- `uart_top_block_mmmc.sdc`의 `o_uart_txd` 부하를 블록 규격인 **`0.01 pF`**로 정정하여 재합성한 결과, PnR 2단계 DRV 위반이 **`0건`**으로 해소되었다 (상세 비교: [`../PNR/README.md`](../PNR/README.md)).
