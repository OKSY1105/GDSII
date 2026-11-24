# UART_GDSII — 자작 8E1 UART RTL-to-GDSII 구현 (`uart_pad` & `uart_no_pad`)

본 프로젝트는 직접 설계한 **16B FIFO · 8E1 UART IP (`uart_top`)**를 Cadence GPDK045 45nm 공정으로 구현하고, **단독 칩 버전(`uart_pad`, 46 PAD)**과 **MCU 내부 블록 버전(`uart_no_pad`, PAD 제외)** 두 가지 형태로 RTL-to-GDSII 전 과정을 완료·검증한 결과다.

---

## 전체 검증 완료 현황

| 항목 | `uart_pad` (단독 칩, 46 PAD) | `uart_no_pad` (코어 블록, PAD 제외) | 상세 문서 |
|---|---|---|---|
| **RTL 구성** | `uart_top` + 4개 하위 모듈 (`-define USE_IO_PAD`) | 동일 RTL (`USE_IO_PAD` 미정의) | [`TOP/RTL/README.md`](SoC_make_G45/TOP/RTL/README.md) |
| **기능 시뮬레이션** | 28바이트 ASCII 에코 `TEST PASSED` | 28바이트 ASCII 에코 `TEST PASSED` | [`TOP/SIM/README.md`](SoC_make_G45/TOP/SIM/README.md) |
| **논리 합성 (Genus MMMC)** | `10 ns` (`100 MHz`), `832` cells, `32,651.6 ㎛²`, SS `+7.080 ns` | `10 ns` (`100 MHz`), `0.01 pF`, `827` cells, `3,847.5 ㎛²`, SS `+7.080 ns` | [`TOP/SYN/README.md`](SoC_make_G45/TOP/SYN/README.md) |
| **Pre-Layout LEC** | **`356 / 356` Equivalent PASS** (PO 17 + DFF 339) | **`356 / 356` Equivalent PASS** (PO 17 + DFF 339) | [`TOP/EC/README.md`](SoC_make_G45/TOP/EC/README.md) |
| **PnR (Innovus 0~5단계)** | Die `1,748×1,748 ㎛`, Setup `+6.103 ns`, Hold `+0.003 ns`, DRV `0`, DRC·Conn `0/0`, Power `12.51 mW` | Util `55%` (Margin `20 ㎛`), Setup `+7.769 ns`, Hold `+0.013 ns`, DRV `0`, DRC·Conn `0/0`, Power `0.1425 mW` | [`TOP/PNR/README.md`](SoC_make_G45/TOP/PNR/README.md) |
| **Tempus Sign-off STA** | Real Net `100.00%` (`1,099/1,099`), **전 항목 `0 Violated`** | Removal `5 → 0`, **전 항목 `0 Violated`** | [`TOP/PNR/README.md`](SoC_make_G45/TOP/PNR/README.md) |
| **Post-Layout LEC** | **`356 / 356` Equivalent PASS** (16 Power PAD BBOX) | **`356 / 356` Equivalent PASS** | [`TOP/EC/README.md`](SoC_make_G45/TOP/EC/README.md) |

---

## 폴더 구조

```text
UART_GDSII/
├── README.md                           ← 본 문서
└── SoC_make_G45/TOP/
    ├── RTL/                            ← UART 5개 모듈 + cpu8 RTL
    ├── SIM/                            ← FUNCTION / PRE 시뮬레이션 스크립트·TB·캡처
    ├── SYN/                            ← uart_pad / uart_no_pad MMMC 합성 스크립트·리포트
    ├── EC/                             ← Pre/Post-LEC 스크립트 및 PASS 캡처
    └── PNR/                            ← uart_pad & uart_no_pad 0~5단계, Tempus, SVG 차트·캡처
```
