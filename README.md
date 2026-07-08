# SnapFlow

> 拍照片，生成步骤文档 —— 为现场工作者打造的移动端工作流手册工具。

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)
[![Build](https://github.com/mo-888/snap-flow/actions/workflows/build.yml/badge.svg)](https://github.com/mo-888/snap-flow/actions/workflows/build.yml)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

现场巡检、设备安装、运维记录场景下，打字不便，用**拍照 + 语音**快速生成结构化的操作手册，支持图片编辑、模板复用、PDF 导出。

## ✨ 核心功能

| 模块 | 能力 |
|------|------|
| 📸 拍照采集 | 相机拍摄 / 相册多选，三层数据存储（原图 / 编辑后 / 缩略图） |
| ✂️ 图片编辑 | 裁剪、旋转、调色（亮度/对比/饱和度）、标注、马赛克 |
| 🎤 语音转文字 | 长按录音转文字，适配现场无法打字的场景（ASR 可替换为云端） |
| 📑 模板复用 | 内置电力巡检、设备安装等工作流模板，一键创建 |
| 📄 PDF 导出 | 图文并茂的 PDF，系统分享发送 |
| 🗂 手册管理 | 搜索、筛选（最近/收藏/模板/未完成）、收藏、拖拽排序 |
| ✅ 进度跟踪 | 步骤完成态、整体完成进度 |
| 💾 本地持久化 | drift (SQLite) 离线存储，无需联网 |

## 📱 平台支持

- **Android**（主要目标，CI 自动构建 APK）
- **iOS**（需 macOS 环境签名）
- **Linux**（桌面调试）

## 🏗 架构

Clean Architecture lite，三层 + 七个 feature 模块：

```
lib/
├── app.dart                  # MaterialApp 入口 + 主题
├── main.dart                 # bootstrap
├── core/
│   ├── theme.dart            # SnapFlowTheme (teal-green #0D9488)
│   ├── db/                   # drift database + schema (Manuals/Steps/StepImages)
│   └── files/                # 三层文件服务 (originals/edited/thumbnails)
├── features/
│   ├── manual/               # 手册核心 (domain/data/presentation)
│   ├── capture/              # 图片采集抽象 (相机/相册)
│   ├── editor/               # 图片编辑器 (5 工具栏)
│   ├── voice/                # 语音转文字 (ASR + hold-to-record)
│   ├── export/               # PDF 导出
│   └── template/             # 预置模板
└── shared/
    ├── providers.dart        # Riverpod providers
    └── widgets/              # EmptyState, SnapToast, SnapSheet, SnapIconButton
```

### 数据模型

```
Manual  1──*  Step  1──*  StepImage
  │             │              │
  │             │              ├─ originalPath   (原图)
  │             │              ├─ editedPath     (编辑后)
  │             ├─ title        └─ thumbnailPath  (缩略图)
  ├─ note
  ├─ completed
  └─ optionalFields (动态键值对)
```

## 🚀 快速开始

### 环境要求

- Flutter ≥ 3.24
- Dart ≥ 3.5
- Android Studio / Xcode（移动端）

### 安装运行

```bash
# 克隆
git clone https://github.com/mo-888/snap-flow.git
cd snap-flow

# 安装依赖
flutter pub get

# 生成 drift 代码（首次或修改 schema 后）
dart run build_runner build --delete-conflicting-outputs

# 运行
flutter run
```

### 测试

```bash
flutter test          # 单元 + widget 测试
flutter analyze       # 静态分析
```

## 🔧 技术栈

| 类别 | 选型 |
|------|------|
| 框架 | Flutter |
| 状态管理 | Riverpod 2 |
| 数据库 | drift (SQLite) |
| 图片处理 | image |
| 图片采集 | image_picker |
| 录音 | record |
| PDF | pdf + printing |
| 路由 | Navigator 1.0 |

## 📦 CI/CD

提交到 `master` 或打 tag 自动触发 GitHub Actions：

- `flutter pub get` + `dart run build_runner build`
- `flutter analyze`（静态分析必须通过）
- `flutter test`（测试必须通过）
- `flutter build apk --release`（构建 Release APK）
- APK 作为 Artifact 上传，可下载

打 tag `v*` 时额外构建 production 签名包（需配置 keystore secrets）。

详见 [`.github/workflows/build.yml`](.github/workflows/build.yml)。

## 📄 License

MIT
