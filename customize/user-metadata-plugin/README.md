# User Metadata Plugin for Kong Gateway

이 플러그인은 Kong Gateway에서 사용자별 메타데이터(TDL Matrix, capabilities, 토큰 제한 등)를 관리하고, 요청 처리 시 자동으로 헤더에 추가하는 기능을 제공합니다. AI Gateway 환경에서 사용자별 정책과 제한을 효과적으로 관리할 수 있습니다.

## 🚀 주요 기능

### 📊 TDL Matrix 관리
- **사용량 추적**: 시간대별(T1-T12) 사용량 매트릭스 관리
- **실시간 모니터링**: 각 시간대별 API 호출 횟수 추적
- **제한 정책**: 시간대별 사용량 제한 설정

### 🔐 Capabilities 관리
- **기능별 권한**: 사용자별 기능 접근 권한 설정
- **등급별 서비스**: 프리미엄/일반 사용자 차별화
- **동적 권한**: 런타임에 권한 변경 가능

### 💰 비용 관리
- **토큰별 비용**: 입력/출력 토큰별 비용 계산
- **사용자별 요금**: 개별 사용자별 요금 정책
- **실시간 과금**: 사용량 기반 실시간 과금

### 📈 토큰 제한
- **입력 토큰 제한**: 최대 입력 토큰 수 제한
- **출력 토큰 제한**: 최대 출력 토큰 수 제한
- **동적 조정**: 사용자 등급에 따른 토큰 제한 조정

## 🛠️ 설치 및 설정

### 1. Docker 이미지 빌드

```bash
# 프로젝트 디렉토리로 이동
cd /Users/kyunghwan/Desktop/A-Pattern/docker-kong/customize

# Kong 이미지 빌드 (user-metadata 플러그인 포함)
docker build -f Dockerfile.user-metadata -t kong-with-user-metadata .
```

### 2. Kong 설정에서 플러그인 활성화

`compose/config/kong.yaml` 파일에서 플러그인을 Consumer에 추가:

```yaml
consumers:
  - username: "llama2-client"
    custom_id: "client-001"
    keyauth_credentials:
      - key: "llama2-secret-key-12345"
    plugins:
      - name: user-metadata
        config:
          id: "kt-llama3-1"
          provider_name: "kt"
          tags: ["뭘봐임마"]
          tdl_matrix:
            T1: [0, 0, 0, 0, 0, 3, 0, 0, 0, 0]
            T2: [0, 0, 0, 0, 0, 3, 0, 0, 0, 0]
            T3: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            # ... T4-T12 설정
          capabilities: [1, 1, 0, 0, 0]
          max_input_tokens: 24000
          max_output_tokens: 8000
          input_cost_per_token: 0.000000083
          output_cost_per_token: 0.00000033
```

### 3. Kong 컨테이너 실행

```bash
# compose 디렉토리로 이동
cd /Users/kyunghwan/Desktop/A-Pattern/docker-kong/compose

# Kong 컨테이너 실행
docker-compose up -d
```

## 📝 사용 방법

### 1. API 호출 예시

```bash
# llama2-client로 API 호출
curl -X POST http://localhost:8000/llama2/chat \
  -H "apikey: llama2-secret-key-12345" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "안녕하세요"}
    ]
  }'

# premium-client로 API 호출
curl -X POST http://localhost:8000/llama2/chat \
  -H "apikey: premium-secret-key-67890" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "안녕하세요"}
    ]
  }'
```

### 2. 자동 추가되는 헤더

요청이 처리될 때 다음 헤더들이 자동으로 추가됩니다:

```http
X-User-TDL-Matrix: {"T1":[0,0,0,0,0,3,0,0,0,0],"T2":[0,0,0,0,0,3,0,0,0,0],...}
X-User-Capabilities: [1,1,0,0,0]
X-Consumer-ID: kt-llama3-1
X-User-Max-Input-Tokens: 24000
X-User-Max-Output-Tokens: 8000
X-User-Input-Cost: 0.000000083
X-User-Output-Cost: 0.00000033
X-User-Provider: kt
X-User-Tags: ["뭘봐임마"]
```

## 📁 플러그인 구조

```
user-metadata-plugin/
├── handler.lua      # 플러그인 메인 로직
│                   # - 헤더 추가 로직
│                   # - TDL Matrix 처리
│                   # - Capabilities 관리
├── schema.lua       # 플러그인 설정 스키마
│                   # - 설정 검증
│                   # - 기본값 정의
├── rockspec         # LuaRocks 패키지 정의
│                   # - 의존성 관리
│                   # - 버전 정보
└── README.md        # 이 파일
```

