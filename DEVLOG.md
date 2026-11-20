# 开发日志 (DEVLOG)

记录本仓库的功能开发与定制改动，按时间倒序排列。

---

## 2026-11-20 — 前端内嵌模式（`?embed=1`）

### 背景

需要将 DolphinScheduler UI 内嵌到第三方系统中，隐藏顶部菜单栏，只展示下方内容区并全屏铺满。

### 方案

采用 URL 查询参数 `?embed=1` 作为开关，前端布局层读取该参数动态隐藏顶部栏（`NLayoutHeader` / `NavBar`），并让内容区从 `top: 65px` 上移到 `top: 0`。为应对 history 路由下页面内跳转丢失 query 的问题，在全局路由守卫中自动延续该参数。

### 改动文件

| 文件                                                | 改动                                                                                                                                            |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `dolphinscheduler-ui/src/layouts/content/index.tsx` | 新增响应式 `embedMode = computed(() => route.query.embed === '1')`；`embed=1` 时不渲染 `NLayoutHeader`，内容 layout 的 `top` 由 `65px` 改为 `0` |
| `dolphinscheduler-ui/src/router/index.ts`           | `beforeEach` 守卫中：一旦进入 embed 模式（当前或来源 URL 带 `embed=1`），后续跳转自动补上该参数；安全中心重定向分支同样保留该参数               |

### 使用方式

history 路由，生产 base 为 `/dolphinscheduler/ui/`，URL 中不带 `#`：

```html
<!-- 首页，隐藏顶部栏 -->
<iframe src="https://your-host/dolphinscheduler/ui/?embed=1"></iframe>

<!-- 直达指定页面 -->
<iframe
  src="https://your-host/dolphinscheduler/ui/projects/123/workflow-definition?embed=1"
></iframe>
```

侧边栏在 embed 模式下仍保留（本次需求仅隐藏顶部栏）。

### 内嵌集成注意事项

- **登录态**：请求拦截器注入 `sessionId` header 与 `language` cookie；iframe 同源时 cookie 自动带上，跨域需后端配置 `SameSite=None; Secure` 并放行 CORS，或由宿主系统完成单点登录注入。
- **401/504 跳转**：`service.ts` 中未登录会跳转 `/login`，在 iframe 内会把子页面切到登录页；无感登录场景需改造为通知宿主。
- **反向代理**：需同时转发 `/dolphinscheduler/ui/**` 与 `/dolphinscheduler/**`。
- **frame 嵌入限制**：网关若设置 `X-Frame-Options: DENY/SAMEORIGIN` 或 CSP `frame-ancestors`，iframe 会被浏览器拒绝，需在代理层放行宿主域名。

### 验证

- `vue-tsc --noEmit`：通过（exit 0）
- `prettier --check`（两个改动文件）：通过
- 本地 Vite dev server（`http://localhost:5173/`）+ CDP 实测：
  - 从 `/?embed=1` 进入后 URL 变为 `/home?embed=1`，证明路由守卫生效；
  - embed 模式 DOM 中无 `NLayoutHeader` 节点，内容区从顶部开始渲染；
  - 两种模式截图像素对比确认顶部栏被移除。

---

## 2026-11-20 — 仓库基础整理

- 合并 `2dev/feat/add-schedule-interval`（interval 定时触发功能，11 个 commit）到 `2dev/master`。
- 拉取并合并最新 `origin/dev`（约 100 个 commit，420 文件变更）到 `2dev/master`，无内容冲突。
- `.gitignore` 移除 `!.idea/icon.png`、`!.idea/vcs.xml` 例外，完整忽略 `.idea/`，并从索引取消跟踪这两个 IDE 配置文件。
