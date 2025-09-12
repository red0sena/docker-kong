return {
  name = "user-metadata",
  fields = {
    { config = {
        type = "record",
        fields = {
    {
      id = {
        type = "string",
        required = true,
        default = "kt-llama3-1",
        description = "사용자 메타데이터 ID"
      }
    },
    {
      provider_name = {
        type = "string",
        required = true,
        default = "kt",
        description = "서비스 프로바이더 이름"
      }
    },
    {
      tags = {
        type = "array",
        required = false,
        default = {"나는가수다"},
        elements = {
          type = "string"
        },
        description = "태그 목록"
      }
    },
    {
      tdl_matrix = {
        type = "record",
        required = true,
        default = {
          T1 = {0, 0, 0, 0, 0, 3, 0, 0, 0, 0},
          T2 = {0, 0, 0, 0, 0, 3, 0, 0, 0, 0},
          T3 = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
          T4 = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
          T5 = {0, 0, 0, 0, 0, 3, 0, 0, 0, 0},
          T6 = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
          T7 = {0, 0, 0, 0, 0, 3, 0, 0, 0, 0},
          T8 = {0, 0, 0, 0, 0, 3, 0, 0, 0, 0},
          T9 = {0, 0, 0, 0, 0, 3, 0, 0, 0, 0},
          T10 = {0, 0, 0, 0, 0, 3, 0, 0, 0, 0},
          T11 = {0, 0, 0, 0, 0, 3, 0, 0, 0, 0},
          T12 = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
        },
        fields = {
          {
            T1 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T2 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T3 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T4 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T5 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T6 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T7 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T8 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T9 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T10 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T11 = {
              type = "array",
              elements = { type = "number" }
            }
          },
          {
            T12 = {
              type = "array",
              elements = { type = "number" }
            }
          }
        },
        description = "TDL 매트릭스 데이터"
      }
    },
    {
      capabilities = {
        type = "array",
        required = true,
        default = {1, 1, 0, 0, 0},
        elements = {
          type = "number"
        },
        description = "사용자 권한 목록"
      }
    },
    {
      max_input_tokens = {
        type = "number",
        required = true,
        default = 24000,
        description = "최대 입력 토큰 수"
      }
    },
    {
      max_output_tokens = {
        type = "number",
        required = true,
        default = 8000,
        description = "최대 출력 토큰 수"
      }
    },
    {
      input_cost_per_token = {
        type = "number",
        required = true,
        default = 0.000000083,
        description = "입력 토큰당 비용"
      }
    },
    {
      output_cost_per_token = {
        type = "number",
        required = true,
        default = 0.00000033,
        description = "출력 토큰당 비용"
      }
    }
        }
    }}
  }
}