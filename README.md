## How to Run Simulation and Formal Verification

### 1. Run Simulation with VCS
```bash
vcs -R -sverilog tb.sv dut.sv -full64 -debug_access+all +v2k | tee test.log
````

---

## 2. Open JasperGold

啟動 Cadence JasperGold：

```bash
jaspergold &
```
`&` 代表讓 JasperGold 在背景執行，terminal 還可以繼續輸入其他指令。

---

## 3. Run Formal Verification Script

在 JasperGold console 裡執行 `.tcl` script：

```tcl
source run_jg.tcl
```

---

## Flow Summary

```text
Formal Verification Flow:
dut.sv + sva.sv + tcl script
      ↓
JasperGold
      ↓
Check assert / cover / counterexample
```
