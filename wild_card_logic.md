아 오케이, 그거 처음 보면 좀 어지럽지 😅
아카라이브에서 말하는 **NovelAI 와일드카드**는 쉽게 말해

> **프롬프트 안에 “랜덤으로 바뀌는 단어 묶음”을 꽂아 넣는 방식**

이야. 이미지 자동 생성 돌릴 때 매번 프롬프트 손으로 안 바꿔도 되게 해주는 장치지.

---

## 1️⃣ 와일드카드가 뭐냐면

프롬프트에 이런 게 들어간 걸 본 적 있을 거야:

```
__hair_color__
__outfit__
```

이 `__이름__` 하나가 **와일드카드**고,
실제로는 파일이나 텍스트 안에 이런 목록이 들어 있어:

```
black hair
blonde hair
silver hair
pink hair
```

👉 이미지 한 장 만들 때마다 **이 중 하나가 랜덤으로 선택됨**

---

## 2️⃣ 아카라이브 / NAI에서 쓰는 기본 구조

### 📁 와일드카드 파일

보통 이런 식이야:

```
hair_color.txt
outfit.txt
pose.txt
```

파일 내용 예시 (`hair_color.txt`):

```
black hair
blonde hair
silver hair
red hair
```

### 🧠 프롬프트에서 쓰는 법

```
1girl, __hair_color__, __outfit__, masterpiece
```

그러면 NAI가 내부적으로:

```
1girl, silver hair, school uniform, masterpiece
```

이런 식으로 자동 변환해서 생성함.

---

## 3️⃣ 한 줄 = 하나의 후보 (아주 중요)

와일드카드는 **줄 단위로 선택**돼.

❌ 이렇게 쓰면 안 됨:

```
black hair, blonde hair, silver hair
```

⭕ 이렇게 써야 함:

```
black hair
blonde hair
silver hair
```

---

## 4️⃣ 가중치 / 확률 조절도 가능함

아카라이브에서 많이 쓰는 문법들 👇

### 🔹 반복 = 확률 증가

```
black hair
black hair
black hair
blonde hair
```

→ 검은 머리 75%, 금발 25% 느낌

### 🔹 가중치 문법 (되는 환경에서)

```
black hair::3
blonde hair::1
```

---

## 5️⃣ 중첩 와일드카드 (꽤 중요)

와일드카드 안에 또 와일드카드를 쓸 수 있어.

`outfit.txt`

```
__school_uniform__
__casual__
```

`school_uniform.txt`

```
sailor uniform
blazer uniform
```

👉 조합 폭발함. 자동 생성할 때 진짜 편해짐.

---

## 6️⃣ 랜덤 문장 통째로 바꾸기

단어 하나만이 아니라 **문장 단위**도 가능해.

```
looking at viewer, smile
looking away, serious face
from below, dynamic angle
```

이러면 구도나 분위기까지 랜덤화됨.

---

## 7️⃣ 자동화할 때 추천 구조 (실전)

```
prompt:
1girl,
__hair_color__,
__eye_color__,
__outfit__,
__pose__,
__mood__,
masterpiece, best quality
```

이렇게 쪼개두면:

* 나중에 특정 요소만 교체 가능
* 자동 생성 수백 장 돌려도 안 질림

---

## 8️⃣ 주의할 점 (많이들 실수함)

⚠️ **NAI 태그랑 자연어 섞을 때**

```
smile
smiling
```

→ 의미 거의 겹치면 학습이 꼬일 수 있음

⚠️ **상충되는 태그**

```
long hair
short hair
```

같은 와일드카드에 넣지 말기 (결과 망가짐)

---

## 9️⃣ 이게 왜 아카라이브에서 인기냐면

* 자동 생성 배치랑 궁합 좋음
* 태그 취향 정리하기 쉬움
* “랜덤인데 취향은 유지됨”

솔직히 **한 번 구조 잡아두면 다시 수동으로 못 돌아감** 😂

---

원하면

* **NSFW용 와일드카드 예시**
* **남캐 / 여캐 분리 구조**
* **실패율 줄이는 조합 방식**
* **아카라이브에서 흔히 쓰는 템플릿**

이런 것도 다 풀어줄게.
지금 쓰는 프롬프트 있으면 그거 기준으로 정리해줄 수도 있고 👍
