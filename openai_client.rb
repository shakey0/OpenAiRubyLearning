require 'httparty'
require 'json'
require 'dotenv'

Dotenv.load

API_KEY = ENV['OPENAI_API_KEY']

OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'

def generate_response(word, sentence, model = 'gpt-4o-mini-2024-07-18', max_tokens = 1000)
  prompt = <<~TEXT
    Teach me about the word \"#{word}\" and its different parts of speech in English.
    I read this word in the following sentence: \"#{sentence}\"
    Give 4 standard examples of how this word is used in sentences in English (you can change the form in different examples), and specify the part of speech of the word for each example.
    The examples should be simple and easy to understand, and they should help me understand the meaning of the word.
  TEXT

  response = HTTParty.post(
    OPENAI_API_URL,
    headers: {
      "Authorization" => "Bearer #{API_KEY}",
      "Content-Type" => "application/json"
    },
    body: {
      model: model,
      messages: [
        {
          role: 'system',
          content: 'You are a helpful English language tutor. Use simple language to explain the word to the user.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "content",
          strict: true,
          schema: {
            type: "object",
            additionalProperties: false,
            properties: {
              details_of_word: {
                type: "object",
                additionalProperties: false,
                properties: {
                  parts_of_speech_of_word: {
                    type: "array",
                    items: {
                      type: "object",
                      additionalProperties: false,
                      properties: {
                        part_of_speech: {
                          type: "string"
                        },
                        word_in_english: {
                          type: "string"
                        },
                        word_in_chinese: {
                          type: "string"
                        },
                        meaning_explained_in_english: {
                          type: "string"
                        },
                        meaning_explained_in_chinese: {
                          type: "string"
                        }
                      },
                      required: ["part_of_speech", "word_in_english", "word_in_chinese", "meaning_explained_in_english", "meaning_explained_in_chinese"]
                    }
                  },
                  examples_in_sentences_in_english: {
                    type: "array",
                    items: {
                      type: "object",
                      additionalProperties: false,
                      properties: {
                        example: {
                          type: "string"
                        },
                        part_of_speech_of_word_for_example: {
                          type: "string"
                        }
                      },
                      required: ["example", "part_of_speech_of_word_for_example"]
                    }
                  },
                },
                required: ["parts_of_speech_of_word", "examples_in_sentences_in_english"]
              }
            },
            required: ["details_of_word"]
          }
        }
      },
      max_tokens: max_tokens
    }.to_json
  )

  if response.code == 200
    puts "Response from OpenAI:"
    puts response.parsed_response['choices'].first['message']['content']
    puts response.parsed_response['usage']['total_tokens']
  else
    puts "Error: #{response.code} - #{response.message}"
    puts response.parsed_response
  end
end

# generate_response('carving', 'And as I walked through the forest, I saw some beautiful carvings on the trees.')
# generate_response('carve', 'The artist carved a beautiful statue out of wood.')
# generate_response('mansion', 'And as he walked through the forest, he saw a beautiful mansion in the distance.')
# generate_response('gleaming', 'The sun was gleaming brightly in the sky.')
# generate_response('successful', 'The girl was successful in her exams.')
generate_response('success', 'They attributed their success to hard work and perseverance.')