## ⚙️ 설정 옵션

| 옵션 | 타입 | 필수 | 설명 | 예시 |
|------|------|------|------|------|
| `id` | string | ✅ | 사용자 고유 ID | `"kt-llama3-1"` |
| `provider_name` | string | ✅ | 제공업체 이름 | `"kt"` |
| `tags` | array | ❌ | 사용자 태그 | `["뭘봐임마"]` |
| `tdl_matrix` | object | ✅ | TDL 매트릭스 | `{"T1": [0,0,0,0,0,3,0,0,0,0]}` |
| `capabilities` | array | ✅ | 기능 권한 | `[1,1,0,0,0]` |
| `max_input_tokens` | number | ✅ | 최대 입력 토큰 | `24000` |
| `max_output_tokens` | number | ✅ | 최대 출력 토큰 | `8000` |
| `input_cost_per_token` | number | ✅ | 입력 토큰 비용 | `0.000000083` |
| `output_cost_per_token` | number | ✅ | 출력 토큰 비용 | `0.00000033` |

## 🔄 TDL Matrix 구조

TDL Matrix는 시간대별 사용량을 추적하는 12x10 매트릭스입니다:

```yaml
tdl_matrix:
  T1: [0, 0, 0, 0, 0, 3, 0, 0, 0, 0]  # 00:00-01:59
  T2: [0, 0, 0, 0, 0, 3, 0, 0, 0, 0]  # 02:00-03:59
  T3: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]  # 04:00-05:59
  # ... T4-T12
```

- **T1-T12**: 2시간 단위 시간대 (00:00-23:59)
- **배열 인덱스**: 각 시간대별 사용량 카운터
- **값**: 해당 시간대의 API 호출 횟수

## 🎯 Capabilities 구조

Capabilities는 사용자별 기능 접근 권한을 나타냅니다:

```yaml
capabilities: [1, 1, 0, 0, 0]
```

- **인덱스 0**: 기본 채팅 기능
- **인덱스 1**: 고급 채팅 기능
- **인덱스 2**: 이미지 생성 기능
- **인덱스 3**: 음성 변환 기능
- **인덱스 4**: 프리미엄 기능
- **값**: 1(허용), 0(차단)

## 🚀 확장 방법

### 1. 데이터베이스 연동

```lua
-- handler.lua에서 수정
local function get_user_metadata(consumer_id)
  -- 데이터베이스에서 사용자 메타데이터 조회
  local result = db.query("SELECT * FROM user_metadata WHERE consumer_id = ?", consumer_id)
  return result
end
```

### 2. Redis 캐시 활용

```lua
-- Redis 캐시를 통한 성능 최적화
local function get_cached_metadata(consumer_id)
  local cached = redis:get("user_metadata:" .. consumer_id)
  if cached then
    return json.decode(cached)
  end
  
  local metadata = get_user_metadata(consumer_id)
  redis:setex("user_metadata:" .. consumer_id, 3600, json.encode(metadata))
  return metadata
end
```

### 3. 외부 API 호출

```lua
-- 외부 서비스에서 사용자 메타데이터 조회
local function fetch_metadata_from_api(consumer_id)
  local response = http.request("GET", "https://api.example.com/users/" .. consumer_id)
  return json.decode(response.body)
end
```

## 🔧 개발 및 디버깅

### 1. 플러그인 로그 확인

```bash
# Kong 컨테이너 로그 확인
docker-compose logs -f kong

# 특정 플러그인 로그 필터링
docker-compose logs kong | grep "user-metadata"
```

### 2. 헤더 검증

```bash
# 요청 헤더 확인
curl -v -X POST http://localhost:8000/llama2/chat \
  -H "apikey: llama2-secret-key-12345" \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "test"}]}'
```

### 3. 플러그인 상태 확인

```bash
# Kong Admin API로 플러그인 상태 확인
curl http://localhost:8001/plugins
```

## 📋 사용 사례

### 1. AI 서비스 제공업체
- 사용자별 토큰 제한 관리
- 시간대별 사용량 모니터링
- 등급별 서비스 차별화

### 2. 멀티 테넌트 환경
- 테넌트별 정책 적용
- 사용량 기반 과금
- 실시간 리소스 관리

### 3. API 게이트웨이
- 사용자별 접근 제어
- 메타데이터 기반 라우팅
- 정책 기반 요청 처리

## 🤝 기여 방법

1. 이슈 생성 또는 기존 이슈 확인
2. 포크 후 브랜치 생성
3. 코드 수정 및 테스트
4. 풀 리퀘스트 생성

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 📞 지원

문제가 발생하거나 질문이 있으시면 이슈를 생성해 주세요.
