# 代码优化报告

## 删除的文件

### 1. app/templates/user-settings.html
- **原因**: 功能已合并到 user.html 中
- **说明**: 设置页面（个人资料、账号安全、第三方绑定）已作为标签页集成到用户中心主页
- **日期**: 2026-03-09

## 代码变更

### 1. main.py
- **移除**: `/user/settings` 路由指向已删除的 user-settings.html
- **新增**: 重定向到 `/user?tab=settings`
- **移除**: 重复的 `/oauth_callback` 路由

### 2. user.html
- **新增功能**:
  - 设置标签页（settings-tab）包含个人资料、账号安全、第三方绑定
  - 密码修改需邮箱验证码验证
  - OAuth 第三方账号绑定/解绑
- **优化**:
  - 移动端响应式布局优化（API密钥、知识库、嵌入配置、订单记录页面）
  - 顶栏布局优化（汉堡菜单靠左，主题/退出按钮靠右）
  - 昼夜主题切换功能完善
  - 弹窗函数 showModal/hideModal 补全
  - 概览页面数据获取修复（使用 /api/user/stats）

### 3. admin.html
- **移除**: 重复的支付配置内嵌页面（tab-payment）
- **移除**: 重复的邮箱配置内嵌页面（tab-email）
- **移除**: 旧的未使用函数（loadPaymentConfig, savePaymentConfig, loadEmailConfig, saveEmailConfig, testEmailConfig, loadEmailTemplate, saveEmailTemplate, resetEmailTemplate, switchEmailSubTab, switchPaymentSubTab）
- **优化**: 减少约 380 行重复代码

## 移动端适配完成页面
- API密钥管理 (`#tab-apikeys`)
- 知识库管理 (`#tab-knowledge`)
- 嵌入配置 (`#tab-embed`)
- 订单记录 (`#tab-orders`)

所有页面均采用卡片式布局，移动端自动隐藏表格表头，显示数据标签。