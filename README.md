# Graylog Cisco IOS Syslog Pipeline

Cisco IOS 계열 syslog 메시지에서 타임스탬프, 타임존, facility, severity, mnemonic 및 본문을 추출하는 Graylog 파이프라인 규칙입니다.

## 대상 환경

- Graylog 7.2.x
- Pipeline Rule Source Code Editor
- `message` 필드에 다음 형태의 Cisco IOS 원문이 들어오는 구성

```text
<187>*Oct  1 2026 16:02:03.123 KST: %LINK-3-UPDOWN: Interface GigabitEthernet1/0/1, changed state to down
```

## 파일 구성

- `rules/cisco-ios-generic.rule`
  - 권장 버전
  - 임시 메시지 필드를 만들지 않으므로 필드 삭제 함수가 필요하지 않음
  - 선택적 PRI, `*`/`.` 타임스탬프 플래그, 선택적 소수점 이하 초를 허용
- `rules/cisco-ios-generic-minimal-change.rule`
  - 기존 규칙을 최대한 유지한 마이그레이션 버전
  - deprecated `remove_field()`를 `remove_single_field()`로 교체
- `samples/cisco-ios-syslog.txt`
  - Rule Simulation용 예제 메시지

## Deprecated 함수 처리

Graylog 최신 함수 레퍼런스에서는 단일 필드 삭제에 `remove_single_field()`를 사용하고, 정규식 또는 목록 기반 다중 삭제에는 `remove_multiple_fields()`를 사용합니다.

기존 코드의 최소 변경은 다음과 같습니다.

```diff
- remove_field("cisco_type_raw");
+ remove_single_field("cisco_type_raw");
```

권장 규칙은 `cisco_type_raw`를 메시지 필드로 저장하지 않고 로컬 변수에서 처리하므로 삭제 호출 자체를 제거했습니다.

공식 문서:

- https://go2docs.graylog.org/current/making_sense_of_your_log_data/functions_index.html
- https://go2docs.graylog.org/current/making_sense_of_your_log_data/functions.html

## 생성 필드

| 필드 | 형식 | 예시 |
|---|---|---|
| `syslog_pri` | 문자열 | `187` |
| `cisco_month` | 문자열 | `Oct` |
| `cisco_day` | 문자열 | `1` |
| `cisco_year` | 문자열 | `2026` |
| `cisco_time` | 문자열 | `16:02:03.123` |
| `cisco_timezone` | 문자열 | `KST` |
| `cisco_type` | 문자열 | `LINK-3-UPDOWN` |
| `cisco_facility` | 문자열 | `LINK` |
| `cisco_severity` | long | `3` |
| `cisco_mnemonic` | 문자열 | `UPDOWN` |
| `cisco_message` | 문자열 | `Interface ... changed state to down` |
| `parser_name` | 문자열 | `cisco_ios_generic` |
| `parser_status` | 문자열 | `parsed` |

## 적용 절차

1. Graylog에서 **System > Pipelines > Manage rules**로 이동합니다.
2. 새 Rule을 만들고 `rules/cisco-ios-generic.rule` 내용을 붙여 넣습니다.
3. 대상 Stream에 연결된 Pipeline Stage에 Rule을 추가합니다.
4. `samples/cisco-ios-syslog.txt`의 메시지로 Rule Simulation을 실행합니다.
5. 실제 메시지에서 생성 필드와 Pipeline Processing Errors를 확인합니다.

## 주의사항

- 이 규칙은 연도와 타임존이 포함된 Cisco IOS 형식을 대상으로 합니다.
- RFC 5424 형식, 연도가 없는 기본 IOS 타임스탬프, sequence number가 앞에 붙는 형식은 별도 패턴이 필요합니다.
- 규칙은 Graylog의 기본 `timestamp` 필드를 변경하지 않습니다.
- 기존 인덱스에서 `cisco_severity`가 문자열로 매핑된 상태라면 long 값과 매핑 충돌이 발생할 수 있습니다. 새 인덱스 세트 사용 또는 인덱스 로테이션 후 적용을 검토하십시오.
