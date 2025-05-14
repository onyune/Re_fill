# Re:fill

## ✅ 개발 전 필독

### 긴가민가한 코드는 ChatGPT에게 검토받기!

### 📌 개발 순서
1. **개발 전, Github에서 변경 사항 확인 먼저!**
    - 변경 사항을 반영하지 않고 커밋하면 충돌이 발생할 수 있음
2. **개발은 반드시 자신의 브랜치에서 진행**
    - `master`에서 직접 개발하면 오류 발생 시 전체에 영향
3. **작업 완료 후 Pull Request 보내기**
    - “내가 이렇게 개발했는데 master에 적용해도 될까요?” 요청
4. **PR 승인(Merge Confirm)되면 master에 반영**
    - 리뷰 결과 문제가 없다면 `master`에 병합
5. **master 변경사항을 다시 자신의 브랜치로 가져와서 작업 이어가기**
    - 최신 상태 유지 필수!
  
   * 각자 개인 브랜치로 작업 후 merged-dev에 임시 merge 할 예정
   * 완벽하게 오류 없으면 master로 merge. master는 팀원 동의 전부 구하고 merge하기

### 📝 Commit 규칙
1. 커밋 후 `push` 까지 완료할 것!
2. 커밋 메시지는 **구체적**이고 **의미 있게** 작성
3. 검토 후 오류가 없으면 `pull request` 생성

### 🧾 Commit 메시지 작성법
1. **제목과 본문은 한 줄 띄워 구분**
2. **제목은 50자 이내**, 마침표 ❌
3. **본문 각 줄은 72자 이내**
4. **무엇을** 하고 **왜** 했는지 작성 (어떻게는 X)


## 🔐 사용자 인증 기능

앱에서는 Firebase를 활용하여 다음과 같은 인증 기능을 구현:

---

### ✅ 회원가입
- 이메일, 비밀번호, 이름, 사용자 ID 입력
- Firebase Authentication을 통해 이메일/비밀번호 기반 계정 생성
- Firestore에 다음 정보 저장:
   - `userId`: 사용자 지정 ID
   - `name`: 이름
   - `email`: 이메일
   - `createdAt`: 생성 시간

---

### 🔎 아이디 찾기
- 이메일 입력 → 인증(비밀번호 재설정용 메일 발송)
- 입력한 이메일이 Firebase에 등록된 계정일 경우:
   - Firestore에서 해당 이메일과 연결된 `userId`를 조회하여 앱 화면에 표시
- 실제 메일 인증 여부와는 무관하며, 단순 존재 확인 및 조회용으로 사용

---

### 🔁 비밀번호 찾기
- 이메일 입력 후 `"비밀번호 재설정 메일 보내기"` 버튼 클릭
- Firebase에서 해당 이메일로 비밀번호 재설정 링크 전송
- 사용자는 이메일을 열어 새 비밀번호를 설정

---

### ⚠️ 유의 사항
- 전화번호 인증은 사용하지 않음
- 이메일 기반 인증 기능만 제공
- 인증 메일과 비밀번호 재설정 메일은 **Firebase 기본 템플릿**을 사용

---

## 📚 참고자료
For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
