# MCU_UART — ARM Cortex-M0 SoC UART2 교체 및 RTL-to-GDSII 구현

본 프로젝트는 ARM Cortex-M0 DesignStart 기반 `cmsdk_mcu` SoC의 기존 예제 UART2(`cmsdk_apb_uart`)를 **직접 설계한 16B FIFO · 8E1 UART IP 및 21핀 APB Wrapper(`uart_apb_wrapper`)**로 교체하여 **RTL 통합 → 2단 논리 합성 → Pre-LEC → Pre-Layout SIM → Innovus PnR 0~5단계 → Tempus Sign-off STA → Post-LEC → Post-Layout Gate+SDF SIM (`max`/`min`)** 전 과정을 완주한 결과다.

> **저작권 보호 안내**: ARM DesignStart / CMSDK 원본 RTL, 파생 게이트 넷리스트(`.v`), SDF(`.sdf`), GPDK045 라이브러리 및 `.gds` 바이너리는 본 저장소에 포함하지 않는다. 자작 RTL(`uart_apb`), 테스트벤치, 실행 스크립트, 제약 조건, 리포트 및 검증 캡처 이미지만 공개한다.

---

## 설계 구조 (Plan B 평면 통합)

- **교체 대상**: `cmsdk_apb_subsystem` 내부 `gen_apb_uart_2.u_apb_uart_2`
- **호환성 설계**: `uart_apb_wrapper.v`가 기존 `cmsdk_apb_uart`와 동일한 21개 포트 및 APB 레지스터 오프셋(`0x000`~`0x010`)을 제공하므로, 주변 AHB/APB 서브시스템과 기존 `hello.hex` 펌웨어를 수정하지 않고 즉시 통합한다.
- **동작 조건**: 시스템 클록 `125 MHz` (`8 ns`), UART 프레임 `8E1` (8-bit Data + Even Parity + 1 Stop), `115200 baud` (`OS_DIV = 68`, 보레이트 오차 `-0.27%`).
- **칩 구성**: Die `4,030 × 4,030 ㎛`, Core `~1,150 × 1,150 ㎛`, 총 `204`개 PAD (Signal `151` + Power `49` + Corner `4`, 70 ㎛ 피치).

---

## 단계별 검증 요약 및 핵심 트러블슈팅

| 단계 | 상세 문서 | 최종 결과 | 핵심 트러블슈팅 / 개선 |
|---|---|---|---|
| **자작 RTL** | [`uart_apb/README.md`](cortexm0_designstart/logical/uart_apb/README.md) | 6개 Verilog 모듈 (`u_apb_uart_2` 합성 `1,320` cells, `5,533.8 ㎛²`) | 21핀 포트·레지스터 맵 100% 호환 APB Wrapper 설계 |
| **시뮬레이션** | [`TOP/SIM/README.md`](SoC_make_G45/TOP/SIM/README.md) | 단위 `23/23 PASS`, Pre-SIM SDF `94.26%`, Post-SIM `max`/`min` SDF **`98.26%`** · 위반 `0` · `TEST Passed` | `saveNetlist -flat` vs 계층형 SDF 충돌(`0.92%`) 규명 → `mcu_uart_hier.v` 분리로 `98.26%` 달성 |
| **논리 합성** | [`TOP/SYN/README.md`](SoC_make_G45/TOP/SYN/README.md) | Stage 1/2 Violating `0`, `15,403` cells (`2,545` DFF), Setup Slack `+4.296 ns` | 2차 합성 SDC 586행 `set_dont_touch` 원인 식별 |
| **등가성 검증** | [`TOP/EC/README.md`](SoC_make_G45/TOP/EC/README.md) | Pre-LEC **`2,621/2,621` PASS**, Post-LEC **`2,621/2,621` PASS** | Golden/Revised 전체 비교점(PO 77 + DFF 2,544) 100% 등가 검증 |
| **PnR & Tempus** | [`TOP/PNR/README.md`](SoC_make_G45/TOP/PNR/README.md) | Post-Route Setup `+0.026 ns` / Hold `+0.005 ns`, DRC·Conn **`0/0`**, Power **`77.47 mW`**, Tempus Real Net **`100%`** · 전 항목 **`0 Violated`** | SDC `set_dont_touch` 해제(`WNS -5.189 → +0.002 ns`), `-ignorePGPin`(`32 → 0 Viols`), `holdTargetSlack 0.02` 선제 반영으로 **6단계 ECO 없이 1회 Sign-off** |

---

## 폴더 구성

```text
MCU_UART/
├── README.md                                   ← 본 문서
├── cortexm0_designstart/logical/uart_apb/      ← 자작 APB Wrapper + 8E1 UART RTL (6개)
└── SoC_make_G45/TOP/
    ├── SIM/                                    ← UNIT / FUNCTION / PRE / POST(max, min)
    ├── SYN/                                    ← Genus 45nm 합성 스크립트·SDC·리포트
    ├── EC/                                     ← Conformal Pre-LEC / Post-LEC 스크립트 및 캡처
    └── PNR/                                    ← Innovus 0~5단계 + Tempus STA 스크립트·리포트·캡처
```
