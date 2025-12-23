# Index - Danh mục Rules

> Danh sách tất cả rules cho AI

## Thứ tự Đọc

```
1. 00-DOC-TRUOC.md          ← Đọc TRƯỚC TIÊN
2. 04-CONTEXT/              ← Hiểu tình trạng dự án
3. 02-CODE/                 ← Quy tắc code
4. 03-TASK/                 ← Tùy loại task
```

---

## 04-CONTEXT/ - Context Dự án ⭐ QUAN TRỌNG

| File                                                  | Mô tả                               | Khi nào đọc         |
| ----------------------------------------------------- | ----------------------------------- | ------------------- |
| [CURRENT-STATUS.md](04-CONTEXT/CURRENT-STATUS.md)     | Tình trạng dự án hiện tại           | **Mỗi session mới** |
| [INTEGRATION-PLAN.md](04-CONTEXT/INTEGRATION-PLAN.md) | Kế hoạch tích hợp ios-template-home | Khi làm Phase 1     |
| [REFERENCE-CODE.md](04-CONTEXT/REFERENCE-CODE.md)     | Code snippets để copy               | Khi cần copy code   |

---

## 01-CHUNG/ - Quy tắc Chung

| File                                      | Mô tả                              |
| ----------------------------------------- | ---------------------------------- |
| [NGON-NGU.md](01-CHUNG/NGON-NGU.md)       | Code tiếng Anh, comment tiếng Việt |
| [GIT.md](01-CHUNG/GIT.md)                 | Commit message, branch naming      |
| [BAO-VE-DOCS.md](01-CHUNG/BAO-VE-DOCS.md) | Không sửa ios-template-docs        |

---

## 02-CODE/ - Quy tắc Code

| File                                 | Mô tả                    |
| ------------------------------------ | ------------------------ |
| [STRUCTURE.md](02-CODE/STRUCTURE.md) | Cấu trúc file/folder     |
| [NAMING.md](02-CODE/NAMING.md)       | Đặt tên biến, hàm, class |
| [TCA.md](02-CODE/TCA.md)             | TCA pattern chuẩn        |

---

## 03-TASK/ - Quy trình Task

| File                                     | Mô tả                                    |
| ---------------------------------------- | ---------------------------------------- |
| [WORKFLOW.md](03-TASK/WORKFLOW.md)       | **⭐ Workflow sau khi hoàn thành task**  |
| [TAO-FEATURE.md](03-TASK/TAO-FEATURE.md) | Cách tạo feature mới                     |
| [SUA-LOI.md](03-TASK/SUA-LOI.md)         | Cách sửa lỗi                             |
| [TESTING.md](03-TASK/TESTING.md)         | Viết test                                |

---

## Quick Reference

### Khi bắt đầu session mới

```
Đọc: 00-DOC-TRUOC.md → 04-CONTEXT/CURRENT-STATUS.md
```

### Khi làm task Phase 1 (Theme, UI, Storage)

```
Đọc: 04-CONTEXT/INTEGRATION-PLAN.md → 04-CONTEXT/REFERENCE-CODE.md
```

### Khi tạo feature

```
Đọc: 03-TASK/TAO-FEATURE.md → 02-CODE/TCA.md
```

### Khi cần xem backlog

```
Đọc: ../progress/CHO-XU-LY.md
```

---

## Docs Chi tiết

| Folder                                    | Mô tả                   |
| ----------------------------------------- | ----------------------- |
| `../ios-template-docs/01-KIEN-TRUC/`      | Kiến trúc cần tuân thủ  |
| `../ios-template-docs/06-KE-HOACH/`       | Roadmap và task tracker |
| `../ios-template-docs/05-CODE-TEMPLATES/` | Templates code          |

---

**Cập nhật:** December 23, 2024
