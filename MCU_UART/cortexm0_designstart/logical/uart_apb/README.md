# uart_apb — Cortex-M0 APB 호환 자작 8E1 UART RTL

본 폴더는 ARM Cortex-M0 `cmsdk_apb_subsystem`의 UART2(`cmsdk_apb_uart`)를 무수정 교체하기 위해 직접 작성한 **21핀 APB Wrapper 및 16B FIFO · 8E1 UART RTL 6개**를 수록한다.

---

## 1. 파일 구성 (입력 및 모듈 계층)

| 파일명 | 모듈명 | 역할 |
|---|---|---|
| `verilog/uart_apb_wrapper.v` | `uart_apb_wrapper` | CMSDK `cmsdk_apb_uart`와 21핀 포트 및 레지스터 오프셋이 호환되는 APB 슬레이브 래퍼 |
| `verilog/uart_top.v` | `uart_top` | 송수신 제어·LSR 상태 통합 최상위 모듈 (`CLK_FREQ_HZ=125_000_000`, `BAUD_RATE=115200`) |
| `verilog/baud_rate_gen.v` | `baud_rate_gen` | 16x 오버샘플링 틱 생성기 (`OS_DIV = round(125M / (16 × 115200)) = 68`, 오차 `-0.27%`) |
| `verilog/uart_tx.v` | `uart_tx` | 8-bit 데이터 + 짝수 패리티(Even Parity) + 1 Stop 비트 직렬 송신기 |
| `verilog/uart_rx.v` | `uart_rx` | 16x 중앙 샘플링 직렬 수신기, Sticky Frame/Parity 오류 검출 |
| `verilog/fifo.v` | `fifo` | 8-bit × 16-entry 동기식 TX/RX FIFO |

---

## 2. APB 레지스터 맵 (CMSDK UART 호환)

`uart_apb_wrapper`는 `PREADY`를 상시 `1`, `PSLVERR`를 상시 `0`으로 유지하며 액세스 페이즈(`PSEL & PENABLE`)에서 단일 사이클 읽기/쓰기를 수행한다.

| 오프셋 (`PADDR[11:2]`) | 레지스터 | 접근 | 비트 정의 |
|---|---|:---:|---|
| `0x000` (`10'h000`) | `DATA` | R / W | **R**: RX FIFO 헤드 `[7:0]` 팝 / **W**: TX FIFO `[7:0]` 푸시 (Full 시 TX Overrun 플래그 설정) |
| `0x004` (`10'h001`) | `STATE` | R / W1C | `[0]` TX Full, `[1]` RX Data Ready, `[2]` TX Overrun, `[3]` RX Overrun, `[4]` RX Frame Error, `[5]` RX Parity Error (`[2],[3]`은 1 쓰기로 해제) |
| `0x008` (`10'h002`) | `CTRL` | R / W | `[0]` TX Enable (`TXEN`), `[1]` RX Enable (`RXD` 게이팅), `[2]` TX Int En, `[3]` RX Int En, `[4]` TX Ovr Int En, `[5]` RX Ovr Int En, `[6]` High-speed test (저장 전용) |
| `0x00C` (`10'h003`) | `INTSTATUS` / `INTCLEAR` | R / W1C | `[0]` TX, `[1]` RX, `[2]` TX Overrun, `[3]` RX Overrun (1 쓰기로 인터럽트 클리어) |
| `0x010` (`10'h004`) | `BAUDDIV` | R / W | `[19:0]` 소프트웨어 호환용 저장 레지스터 (실제 보레이트는 파라미터 `CLK_FREQ_HZ`, `BAUD_RATE`로 고정) |

---

## 3. MCU 통합 및 합성 결과 요약

- **단위 검증**: [`SIM/UNIT_UART_APB/`](../../../SoC_make_G45/TOP/SIM/README.md)의 `tb_uart_apb_wrapper.v`로 APB 읽기/쓰기, TX→RX 루프백, 패리티/프레임 오류, 인터럽트 클리어 `23/23` 항목을 통과한다.
- **MCU 합성 면적 (`09_cmsdk_mcu_SYN_area.rpt`)**:
  - `gen_apb_uart_2.u_apb_uart_2` (`uart_apb_wrapper` 전체): **`1,320` cells**, Cell Area **`3,968.23 ㎛²`**, Total Area **`5,533.76 ㎛²`**
  - 내부 `u_uart_top`: `1,176` cells (`u_uart_rx` `591`, `u_uart_tx` `547`, `u_baud_rate_gen` `38`)
