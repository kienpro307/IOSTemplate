# 🔀 Quy Tắc Git

## Branches
- `main` - Production code
- `develop` - Development branch
- `feature/ten-tinh-nang` - New features
- `bugfix/mo-ta-loi` - Bug fixes
- `hotfix/sua-khan-cap` - Urgent fixes

## Commit Messages (Conventional Commits)
```
feat: thêm màn hình đăng nhập
fix: sửa lỗi crash khi logout
docs: cập nhật README
test: thêm unit tests cho auth
refactor: tối ưu network layer
style: format code
chore: cập nhật dependencies
```

## Git Tags (Milestones)

Tag được sử dụng để đánh dấu các milestone quan trọng trong dự án:

### Khi nào cần tag?
- ✅ Hoàn thành một Phase (Phase 0, Phase 1, Phase 2, ...)
- ✅ Hoàn thành một feature lớn (Onboarding, Payment, ...)
- ✅ Release version (v1.0.0, v1.1.0, ...)
- ✅ Hoàn thành integration quan trọng (Firebase, Analytics, ...)

### Format tag
```
# Phase milestone
phase-0-complete
phase-1-complete
phase-2-complete

# Feature milestone
feature-onboarding-complete
feature-payment-complete
feature-offline-complete

# Release version (semantic versioning)
v1.0.0
v1.1.0
v2.0.0
```

### Cách tạo tag
```bash
# Tạo annotated tag với message
git tag -a phase-1-complete -m "Hoàn thành Phase 1: Nền tảng"

# Push tag lên remote
git push origin phase-1-complete

# Push tất cả tags
git push --tags
```

### Best Practices
- Luôn dùng annotated tag (`-a`) với message mô tả
- Tag trên branch `develop` hoặc `main` sau khi merge
- Không tag trên feature branch
- Tag ngay sau khi hoàn thành milestone, không để lâu

## Workflow
1. Tạo branch từ develop
2. Code và commit
3. Push và tạo PR
4. Code review
5. Merge vào develop
6. **Tag milestone** (nếu hoàn thành milestone quan trọng)
7. Release: develop → main (tag version)
