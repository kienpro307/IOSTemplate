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

## Workflow
1. Tạo branch từ develop
2. Code và commit
3. Push và tạo PR
4. Code review
5. Merge vào develop
6. Release: develop → main
