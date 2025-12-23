# ✅ Checklist Trước Khi Commit

## Code Quality
- [ ] Không có SwiftLint warnings
- [ ] Không force unwrap (!)
- [ ] Không force cast (as!)
- [ ] Xử lý tất cả error cases
- [ ] Comment tiếng Việt cho logic phức tạp

## TCA Compliance
- [ ] State là struct, conform Equatable
- [ ] Actions mô tả sự kiện (past tense)
- [ ] Effects isolated, có thể cancel
- [ ] Dependencies được inject

## Testing
- [ ] Unit tests cho business logic
- [ ] Test coverage > 80% cho reducers
- [ ] Tests pass locally

## Documentation
- [ ] Update README nếu cần
- [ ] Comment cho public APIs
- [ ] Update CHANGELOG

## Git
- [ ] Commit message theo conventional commits
- [ ] Không commit debug code
- [ ] Không commit sensitive data
