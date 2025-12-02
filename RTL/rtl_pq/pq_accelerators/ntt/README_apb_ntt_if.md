# APB 接口 (apb_ntt_if)

`apb_ntt_if` 为 `ntt_closely_top` 核提供松耦合接入方式，使得处理器可以通过 APB3 总线配置 NTT、下发命令、搬运向量数据以及（可选）接收运算完成中断。

## 寄存器概要

| 偏移 | 名称 | 访问 | 描述 |
| ---- | ---- | ---- | ---- |
| `0x000` | `CMD` | WO | 写入脉冲控制位（bit0~bit9 分别对应 `ntt_start`、`single_bf`、`update_m_single_bf`、`update_omega_single_bf`、`mul_psi1`、`mul_psi2`、`update_psi`、`mod_mul`、`mod_add`、`mod_sub`）。写 1 产生单周期脉冲。|
| `0x004` | `CONFIG` | RW | bit0=`fwd_ntt` (1 正变换，0 逆变换)，bit1=`ntt_first_rounds`。|
| `0x008` | `PARAM_N` | RW | NTT 点数，默认 `0x100` (256)。|
| `0x00C` | `MODULUS` | RW | 模数 `q` 下半字。|
| `0x010` | `MIN_QINV` | RW | `MinQinvModR` 参数。|
| `0x014` | `SINGLE_IDX` | RW | `single_bf`/`update_m_single_bf` 使用的 4-bit 索引。|
| `0x018` | `PQ_OPERATOR` | RW | `pq_operator_id[4:0]`，用于多项式算术/蝶形特殊模式。|
| `0x01C` | `ALU_CTRL` | WO | bit0=`pq_en_id` 脉冲；写 1 时使用 `OPERAND_*` 触发一次寄存器算术操作。|
| `0x020` | `OPERAND_A` | RW | ALU 操作数 A。|
| `0x024` | `OPERAND_B` | RW | ALU 操作数 B。|
| `0x028` | `OPERAND_C` | RW | ALU 操作数 C / `omega` 覆盖值。|
| `0x02C` | `RESULT1` | RO | 捕获 `pq_id_alu_res1`。在 `STATUS.bit1` 清零前保持。|
| `0x030` | `RESULT2` | RO | 捕获 `pq_id_alu_res2`。在 `STATUS.bit2` 清零前保持。|
| `0x034` | `STATUS` | RW | bit0=`busy_flag`，bit1=`result1_valid`，bit2=`result2_valid`，bit3=`rf_conflict_flag`，bit4=`ntt_rf_write_active`（只读）。写 1 到 bit0~bit3 可清标志。|
| `0x038` | `IRQ_MASK` | RW | bit0 使能 `RESULT1` 中断，bit1 使能 `RESULT2` 中断。IRQ 输出为 `mask & valid`。|
| `0x100-0x17C` | `RF_WINDOW[i]` | RW | 32×32-bit 本地 PQ 寄存器窗，对应 `rdata_pq_i`/`wdata_pq_o`。|

## 访问流程示例

1. **初始化参数**：写 `PARAM_N`、`MODULUS`、`MIN_QINV`、`CONFIG`，并通过 `RF_WINDOW` 搬运多项式系数。
2. **触发 NTT**：
   - 对于批量蝶形：向 `CMD` 写 `bit0=1` (`ntt_start`)；软件可选使用 `STATUS.bit0` 追踪 busy，并在完成后写 1 清零。
   - 对于单蝶/psi/模运算：按照需要写相应 bit（1-cycle 脉冲）。
3. **读取结果**：
   - 如果核心回写 PQ 寄存器，直接读取窗口地址；
   - 若使用 ALU 结果，在写好 `OPERAND_*` 和 `PQ_OPERATOR` 后向 `ALU_CTRL` 写 `bit0=1`，然后轮询 `STATUS.bit1/bit2` 并从 `RESULT1/2` 读取，最后写 `STATUS` 清 valid 位。
4. **中断使用**（可选）：配置 `IRQ_MASK` 并连接 IRQ 线，软件在中断服务中读取 `RESULT` 或 PQ 寄存器。

## 设计要点

- **冲突保护**：当 NTT 正在写 PQ 寄存器 (`STATUS.bit4=1`) 时，APB 对 `RF_WINDOW` 的写请求会被 `PREADY=0` 暂停，`STATUS.bit3` 会记录被阻塞的尝试。
- **命令脉冲**：所有命令位均为写 1 产生单周期脉冲，避免重复触发；软件需再次写 1 触发下一次操作。
- **可配置深度**：通过参数 `ADDR_WIDTH`/`DATA_WIDTH` 调整寄存器窗大小，默认为 32×32-bit，与原 NTT 内核保持一致。

将 `apb_ntt_if` 作为 APB 从设备实例化后，即可达到“松耦合”加速器的形态：处理器侧仅需进行普通寄存器读写，无需了解 NTT 内部的微架构细节。