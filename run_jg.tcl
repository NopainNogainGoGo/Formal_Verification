# 1. 清除舊的專案紀錄
clear -all

# 2. 分析與讀取設計檔案 (含 RTL 與 SVA)
analyze -sv seq_detect_fsm.sv
analyze -sv seq_detect_fv.sv

# 3. 指定 Top 模組並進行編譯 Elaborate
elaborate -top seq_detect_fsm

# 4. 設定時脈與重置訊號 (Formal 的環境約束)
clock clk
reset -expr {!rst_n}

# 5. 啟動證明引擎
prove -all