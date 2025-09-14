local cjson = require "cjson"

local UserMetadataPlugin = {
  PRIORITY = 1000,
  VERSION = "1.0.0",
}


function UserMetadataPlugin:access(conf)
  -- Consumer 정보 가져오기
  local consumer = kong.client.get_consumer()
  if not consumer then
    return
  end

  -- Consumer의 custom_id 또는 username으로 메타데이터 조회
  local consumer_id = consumer.custom_id or consumer.username
  
  -- API-KEY를 통해 메타데이터 조회
  local user_metadata_list = self:get_user_metadata_by_apikey(consumer_id, conf)
  
  kong.log.notice("User metadata list: ", cjson.encode(user_metadata_list))
  kong.log.notice("User metadata list length: ", user_metadata_list and #user_metadata_list or "nil")
  
  if user_metadata_list and #user_metadata_list > 0 then
    -- TDL Matrix API 엔드포인트인지 확인
    local path = kong.request.get_path()
    kong.log.notice("Request path: ", path)
    
    if path == "/api/user-metadata" or path == "/api/tdl-matrix" then
      -- 전체 메타데이터 리스트를 직접 응답으로 반환
      kong.response.set_header("Content-Type", "application/json")
      kong.response.set_header("Access-Control-Allow-Origin", "*")
      kong.response.set_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
      kong.response.set_header("Access-Control-Allow-Headers", "Content-Type, Authorization, apikey")
      
      kong.log.notice("Returning metadata list: ", cjson.encode(user_metadata_list))
      -- 메타데이터 리스트를 그대로 반환
      kong.response.exit(200, cjson.encode(user_metadata_list))
      return
    else
      -- 다른 엔드포인트에서는 첫 번째 메타데이터를 사용하여 헤더에 추가
      local first_metadata = user_metadata_list[1]
      if first_metadata then
        if first_metadata.tdl_matrix then
          kong.service.request.set_header("X-User-TDL-Matrix", cjson.encode(first_metadata.tdl_matrix))
          kong.log.notice("TDL Matrix added for consumer: ", consumer_id)
        else
          kong.log.warn("No TDL Matrix found for consumer: ", consumer_id)
        end
        
        if first_metadata.capabilities then
          kong.service.request.set_header("X-User-Capabilities", cjson.encode(first_metadata.capabilities))
          kong.log.notice("Capabilities added for consumer: ", consumer_id)
        end
        
        -- Consumer ID를 헤더에 추가
        kong.service.request.set_header("X-Consumer-ID", consumer_id)
      end
    end
  end
end

function UserMetadataPlugin:get_user_metadata_by_apikey(consumer_id, conf)
  -- Consumer의 API-KEY를 가져오기
  local apikey = self:get_consumer_apikey(consumer_id)
  if not apikey then
    kong.log.warn("No API key found for consumer: ", consumer_id)
    return nil
  end
  
  -- API-KEY를 기반으로 메타데이터 조회
  -- 실제 구현에서는 외부 API나 데이터베이스에서 조회
  local user_metadata = self:fetch_metadata_by_apikey(apikey, conf)
  
  if user_metadata then
    kong.log.notice("Metadata fetched for API key: ", apikey)
    return user_metadata
  else
    kong.log.warn("No metadata found for API key: ", apikey)
    return nil
  end
end

function UserMetadataPlugin:get_consumer_apikey(consumer_id)
  -- 우선 이미 인증된 key-auth 자격 증명에서 키를 가져옵니다.
  local credential = kong.client.get_credential()
  if credential and credential.key then
    return credential.key
  end

  -- 우선순위 이슈 등으로 key-auth가 아직 처리되지 않았을 수 있으므로
  -- 요청 헤더에서 직접 키를 조회합니다.
  local header_key =
    kong.request.get_header("apikey") or
    kong.request.get_header("api-key") or
    kong.request.get_header("x-api-key")

  if header_key and header_key ~= "" then
    return header_key
  end

  kong.log.warn("API key not found for consumer: ", consumer_id)
  return nil
end

function UserMetadataPlugin:fetch_metadata_by_apikey(apikey, conf)
  -- 설정에서 메타데이터 반환 (실제 운영에서는 데이터베이스나 외부 API에서 조회)
  kong.log.notice("Config structure: ", cjson.encode(conf))
  
  if conf.metadata_list and #conf.metadata_list > 0 then
    -- 새로운 metadata_list 구조 사용
    kong.log.notice("Using metadata_list with ", #conf.metadata_list, " items")
    return conf.metadata_list
  else
    -- 기존 단일 메타데이터 구조 (하위 호환성)
    kong.log.notice("Using legacy single metadata structure")
    return {
      {
        id = conf.id,
        provider = conf.provider_name,
        tags = conf.tags,
        tdl_matrix = conf.tdl_matrix,
        capabilities = conf.capabilities,
        max_input_tokens = conf.max_input_tokens,
        max_output_tokens = conf.max_output_tokens,
        input_cost_per_token = conf.input_cost_per_token,
        output_cost_per_token = conf.output_cost_per_token
      }
    }
  end
end

return UserMetadataPlugin