
# skeleton

Skeleton proj

## Getting Started

This project is a starting point for a Flutter application.

* 객체 파일은 domain 폴더내에 해당하는 폴더명 만들고 freezed 라이브러리 활용해서 생성 
	* Ex) domain/user/user.freezed.dart
* 백엔드와 통신하는 repository는 infra에 해당하는 폴더명 만들고 생성
	* Ex) infra/user/user_repository.dart
* 백엔드와 통신을 호출하는 Irepository는 domain에 해당하는 폴더명 만들고 생성
	* Ex) domain/user/I_user_repository.dart


TODO
현재 생성된 이미지 꾹 눌러 상호작용 버튼 생성하기 (이미지 메타데이터 복사)
캐릭터 레퍼런스 이미지 업로드 기능 추가
와일드카드 기능 추가
프리셋 정렬 기능 추가