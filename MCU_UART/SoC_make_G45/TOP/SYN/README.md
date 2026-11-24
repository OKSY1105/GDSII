# SYN — MCU_UART Genus 45nm 2단계 논리 합성

본 폴더는 Cadence Genus 22.17을 이용하여 `cmsdk_mcu`(ARM Cortex-M0 + 자작 8E1 UART2 통합 SoC)를 GPDK045 45nm 공정에 합성하기 위한 스크립트, SDC/MMMC 제약 및 최종 합성 리포트를 관리한다.

---

## 1. 실험 입력 구성 (무엇을 연결하여 합성하였는가)

- **라이브러리**: GPDK045 45nm SVT (`slow_vdd1v0_basicCells.lib`, `PVT_0P9V_125C`) 및 IO 패드 (`pads_SS_s1vg.lib`)
- **제약 조건**:
  - `cons/mcu_uart.sdc`: `MAIN_CLOCK` 주기 **`8.0 ns` (`125 MHz`)** (`XTAL1`), 입력 지연 `max 0.1 ns` / `min 0.01 ns`, 출력 지연 `max 0.1 ns` / `min -0.01 ns`, 출력 부하 `PADDO/A`
  - `cons/mcu_uart.mmmc.view`: `FUNC_SS_WORST` (`0.9 V`, `125 ℃`) / `FUNC_FF_BEST` (`1.1 V`, `0 ℃`) 뷰 정의
- **합성 스크립트**: `mcu_uart_run_synthesis` → `script/mcu_uart_45nm.tcl` (MMMC 변형: `script/mcu_uart_45nm_mmmc.tcl`)
- **RTL 입력 구조 (2단계 계층 합성)**:
  1. **1단계 (`cmsdk_mcu_system`)**: Cortex-M0 코어 + AHB/APB 서브시스템 + 자작 `uart_apb` 6개 모듈(`gen_apb_uart_2.u_apb_uart_2`) 합성 → `mcu_uart_system_syn_final.v`
  2. **2단계 (`cmsdk_mcu`)**: 1단계 합성 넷리스트 + 클록 제어기(`cmsdk_mcu_clkctrl`) + 최상위 IO 패드 링을 결합하여 Top 합성 → `mcu_uart_mapped/mcu_uart_syn_final.v`, `mcu_uart_syn_final.sdc`, `mcu_uart_delays.sdf`

---

## 2. 실행 순서

1. `TOP/SYN/`에서 `./mcu_uart_run_synthesis` 실행.
2. `read_hdl` → `elaborate cmsdk_mcu` → `check_design` (`00_check_design.rpt`) 및 `check_timing_intent` (`01_check_timing_intent.rpt`) 확인.
3. `syn_generic` → `syn_map` → `syn_opt` 순차 수행 및 단계별 QoR/Timing 리포트(`syn_*_qor.rpt`) 생성.
4. 최종 넷리스트(`mcu_uart_syn_final.v`), SDC(`mcu_uart_syn_final.sdc`), SDF(`mcu_uart_delays.sdf`) 및 최종 리포트(`08_*` ~ `20_*`) 출력.

---

## 3. 합성 결과 요약 (실제 리포트 기준)

### 3-1. QoR 및 타이밍 (`mcu_uart_report/19_cmsdk_mcu_SYN_qor.rpt`)

| 항목 | 값 |
|---|---|
| 최상위 모듈 / 동작 조건 | `cmsdk_mcu` / `PVT_0P9V_125C` (`FUNC_SS_WORST`) |
| 타겟 클록 (`MAIN_CLOCK`) | `8.0 ns` (`125 MHz`) |
| Critical Path Setup Slack | **`+4,296.1 ps` (`+4.296 ns`)** |
| TNS / Violating Paths | **`0.0` / `0`** |
| 총 Leaf Instance 수 | **`15,403`** (Sequential `2,545` + Combinational `12,858`) |
| 총 Cell Area / Net Area / Total Area | `2,215,486.51 ㎛²` / `20,590.51 ㎛²` / `2,236,077.02 ㎛²` (IO PAD 면적 포함) |
| 평균 Fanout / Max Fanout | `2.5` / `1,708` (`FCLK`) |

### 3-2. 주요 계층별 면적 (`mcu_uart_report/09_cmsdk_mcu_SYN_area.rpt`)

| 계층 인스턴스 | 셀 수 | Cell Area (`㎛²`) | Total Area (`㎛²`) |
|---|---:|---:|---:|
| `cmsdk_mcu` (Top + IO PAD 포함) | `15,403` | `2,215,486.51` | `2,236,077.02` |
| └ `u_cmsdk_mcu_system` (코어 전체) | `15,200` | `41,009.90` | `60,851.17` |
| &nbsp;&nbsp;└ `u_apb_subsystem` | `5,118` | `15,055.18` | `21,364.94` |
| &nbsp;&nbsp;&nbsp;&nbsp;└ **`gen_apb_uart_2.u_apb_uart_2` (자작 UART2)** | **`1,320`** | **`3,968.23`** | **`5,533.76`** |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└ `u_uart_top` (`rx 591` + `tx 547` + `baud 38`) | `1,176` | `3,545.86` | `4,960.43` |
| &nbsp;&nbsp;&nbsp;&nbsp;└ `u_apb_uart_0` / `u_apb_uart_1` (기존 CMSDK UART, 각) | `480` | `1,353.98` | `1,902.37` |

### 3-3. 합성 단계 전력 추정 (`mcu_uart_report/18_cmsdk_mcu_SYN_pwr.rpt`)

| 항목 | Leakage | Internal | Switching | Total | 비중 |
|---|---:|---:|---:|---:|---:|
| Pad | `5.892 mW` | `80.684 mW` | `2.101 mW` | `88.677 mW` | `96.24%` |
| Register + Logic + Clock | `0.002 mW` | `1.902 mW` | `1.562 mW` | `3.466 mW` | `3.76%` |
| **합계** | **`5.895 mW`** | **`82.586 mW`** | **`3.663 mW`** | **`92.144 mW`** | **`100.00%`** |

---

## 4. PnR 연계를 위한 SDC 트러블슈팅 기록

- 2단계 합성 시 `u_cmsdk_mcu_system`을 미리 합성된 블록으로 읽으면서 `mcu_uart_mapped/mcu_uart_syn_final.sdc` 586행에 `set_dont_touch [get_cells u_cmsdk_mcu_system]` 제약이 자동 기록되었다.
- 이로 인해 Innovus PnR 2단계(`PlaceOpt`)에서 내부 버퍼 삽입·사이징이 전면 차단되어 Setup WNS `-5.189 ns` (861경로 위반)가 발생하였다.
- 해당 586행을 주석 처리하고 PnR `0 → 1 → 2`단계를 클린 재실행하여 `optDesign` Setup WNS **`+0.002 ns` (`0` 위반)**으로 완전 해소하였다 (상세 캡처: [`../PNR/README.md`](../PNR/README.md)).
