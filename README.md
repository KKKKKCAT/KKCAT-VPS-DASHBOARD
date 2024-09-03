# ✔ KKCAT 貓咪探針 (Non-Open Source)

KKCAT 貓咪探針 is a powerful and user-friendly VPS management dashboard solution designed to monitor and manage multiple virtual servers in real time through an intuitive interface. This dashboard is built on Cloudflare Workers and Cloudflare Pages, integrating features like streaming media detection, performance monitoring, and more to ensure efficient operation and visual management of servers.

## Demo URL
https://vps-demo.kkcat.blog

## 📱 Feature Overview

- Real-time monitoring of VPS CPU, memory, and disk usage
- Streaming service availability detection
- Multi-country/region support with icons and flags
- Dynamic updates for real-time data retrieval and display
- Responsive design suitable for multiple devices

## ⭐ Key Features

### Front-End UI Design

The front end of the VPS Dashboard adopts a modern design style, combining responsive layouts with rich animation effects to ensure the best user experience across various devices. Key design features include:

- **Card Layout**: Each VPS is displayed in a card format, showing key system metrics (CPU, memory, disk, etc.) and streaming media detection results.
- **Interactive Elements**: Users can click on a card to expand and view more detailed information, including the operating system, virtualization type, kernel version, and more.
- **Dynamic Updates**: The dashboard refreshes periodically to ensure that the latest server status is displayed.

### Code for Fetching VPS Information

The dashboard fetches real-time data from VPSs by calling APIs provided by Cloudflare Workers. Here are the core functions and their roles:

- Sending requests to Cloudflare Workers to fetch the latest data for all VPSs.
- Retrieving specific VPS details based on the server ID.
- Updating all VPS information on the dashboard, including re-fetching data and rendering the page.

These functions work by sending HTTP requests to Cloudflare Workers to fetch VPS data extracted from the database, dynamically updating and displaying it on the front end.

### Streaming Media Detection Principle

Streaming media detection is a major feature of the VPS Dashboard. It automatically detects the availability of major streaming services on different VPSs, providing users with real-time streaming access status.

- **Detection Mechanism**: Uses scripts to execute requests on VPSs to detect the availability of various streaming services and returns the results to the dashboard for display.
- **Supported Streaming Services**: Includes Netflix, YouTube, Disney+, TikTok, Dazn, Bahamut, Bilibili, and more.
- **Status Display**: The dashboard displays the detection results for each VPS's streaming services in a tabular format and marks the status with different colors or symbols (e.g., Available, Unavailable, Region Restricted).

### Database and API Integration

VPS Dashboard uses Cloudflare Workers as a serverless environment combined with database queries to fetch and manage VPS data.

- **Database Queries**: Uses SQL statements to extract VPS status and traffic data from the database.
- **API Endpoints**: Communication between the dashboard and Cloudflare Workers is done via RESTful APIs to ensure real-time and accurate data.

### Customizability

VPS Dashboard supports a high degree of customizability, allowing users to add or modify displayed information and adjust the interface style and layout as needed.

- **Style Customization**: Users can easily change the appearance of the dashboard, including colors, fonts, layouts, and more by modifying CSS files.
- **Feature Expansion**: Supports adding new features or data fields through JavaScript to meet the needs of different users.

## 👀 Front-End Demo

![](https://img2.kkcat.blog/file/3abceeee7c463c7fee6bb.png)

![](https://img2.kkcat.blog/file/f4402fcdf6f26ac881706.png)

![](https://img2.kkcat.blog/file/ecb213d5df4700677f6ad.png)

## 👀 Back-End Demo
![](https://img2.kkcat.blog/file/883a3794c9f8189c1e469.png)

## Contributions

Pull requests are welcome to improve this project. For major changes, please submit an issue first to discuss your modification suggestions.

## 👤 Author

**KKCAT**

- [![Telegram](https://img.shields.io/badge/-Telegram-2CA5E0?style=flat-square&logo=telegram&logoColor=white)](https://t.me/kkkkkcat)
- [![Twitter](https://img.shields.io/badge/Twitter-Follow-1DA1F2?style=flat&logo=twitter)](https://twitter.com/kcat88888)

---

*Note: Due to the privacy and security of the project, some code and detailed implementations are not publicly available.*

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=KKKKKCAT/KKCAT-VPS-DASHBOARD&type=Date)](https://star-history.com/#KKKKKCAT/KKCAT-VPS-DASHBOARD&Date)


