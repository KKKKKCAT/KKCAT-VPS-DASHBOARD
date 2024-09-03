# ✔ KKCAT 貓咪探針 (非開源)

KKCAT 貓咪探針 是一個強大且易用的 VPS 管理儀表板解決方案，旨在通過直觀的界面實時監控和管理多個虛擬服務器。本儀表板基於 Cloudflare Workers 和 Cloudflare Pages 構建，集成了流媒體檢測、性能監控和其他功能，以確保服務器運行的高效性和可視化管理。

## 📱 功能概覽

- 實時監控 VPS 的 CPU、內存和磁盤使用情況
- 流媒體服務可用性檢測
- 多國家/地區支持，通過圖標和標志顯示
- 動態更新，實時獲取和顯示最新的數據
- 適用於多設備的響應式設計

## ⭐ 主要功能

### 前端 UI 設計

VPS Dashboard 的前端采用了現代化的設計風格，結合了響應式布局和豐富的動畫效果，以確保在各種設備上的最佳用戶體驗。以下是主要的設計特點：

- **卡片式布局**：每個 VPS 都以卡片形式顯示，包含關鍵的系統指標（CPU、內存、磁盤等）和流媒體檢測結果。
- **交互式元素**：用戶可以點擊卡片以展開更多詳細信息，包括操作系統、虛擬化類型、內核版本等。
- **動態更新**：儀表板會定期刷新，以確保顯示的是最新的服務器狀態。

### 獲取 VPS 信息的代碼

儀表板通過調用 Cloudflare Workers 提供的 API 來獲取 VPS 的實時數據。以下是核心函數和其功能：

- `fetchVpsData()`：發送請求到 Cloudflare Workers，獲取所有 VPS 的最新數據。
- `fetchVpsDetail(server_id)`：根據服務器 ID 獲取特定 VPS 的詳細信息。
- `updateDashboard()`：更新儀表板上的所有 VPS 信息，包括重新獲取數據並渲染頁面。

這些函數通過發送 HTTP 請求到 Cloudflare Workers，獲取從數據庫中提取的 VPS 數據，並在前端進行動態更新和顯示。

### 流媒體檢測原理

流媒體檢測是 VPS Dashboard 的一大特色功能，它通過自動檢測各大流媒體服務在不同 VPS 上的可用性，為用戶提供實時的流媒體訪問狀態。

- **檢測機制**：利用腳本在 VPS 上執行請求，檢測不同流媒體服務的可用性，並將結果返回給儀表板進行顯示。
- **支持的流媒體服務**：包括 Netflix、YouTube、Disney+、TikTok、Dazn、Bahamut 和 Bilibili 等。
- **狀態顯示**：在儀表板上以表格形式展示每個 VPS 對流媒體服務的檢測結果，並用不同的顏色或符號標記狀態（例如：可用、不可用、區域限制等）。

### 數據庫與 API 集成

VPS Dashboard 利用 Cloudflare Workers 作為無服務器環境，結合數據庫查詢來獲取和管理 VPS 數據。

- **數據庫查詢**：通過 SQL 語句從數據庫中提取 VPS 狀態和流量數據。
- **API 端點**：儀表板與 Cloudflare Workers 之間通過 RESTful API 進行通信，確保數據的實時性和準確性。

### 可定制性

VPS Dashboard 支持高度的定制性，用戶可以根據需要添加或修改顯示的信息，以及調整界面的樣式和布局。

- **樣式自定義**：通過修改 CSS 文件，用戶可以輕松更改儀表板的外觀，包括顏色、字體、布局等。
- **功能擴展**：支持通過 JavaScript 添加新的功能或數據字段，滿足不同用戶的需求。

## 👀 前端演示

![](https://img2.kkcat.blog/file/3abceeee7c463c7fee6bb.png)
![](https://example.com/img/VPS-Dashboard-2.webp)


## 貢獻

歡迎提交 Pull Requests 以改進這個項目。對於重大更改，請先提交 issue 討論您的修改建議。

## 👤 作者

**YourName**

- [![Telegram](https://img.shields.io/badge/-Telegram-2CA5E0?style=flat-square&logo=telegram&logoColor=white)](https://t.me/yourtelegram)
- [![Twitter](https://img.shields.io/badge/Twitter-Follow-1DA1F2?style=flat&logo=twitter)](https://twitter.com/yourtwitter)

---

*注：由於項目的隱私性和安全性，部分代碼和詳細實現未公開。*
