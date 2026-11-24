# RTL — 자작 8E1 UART IP 및 8-bit CPU (`cpu8`)

본 폴더는 `UART_GDSII` 프로젝트의 원천 Verilog RTL을 보관한다. 주 설계 대상은 **16B FIFO · 8E1 UART (`uart_top`)**이며, 추가 실험용 자작 8비트 CPU(`cpu8/`)를 함께 관리한다.

---

## 1. UART RTL 모듈 구성

| 파일명 | 모듈명 | 기능 및 핵심 사양 |
|---|---|---|
| `uart_top.v` | `uart_top` | 최상위 통합 모듈 (`CLK_FREQ_HZ=100_000_000`, `BAUD_RATE=115200`, `DATA_BIT=8`, `FIFO_DEPTH=16`). `ifdef USE_IO_PAD`로 RX(`PADDI`)·TX(`PADDO`) IO 패드 삽입 여부를 분기한다. |
| `baud_rate_gen.v` | `baud_rate_gen` | 16x 오버샘플링 틱 생성기 (`100 MHz / (16 × 115200)`) |
| `uart_tx.v` | `uart_tx` | 16B TX FIFO 연동 직렬 송신기 (`Start + 8 Data + Even Parity + 1 Stop`) |
| `uart_rx.v` | `uart_rx` | 16x 중앙 샘플링 직렬 수신기, 16B RX FIFO, Frame/Parity/Overrun 오류 검출 |
| `fifo.v` | `fifo` | 파라미터화 동기식 원형 버퍼 FIFO (`WIDTH=8`, `DEPTH=16`) |
| `add_pad` | (보조 스니펫) | 전원 패드 인스턴스 템플릿 |

### 인터페이스 요약 (`uart_top`)
- **제어/클록**: `i_clk`, `i_rst_n`
- **직렬 핀**: `o_uart_txd`, `i_uart_rxd`
- **CPU 측 THR/RHR 인터페이스**: `i_thr_we`, `i_thr_wdata[7:0]`, `i_rhr_re`, `o_rhr_rdata[7:0]`
- **상태 출력 (LSR & 디버그)**: `o_lsr_dr`, `o_lsr_thre`, `o_lsr_temt`, `o_lsr_fe`, `o_lsr_pe`, `o_lsr_oe`, `o_tx_fifo_full`, `o_rx_fifo_full`

### `USE_IO_PAD` 컴파일 분기
- **`uart_pad` (단독 칩)**: Genus 합성 및 Conformal LEC 시 `-define USE_IO_PAD`를 지정하여 `u_pad_uart_rx` (`PADDI`), `u_pad_uart_tx` (`PADDO`)를 RTL 단계에서 인스턴스화한다.
- **`uart_no_pad` (코어 블록 / MCU 통합용)**: `USE_IO_PAD`를 정의하지 않아 순수 코어 로직만 합성한다.

---

## 2. 부가 실험 — 8-bit CPU (`cpu8/`)

| 파일명 | 역할 |
|---|---|
| `cpu8/cpu8_isa.vh` | 명령어 셋(ISA) 상수 및 오프코드 정의 |
| `cpu8/cpu8_decoder.v` | 명령어 디코더 |
| `cpu8/cpu8_regfile.v` | 범용 레지스터 파일 |
| `cpu8/cpu8_alu.v` | 산술·논리 연산기(ALU) |
| `cpu8/cpu8_top.v` / `cpu8/cpu8_pad_top.v` | 코어 최상위 및 패드 래퍼 |
