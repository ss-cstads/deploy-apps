# API de mensagens em Ruby (Sinatra).
# As mensagens ficam em memória: somem quando o app reinicia.
require "sinatra"
require "json"
require "time"

set :host_authorization, { permitted_hosts: [] }   # atende pelo endereço público do cluster

MENSAGENS = []
TRAVA = Mutex.new
proximo_id = 1

before { content_type :json }

get "/" do
  { status: "ok", api: "/api/mensagens" }.to_json
end

get "/api/mensagens" do
  TRAVA.synchronize { MENSAGENS.to_json }
end

post "/api/mensagens" do
  texto = (JSON.parse(request.body.read)["texto"] rescue nil).to_s.strip
  halt 400, { erro: 'envie {"texto": "..."}' }.to_json if texto.empty?
  mensagem = TRAVA.synchronize do
    m = { id: proximo_id, texto: texto, criada_em: Time.now.iso8601 }
    proximo_id += 1
    MENSAGENS << m
    m
  end
  status 201
  mensagem.to_json
end
